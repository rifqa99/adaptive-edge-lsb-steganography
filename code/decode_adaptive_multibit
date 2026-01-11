function extracted_image = decode_adaptive_multibit(stego_path, meta_path, key)
% Meta veri + anahtar tabanlı rastgeleleştirme kullanarak 
% uyarlanabilir çok bitli stego görüntüden gizli görüntüyü çözer
    
    % Dosyaları oku
    stego = imread(stego_path);
    meta = load(meta_path);  % Meta verilerin yapı (struct) olarak yüklenmesi beklenir
    
    bits_map = meta.bits_map;
    payload_bits = meta.payload_bits;
    [rows, cols, ~] = size(stego);
    
    % Boyut kontrolü: Bit haritası ile stego görüntüsü uyumlu mu?
    if ~isequal(size(bits_map), [rows, cols])
        error('Boyut uyumsuzluğu: bits_map ve stego boyutları eşleşmiyor.');
    end
    
    % --- AYNI anahtarı kullanarak AYNI rastgele sırayı oluştur ---
    % Veri gömülmüş olan piksellerin lineer indekslerini bul
    eligible_idx = find(bits_map(:) > 0);
    
    % Rastgele sayı üretecini (RNG) anahtar ile başlat (Kodlayıcı ile aynı olmalı)
    rng(key, 'twister');
    perm = randperm(numel(eligible_idx));
    eligible_idx = eligible_idx(perm); % İndeksleri karıştır
    
    % Çıkarılacak bitler için yer ayır
    extracted_bits = zeros(1, payload_bits, 'uint8');
    bit_idx = 1;
    
    % Karıştırılmış indeksler üzerinde döngü başlat
    for k = 1:numel(eligible_idx)
        if bit_idx > payload_bits
            break; % Tüm veriler çıkarıldıysa döngüden çık
        end
        
        idx = eligible_idx(k);
        b = bits_map(idx); % Bu pikselde kaç bit gizli olduğunu kontrol et (1 veya 2)
        [i, j] = ind2sub(size(bits_map), idx); % Lineer indeksi koordinatlara çevir
        
        if b == 1
            % Mavi kanalın 1. LSB bitini oku
            extracted_bits(bit_idx) = bitget(stego(i,j,3), 1);
            bit_idx = bit_idx + 1;
        elseif b == 2
            % Mavi kanalın 1. LSB bitini oku
            extracted_bits(bit_idx) = bitget(stego(i,j,3), 1);
            bit_idx = bit_idx + 1;
            
            % Eğer hala çıkarılacak bit varsa 2. LSB bitini oku
            if bit_idx <= payload_bits
                extracted_bits(bit_idx) = bitget(stego(i,j,3), 2);
                bit_idx = bit_idx + 1;
            end
        end
    end
    
    % Bit dizisini (bitstream) tekrar byte (tam sayı) formatına dönüştür
    extracted_bytes = bit2int(reshape(extracted_bits, 8, []), 8);
    
    % Görüntüyü orijinal boyutlarına göre yeniden yapılandır
    extracted_image = reshape(uint8(extracted_bytes), meta.secret_size);
    
    % Veri tipini orijinal haline getir (uint8 vb.)
    extracted_image = cast(extracted_image, meta.secret_class);
    
    % Sonucu görselleştir
    figure; imshow(extracted_image);
    title('Kurtarılan Gizli Görüntü (Anahtar-rastgeleleştirmeli Adaptif Çok-Bitli)');
end
