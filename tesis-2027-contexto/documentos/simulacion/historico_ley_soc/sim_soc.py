"""
Modelo energético promedio de 24 h — Micro-red híbrida AC/DC por fase
Tres DC-MR independientes (a, b, c), cada una acoplada a su fase por IC_i.

Ecuaciones (ver doc "Aporte de tesis — Coordinación SOC-consciente por fase"):
    E_i dSOC_i/dt = P_IC,i - P_net,i          (bateria forma Vdc_i; P_B,i = P_net,i - P_IC,i)
    I_n = D / V,  D = sqrt(sum P^2 - sum P_i P_j)   (FP unitario, red rigida balanceada)

Casos:
    L      : control local, cada IC trae su demanda neta (P_IC,i = P_net,i), bateria en reposo
    C_inf  : coordinado sin SOC (tau -> inf): P_IC,i = media de P_net
    C_tau  : coordinado SOC-consciente: P_IC,i = Pbar + E_i/tau (SOCbar_w - SOC_i)
    C_tau_dist : igual a C_tau pero con promedios estimados por consenso de promedio
                 dinamico (Kia et al. 2019) en grafo linea a-b-c
Saturacion: si SOC o P_B tocan limite, la bateria entrega lo que puede y el IC cubre el resto.
"""
import numpy as np
import csv, json, sys

dt_min = 1.0
dt = dt_min / 60.0                       # h
t = np.arange(0, 24, dt)                 # h
N = len(t)
V = 230.0                                # V fase-neutro
E = np.array([10.0, 10.0, 10.0])         # kWh
SOC0 = np.array([0.5, 0.5, 0.5])
SOCmin, SOCmax = 0.1, 0.9
PBmax = 5.0                              # kW
PICmax = 12.0                            # kW


def bump(t, c, w):
    return np.exp(-0.5 * ((t - c) / w) ** 2)


def load_shape(t):
    return 0.5 + 1.2 * bump(t, 8.0, 1.0) + 2.0 * bump(t, 20.0, 1.6)


def pv_shape(t):
    s = np.clip(np.cos((t - 13.0) / 6.0 * np.pi / 2), 0, None)
    s[(t < 7) | (t > 19)] = 0
    return s ** 1.5


def profiles():
    load = np.vstack([1.4 * load_shape(t), 1.0 * load_shape(t), 0.8 * load_shape(t)])
    ev = np.zeros((3, N))
    ev[0, (t >= 19.0) & (t < 22.0)] = 7.0          # EV monofasico en fase a
    pv = np.vstack([0.0 * pv_shape(t), 3.0 * pv_shape(t), 8.0 * pv_shape(t)])
    return load + ev - pv, load, ev, pv


Pnet, Pload, Pev, Ppv = profiles()


def dispersion(P):
    a, b, c = P
    return np.sqrt(np.maximum(a**2 + b**2 + c**2 - a*b - b*c - c*a, 0.0))


def run(case, tau=None, eps=0.3, iters=10):
    SOC = SOC0.copy()
    socs = np.zeros((3, N)); pic = np.zeros((3, N)); pb = np.zeros((3, N))
    sat = np.zeros(3)
    # estados del consenso de promedio dinamico (3 senales por agente)
    x_p = Pnet[:, 0].copy(); x_es = E * SOC; x_e = E.copy()
    up_prev = Pnet[:, 0].copy(); ues_prev = E * SOC
    Lap = np.array([[1, -1, 0], [-1, 2, -1], [0, -1, 1]], float)   # grafo linea a-b-c
    for k in range(N):
        pn = Pnet[:, k]
        if case == 'L':
            ref = pn.copy()
        elif case == 'C_inf':
            ref = np.full(3, pn.mean())
        elif case == 'C_tau':
            sw = (E * SOC).sum() / E.sum()
            ref = pn.mean() + E / tau * (sw - SOC)
        elif case == 'C_tau_dist':
            ues = E * SOC
            x_p = x_p + (pn - up_prev); x_es = x_es + (ues - ues_prev)
            up_prev = pn.copy(); ues_prev = ues.copy()
            for _ in range(iters):
                x_p = x_p - eps * Lap @ x_p
                x_es = x_es - eps * Lap @ x_es
                x_e = x_e - eps * Lap @ x_e
            ref = x_p + E / tau * (x_es / x_e - SOC)
        ref = np.clip(ref, -PICmax, PICmax)
        # bateria cubre la diferencia, con limites de potencia y energia
        pbat = pn - ref
        pbat = np.clip(pbat, -PBmax, PBmax)
        e_avail_dis = (SOC - SOCmin) * E / dt           # kW maximo de descarga en este paso
        e_avail_ch = (SOCmax - SOC) * E / dt
        pbat_lim = np.clip(pbat, -e_avail_ch, e_avail_dis)
        sat += (np.abs(pbat_lim - (pn - ref)) > 1e-6)
        pbat = pbat_lim
        p_ic = pn - pbat
        SOC = SOC - pbat * dt / E
        socs[:, k] = SOC; pic[:, k] = p_ic; pb[:, k] = pbat
    D = dispersion(pic)
    In = D * 1000 / V
    imp = pic.sum(axis=0)
    metrics = dict(
        case=case, tau=tau,
        In_rms_A=float(np.sqrt(np.mean(In**2))),
        In_max_A=float(In.max()),
        In_p95_A=float(np.percentile(In, 95)),
        SOC_spread_max=float((socs.max(0) - socs.min(0)).max()),
        SOC_min=float(socs.min()), SOC_max=float(socs.max()),
        sat_minutes=int(sat.sum()),
        E_grid_kWh=float(imp.sum() * dt),
    )
    return dict(soc=socs, pic=pic, pb=pb, In=In, m=metrics)


if __name__ == '__main__':
    # regla de diseno de tau (Propiedad 3)
    dP = Pnet - Pnet.mean(axis=0)
    dPmax = np.abs(dP).max(axis=1)
    margin = min(SOCmax - 0.5, 0.5 - SOCmin)
    tau_rule = (E * margin / dPmax).min()
    print('dPmax por fase [kW]:', dPmax.round(2), ' tau_regla [h]:', round(tau_rule, 2))

    res = {}
    res['L'] = run('L')
    res['C_inf'] = run('C_inf')
    for tau in [0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 6.0, 8.0]:
        res[f'C_tau_{tau}'] = run('C_tau', tau=tau)
    TAU = 2.0
    res['C_tau_dist'] = run('C_tau_dist', tau=TAU)
    for k, r in res.items():
        print(json.dumps(r['m']))

    # verificacion: I_n por suma fasorial vs formula D/V
    p = res['C_tau_2.0']['pic'][:, 600]
    a = np.exp(2j * np.pi / 3)
    In_phasor = abs(p[0] + p[1] * a**-1 + p[2] * a) * 1000 / V
    print('check I_n fasorial vs D/V:', round(In_phasor, 4), round(res['C_tau_2.0']['In'][600], 4))
    # verificacion: distribuido vs centralizado
    dd = np.abs(res['C_tau_dist']['pic'] - res['C_tau_2.0']['pic']).max()
    print('max |P_IC dist - central| [kW]:', round(dd, 4))

    # exportar series cada 15 min
    idx = np.arange(0, N, 15)
    with open('series_In.csv', 'w', newline='') as f:
        w = csv.writer(f); w.writerow(['h', 'case', 'In'])
        for c, name in [('L', 'Local'), ('C_inf', 'Coordinado sin SOC'), ('C_tau_2.0', 'Coordinado SOC (tau 2 h)')]:
            for i in idx:
                w.writerow([round(t[i], 2), name, round(res[c]['In'][i], 1)])
    with open('series_soc.csv', 'w', newline='') as f:
        w = csv.writer(f); w.writerow(['h', 'case', 'phase', 'soc'])
        for c, name in [('C_inf', 'Coordinado sin SOC'), ('C_tau_2.0', 'Coordinado SOC (tau 2 h)')]:
            for ph in range(3):
                for i in idx:
                    w.writerow([round(t[i], 2), name, 'abc'[ph], round(res[c]['soc'][ph, i] * 100, 1)])
    with open('sweep.csv', 'w', newline='') as f:
        w = csv.writer(f); w.writerow(['tau', 'In_rms', 'SOC_min', 'SOC_max', 'sat_min'])
        for tau in [0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 6.0, 8.0]:
            m = res[f'C_tau_{tau}']['m']
            w.writerow([tau, round(m['In_rms_A'], 2), round(m['SOC_min'] * 100, 1), round(m['SOC_max'] * 100, 1), m['sat_minutes']])
    with open('profiles.csv', 'w', newline='') as f:
        w = csv.writer(f); w.writerow(['h', 'phase', 'pnet'])
        for ph in range(3):
            for i in idx:
                w.writerow([round(t[i], 2), 'abc'[ph], round(Pnet[ph, i], 2)])
