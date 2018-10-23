clear; clc; close all;
%% Q3. Mixed gradient blending (10 pts)
disp('Q3. Mixed gradient blending (10 pts) ...');
tic

% Read image
% Target image
X_target = imread('data/hiking.jpg');
X_target = im2double(X_target);

[X, N_, N_] = imread('data/preprocessed/penguin_original.png');
[N_, N_, alpha] = imread('data/preprocessed/penguin.png');
[imh, imw, imc] = size(X);
X_penguin = im2double(X);
M_penguin = zeros([imh imw]);
M_penguin(alpha > 0) = 1;


[X, N_, N_] = imread('data/preprocessed/chick_original.png');
[N_, N_, alpha] = imread('data/preprocessed/chick.png');
[imh, imw, imc] = size(X);
X_chick = im2double(X);
M_chick = zeros([imh imw]);
M_chick(alpha > 0) = 1;

% Blending
% To reduce process complexity, crop processing area to sub image.
bbox_chick = [1554 844; 1848 1078];
bbox_penguin = [1308 2494; 1617 2725];

% Penguin blending
% result_penguin_poisson = poisson_blending(X_target, X_penguin, M_penguin, bbox_penguin);
result_penguin_mixedg = mixed_gradient_blending(X_target, X_penguin, M_penguin, bbox_penguin);

% Chick blending
% result_chick_poisson = poisson_blending(X_target, X_chick, M_chick, bbox_chick);
result_chick_mixedg = mixed_gradient_blending(X_target, X_chick, M_chick, bbox_chick);

% result_image_poisson = X_target;
% 
% result_image_poisson(bbox_chick(1, 1):bbox_chick(2, 1)-1, ...
%                        bbox_chick(1, 2):bbox_chick(2, 2)-1, :) = ...
%              result_chick_poisson(1:end-1, 1:end-1, :);
% result_image_poisson(bbox_penguin(1, 1):bbox_penguin(2, 1)-1, ...
%                        bbox_penguin(1, 2):bbox_penguin(2, 2)-1, :) = ...
%              result_penguin_poisson(1:end-1, 1:end-1, :); 

         
result_image_mixedg = X_target;

result_image_mixedg(bbox_chick(1, 1):bbox_chick(2, 1)-1, ...
                       bbox_chick(1, 2):bbox_chick(2, 2)-1, :) = ...
             result_chick_mixedg(1:end-1, 1:end-1, :);
result_image_mixedg(bbox_penguin(1, 1):bbox_penguin(2, 1)-1, ...
                       bbox_penguin(1, 2):bbox_penguin(2, 2)-1, :) = ...
             result_penguin_mixedg(1:end-1, 1:end-1, :); 

result_image_poisson = imread('results/Q2/Q2_blended_image.png');

figure(1);
subplot(2, 1, 1);
imshow(result_image_poisson);
title('Poisson blending');
         
subplot(2, 1, 2);
imshow(result_image_mixedg);
title('Mixed gradient blending');

imwrite(result_image_mixedg, 'Q3_mixed_gradient_blended_image.png');
imwrite(result_image_poisson, 'Q3_poisson_blended_image.png');

toc
fprintf('Done !\n\n');
