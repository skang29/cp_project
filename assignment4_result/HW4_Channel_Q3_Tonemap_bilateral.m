clear; clc; % close all;
%% Q3. bilateral tonemapping (30 pts.)
% Parameters
S_rgb = 0.15;
sigma_spatial_rgb = 1;
sigma_intensity_rgb = 0.1;
kernel_size_rgb = 5;

S_xyY = 0.17;
sigma_spatial_xyY = 1;
sigma_intensity_xyY = 0.1;
kernel_size_xyY = 5;

epsilon = 1e-6;

% Running codes
% Reading images
tic

fprintf('Reading images ... ');
matfile = load(sprintf('results/Q2_HDR/hdr_raw/%s_%s_%s.mat', 'gaussian', 'raw', 'logarithmic'));
HDR_image_rgb = matfile.im_hdr;
[imh, imw, imc] = size(HDR_image_rgb);

HDR_image_xyz = rgb2xyz(HDR_image_rgb, 'ColorSpace', 'linear-rgb');
cfrom_xyz2xyY = makecform('xyz2xyl');
cfrom_xyY2xyz = makecform('xyl2xyz');
HDR_image_xyY = applycform(HDR_image_xyz, cfrom_xyz2xyY);

L = log(HDR_image_rgb+epsilon);
L_rerange = L - min(min(min(L)));
denominator = max(max(max(L_rerange)));
L_rerange = L_rerange / denominator;
B_rerange = bfilter2(L_rerange, kernel_size_rgb, [sigma_spatial_rgb sigma_intensity_rgb]);
B = B_rerange * denominator +  min(min(min(L)));
D = L - B;
B_prime = S_rgb * (B - max(max(max(B))));
I_recon_rgb = exp(B_prime + D);



L = log(HDR_image_xyY(:, :, 3)+epsilon);
L_rerange = L - min(min(min(L)));
denominator = max(max(max(L_rerange)));
L_rerange = L_rerange / denominator;
B_rerange = bfilter2(L_rerange, kernel_size_xyY, [sigma_spatial_xyY sigma_intensity_xyY]);
B = B_rerange * denominator +  min(min(min(L)));
D = L - B;
B_prime = S_xyY * (B - max(max(max(B))));
I_recon_xyY = HDR_image_xyY;
I_recon_xyY(:, :, 3) = exp(B_prime + D);
I_recon_xyY = applycform(I_recon_xyY, cfrom_xyY2xyz);
I_recon_xyY = xyz2rgb(I_recon_xyY, 'ColorSpace', 'linear-rgb');

figure(1);
subplot(1, 3, 1);
imshow(HDR_image_rgb);
title('Raw HDR image');

subplot(1, 3, 2);
imshow(I_recon_rgb);
title('Bilateral tonemap RGB');

subplot(1, 3, 3);
imshow(I_recon_xyY);
title('Bilateral tonemap xyY');

imwrite(I_recon_rgb, 'results/Q3_tonemap/bilateral_rgb.png');
imwrite(I_recon_xyY, 'results/Q3_tonemap/bilateral_xyY.png');