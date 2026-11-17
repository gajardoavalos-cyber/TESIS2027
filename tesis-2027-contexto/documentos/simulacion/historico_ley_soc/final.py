"""Escenario de trabajo para el lunes: 4 dias repetidos, se reporta el dia 4 (regimen periodico)."""
import numpy as np, importlib.util, json
spec = importlib.util.spec_from_file_location('s', 'sim_soc.py'); s = importlib.util.module_from_spec(spec); spec.loader.exec_module(s)
DAYS=4
PV_B, PV_C, EV_KW, EV_H, EKWH = 1.5, 3.0, 3.7, 2.0, 20.0
t=np.arange(0,24*DAYS,s.dt); h=t%24
load = np.vstack([1.4*s.load_shape(h), 1.0*s.load_shape(h), 0.8*s.load_shape(h)])
ev = np.zeros((3,len(t))); ev[0,(h>=19)&(h<19+EV_H)] = EV_KW
pv = np.vstack([0*s.pv_shape(h), PV_B*s.pv_shape(h), PV_C*s.pv_shape(h)])
P = load+ev-pv
s.t=t; s.N=len(t); s.Pnet=P; s.E=np.array([EKWH]*3)
last = t>=24*(DAYS-1)
m = P[:,last].mean(1); floor = float(s.dispersion(m[:,None])[0]*1000/s.V)
def stats(r):
    In=r['In'][last]; soc=r['soc'][:,last]
    return dict(rms=round(float(np.sqrt((In**2).mean())),1), mx=round(float(In.max()),1),
                socmin=round(float(soc.min())*100), socmax=round(float(soc.max())*100), sat=int(r['m']['sat_minutes']))
R={}
R['L']=s.run('L'); R['Cinf']=s.run('C_inf'); R['C4']=s.run('C_tau',4.0); R['C4d']=s.run('C_tau_dist',4.0)
out={k:stats(v) for k,v in R.items()}
out['floor']=round(floor,1); out['daily_means_kW']=m.round(2).tolist()
out['dist_vs_central_max_kW']=round(float(np.abs(R['C4d']['pic']-R['C4']['pic']).max()),3)
sweep=[]
for tau in [0.5,1,2,3,4,5,6,8,12]:
    st=stats(s.run('C_tau',float(tau))); sweep.append(dict(tau=tau, rms=st['rms'], sat=st['sat']))
out['sweep']=sweep
print(json.dumps(out,indent=1))
# series para graficos
idx_last = np.where(last)[0][::15]
In_rows=[]
for k,name in [('L','Local'),('Cinf','Coordinado sin SOC'),('C4','Coordinado con SOC')]:
    for i in idx_last: In_rows.append(dict(h=round(float(h[i]),2), caso=name, In=round(float(R[k]['In'][i]),1)))
soc_rows=[]
for k,name in [('Cinf','Sin SOC'),('C4','Con SOC (tau 4 h)')]:
    for ph in range(3):
        for i in range(0,len(t),30): soc_rows.append(dict(h=round(float(t[i]),1), caso=name, fase='abc'[ph], soc=round(float(R[k]['soc'][ph,i])*100,1)))
pn_rows=[]
for ph in range(3):
    for i in idx_last: pn_rows.append(dict(h=round(float(h[i]),2), fase='abc'[ph], p=round(float(P[ph,i]),2)))
json.dump(dict(In=In_rows, soc=soc_rows, pnet=pn_rows, out=out), open('chart_data.json','w'))
print(len(In_rows), len(soc_rows), len(pn_rows))
