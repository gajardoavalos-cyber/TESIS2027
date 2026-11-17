"""
Prototipo del escenario ampliado (Prof. Espina, 20-oct-2026):
alimentador BT 3φ-4W desbalanceado por clientes monofásicos + N_a, N_b, N_c Micro-redes DC
con IC monofásicos. Nivel terciario centralizado (QP/SOCP, horizonte 24 h, Δt = 15 min)
que decide P y Q por fase para gestionar intercambio y desbalance en la cabecera.
Supuestos: tensión de cabecera balanceada y rígida (V = 230 V f-n), sin pérdidas en el
alimentador, IC sin pérdidas. Convención: P_IC > 0 = inyección DC -> AC.
"""
import numpy as np, cvxpy as cp, json, os
import matplotlib; matplotlib.use('Agg'); import matplotlib.pyplot as plt
plt.rcParams.update({'font.family':'sans-serif','font.size':9,'pdf.fonttype':42,'mathtext.fontset':'dejavusans','axes.grid':True,'grid.alpha':.3})
here=os.path.dirname(os.path.abspath(__file__)); F=lambda n: os.path.join(here,'fig',n)
V=230.0; dt=0.25; t=np.arange(0,24,dt); T=len(t)
bump=lambda c,w: np.exp(-0.5*((t-c)/w)**2)
pvs=np.clip(np.cos((t-13)/6*np.pi/2),0,None)**1.5; pvs[(t<7)|(t>19)]=0
ph=['a','b','c']; th=np.deg2rad([0,-120,120]); al=np.exp(2j*np.pi/3)
# ---- clientes monofásicos del alimentador (agregado por fase), kW / kvar
PLd=np.vstack([6+10*bump(20,1.8)+3*bump(8,1.2), 5+9*bump(13,2.5), 7+7*bump(20,2.0)])
PVc=np.vstack([0*pvs,0*pvs,9*pvs])                    # FV de clientes (no controlable) en fase c
PL=PLd-PVc; QL=np.tan(np.arccos(0.95))*PLd*np.array([[1.0],[0.8],[1.2]])
# ---- Micro-redes DC (N_a=2, N_b=1, N_c=3)
MR=[dict(f=0,pv=6,ld=1.5+1.5*bump(19,1.5),E=30,PB=7.5,S=10),
    dict(f=0,pv=4,ld=1.0+2.0*bump(20,1.5),E=20,PB=5,S=10),
    dict(f=1,pv=8,ld=2.0+0*t,E=25,PB=6,S=10),
    dict(f=2,pv=3,ld=1.5+0*t,E=15,PB=4,S=8),
    dict(f=2,pv=5,ld=2.0+1.0*bump(13,2),E=20,PB=5,S=10),
    dict(f=2,pv=2,ld=1.0+0*t,E=10,PB=3,S=6)]
for m in MR: m['ppv']=m['pv']*pvs
Nf=[sum(1 for m in MR if m['f']==i) for i in range(3)]
agg=lambda key: np.vstack([sum(m[key] if np.ndim(m[key]) else m[key]*np.ones(T) for m in MR if m['f']==i) for i in range(3)])
PPV=agg('ppv'); PDL=agg('ld'); E=np.array([sum(m['E'] for m in MR if m['f']==i) for i in range(3)])
PBmax=np.array([sum(m['PB'] for m in MR if m['f']==i) for i in range(3)]); Smax=np.array([sum(m['S'] for m in MR if m['f']==i) for i in range(3)])
SOC0=0.5; SOCmin,SOCmax=0.1,0.9
PTR=36.0  # límite de potencia en cabecera (transformador / contrato), kW
price=np.where((t>=18)&(t<22),1.6,np.where((t>=7)&(t<18),1.0,0.7))
# ---- secuencias en cabecera: I_k = sum_phi (A_kphi P + B_kphi Q), en A con P,Q en kW/kvar
C=np.array([[1,1,1],[1,al,al**2],[1,al**2,al]])/3
u=np.exp(1j*th); w=-1j*np.exp(1j*th)
A=C*u[None,:]*1000/V; B=C*w[None,:]*1000/V
def seqI(P,Q):  # P,Q: (3,T) potencias en cabecera
    return np.einsum('kf,ft->kt',A,P)+np.einsum('kf,ft->kt',B,Q)
def metrics(Ph,Qh,soc=None,name=''):
    I=seqI(Ph,Qh); In=3*np.abs(I[0]); I2=np.abs(I[2])
    d=dict(case=name,In_rms=round(float(np.sqrt((In**2).mean())),1),In_max=round(float(In.max()),1),
           I2_rms=round(float(np.sqrt((I2**2).mean())),1),I2_max=round(float(I2.max()),1),
           Phead_max=round(float(Ph.sum(0).max()),1),E_import=round(float(Ph.sum(0).sum()*dt),1),
           cost=round(float((price*Ph.sum(0)).sum()*dt),1))
    if soc is not None: d.update(SOCmin=round(float(soc.min())*100),SOCmax=round(float(soc.max())*100))
    return d,In,I2
# ---- Caso 0: sin DC-MR (solo clientes)
res={}; series={}
d,In,I2=metrics(PL,QL,name='Solo clientes'); res['C0']=d; series['C0']=(In,I2)
# ---- Caso L: DC-MR con control local (autoconsumo con BESS, Q=0), por Micro-red
PICl=np.zeros((3,T)); socl=np.zeros((len(MR),T))
for j,m in enumerate(MR):
    soc=SOC0
    for k in range(T):
        need=m['ld'][k]-m['ppv'][k]                       # >0 déficit
        pb=np.clip(need,-m['PB'],m['PB'])
        pb=np.clip(pb,-(SOCmax-soc)*m['E']/dt,(soc-SOCmin)*m['E']/dt)
        soc-=pb*dt/m['E']; socl[j,k]=soc
        PICl[m['f'],k]+= -(need-pb)                       # inyección = -(déficit no cubierto)
d,In,I2=metrics(PL-PICl,QL,socl,'DC-MR local'); d['dE_storage_kWh']=round(float(sum((socl[j,-1]-SOC0)*m['E'] for j,m in enumerate(MR))),1); d['cost_corr']=round(d['cost']-price.min()*d['dE_storage_kWh'],1); res['L']=d; series['L']=(In,I2)
# ---- Nivel terciario: QP/SOCP por fase (agregado), horizonte 24 h
def tertiary(useQ=True,In_max=None,w0=0.2,w2=0.2,wE=1.0,wc=2.0,Ptr=PTR):
    P=cp.Variable((3,T)); Q=cp.Variable((3,T)); PB=cp.Variable((3,T)); S=cp.Variable((3,T+1)); Pc=cp.Variable((3,T),nonneg=True)
    Ph=PL-P; Qh=QL-Q
    I0r=sum(cp.multiply(A[0,f].real,Ph[f])+cp.multiply(B[0,f].real,Qh[f]) for f in range(3))
    I0i=sum(cp.multiply(A[0,f].imag,Ph[f])+cp.multiply(B[0,f].imag,Qh[f]) for f in range(3))
    I2r=sum(cp.multiply(A[2,f].real,Ph[f])+cp.multiply(B[2,f].real,Qh[f]) for f in range(3))
    I2i=sum(cp.multiply(A[2,f].imag,Ph[f])+cp.multiply(B[2,f].imag,Qh[f]) for f in range(3))
    cons=[P==PPV-Pc+PB-PDL, Pc<=PPV, S[:,0]==SOC0,
          S[:,1:]==S[:,:-1]-cp.multiply(PB,np.repeat((dt/E)[:,None],T,1)),
          S>=SOCmin, S<=SOCmax, cp.abs(PB)<=np.repeat(PBmax[:,None],T,1), S[:,T]==SOC0]
    for f in range(3): cons.append(cp.norm(cp.vstack([P[f],Q[f]]),2,axis=0)<=Smax[f])
    if not useQ: cons.append(Q==0)
    if Ptr is not None: cons.append(cp.sum(Ph,0)<=Ptr)
    if In_max is not None: cons.append(3*cp.norm(cp.vstack([I0r,I0i]),2,axis=0)<=In_max)
    obj=wE*cp.sum(cp.multiply(price,cp.sum(Ph,0)))*dt + wc*cp.sum(Pc)*dt + w0*cp.sum_squares(cp.vstack([I0r,I0i]))*dt + w2*cp.sum_squares(cp.vstack([I2r,I2i]))*dt + 1e-3*cp.sum_squares(PB)
    pr=cp.Problem(cp.Minimize(obj),cons); pr.solve(solver='CLARABEL')
    return pr.status,P.value,Q.value,PB.value,S.value,Pc.value
out={}
for key,kw,name in [('TP',dict(useQ=False),'Terciario P'),('TPQ',dict(useQ=True),'Terciario P+Q')]:
    st,P,Q,PB,S,Pc=tertiary(**kw)
    d,In,I2=metrics(PL-P,QL-Q,S,name); d['status']=st; d['curt_kWh']=round(float(Pc.sum()*dt),1)
    res[key]=d; series[key]=(In,I2); out[key]=dict(P=P,Q=Q,PB=PB,S=S)
# ---- piso energético de cabecera (solo P): medias diarias de P_L - (P_PV - P_dl) con ΔSOC = 0
mP=(PL-(PPV-PDL)).mean(1); fl=np.abs(seqI(mP[:,None],np.zeros((3,1)))[0,0])*3
res['floor_In_A_activo']=round(float(fl),1); res['daily_mean_head_P_kW']=mP.round(2).tolist()
res['N_phase']=Nf; res['E_phase_kWh']=E.tolist(); res['PBmax']=PBmax.tolist(); res['Smax']=Smax.tolist()
# ---- restricción dura de I_n (punto 4): barrido de In_max con P+Q
sw=[]
for lim in [40,30,20,15,10,7,5]:
    st,P,Q,PB,S,Pc=tertiary(useQ=True,In_max=lim)
    if P is None: sw.append(dict(In_max=lim,status=st)); continue
    d,In,I2=metrics(PL-P,QL-Q,S); sw.append(dict(In_max=lim,status=st,In_max_real=d['In_max'],I2_max=d['I2_max'],cost=d['cost']))
res['sweep_In_max']=sw
par={'P':[],'PQ':[]}
for wq in [0,0.01,0.03,0.1,0.3,1,3]:
    for key,uq in [('P',False),('PQ',True)]:
        st,P,Q,PB,S,Pc=tertiary(useQ=uq,w0=wq,w2=wq)
        d,In,I2=metrics(PL-P,QL-Q,S); par[key].append(dict(w=wq,cost=d['cost'],In_rms=d['In_rms'],I2_rms=d['I2_rms'],Phead_max=d['Phead_max'],curt=round(float(Pc.sum()*dt),1)))
res['pareto']=par
json.dump(res,open(os.path.join(here,'escenario_res.json'),'w'),indent=1)
np.savez(os.path.join(here,'escenario_out.npz'),t=t,PL=PL,QL=QL,PPV=PPV,PDL=PDL,PICl=PICl,
         **{f'{k}_{v}':out[k][v] for k in out for v in out[k]})
print(json.dumps(res,indent=1))
# ---- figuras
cols=['#C0392B','#2E8B57','#1F5FAF']
fig,ax=plt.subplots(1,2,figsize=(7.4,2.6))
for i in range(3): ax[0].plot(t,PL[i],color=cols[i],lw=1.3,label=f'$P_{{L,{ph[i]}}}$')
ax[0].set_title('Clientes monofásicos por fase',fontsize=9); ax[0].set_xlabel('Hora'); ax[0].set_ylabel('kW'); ax[0].legend(fontsize=7); ax[0].set_xticks(range(0,25,4))
for i in range(3): ax[1].plot(t,PPV[i]-PDL[i],color=cols[i],lw=1.3,label=f'$P_{{PV}}-P_{{dl}}$, {ph[i]} ($N_{ph[i]}$={Nf[i]})')
ax[1].axhline(0,color='k',lw=.6); ax[1].set_title('Excedente propio de las DC-MR por fase',fontsize=9); ax[1].set_xlabel('Hora'); ax[1].legend(fontsize=7); ax[1].set_xticks(range(0,25,4))
fig.tight_layout(); fig.savefig(F('esc_perfiles.pdf'))
fig,ax=plt.subplots(1,2,figsize=(7.4,2.7))
sty={'L':('#7f7f7f','-','Sin coordinación (local)'),'TP':('#1F5FAF','-','Terciario P'),'TPQ':('#D35400','-','Terciario P+Q')}
for k,(c,ls,lb) in sty.items():
    ax[0].plot(t,series[k][0],color=c,ls=ls,lw=1.3,label=lb); ax[1].plot(t,series[k][1],color=c,ls=ls,lw=1.3,label=lb)
ax[0].axhline(res['floor_In_A_activo'],color='k',lw=.7,ls=':')
ax[0].set_title(r'$|I_n|=3|I_0|$ en cabecera [A]',fontsize=9); ax[1].set_title(r'$|I_2|$ en cabecera [A]',fontsize=9)
for a in ax: a.set_xlabel('Hora'); a.set_xticks(range(0,25,4))
ax[0].legend(fontsize=7); fig.tight_layout(); fig.savefig(F('esc_secuencias.pdf'))
fig,ax=plt.subplots(1,2,figsize=(7.4,2.6))
for i in range(3):
    ax[0].plot(t,out['TPQ']['S'][i,1:]*100,color=cols[i],lw=1.3,label=f'SOC$_{ph[i]}$')
    ax[1].plot(t,out['TPQ']['Q'][i],color=cols[i],lw=1.3,label=f'$Q_{{IC,{ph[i]}}}$')
ax[0].set_title('SOC agregado por fase (Terciario P+Q) [%]',fontsize=9); ax[1].set_title('Q por fase decidido por el terciario [kvar]',fontsize=9)
for a in ax: a.set_xlabel('Hora'); a.legend(fontsize=7); a.set_xticks(range(0,25,4))
fig.tight_layout(); fig.savefig(F('esc_soc_q.pdf'))

fig,ax=plt.subplots(figsize=(4.2,2.8))
for key,c,lb in [('P','#1F5FAF','Terciario P'),('PQ','#D35400','Terciario P+Q')]:
    ax.plot([d['cost'] for d in par[key]],[d['In_rms'] for d in par[key]],'o-',color=c,label=lb,ms=4)
ax.plot(res['L']['cost_corr'],res['L']['In_rms'],'s',color='gray',label='Sin coordinación*')
ax.axhline(res['floor_In_A_activo'],color='k',lw=.7,ls=':'); ax.set_xlabel('Costo de energía diario [u.m.]'); ax.set_ylabel(r'$|I_n|$ RMS [A]'); ax.legend(fontsize=7)
fig.tight_layout(); fig.savefig(F('esc_pareto.pdf'))
