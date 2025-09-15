import math

giga = math.pow(10, 9)
mega = math.pow(10, 6)

milli = math.pow(10, -3)
micro = math.pow(10, -6)
nano = math.pow(10, -9)
pico = math.pow(10, -12)
femto = math.pow(10, -15)

e_0 = 8.85418782 * math.pow(10, -12)
e_SiO2 = 3.9 * e_0

# ohms/um
rho = 20 / micro

# femtofarads/um
C_dens = 0.15 * femto / micro

L_wire = 60 * micro

# meters
W_trans = 2 * micro
L_trans = 200 * nano
H_cap = 5 * nano

K_on = 0.0004 / micro
K_off = 1 / micro

# K*T/q (V)
KTq = 25 * milli

# (V)
VDD = 1
V_t = 0.4

# circuit info
LD = 18
FO = 2

N_stages = 5

alpha = 0.1

N_cycles = 1 * giga

print("[Q1]")
# math starts here
C_in = e_SiO2 * W_trans * L_trans / H_cap
C_out = C_in / 4

C_inv_in = 2 * C_in
C_inv_out = 2 * C_out

C_wire = C_dens * L_wire
R_wire = rho * L_wire

I_on = W_trans * K_on * math.pow(VDD - V_t, 2)
I_off = W_trans * K_off * math.exp(-V_t / KTq)

R_on = VDD / I_on
R_off = VDD / I_off

tau = R_on * (C_inv_out + C_wire + FO * C_inv_in) + R_wire * (C_wire/2 + FO * C_inv_in)
t_p = 1/2 * math.log(2) * tau

T_clk = LD * t_p
F_clk = 1/T_clk

print("a)")
print(f"F_clk = {F_clk/giga:.3f} GHz")
print()

# sum: 1 + 2 + 4 + 8 + ...
# N-sum: 2^N - 1
PN_gates = math.pow(2, LD) - 1

P_static = math.pow(VDD, 2) / R_off
E_leak = P_static * T_clk
E_leak_tot = E_leak * PN_gates * N_stages

E_dyn = (C_inv_out + C_wire + FO * C_inv_in) * math.pow(VDD, 2) * alpha
E_dyn_tot = E_dyn * PN_gates * N_stages

E_tot = E_leak_tot + E_dyn_tot
E_app = E_tot * N_cycles

print("b)")
print(f"E_tot = {E_tot:.3e}")
print()
print(f"E_app = {E_app:.3f} Joules")
print(f"E_dyn_tot/E_tot (%) = {100*E_dyn_tot/E_tot:.3f}%")
print(f"E_leak_tot/E_tot (%) = {100*E_leak_tot/E_tot:.3f}%")
print()

print("[Q2]")
# change parameters for graphine
rho /= 100
C_dens /= 2

# redo math for graphine
C_in = e_SiO2 * W_trans * L_trans / H_cap
C_out = C_in / 4

C_inv_in = 2 * C_in
C_inv_out = 2 * C_out

C_wire = C_dens * L_wire
R_wire = rho * L_wire

I_on = W_trans * K_on * math.pow(VDD - V_t, 2)
I_off = W_trans * K_off * math.exp(-V_t / KTq)

R_on = VDD / I_on
R_off = VDD / I_off

tau = R_on * (C_inv_out + C_wire + FO * C_inv_in) + R_wire * (C_wire/2 + FO * C_inv_in)
t_p = 1/2 * math.log(2) * tau

T_clk = LD * t_p
F_clk = 1/T_clk

print("a)")
print(f"F_clk = {F_clk/giga:.3f} GHz")
print()

PN_gates = math.pow(2, LD) - 1

P_static = math.pow(VDD, 2) / R_off
E_leak = P_static * T_clk
E_leak_tot = E_leak * PN_gates * N_stages

E_dyn = (C_inv_out + C_wire + FO * C_inv_in) * math.pow(VDD, 2) * alpha
E_dyn_tot = E_dyn * PN_gates * N_stages

E_tot = E_leak_tot + E_dyn_tot
E_app = E_tot * N_cycles

print(f"E_tot = {E_tot:.3e}")
print()
print(f"E_app = {E_app:.3f} Joules")
print(f"E_dyn_tot/E_tot (%) = {100*E_dyn_tot/E_tot:.3f}%")
print(f"E_leak_tot/E_tot (%) = {100*E_leak_tot/E_tot:.3f}%")
print()

# undo changes of graphene
rho *= 100
C_dens *= 2

# change parameters for carbon nano tubes
K_on *= 2
K_off *= 2

L_trans /= 5
VDD = 0.96
V_t = 0.4

# redo math for CNT
C_in = e_SiO2 * W_trans * L_trans / H_cap
C_out = C_in / 4

C_inv_in = 2 * C_in
C_inv_out = 2 * C_out

C_wire = C_dens * L_wire
R_wire = rho * L_wire

I_on = W_trans * K_on * math.pow(VDD - V_t, 2)
I_off = W_trans * K_off * math.exp(-V_t / KTq)

R_on = VDD / I_on
R_off = VDD / I_off

tau = R_on * (C_inv_out + C_wire + FO * C_inv_in) + R_wire * (C_wire/2 + FO * C_inv_in)
t_p = 1/2 * math.log(2) * tau

T_clk = LD * t_p
F_clk = 1/T_clk

print("b) CNT")
print(f"F_clk = {F_clk/giga:.3f} GHz")
print()

PN_gates = math.pow(2, LD) - 1

P_static = math.pow(VDD, 2) / R_off
E_leak = P_static * T_clk
E_leak_tot = E_leak * PN_gates * N_stages

E_dyn = (C_inv_out + C_wire + FO * C_inv_in) * math.pow(VDD, 2) * alpha
E_dyn_tot = E_dyn * PN_gates * N_stages

E_tot = E_leak_tot + E_dyn_tot
E_app = E_tot * N_cycles

print(f"E_tot = {E_tot:.3e}")
print()
print(f"E_app = {E_app:.3f} Joules")
print(f"E_dyn_tot/E_tot (%) = {100*E_dyn_tot/E_tot:.3f}%")
print(f"E_leak_tot/E_tot (%) = {100*E_leak_tot/E_tot:.3f}%")
print()
print(f"T_clk*E_tot (EDP) = {T_clk*E_tot:.3e}")

print("[Q3]")
# undo changes of carbon nano tubes
K_on /= 2
K_off /= 2

L_trans *= 5

VDD = 1

# change parameters for bad wires
rho *= 100
C_dens *= 100

# redo math for CNT
C_in = e_SiO2 * W_trans * L_trans / H_cap
C_out = C_in / 4

C_inv_in = 2 * C_in
C_inv_out = 2 * C_out

C_wire = C_dens * L_wire
R_wire = rho * L_wire

I_on = W_trans * K_on * math.pow(VDD - V_t, 2)
I_off = W_trans * K_off * math.exp(-V_t / KTq)

R_on = VDD / I_on
R_off = VDD / I_off

tau = R_on * (C_inv_out + C_wire + FO * C_inv_in) + R_wire * (C_wire/2 + FO * C_inv_in)
t_p = 1/2 * math.log(2) * tau

T_clk = LD * t_p
F_clk = 1/T_clk

print("a)")
print(f"F_clk = {F_clk/mega:.3f} MHz")
print()

PN_gates = math.pow(2, LD) - 1

P_static = math.pow(VDD, 2) / R_off
E_leak = P_static * T_clk
E_leak_tot = E_leak * PN_gates * N_stages

E_dyn = (C_inv_out + C_wire + FO * C_inv_in) * math.pow(VDD, 2) * alpha
E_dyn_tot = E_dyn * PN_gates * N_stages

E_tot = E_leak_tot + E_dyn_tot
E_app = E_tot * N_cycles

print(f"E_tot = {E_tot:.3e}")
print()
print(f"E_app = {E_app:.3f} Joules")
print(f"E_dyn_tot/E_tot (%) = {100*E_dyn_tot/E_tot:.3f}%")
print(f"E_leak_tot/E_tot (%) = {100*E_leak_tot/E_tot:.3f}%")
print()
print(f"T_clk*E_tot (EDP) = {T_clk*E_tot:.3e}")

# change parameters for CNT
K_on *= 2
K_off *= 2

L_trans /= 5

# redo math for CNT
C_in = e_SiO2 * W_trans * L_trans / H_cap
C_out = C_in / 4

C_inv_in = 2 * C_in
C_inv_out = 2 * C_out

C_wire = C_dens * L_wire
R_wire = rho * L_wire

I_on = W_trans * K_on * math.pow(VDD - V_t, 2)
I_off = W_trans * K_off * math.exp(-V_t / KTq)

R_on = VDD / I_on
R_off = VDD / I_off

tau = R_on * (C_inv_out + C_wire + FO * C_inv_in) + R_wire * (C_wire/2 + FO * C_inv_in)
t_p = 1/2 * math.log(2) * tau

T_clk = LD * t_p
F_clk = 1/T_clk

print("b)")
print(f"F_clk = {F_clk/mega:.3f} MHz")
print()

PN_gates = math.pow(2, LD) - 1

P_static = math.pow(VDD, 2) / R_off
E_leak = P_static * T_clk
E_leak_tot = E_leak * PN_gates * N_stages

E_dyn = (C_inv_out + C_wire + FO * C_inv_in) * math.pow(VDD, 2) * alpha
E_dyn_tot = E_dyn * PN_gates * N_stages

E_tot = E_leak_tot + E_dyn_tot
E_app = E_tot * N_cycles

print(f"E_tot = {E_tot:.3e}")
print()
print(f"E_app = {E_app:.3f} Joules")
print(f"E_dyn_tot/E_tot (%) = {100*E_dyn_tot/E_tot:.3f}%")
print(f"E_leak_tot/E_tot (%) = {100*E_leak_tot/E_tot:.3f}%")
print()
print(f"T_clk*E_tot (EDP) = {T_clk*E_tot:.3e}")
