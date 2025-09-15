import numpy as np
import matplotlib.pyplot as plt
from lib6300.audio import wav_write
import pickle


def fourier(t, ck, dk, omega):
    cknum = np.arange(1, len(ck))
    dknum = np.arange(1, len(dk))

    fcos = np.cos(np.outer(cknum, omega * t))
    fsin = np.sin(np.outer(dknum, omega * t))

    return ck[0] + (ck[1:] @ fcos) + (dk[1:] @ fsin)


with open("signal.pkl", "rb") as f:
    ck, dk = np.array(pickle.load(f))

# ck = ck[: len(ck) // 5]
# dk = dk[: len(dk) // 5]

# dk = -dk
# ck = np.zeros(len(ck))

duration = 3
fs = 20000  # sampling frequency
omega = 2

batches = 2
batch_duration = duration / batches

sig_parts = [[] for b in range(batches)]

for batch in range(batches):
    start = batch * batch_duration
    end = min(start + batch_duration, duration)

    t = np.linspace(start, end, int((end - start) * fs), endpoint=False)
    sig_parts[batch] = fourier(t, ck, dk, omega)

    print(f"{batch + 1}/{batches}")

signal = np.concatenate(sig_parts)

# signal = signal[::-1]

wav_write(signal, fs, "test.wav")
