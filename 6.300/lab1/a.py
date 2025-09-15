from math import pi, sin
from matplotlib.pyplot import plot, show


def plot_func(func):
    x = []
    y = []

    t = 0
    while t < 10:
        x.append(t)
        y.append(func(t))
        t += 0.01

    plot(x, y)


def approximate(t):
    sum = 0
    for k in range(1, 10000, 1):
        sum += sin(k * t) / k
    return sum


def top_bound(t):
    return pi / 2


def bottom_bound(t):
    return -pi / 2


def closed_form(t):
    return -t / 2 % (pi) - pi / 2


plot_func(approximate)
# plot_func(top_bound)
# plot_func(bottom_bound)
plot_func(closed_form)

show()
