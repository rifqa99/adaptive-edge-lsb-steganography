clear; clc; close all;

% --- PARAMETRELER ---
se_size = 3;        % Genişletme (Dilation) için yapısal eleman boyutu
T = 0.35;           % Güçlü/Zayıf kenar ayrımı için eşik değeri
key = 4869;         % Karıştırma için güvenlik anahtarı
secret = imread('QR_secret.png'); % Tüm deneylerde kullanılacak gizli veri (QR kod)

% Test edilecek kapak resimleri listesi
covers = {
    'cover_btu.jpeg'
    'cover_dessert.jpeg'
    'cover_ebru.jpg'
};
num_covers = length(covers);

%% --- MİNİMUM KAPASİTE HESAPLAMA ---
% Tüm resimler arasında en küçük kapasiteye sahip olanı bulup deney A için sabit yük belirleriz.
capacities = zeros(num_covers,1);
for k = 1:num_covers
    cover = imread(covers{k});
    gray = rgb2gray(cover);
    
    % Kenar ve gradyan analizi
    edges = edge(gray,'canny');
    se = strel('square', se_size);
    mask = imdilate(edges, se);
    G = imgradient(gray,'sobel');
    G = mat2gray(G);
    
    % Bit haritası oluşturma
    strong = mask & (G > T);
    bits_map = zeros(size(mask),'uint8');
    bits_map(mask)   = 1; % Zayıf kenarlar
    bits_map(strong) = 2; % Güçlü kenarlar
    capacities(k) = sum(bits_map(:)); % Toplam bit kapasitesi
end

% Deney A için yük: En küçük kapasitenin %80'i kadar sabit veri gömülecek.
payload_fixed = floor(0.8 * min(capacities)); 
fprintf('Deney A Sabit Yük: %d bit\n', payload_fixed);

%% --- DENEY A: SABİT YÜK ANALİZİ (Görüntü Kalitesi Karşılaştırması) ---
% Bu bölümde farklı resimlere AYNI miktarda veri gömüldüğünde sonuçlar karşılaştırılır.
ImageName = strings(num_covers,1);
PSNR_A    = zeros(num_covers,1);
SSIM_A    = zeros(num_covers,1);
L1  = zeros(num_covers,1); % Histogram farkı metrikleri
L2  = zeros(num_covers,1);
CHI = zeros(num_covers,1); % Chi-Square testi
KL  = zeros(num_covers,1); % Kullback-Leibler Divergence (İstatistiksel benzerlik)

for k = 1:num_covers
    cover = imread(covers{k});
    [stego, meta] = encode_adaptive_multibit(cover, secret, se_size, T, key, payload_fixed);
    
    % Görüntü Kalite Metrikleri
    PSNR_A(k) = psnr(stego, cover);
    SSIM_A(k) = ssim(stego, cover);
    
    % --- HİSTOGRAM ANALİZİ (İstatistiksel Güvenlik) ---
    % Mavi kanaldaki (veri gömülen kanal) histogram değişimini ölçer
    h_cover = imhist(cover(:,:,3));
    h_stego = imhist(stego(:,:,3));
    
    % Normalize etme (olasılık yoğunluk fonksiyonuna çevirme)
    h_cover = h_cover / sum(h_cover);
    h_stego = h_stego / sum(h_stego);
    
    % Histogramlar arasındaki farkların hesaplanması
    L1(k)  = sum(abs(h_cover - h_stego));
    L2(k)  = norm(h_cover - h_stego);
    CHI(k) = sum((h_cover - h_stego).^2 ./ (h_cover + eps));
    KL(k)  = sum(h_cover .* log((h_cover + eps) ./ (h_stego + eps)));
    ImageName(k) = covers{k};
end

Results_A = table(ImageName, PSNR_A, SSIM_A, L1, L2, CHI, KL);
disp('--- Deney A Sonuçları (Sabit Yük) ---');
disp(Results_A);

%% --- DENEY B: KAPASİTEYE GÖRE UYARLANABİLİR YÜK ---
% Bu bölümde her resmin kendi maksimum kapasitesinin %80'i kadar veri gömülür.
Capacity_B = zeros(num_covers,1);
Payload_B  = zeros(num_covers,1);
PSNR_B     = zeros(num_covers,1);
SSIM_B     = zeros(num_covers,1);

for k = 1:num_covers
    cover = imread(covers{k});
    gray = rgb2gray(cover);
    
    % Kapasite tahmini (Yeniden hesaplanır çünkü her resmin dokusu farklıdır)
    edges = edge(gray,'canny');
    se = strel('square', se_size);
    mask = imdilate(edges, se);
    G = imgradient(gray,'sobel');
    G = mat2gray(G);
    
    strong = mask & (G > T);
    bits_map = zeros(size(mask),'uint8');
    bits_map(mask)   = 1;
    bits_map(strong) = 2;
    
    capacity = sum(bits_map(:));
    payload  = floor(0.8 * capacity); % Resme özel %80 doluluk oranı
    
    % Gömme İşlemi
    [stego, meta] = encode_adaptive_multibit(cover, secret, se_size, T, key, payload);
    
    Capacity_B(k) = capacity;
    Payload_B(k)  = payload;
    PSNR_B(k)     = psnr(stego, cover);
    SSIM_B(k)     = ssim(stego, cover);
    ImageName(k) = covers{k};
end

Results_B = table(ImageName, Capacity_B, Payload_B, PSNR_B, SSIM_B);
disp('--- Deney B Sonuçları (Resme Özel Değişken Yük) ---');
disp(Results_B);
