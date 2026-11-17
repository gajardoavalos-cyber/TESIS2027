"""Nivel secundario distribuido, fase c (N_c = 3): reparto de la consigna P*_c del terciario por
consenso de costo incremental (lambda) con estimación distribuida del desbalance de potencia
[Yang, Tan, Xu, IEEE TPWRS 2013]. Extiende el cap. 4 de la tesis de E. Espina (lambda único) a lambda_phi por fase."""
import numpy as np, json, os
import matplotlib; matplotlib.use('Agg'); import matplotlib.pyplot as plt
plt.rcParams.update({'font.family':'sans-serif','font.size':9,'pdf.fonttype':42,'mathtext.fontset':'dejavusans','axes.grid':True,'grid.alpha':.3})
here=os.path.dirname(os.path.abspath(__file__))
z=np.load(os.path.join(here,'escenario_out.npz')); t=z['t']; k=int(np.argmin(abs(t-20.0)))
# Micro-redes de la fase c (mismos datos que escenario.py)
E=np.array([15.,20.,10.]); PBm=np.array([4.,5.,3.]); SOC=np.array([0.35,0.60,0.80])
pvs=np.clip(np.cos((t[k]-13)/6*np.pi/2),0,None)**1.5 if 7<=t[k]<=19 else 0.0
Ppv=np.array([3,5,2])*pvs; Pdl=np.array([1.5,2.0+1.0*np.exp(-0.5*((t[k]-13)/2)**2),1.0])
Pstar=float(z['TPQ_P'][2,k])                 # consigna del terciario para la fase c en t = 20:00
D=Pstar-(Ppv-Pdl).sum()                      # esfuerzo total de baterías requerido en la fase
a=1.0/E; beta=4.0; b=beta*(0.5-SOC)          # C_k = a_k/2 P_B^2 + b_k P_B  (descargar con SOC bajo es caro)
# óptimo centralizado (referencia)
def alloc(lam): return np.clip((lam-b)/a,-PBm,PBm)
lo,hi=-50,50
for _ in range(200):
    m=(lo+hi)/2; (lo,hi)=(m,hi) if alloc(m).sum()<D else (lo,m)
lam_opt=(lo+hi)/2; PB_opt=alloc(lam_opt)
# consenso distribuido: grafo línea 1-2-3, pesos de Metropolis, agente 1 = líder (conoce P*_c)
W=np.array([[2/3,1/3,0],[1/3,1/3,1/3],[0,1/3,2/3]]); eps=0.02; it=300
lam=b.copy(); PB=alloc(lam); d=np.array([D,0,0]); y=d-PB
H_l=[lam.copy()]; H_p=[PB.copy()]
for n in range(it):
    lam_n=W@lam+eps*y; PB_n=alloc(lam_n); y=W@y-(PB_n-PB); lam,PB=lam_n,PB_n
    H_l.append(lam.copy()); H_p.append(PB.copy())
H_l=np.array(H_l); H_p=np.array(H_p)
res=dict(t=float(t[k]),Pstar_c_kW=round(Pstar,2),D_kW=round(float(D),2),SOC=SOC.tolist(),
         lam_opt=round(lam_opt,4),PB_opt=PB_opt.round(3).tolist(),PB_cons=H_p[-1].round(3).tolist(),
         lam_cons=H_l[-1].round(4).tolist(),sum_err=round(float(H_p[-1].sum()-D),4),
         n_to_1pct=int(np.argmax(np.all(abs(H_p-PB_opt)<=0.01*max(abs(D),1),axis=1))))
json.dump(res,open(os.path.join(here,'secundario_res.json'),'w'),indent=1); print(json.dumps(res,indent=1))
fig,ax=plt.subplots(1,2,figsize=(7.2,2.5)); cols=['#1F5FAF','#5DADE2','#154360']
for i in range(3):
    ax[0].plot(H_l[:,i],color=cols[i],lw=1.3,label=f'$\\lambda_{{c,{i+1}}}$ (SOC={SOC[i]:.2f})')
    ax[1].plot(H_p[:,i],color=cols[i],lw=1.3,label=f'$P_{{B,{i+1}}}$'); ax[1].axhline(PB_opt[i],color=cols[i],lw=.7,ls=':')
ax[0].axhline(lam_opt,color='k',lw=.7,ls=':'); ax[0].set_title('Costo incremental (consenso)',fontsize=9); ax[0].set_xlabel('Iteración'); ax[0].legend(fontsize=7)
ax[1].set_title('Potencia de BESS por Micro-red [kW]',fontsize=9); ax[1].set_xlabel('Iteración'); ax[1].legend(fontsize=7)
fig.tight_layout(); fig.savefig(os.path.join(here,'fig','sec_consenso.pdf'))
