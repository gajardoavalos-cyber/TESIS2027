"""Verificación numérica de las observaciones 1-3 del Prof. Espina sobre la ley P*_i = Pbar + (E/tau)(SOCw - SOC_i)."""
import numpy as np, json, importlib.util, os
import matplotlib; matplotlib.use('Agg'); import matplotlib.pyplot as plt
plt.rcParams.update({'font.family':'sans-serif','font.size':9,'pdf.fonttype':42,'mathtext.fontset':'dejavusans'})
here = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location('s', os.path.join(here, 'sim_soc.py'))
s = importlib.util.module_from_spec(spec); spec.loader.exec_module(s)
out = {}
# --- (1) escenario de 4 días: suma de potencias de BESS y SOCw
DAYS=4; t=np.arange(0,24*DAYS,s.dt); h=t%24
load=np.vstack([1.4*s.load_shape(h),1.0*s.load_shape(h),0.8*s.load_shape(h)])
ev=np.zeros((3,len(t))); ev[0,(h>=19)&(h<21)]=3.7
pv=np.vstack([0*s.pv_shape(h),1.5*s.pv_shape(h),3.0*s.pv_shape(h)])
s.t=t; s.N=len(t); s.Pnet=load+ev-pv; s.E=np.array([20.]*3)
r=s.run('C_tau',4.0)
sumPB=r['pb'].sum(0); socw=(s.E[:,None]*r['soc']).sum(0)/s.E.sum()
out['obs1_max_abs_sum_PB_kW']=float(np.abs(sumPB).max())
out['obs1_SOCw_min_max']=[round(float(socw.min()),4),round(float(socw.max()),4)]
# --- (2) potencias netas constantes y distintas: régimen permanente
T=48; t2=np.arange(0,T,s.dt); s.t=t2; s.N=len(t2)
Pn=np.array([3.0,1.0,-1.0]); s.Pnet=np.tile(Pn[:,None],(1,len(t2)))
s.SOC0=np.array([0.5,0.5,0.5])
rL=s.run('L'); rC=s.run('C_tau',4.0)
out['obs2_Pnet_kW']=Pn.tolist()
out['obs2_PIC_final_coord_kW']=rC['pic'][:,-1].round(3).tolist()
out['obs2_In_final_local_A']=round(float(rL['In'][-1]),2); out['obs2_In_final_coord_A']=round(float(rC['In'][-1]),2)
out['obs2_SOC_final']=rC['soc'][:,-1].round(3).tolist()
out['obs2_SOC_pred']=(0.5-4.0*(Pn-Pn.mean())/20).round(3).tolist()
k95=[int(np.argmax(np.abs(rC['pic'][i]-Pn[i])<0.05*abs(Pn[i]-Pn.mean()))) for i in range(3)]
out['obs2_t95_h']=[round(k*s.dt,2) for k in k95]
fig,ax=plt.subplots(1,2,figsize=(7.2,2.6))
cols=['#C0392B','#2E8B57','#1F5FAF']
for i,l in enumerate('abc'):
    ax[0].plot(t2,rC['pic'][i],color=cols[i],lw=1.4,label=f'$P_{{IC,{l}}}$')
    ax[0].axhline(Pn[i],color=cols[i],lw=.7,ls=':')
ax[0].set_xlabel('t [h]'); ax[0].set_ylabel('[kW]'); ax[0].set_title(r'$P_{IC,i}\to P_{net,i}$ (punteado)',fontsize=9); ax[0].legend(fontsize=7)
ax[1].plot(t2,rL['In'],color='gray',lw=1.4,label='Local'); ax[1].plot(t2,rC['In'],color='#D35400',lw=1.4,label=r'Ley con $\tau=4$ h')
ax[1].set_xlabel('t [h]'); ax[1].set_ylabel(r'$|I_n|$ [A]'); ax[1].legend(fontsize=7); ax[1].set_ylim(0,None)
for a in ax: a.grid(alpha=.3)
fig.tight_layout(); fig.savefig(os.path.join(here,'fig','obs2_step.pdf'))
print(json.dumps(out,indent=1))
