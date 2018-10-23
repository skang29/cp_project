clear; clc; close all;
%% Q2. Poisson blending (50 pts)
disp('Q2. Poisson blending (50 pts) ...');
tic

% Read image
% Target image
X_target = imread('data/hiking.jpg');
X_target = im2double(X_target);

figure(1);
[X, N_, N_] = imread('data/preprocessed/penguin_original.png');
[N_, N_, alpha] = imread('data/preprocessed/penguin.png');
[imh, imw, imc] = size(X);
X_penguin = im2double(X);
M_penguin = zeros([imh imw]);
M_penguin(alpha > 0) = 1;

subplot(2, 2, 1);
imshow(X_penguin);
title('Image(penguin)');

subplot(2, 2, 3);
imshow(M_penguin);
title('Mask(penguin)');

[X, N_, N_] = imread('data/preprocessed/chick_original.png');
[N_, N_, alpha] = imread('data/preprocessed/chick.png');
[imh, imw, imc] = size(X);
X_chick = im2double(X);
M_chick = zeros([imh imw]);
M_chick(alpha > 0) = 1;

subplot(2, 2, 2);
imshow(X_chick);
title('Image(chick)');

subplot(2, 2, 4);
imshow(M_chick);
title('Mask(chick)');

figure(2);
subplot(2, 2, 1);
imshow(X_target);
title('Target image');

copy_and_paste = X_target;
temp_mask = repmat(M_penguin, [1 1 imc]);
copy_and_paste(temp_mask > 0) = X_penguin(temp_mask > 0);
temp_mask = repmat(M_chick, [1 1 3]);
copy_and_paste(temp_mask > 0) = X_chick(temp_mask > 0);
subplot(2, 2, 2);
imshow(copy_and_paste);
title('Copy and paste');
toc

% Blending
% To reduce process complexity, crop processing area to sub image.
bbox_chick = [1554 844; 1848 1078];
bbox_penguin = [1308 2494; 1617 2725];
subplot(2, 2, 3);
imshow(copy_and_paste);
hold on;
rectangle('Position',[bbox_penguin(1, 2) bbox_penguin(1, 1) ...
                      bbox_penguin(2, 2) - bbox_penguin(1, 2) ...
                      bbox_penguin(2, 1) - bbox_penguin(1, 1)],...
          'Curvature',[0, 0],...
         'LineWidth',2,'LineStyle','-', 'EdgeColor', 'red');
title('Bbox(penguin)');
hold off;

subplot(2, 2, 4);
imshow(copy_and_paste);
hold on;
rectangle('Position',[bbox_chick(1, 2) bbox_chick(1, 1) ...
                      bbox_chick(2, 2) - bbox_chick(1, 2) ...
                      bbox_chick(2, 1) - bbox_chick(1, 1)],...
          'Curvature',[0, 0],...
         'LineWidth',2,'LineStyle','-', 'EdgeColor', 'red');
title('Bbox(chick)');
hold off;

% Penguin blending
crop_cp = copy_and_paste(bbox_penguin(1, 1):bbox_penguin(2, 1), ...
                       bbox_penguin(1, 2):bbox_penguin(2, 2), :);
crop_target = X_target(bbox_penguin(1, 1):bbox_penguin(2, 1), ...
                       bbox_penguin(1, 2):bbox_penguin(2, 2), :);
crop_mask = M_penguin(bbox_penguin(1, 1):bbox_penguin(2, 1), ...
                       bbox_penguin(1, 2):bbox_penguin(2, 2));
temp_mask = repmat(crop_mask, [1 1 imc]);
crop_source = X_penguin(bbox_penguin(1, 1):bbox_penguin(2, 1), ...
                       bbox_penguin(1, 2):bbox_penguin(2, 2), :);

figure(3);
subplot(2, 2, 1);
imshow(crop_target);
title('Target cropped');

subplot(2, 2, 2);
imshow(crop_source);
title('Source cropped');

subplot(2, 2, 3);
imshow(crop_cp);
title('CP cropped');

result_penguin = poisson_blending(X_target, X_penguin, M_penguin, bbox_penguin);

subplot(2, 2, 4);
imshow(result_penguin);
title('Blended cropped');

% Chick blending
crop_cp = copy_and_paste(bbox_chick(1, 1):bbox_chick(2, 1), ...
                       bbox_chick(1, 2):bbox_chick(2, 2), :);
crop_target = X_target(bbox_chick(1, 1):bbox_chick(2, 1), ...
                       bbox_chick(1, 2):bbox_chick(2, 2), :);
crop_mask = M_chick(bbox_chick(1, 1):bbox_chick(2, 1), ...
                       bbox_chick(1, 2):bbox_chick(2, 2));
temp_mask = repmat(crop_mask, [1 1 imc]);
crop_source = X_chick(bbox_chick(1, 1):bbox_chick(2, 1), ...
                       bbox_chick(1, 2):bbox_chick(2, 2), :);

figure(4);
subplot(2, 2, 1);
imshow(crop_target);
title('Target cropped');

subplot(2, 2, 2);
imshow(crop_source);
title('Source cropped');

subplot(2, 2, 3);
imshow(crop_cp);
title('CP cropped');

result_chick = poisson_blending(X_target, X_chick, M_chick, bbox_chick);

subplot(2, 2, 4);
imshow(result_chick);
title('Blended cropped');


result_image = X_target;


result_image(bbox_chick(1, 1):bbox_chick(2, 1)-1, ...
                       bbox_chick(1, 2):bbox_chick(2, 2)-1, :) = ...
             result_chick(1:end-1, 1:end-1, :);
result_image(bbox_penguin(1, 1):bbox_penguin(2, 1)-1, ...
                       bbox_penguin(1, 2):bbox_penguin(2, 2)-1, :) = ...
             result_penguin(1:end-1, 1:end-1, :); 

figure(5);
subplot(1, 3, 1);
imshow(X_target);
title('Target image');

subplot(1, 3, 2);
imshow(copy_and_paste);
title('CP image');

subplot(1, 3, 3);
imshow(result_image);
title('Blended image');

imwrite(copy_and_paste, 'Q2_cp_image.png')
imwrite(result_image, 'Q2_blended_image.png')

toc
fprintf('Done !\n\n');
