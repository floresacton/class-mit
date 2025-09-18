import numpy as np
import matplotlib.pyplot as plt

Ns = [2**k for k in range(21)]

estimates = []

for N in Ns:
    x = np.random.rand(N)
    y = np.random.rand(N)
    inside = np.sum(x**2 + y**2 <= 1)
    pi_estimate = 4 * inside / N
    estimates.append(pi_estimate)

plt.figure(figsize=(10, 6))
plt.plot(Ns, estimates, marker="o", linestyle="-", label="Estimate")
plt.axhline(np.pi, color="red", linestyle="--", label="PI")

plt.xscale("log")
plt.xlabel("N")
plt.ylabel("Estimate")
plt.title("PI Estimate")
plt.legend()
plt.grid(True, which="both", linestyle="--", linewidth=0.5)
plt.show()
