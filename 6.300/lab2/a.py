import numpy as np
import matplotlib.pyplot as plt

T = 4
omega0 = 2 * np.pi / T
c0 = 1 / 8


def func(t):
    t_mod = np.mod(t, T)
    return np.where((t_mod >= 0) & (t_mod < 1), t_mod, 0.0)


def ck(k, omega):
    a = k * omega
    # return 0
    return 0.5 * (np.sin(a) / a + np.cos(a) / a**2 - 1 / a**2)


def dk(k, omega):
    a = k * omega
    # return -0.5 * (-np.cos(a) / a + np.sin(a) / a**2)
    return 0.5 * (-np.cos(a) / a + np.sin(a) / a**2)


def fourier(t, N):
    series = c0
    for k in range(1, N):
        series += ck(k, omega0) * np.cos(k * omega0 * t) + dk(k, omega0) * np.sin(
            k * omega0 * t
        )
    return series


t = np.linspace(-5.5, 5.5, 1000)

# N = 10
N = 100

f_approx = fourier(t, N)
f_exact = func(t)

plt.figure(figsize=(10, 5))
plt.plot(t, f_exact, "k", label="True")
plt.plot(t, f_approx, "r", label=f"Fourier (N={N})")
plt.xlabel("t")
plt.ylabel("f(t)")
plt.legend()
plt.title("Lab 2")
plt.grid(True)
plt.show()
