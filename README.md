# Adaptive Edge-Based LSB Steganography
A MATLAB implementation of an adaptive edge-based LSB steganography algorithm with multi-bit embedding, key-based randomization, and comprehensive quality and security evaluation.


This repository contains a **MATLAB implementation** of an adaptive edge-based LSB image steganography method with:
- multi-bit embedding,
- key-based randomization,
- and comprehensive quality and security evaluation.

The method adaptively embeds secret data in perceptually complex regions (edges) to achieve high capacity while preserving visual quality and resisting statistical steganalysis.

---

## Method Overview

- **Edge Detection:** Canny edge detector
- **Edge Strength Estimation:** Sobel gradient magnitude
- **Adaptive Embedding:**
  - Weak edges → 1 bit (Blue channel LSB)
  - Strong edges → 2 bits (Blue channel LSBs)
- **Security:** Key-based pseudo-random pixel shuffling
- **Embedding Domain:** Spatial domain (RGB, Blue channel)

---

## Repository Structure

adaptive-edge-lsb-steganography/
│
├── code/ # MATLAB source files
│ ├── encode_adaptive_multibit.m
│ ├── decode_adaptive_multibit.m
│ ├── exp_A_B.m
│ └── main_demo.m
│
├── figures/ # Output figures (histograms, FFT, comparisons)
│
├── data/
│ ├── covers/ # Cover images
│ └── secret/ # Example secret image (QR code)
│
├── report/
│ └── Report.pdf
│
├── appendices/
│ └── Appendices.pdf
│
├── README.md
└── LICENSE


---

## How to Run

1. Open MATLAB
2. Set the project root as the working directory
3. Run:
```matlab
main_demo


or

exp_A_B

Experiments

Experiment A: Fixed payload (80% of minimum capacity)

Experiment B: Capacity-adaptive payload (80% per image)

Metrics: PSNR, SSIM, L1, L2, Chi-square, KL divergence

Security Analysis: Histogram similarity and frequency-domain analysis

Notes

This implementation is intended for academic and educational use.

The secret image is included only for reproducibility.

JPEG compression robustness is not addressed (spatial-domain method).
