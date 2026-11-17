"""Escenario de final.py (4 dias, se reporta el dia 4) + verificaciones adicionales para la reunion."""
import numpy as np, json, importlib.util, os
here = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location('s', os.path.join(here, 'sim_soc.py'))
s = importlib.util.module_from_spec(spec); spec.loader.exec_module(s)

DAYS = 4
PV_B, PV_C, EV_KW, EV_H, EKWH = 1.5, 3.0, 3.7, 2.0, 20.0
t = np.arange(0, 24 * DAYS, s.dt); h = t % 24
load = np.vstack([1.4 * s.load_shape(h), 1.0 * s.load_shape(h), 0.8 * s.load_shape(h)])
ev = np.zeros((3, len(t))); ev[0, (h >= 19) & (h < 19 + EV_H)] = EV_KW
pv = np.vstack([0 * s.pv_shape(h), PV_B * s.pv_shape(h), PV_C * s.pv_shape(h)])
P = load + ev - pv
s.t = t; s.N = len(t); s.Pnet = P; s.E = np.array([EKWH] * 3)
last = t >= 24 * (DAYS - 1)
m = P[:, last].mean(1); floor = float(s.dispersion(m[:, None])[0] * 1000 / s.V)


def stats(r):
    In = r['In'][last]; soc = r['soc'][:, last]
    return dict(rms=round(float(np.sqrt((In**2).mean())), 1), mx=round(float(In.max()), 1),
                socmin=round(float(soc.min()) * 100), socmax=round(float(soc.max()) * 100),
                sat=int(r['m']['sat_minutes']))

R = {}
R['L'] = s.run('L'); R['Cinf'] = s.run('C_inf'); R['C4'] = s.run('C_tau', 4.0); R['C4d'] = s.run('C_tau_dist', 4.0)
out = {k: stats(v) for k, v in R.items()}
out['floor'] = round(floor, 1); out['daily_means_kW'] = m.round(2).tolist()
out['dist_vs_central_max_kW'] = round(float(np.abs(R['C4d']['pic'] - R['C4']['pic']).max()), 3)
sweep = []
for tau in [0.5, 1, 2, 3, 4, 5, 6, 8, 12]:
    st = stats(s.run('C_tau', float(tau))); sweep.append(dict(tau=tau, rms=st['rms'], mx=st['mx'], socmin=st['socmin'], socmax=st['socmax'], sat=st['sat']))
out['sweep'] = sweep

# Perfil diario: min/max por fase
out['pnet_range_kW'] = [[round(float(P[i, last].min()), 2), round(float(P[i, last].max()), 2)] for i in range(3)]
out['pnet_energy_kWh_day'] = (P[:, last].sum(1) * s.dt).round(2).tolist()

# --- Verificacion 1: identidad D^2 = 3/2 * sum (P_i - Pbar)^2
pp = R['L']['pic'][:, last]
lhs = s.dispersion(pp) ** 2; rhs = 1.5 * ((pp - pp.mean(0)) ** 2).sum(0)
out['check_D2_identity_maxerr'] = float(np.abs(lhs - rhs).max())

# --- Verificacion 2: equivalencia con filtro pasa bajos de primer orden (tau) en C_tau sin saturacion
tau = 4.0
dP = P - P.mean(0)
lp = np.zeros_like(dP); a = s.dt / (tau + s.dt)
for k in range(1, len(t)):
    lp[:, k] = lp[:, k - 1] + a * (dP[:, k] - lp[:, k - 1])
dev = R['C4']['pic'] - R['C4']['pic'].mean(0)
out['check_LPF_equiv_max_kW_day4'] = round(float(np.abs(dev[:, last] - lp[:, last]).max()), 3)

# --- Verificacion 3: compensacion de I_n solo con Q en el instante de mayor I_n (caso local)
k = np.where(last)[0][np.argmax(R['L']['In'][last])]
Pk = R['L']['pic'][:, k] * 1e3
al = np.exp(2j * np.pi / 3)
Vph = s.V * np.array([1, al**2, al])           # a, b, c
def seq(I):
    I0 = I.sum() / 3; I1 = (I[0] + al * I[1] + al**2 * I[2]) / 3; I2 = (I[0] + al**2 * I[1] + al * I[2]) / 3
    return abs(I0), abs(I1), abs(I2)
def cur(Pv, Qv):
    return np.conj((Pv + 1j * Qv) / Vph)
I_before = cur(Pk, np.zeros(3))
# I_n = sum conj(S_i)/conj(V_i) = (1/V) sum (P_i - jQ_i) * u_i, u = conj(1/conj(e^{jth})) ... resolver numericamente
u = 1 / np.conj(Vph / s.V)        # I_i = (P_i - jQ_i)/V * u_i
A = np.vstack([np.real(-1j * u), np.imag(-1j * u)])
b = -np.array([np.real((Pk * u).sum()), np.imag((Pk * u).sum())])
Q = np.linalg.pinv(A) @ b
I_after = cur(Pk, Q)
out['Qcomp'] = dict(hora=round(float(h[k]), 2), P_kW=(Pk / 1e3).round(2).tolist(), Q_kvar=(Q / 1e3).round(2).tolist(),
                    In_before=round(abs(I_before.sum()), 1), In_after=round(abs(I_after.sum()), 3),
                    seq_before_I0_I1_I2=[round(x, 1) for x in seq(I_before)],
                    seq_after_I0_I1_I2=[round(x, 1) for x in seq(I_after)],
                    S_kVA=(np.abs(Pk + 1j * Q) / 1e3).round(2).tolist())

# --- Verificacion 4: rizado 2w y condensador DC (ejemplo)
Pdc, Vdc, w, dV = 5e3, 400.0, 2 * np.pi * 50, 0.01 * 400
out['Cdc_mF_for_1pct_pp_at_5kW_400V'] = round(Pdc / (w * Vdc * dV) * 1e3, 2)

# --- Verificacion 5: consenso, autovalores del laplaciano y factor de contraccion
Lap = np.array([[1, -1, 0], [-1, 2, -1], [0, -1, 1]], float)
lam = np.sort(np.linalg.eigvalsh(Lap)); eps = 0.3
out['laplacian_eigs'] = lam.round(3).tolist()
out['consensus_rho_per_iter'] = round(max(abs(1 - eps * lam[1]), abs(1 - eps * lam[2])), 3)
out['consensus_eps_max'] = round(2 / lam[2], 3)

print(json.dumps(out, indent=1))

# series para graficos (dia 4, cada 15 min)
idx = np.where(last)[0][::15]
rows = []
for i in idx:
    rows.append(dict(h=round(float(h[i]), 2), L=round(float(R['L']['In'][i]), 1), Cinf=round(float(R['Cinf']['In'][i]), 1), C4=round(float(R['C4']['In'][i]), 1)))
socrows = []
for i in range(0, len(t), 60):
    socrows.append(dict(h=round(float(t[i]), 0), ai=round(float(R['Cinf']['soc'][0, i]) * 100, 1), bi=round(float(R['Cinf']['soc'][1, i]) * 100, 1), ci=round(float(R['Cinf']['soc'][2, i]) * 100, 1),
                        a4=round(float(R['C4']['soc'][0, i]) * 100, 1), b4=round(float(R['C4']['soc'][1, i]) * 100, 1), c4=round(float(R['C4']['soc'][2, i]) * 100, 1)))
json.dump(dict(In=rows, soc=socrows, out=out), open(os.path.join(here, 'chart_data.json'), 'w'))
print(len(rows), len(socrows))
