"""
Modelo de referencia (Python) de la Micro-red DC del archivo MicroRed_DC_Validacion.plecs.

Replica las mismas ecuaciones del modelo promedio en PLECS:
  - 5 ramas convertidor (FV, BESS, EV, carga activa, IC), cada una = fuente controlada + Rl + L
  - bus DC: C_bus y carga resistiva base R_base
  - lazos de corriente PI discretos (Ts, trapezoidal) con feedforward de Vdc
  - primario: droop V-I en BESS (y en EV, opcional)
  - secundario: PI de restauracion de Vdc + reglas de SOC (recorte FV, reduccion EV, limites BESS)
  - SOC por integracion de potencia, con eficiencias y factor de compresion de tiempo kappa

Sirve para verificar estabilidad y obtener las formas de onda esperadas. NO reemplaza la
simulacion en PLECS: si PLECS entrega algo distinto, hay que revisar el modelo PLECS.

Uso:  python3 referencia_microred_dc.py 1     (escenario 1: validacion dinamica)
      python3 referencia_microred_dc.py 2     (escenario 2: dia comprimido, 1 s = 1 h)
"""
import sys
import numpy as np
from scipy.linalg import expm

ESC = int(sys.argv[1]) if len(sys.argv) > 1 else 1
MES = 1  # 1 = enero, 2 = julio

# ---------------- parametros (identicos al .plecs) ----------------
Ts = 1 / 15000
V0 = 400.0
L, Rl = 1e-3, 0.03
e_i, f_i = 0.8, 400
wn_i = 2 * np.pi * f_i
Kp_i = 2 * e_i * wn_i * L - Rl
Ki_i = wn_i**2 * L
C_bus = 4.7e-3
P_base = 250.0
R_base = V0**2 / P_base

# FV (RS6F-200M, 2 strings x 8 modulos)
Isc, Voc, Imp, Vmp = 5.41, 47.8, 4.99, 41.1
alpha_I, beta_V = 0.05 / 100, -0.32 / 100
NOCT, Tn, Gn = 45.0, 25.0, 1000.0
Np, Ns = 2, 8

# BESS
cell_cap, n_parallel, pack_V = 6.5, 9, 360.0
E_bat = cell_cap * n_parallel * pack_V      # Wh
eta_c, eta_d = 0.95, 0.95
Pb_max = 5000.0
Ib_max = Pb_max / V0
dV_max = 10.0
Rd_b = dV_max / Ib_max

# EV
P_ev_nom = 3700.0
Iev_max = 10.0
Rd_ev = dV_max / (P_ev_nom / V0)
Modo_EV = 1          # 1: participa en el primario (droop), 0: potencia constante
Iev_v2g = 0.0        # corriente maxima de descarga V2G (0 = sin V2G)

# Secundario
Kp_s, Ki_s = 0.2, 20.0
dVsec_max = 25.0
SOC_min, SOC_max, dS = 0.10, 0.90, 0.03


def sat01(x):
    return 0.5 * (abs(x) - abs(x - 1) + 1)


def clamp(y, lo, hi):
    return 0.5 * (abs(y - lo) - abs(y - hi) + lo + hi)


# ---------------- escenarios ----------------
PPV = np.loadtxt('PPV.csv', delimiter=';', skiprows=3, usecols=(1, 2, 3, 4))


def zoh(hourly, Th):
    t = []
    v = []
    for h, val in enumerate(hourly):
        t += [h * Th, (h + 1) * Th - 1e-3]
        v += [val, val]
    return np.array(t + [1e6]), np.array(v + [hourly[-1]])


if ESC == 1:
    kappa, SOC_init, Tsim = 1.0, 0.60, 3.4
    t_G, G_v = [0, 1.6, 1.6005, 100], [800, 800, 500, 500]
    t_T, T_v = [0, 100], [25, 25]
    t_ld, Pld_v = [0, 0.4, 0.4001, 100], [1500, 1500, 2250, 2250]
    t_ev, Pev_v = [0, 0.8, 0.8001, 2.6, 2.6001, 100], [0, 0, 3700, 3700, 0, 0]
    evc_v = [0, 0, 1, 1, 0, 0]
    t_ic, Pic_v = [0, 2.0, 2.0001, 3.0, 3.0001, 100], [0, 0, 3000, 3000, -1000, -1000]
    t_sec, sec_v = [0, 1.2, 1.2001, 100], [0, 0, 1, 1]
else:
    kappa, SOC_init = 3600.0, 0.50
    Th = 3600 / kappa
    Tsim = 24 * Th
    G_h = PPV[:, MES - 1]
    T_h = PPV[:, 1 + MES]
    t_G = list(np.arange(25) * Th) + [1e6]
    G_v = list(G_h) + [G_h[0], G_h[0]]
    t_T, T_v = t_G, list(T_h) + [T_h[0], T_h[0]]
    Pld_h = np.array([400, 320, 320, 320, 320, 400, 640, 960, 800, 640, 560, 560,
                      720, 800, 640, 560, 640, 800, 1200, 1600, 1760, 1440, 960, 640], dtype=float)
    evc_h = np.array([0] * 19 + [1, 1, 1, 1, 0])
    Pev_h = evc_h * P_ev_nom
    Pic_h = np.array([1000] * 7 + [0] * 4 + [-1000] * 5 + [0] * 3 + [3500] * 4 + [1000], dtype=float)
    sec_h = np.ones(24)
    t_ld, Pld_v = zoh(Pld_h, Th)
    t_ev, Pev_v = zoh(Pev_h, Th)
    _, evc_v = zoh(evc_h, Th)
    t_ic, Pic_v = zoh(Pic_h, Th)
    t_sec, sec_v = zoh(sec_h, Th)


def lk(t, x, y):
    return np.interp(t, x, y)


def pv_avail(G, Ta):
    G = max(G, 0.0)
    Tc = Ta + (NOCT - 20) / 800 * G
    I = Np * Imp * G / Gn * (1 + alpha_I * (Tc - Tn))
    V = Ns * Vmp * (1 + beta_V * (Tc - Tn))
    return I * V, Tc


# ---------------- planta discretizada (ZOH) ----------------
# x = [i_pv, i_bat, i_ev, i_ld, i_ic, V];  u = [v_pv, v_bat, v_ev, v_ld, v_ic]
A = np.zeros((6, 6))
B = np.zeros((6, 5))
for k in range(5):
    A[k, k] = -Rl / L
    A[k, 5] = -1 / L
    B[k, k] = 1 / L
    A[5, k] = 1 / C_bus
A[5, 5] = -1 / (R_base * C_bus)
M = np.zeros((11, 11))
M[:6, :6] = A
M[:6, 6:] = B
Md = expm(M * Ts)
Ad, Bd = Md[:6, :6], Md[:6, 6:]

N = int(round(Tsim / Ts))
x = np.zeros(6)
x[5] = V0
Iint = np.zeros(5)
e_prev = np.zeros(5)
Isec, es_prev = 0.0, 0.0
SOC = SOC_init
dec = 15 if ESC == 1 else 150
log = []

for n in range(N):
    t = n * Ts
    ipv, ibat, iev, ild, iic, V = x
    G = lk(t, t_G, G_v)
    Ta = lk(t, t_T, T_v)
    Pdisp, Tc = pv_avail(G, Ta)
    Pld = lk(t, t_ld, Pld_v)
    Pev = lk(t, t_ev, Pev_v)
    evc = lk(t, t_ev, evc_v)
    Pic = lk(t, t_ic, Pic_v)
    son = lk(t, t_sec, sec_v)

    # secundario
    es = son * (V0 - V)
    Isec = Isec + Ki_s * Ts / 2 * (es + es_prev)
    es_prev = es
    dV = clamp(Kp_s * es + Isec, -dVsec_max, dVsec_max)
    k_cur = sat01((SOC_max - dS - SOC) / dS)
    k_ev = sat01((SOC - SOC_min - dS) / dS)

    # referencias de corriente (primario)
    ir_pv = k_cur * Pdisp / V
    hi = Ib_max * sat01((SOC - SOC_min) / dS)
    lo = -Ib_max * sat01((SOC_max - SOC) / dS)
    ir_bat = clamp((V0 + dV - V) / Rd_b, lo, hi)
    ir_ev = evc * clamp(-k_ev * Pev / V + Modo_EV * (V0 - V) / Rd_ev, -Iev_max, Modo_EV * Iev_v2g)
    ir_ld = -Pld / V
    ir_ic = Pic / V
    iref = np.array([ir_pv, ir_bat, ir_ev, ir_ld, ir_ic])

    # lazos de corriente (PI trapezoidal) + feedforward
    e = iref - x[:5]
    Iint = Iint + Ki_i * Ts / 2 * (e + e_prev)
    e_prev = e
    u = Kp_i * e + Iint + V

    # SOC
    Pb = V * ibat
    Pcell = 0.5 * (Pb + abs(Pb)) / eta_d + 0.5 * (Pb - abs(Pb)) * eta_c
    SOC = min(max(SOC - kappa * Pcell / (3600 * E_bat) * Ts, 0.0), 1.0)

    if n % dec == 0:
        log.append([t, V, V * ipv, V * ibat, V * iev, V * ild, V * iic, SOC, dV, Pdisp, G, Tc, k_cur, k_ev,
                    V * V / R_base])
    x = Ad @ x + Bd @ u

log = np.array(log)
np.save(f'ref_esc{ESC}.npy', log)
print(f'Escenario {ESC}: {N} pasos. Vdc min/max = {log[:,1].min():.2f}/{log[:,1].max():.2f} V, '
      f'SOC final = {log[-1,7]:.3f}, SOC min/max = {log[:,7].min():.3f}/{log[:,7].max():.3f}, '
      f'Pbat max = {log[:,3].max():.0f} W, Pbat min = {log[:,3].min():.0f} W')
