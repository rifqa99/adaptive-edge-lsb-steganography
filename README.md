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

