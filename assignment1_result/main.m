close all;
clc; clear;
im1 = imread('data/banana_slug.tiff');

%figure;
%imshow(im1(1:1000, 1:2000));
%title('banana_slug.tiff');

%% Question 1. Initials(5pts)
% As the image is represented using Bayer Pattern,
% original image size is [im1, im2]
imSize = size(im1);
disp('Image information');
fprintf('Image size: %d x %d\n', imSize(1), imSize(2));
fprintf('Datatype: uint16\n');

% Convert image into double precision array
im1 = cast(im1, 'double');

%% Question 2. Linearization (5pts)
% Convert im1 to range(0, 1)
im1 = (im1 - 2047) / (15000 - 2047);

disp('Linearization');
im1Max = max(max(im1));
im1Min = min(min(im1));
fprintf('Max: %.5f\n', im1Max);
fprintf('Min: %.5f\n', im1Min);

% Clipping
disp('Clipping');
im1(im1 > 1) = 1;
im1(im1 < 0) = 0;
im1Max = max(max(im1));
im1Min = min(min(im1));
fprintf('Max: %.5f\n', im1Max);
fprintf('Min: %.5f\n', im1Min);

%% Question 3. Identifying the correct Bayer Pattern (20pts)
% Let's assume 2 by 2 Bayer Pattern to 1 pixel.
% To implement pseudo white balance, I divided every channel by max walue
% of each channel.
figure;
% Pattern if grbg
subplot(2, 2, 1);
red = [1 2]; green = [1 1]; blue = [2 1]; 
r = im1(red(1):2:end, red(2):2:end);
g = im1(green(1):2:end, green(2):2:end);
b = im1(blue(1):2:end, blue(2):2:end);
im_rgb = cat(3, r / max(max(r)), g/ max(max(g)), b/ max(max(b)));
imshow(min(1, im_rgb * 5));
title('GRBG');

% Pattern if rggb
subplot(2, 2, 2);
red = [1 1]; green = [2 1]; blue = [2 2];
r = im1(red(1):2:end, red(2):2:end);
g = im1(green(1):2:end, green(2):2:end);
b = im1(blue(1):2:end, blue(2):2:end);
im_rgb = cat(3, r / max(max(r)), g/ max(max(g)), b/ max(max(b)));
imshow(min(1, im_rgb * 5));
title('RGGB');

% Pattern if bggr
subplot(2, 2, 3);
red = [2 2]; green = [1 2]; blue = [1 1];
r = im1(red(1):2:end, red(2):2:end);
g = im1(green(1):2:end, green(2):2:end);
b = im1(blue(1):2:end, blue(2):2:end);
im_rgb = cat(3, r / max(max(r)), g/ max(max(g)), b/ max(max(b)));
imshow(min(1, im_rgb * 5));
title('BGGR');

% Pattern if gbrg
subplot(2, 2, 4);
red = [2 1]; green = [1 1]; blue = [1 2];
r = im1(red(1):2:end, red(2):2:end);
g = im1(green(1):2:end, green(2):2:end);
b = im1(blue(1):2:end, blue(2):2:end);
im_rgb = cat(3, r / max(max(r)), g/ max(max(g)), b/ max(max(b)));
imshow(min(1, im_rgb * 5));
title('GBRG');

disp('Correct Bayer Pattern: RGGB');

% Pattern if rggb
red = [1 1]; green_1 = [2 1]; green_2 = [1 2]; blue = [2 2];
r = im1(red(1):2:end, red(2):2:end);
g1 = im1(green_1(1):2:end, green_1(2):2:end);
g2 = im1(green_2(1):2:end, green_2(2):2:end);
b = im1(blue(1):2:end, blue(2):2:end);

%% Question 4. White balancing (20pts)
figure;
im_rgb = cat(3, r, (g1 + g2) / 2, b);
subplot(2, 3, 2);
imshow(im_rgb);
title('Original');
subplot(2, 3, 5);
imshow(min(1, im_rgb * 5));

disp('White world assumption');
r = r / max(max(r));
g1 = g1 / max(max(max(g1)), max(max(g2)));
g2 = g2 / max(max(max(g1)), max(max(g2)));
b = b / max(max(b));
im_rgb = cat(3, r, (g1 + g2) / 2, b);
subplot(2, 3, 1);
imshow(im_rgb);
title('White World Assumption');
subplot(2, 3, 4);
imshow(min(1, im_rgb * 5));

disp('Gray world assumption');
r_avg = mean(mean(r));
g_avg = (mean(mean(g1)) + mean(mean(g2))) / 2;
b_avg = mean(mean(b));

r = r / r_avg * g_avg;
b = b / b_avg * g_avg;
im_rgb = cat(3, r, (g1 + g2) / 2, b);
subplot(2, 3, 3);
imshow(im_rgb);
title('Gray World Assumption');
subplot(2, 3, 6);
imshow(min(1, im_rgb * 5));

%% Question 5. Demosaicing (25pts)
interp_r = interp2(r, 1);
interp_g = interp2((g1+g2)/2, 1);
interp_b = interp2(b, 1);

im_rgb = cat(3, interp_r, interp_g, interp_b);
figure;
imshow(im_rgb);
title('Demosaicing');

%% Question 6. Brightness adjustment and gamma correction (20pts)
figure;
max_gray = max(max(rgb2gray(im_rgb)));
for i=0:8
    % Bright adjustment
    im_bright_adj = im_rgb * (1 + i * 0.01);
    adj_max_gray = max(max(rgb2gray(im_bright_adj)));
    
    % Gamma correction
    temp = (1 + 0.055) * power(im_bright_adj, 1/2.4) - 0.055;
    im_bright_adj(im_bright_adj >= 0.0031308) = temp(im_bright_adj >= 0.0031308);
    temp = 12.92 * im_bright_adj;
    im_bright_adj(im_bright_adj < 0.0031308) = temp(im_bright_adj < 0.0031308);
    
    subplot(3, 3, i+1);
    imshow(im_bright_adj);
    title(sprintf('Bright: %.2f%%', adj_max_gray / max_gray * 100));
end

%% Question 7. Compression (5pts)

imwrite(im_bright_adj, 'result_png.png');
imwrite(im_bright_adj, 'result_jpg.jpg', 'jpg', 'Quality', 95);
disp(imfinfo('result_png.png'));
disp(imfinfo('result_jpg.jpg'));

