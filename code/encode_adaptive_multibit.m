function [stego, meta] = encode_adaptive_multibit(COVER, SECRET, se_size, T, key, payload_limit)
% Adaptif bit-başına-piksel + anahtar tabanlı rastgeleleştirme ile uyarlanabilir kenar tabanlı LSB gömme 
% - zayıf kenar pikselleri: 1 bit (LSB) 
% - güçlü kenar pikselleri: 2 bit (LSB + 2. LSB)

    % Giriş parametreleri kontrolü (Varsayılan sınırsız yük)
    if nargin < 6
        payload_limit = inf; 
    end

    % Görüntüleri belleğe alma ve veri tipini hazırlama
    cover  = COVER;
    secret = SECRET;
    secret = uint8(secret);

    % Kapak görüntüsünün RGB formatında olduğunu doğrula
    if size(cover,3) ~= 3
        error('Kapak görüntüsü RGB (H×W×3) formatında olmalıdır.');
    end

    % --- MASKE OLUŞTURMA SÜRECİ ---
    % Renkli görüntüyü kenar algılama için gri tonlamaya dönüştür
    gray_cover = rgb2gray(cover);
    % Canny algoritması ile temel kenarları tespit et
    edges = edge(gray_cover, 'canny');
    
    % Morfolojik Genişletme (Dilation) işlemi
    % Belirlenen kenarları SE (yapısal eleman) kadar genişleterek maske oluşturur
    se   = strel('square', se_size);
    mask = imdilate(edges, se);

    % --- ANALİZ VE SINIFLANDIRMA ---
    % Sobel gradyan hesaplama (Kenar şiddetini ölçmek için)
    G = imgradient(gray_cover, 'sobel'); 
    G = mat2gray(G); % Gradyan değerlerini [0,1] aralığına normalize et
    
    % Güçlü kenarları belirle (Maske içinde ve eşik değeri T'den büyük olanlar)
    strong = mask & (G > T);

    % bits_map (Bit Haritası): 0 = Gömme yok, 1 = Zayıf kenar, 2 = Güçlü kenar
    bits_map = zeros(size(mask), 'uint8');
    bits_map(mask)   = 1; % Tüm maske alanını önce zayıf kabul et
    bits_map(strong) = 2; % Güçlü gradyanlı alanları güncelle

    % Gizli görüntüyü 1D bit dizisine (bitstream) dönüştür
    secret_bits = int2bit(secret(:), 8);
    secret_bits = secret_bits(:)';  
    
    % Eğer payload (yük) sınırı belirtilmişse bit dizisini kırp
    if payload_limit < length(secret_bits)
        secret_bits = secret_bits(1:payload_limit);
    end

    % Kapasite kontrolü: Mevcut alan gizli veriyi taşıyabilir mi?
    total_bits  = numel(secret_bits); 
    capacity_bits = sum(bits_map(:));
    if total_bits > capacity_bits
        error('Gömme başarısız: Gizli veri (%d bit) kapasiteyi (%d bit) aşıyor.', ...
              total_bits, capacity_bits);
    end

    % --- ANAHTAR TABANLI RASTGELELEŞTİRME (GÜVENLİK) ---
    % Veri gömülebilecek piksellerin doğrusal indekslerini bul
    eligible_idx = find(bits_map(:) > 0); 
    % Kullanıcı anahtarı ile rastgele sayı üretecini başlat (Aynı anahtar çözmek için şarttır)
    rng(key, 'twister'); 
    % Piksel sırasını karıştır
    perm = randperm(numel(eligible_idx));
    eligible_idx = eligible_idx(perm);

    % --- VERİ GÖMME (EMBEDDING) SÜRECİ ---
    stego = cover;
    bit_idx = 1;
    for k = 1:numel(eligible_idx)
        if bit_idx > total_bits
            break; % Tüm veriler gömüldüyse döngüyü sonlandır
        end
        
        idx = eligible_idx(k);         % Karıştırılmış doğrusal indeks
        b = bits_map(idx);             % Mevcut pikselin kapasitesi (1 veya 2 bit)
        [i, j] = ind2sub(size(bits_map), idx); % Matris koordinatlarını bul
        
        if b == 1
            % Zayıf kenar: Sadece Mavi kanalın 1. LSB'sine göm
            stego(i,j,3) = bitset(stego(i,j,3), 1, secret_bits(bit_idx));
            bit_idx = bit_idx + 1;
        elseif b == 2
            % Güçlü kenar: Önce 1. LSB'ye göm
            stego(i,j,3) = bitset(stego(i,j,3), 1, secret_bits(bit_idx));
            bit_idx = bit_idx + 1;
            % Eğer hala bit varsa, 2. LSB'ye de göm (Çoklu bit özelliği)
            if bit_idx <= total_bits
                stego(i,j,3) = bitset(stego(i,j,3), 2, secret_bits(bit_idx));
                bit_idx = bit_idx + 1;
            end
        end
    end
    
    payload_bits = bit_idx - 1;

    % --- KALİTE ÖLÇÜMLERİ VE METADATA ---
    % PSNR ve MSE hesaplama (Görüntü kalitesi analizi)
    [psnr_val, mse_val] = psnr(stego, cover);
    % SSIM hesaplama (Yapısal benzerlik analizi)
    ssim_val = ssim(stego, cover);

    % Meta verileri yapı (struct) olarak kaydet (Çözücü için gereklidir)
    meta.mask         = mask;
    meta.bits_map     = bits_map;
    meta.payload_bits = payload_bits;
    meta.secret_size  = size(secret);
    meta.secret_class = class(secret);
    meta.se_size      = se_size;
    meta.T            = T;

    % Sonuçları Görselleştirme
    figure('Name','Orijinal vs Stego Görüntü','NumberTitle','off');
    tiledlayout(1,2,'Padding','compact','TileSpacing','compact');
    nexttile; imshow(cover); title('Orijinal Kapak Resmi');
    nexttile; imshow(stego); title('Stego Görüntüsü (Veri Gizlenmiş)');
end
