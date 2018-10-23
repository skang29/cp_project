clear; clc; close all;
addpath('blending_source_code');
%% Q4. Your own examples (20 pts)
disp('Q4. Your own examples (20 pts) ...');
tic
base_path = 'data/my_own/';

for i=1:3
    fileID = fopen(sprintf('%s%d/bbox.txt', base_path, i), 'r');
    formatSpec = '%d %d';
    bbox = fscanf(fileID, formatSpec, [2 2])';
    
    X_target = imread(sprintf('%s%d/background.png', base_path, i));
    X_target = im2double(X_target);
    
    [X, N_, N_] = imread(sprintf('%s%d/source.png', base_path, i));
    [N_, N_, alpha] = imread(sprintf('%s%d/mask.png', base_path, i));
    [imh, imw, imc] = size(X);
    X_source = im2double(X);
    M_source = zeros([imh imw]);
    M_source(alpha > 0) = 1;
    
    result_poisson = poisson_blending(X_target, X_source, M_source, bbox);
    result_mixedg = mixed_gradient_blending(X_target, X_source, M_source, bbox);
    
    result_image_poisson = X_target;
    result_image_mixedg = X_target;
    
    result_image_poisson(bbox(1, 1):bbox(2, 1)-1, ...
                       bbox(1, 2):bbox(2, 2)-1, :) = ...
             result_poisson(1:end-1, 1:end-1, :);
    
    result_image_mixedg(bbox(1, 1):bbox(2, 1)-1, ...
                       bbox(1, 2):bbox(2, 2)-1, :) = ...
             result_mixedg(1:end-1, 1:end-1, :);
         
    imwrite(result_image_poisson, sprintf('results/Q4/%d/%d_poisson.png', i, i));
    imwrite(result_image_mixedg, sprintf('results/Q4/%d/%d_mixed_gradient.png', i, i));
    
    figure;
    subplot(2, 2, 1);
    imshow(X_target);
    title('Target');
    
    subplot(2, 2, 2);
    imshow(X_source);
    title('Source');
    
    subplot(2, 2, 3);
    imshow(result_image_poisson);
    title('Poisson blending');
    
    subplot(2, 2, 4);
    imshow(result_image_poisson);
    title('Mixed gradient blending');
end


toc
fprintf('Done !\n\n');