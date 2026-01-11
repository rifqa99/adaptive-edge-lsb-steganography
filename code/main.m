clear; clc; close all;

se_size = 3;
T = 0.35;
key = 4869;
cover = imread('cover_ebru.jpg');
secret = imread('QR_secret_small.png');
[stego, meta] = encode_adaptive_multibit(cover,secret, se_size, T, key);

imwrite(stego, 'stego_key.png');
save('meta_key.mat', '-struct', 'meta');

recovered = decode_adaptive_multibit('stego_key.png', 'meta_key.mat', key);
