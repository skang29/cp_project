clear; clc; % close all;
%% Q3. Photographic tonemapping (30 pts.)
% Parameters
K_p = 0.8;
B_p = 0.9;

K_y = 0.2;
B_y = 0.9;

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

tonemapped_rgb = zeros(imh, imw, imc);
tonemapped_rgb(:, :, 1) = tonemap_channel(K_p, B_p, HDR_image_rgb(:, :, 1));
tonemapped_rgb(:, :, 2) = tonemap_channel(K_p, B_p, HDR_image_rgb(:, :, 2));
tonemapped_rgb(:, :, 3) = tonemap_channel(K_p, B_p, HDR_image_rgb(:, :, 3));

tonemapped_xyY = zeros(imh, imw, imc);
tonemapped_xyY(:, :, 1) = HDR_image_xyY(:, :, 1);
tonemapped_xyY(:, :, 2) = HDR_image_xyY(:, :, 2);
tonemapped_xyY(:, :, 3) = tonemap_channel(K_y, B_y, HDR_image_xyY(:, :, 3));

tonemapped_xyY = applycform(tonemapped_xyY, cfrom_xyY2xyz);
tonemapped_xyY = xyz2rgb(tonemapped_xyY);


figure(1);
subplot(1, 3, 1);
imshow(HDR_image_rgb);
title('Raw HDR image');

subplot(1, 3, 2);
imshow(tonemapped_rgb);
title('Photographic RGB tonemap');

subplot(1, 3, 3);
imshow(tonemapped_xyY);
title('Photographic xyY tonemap');

imwrite(tonemapped_rgb, 'results/Q3_tonemap/photo_rgb.png');
imwrite(tonemapped_xyY, 'results/Q3_tonemap/photo_xyY.png');