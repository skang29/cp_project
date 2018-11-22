function HDRWrapper(FILE_TYPE, WEIGHT_TYPE, MERGE_TYPE, NUM_IMAGES)
% Running code
Zmax = 0.99; Zmin=0.01;
Zmax_uint8 = floor(Zmax * 255);
Zmin_uint8 = ceil(Zmin * 255);

fprintf('File type: %s\nWeight type: %s\n', FILE_TYPE, WEIGHT_TYPE);

% Declaration of weight of pixel values
w = zeros(256,1);
if strcmp(WEIGHT_TYPE, 'uniform') 
    for i=1:256
        if Zmin <= (i - 1) / 255 && (i - 1) / 255 <= Zmax
            w(i, 1) = 1;
        end
    end
elseif strcmp(WEIGHT_TYPE, 'tent') 
    for i=1:256
        if Zmin <= (i - 1) / 255 && (i - 1) / 255 <= Zmax
            Zvalue = (i - 1) / 255;
            w(i, 1) = -2 * abs(2*Zvalue-1) + 2;
        end
    end
elseif strcmp(WEIGHT_TYPE, 'gaussian') 
    for i=1:256
        if Zmin <= (i - 1) / 255 && (i - 1) / 255 <= Zmax
            Zvalue = (i - 1) / 255;
            w(i, 1) = normpdf(Zvalue, 0.5, 1/6);
        end
    end
else
    error('Unexpected weight scheme.');
end

fprintf('Reading images ... ');
% Reading pixel values
image_stack = {};
original_stack = {};
if strcmp(FILE_TYPE, 'raw')
    for idx_im=1:NUM_IMAGES
        im = imread(sprintf('exposure_stack/exposure%d.tiff', idx_im));
        im = im(1:4000, 1:6000, :);
        im = imresize(im, 0.2);
        im = im2double(im);
        ori = uint8(im * 255); % À§Ä¡ ¹Ù²Þ
        im(im > Zmax) = Zmax;
        im(im < Zmin) = Zmin;
        image_stack(idx_im, :) = {im};
        original_stack(idx_im, :) = {ori};
    end
elseif strcmp(FILE_TYPE, 'rendered')
    for idx_im=1:NUM_IMAGES
        matfile = load(sprintf('results/Q1_Linearization/linearized/%s/exposure%d.mat', WEIGHT_TYPE, idx_im));
        im = matfile.im;
        image_stack(idx_im, :) = {im};
        ori = imread(sprintf('exposure_stack/exposure%d.jpg', idx_im));
        ori = imresize(ori, 0.2);
        original_stack(idx_im, :) = {ori};
    end
else
    error('Unexpected file type.')
end

fprintf('Done !  ');
toc

% HDR creation
fprintf('Creating HDR image(Type %s) ... ', MERGE_TYPE);
[imh, imw, imc] = size(image_stack{1});
im2var = zeros(imh, imw, imc);
im2var(1:imh * imw * imc) = imh * imw * imc;

t = power(2, (1:NUM_IMAGES) - 1) / 2048;

% im_hdr = zeros(imh, imw, imc, 'double');
if strcmp(MERGE_TYPE, 'linear')
    im_hdr_val = cell(imh, 1);
    parfor idx_h=1:imh
        im_temp = zeros(1, imw, imc);
        for idx_w=1:imw
            for idx_c=1:imc
                numerator = 0;
                denominator = 0;

                for idx_im=1:NUM_IMAGES
                    original_image = original_stack{idx_im};
                    ldr_image = image_stack{idx_im};
                    Zldr = original_image(idx_h, idx_w, idx_c);
                    Zval = ldr_image(idx_h, idx_w, idx_c);
                    numerator = numerator + w(Zldr + 1) * Zval / t(idx_im);
                    denominator = denominator + w(Zldr + 1);
                end
                if denominator < 1e-5
                    im_temp(1, idx_w, idx_c) = 0;  
                else
                    im_temp(1, idx_w, idx_c) = numerator / denominator;
                end
            end
        end
        im_hdr_val{idx_h} = im_temp;
    end
    im_hdr = vertcat(im_hdr_val{:});

elseif strcmp(MERGE_TYPE, 'logarithmic')
    im_hdr_val = cell(imh, 1);
    parfor idx_h=1:imh
        im_temp = zeros(1, imw, imc);
        for idx_w=1:imw
            for idx_c=1:imc
                numerator = 0;
                denominator = 0;
                for idx_im=1:NUM_IMAGES
                    Zldr = original_stack{idx_im}(idx_h, idx_w, idx_c);
                    Zval = image_stack{idx_im}(idx_h, idx_w, idx_c);
                    numerator = numerator + w(Zldr + 1) * (log(Zval) - log(t(idx_im)));
                    denominator = denominator + w(Zldr + 1);
                end
                if denominator < 1e-5
                    im_temp(1, idx_w, idx_c) = 0;  
                else
                    im_temp(1, idx_w, idx_c) = exp(numerator / denominator);
                end
            end
        end
        im_hdr_val{idx_h} = im_temp;
    end
    im_hdr = vertcat(im_hdr_val{:});
end

% im_hdr = im_hdr / max(max(max(im_hdr)));

fprintf('Done !  ');
toc
figure;
subplot(1, 2, 1);
imshow(im_hdr);
title('HDR Image');
subplot(1, 2, 2);
imshow(tonemap(im_hdr));
title('Tonemapped(MATLAB)');

imwrite(tonemap(im_hdr), sprintf('results/Q2_HDR/tonemapped_matlab/%s_%s_%s.jpg', WEIGHT_TYPE, FILE_TYPE, MERGE_TYPE));
save(sprintf('results/Q2_HDR/hdr_raw/%s_%s_%s.mat', WEIGHT_TYPE, FILE_TYPE, MERGE_TYPE), 'im_hdr');
hdrwrite(im_hdr, sprintf('results/Q2_HDR/hdr_images/%s_%s_%s.hdr', WEIGHT_TYPE, FILE_TYPE, MERGE_TYPE));
end