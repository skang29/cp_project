clear; clc; % close all;
%% Q1. Linearize rendered images (25 pts.)
% Parameters
NUM_IMAGES = 16;

WEIGHT_TYPE = 'uniform';
lambda = 1000;

% Running codes
tic
Zmax = 0.99; Zmin=0.01;
Zmax_uint8 = floor(Zmax * 255);
Zmin_uint8 = ceil(Zmin * 255);
Zrange = Zmax_uint8 - Zmin_uint8 + 1;
fprintf('Reading images ... ');
exposure_stack = {};
for i=1:NUM_IMAGES
    image = imread(sprintf('exposure_stack/exposure%d.jpg', i));
    % Image sampling
    image = imresize(image, 0.1);
    image(image < Zmin_uint8) = Zmin_uint8;
    image(image > Zmax_uint8) = Zmax_uint8;
    exposure_stack(i, :) = {image};
end 
fprintf('Done !  ');
toc

% Declaration of weight of pixel values
w = zeros(256,1);
fprintf(sprintf('Weighting WEIGHT_TYPE: %s\n', WEIGHT_TYPE));
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

% LMS Solver
fprintf('Creating LMS solver matrices ... \n');
[imh, imw, imc] = size(exposure_stack{1});
N = imh * imw;
im2var = zeros(imh, imw);
im2var(1:imh * imw) = imh * imw;

g_stack = cell(3, 1);

for idx_c=1:imc
    fprintf('\tProcessing channel %d.\n', idx_c);
    
    % Declaration of matrix b
    b = zeros(N * NUM_IMAGES + Zrange + 1, 1, 'double');
    
    % Creating matrices
    Ai = cell(NUM_IMAGES + 1, 1);
    Aj = cell(NUM_IMAGES + 1, 1);
    Aval = cell(NUM_IMAGES + 1, 1);
    Bval = cell(NUM_IMAGES + 1, 1);
    
    parfor idx_im=1:NUM_IMAGES
        fprintf('\t\t  Processing image %d.\n', idx_im);
        exposure_value = log(power(2, idx_im - 1) / 2048);
        current_image = exposure_stack{idx_im}(:, :, idx_c);
        e_iter = (idx_im - 1) * N;
        Ai_val = zeros(2 * N, 1);
        Aj_val = zeros(2 * N, 1);
        Aval_val = zeros(2 * N, 1);
        Bval_val = zeros(N, 1);
        for idx_N=1:N
            e_iter = e_iter + 1;
            z = current_image(idx_N);
            weight_value = w(z+1);

            Ai_val(idx_N * 2 - 1) = e_iter;
            Aj_val(idx_N * 2 - 1) = z+1-Zmin_uint8;
            Aval_val(idx_N * 2 - 1) = weight_value;

            Ai_val(idx_N * 2) = e_iter;
            Aj_val(idx_N * 2) = Zrange + idx_N;
            Aval_val(idx_N * 2) = -weight_value;

            Bval_val(idx_N) = exposure_value * weight_value;
        end

        Ai{idx_im} = Ai_val;
        Aj{idx_im} = Aj_val;
        Aval{idx_im} = Aval_val;
        Bval{idx_im} = Bval_val;
    end
    
    Ai_val = zeros(Zrange + 1, 1);
    Aj_val = zeros(Zrange + 1, 1);
    Aval_val = zeros(Zrange + 1, 1);
    Bval_val = zeros(Zrange + 1, 1);
    
    fprintf('\t\tProcessing Laplacian term.\n');
    % Laplacian term
    e = NUM_IMAGES * N;
    index_counter = 1;
    
    % Max-1 pixel value to 0
    e = e + 1;
    Ai_val(index_counter, 1) = e;
    Aj_val(index_counter, 1) = Zrange - 1;
    Aval_val(index_counter, 1) = 1;
    index_counter = index_counter + 1;
    
    % Gradient edge front
    e = e + 1;
    Ai_val(index_counter, 1) = e;
    Aj_val(index_counter, 1) = 1;
    Aval_val(index_counter, 1) = - w(Zmin_uint8) * lambda;
    index_counter = index_counter + 1;
    
    Ai_val(index_counter, 1) = e;
    Aj_val(index_counter, 1) = 2;
    Aval_val(index_counter, 1) = w(Zmin_uint8) * lambda;
    index_counter = index_counter + 1;
    
    % Gradient edge rear
    e = e + 1;
    Ai_val(index_counter, 1) = e;
    Aj_val(index_counter, 1) = Zrange;
    Aval_val(index_counter, 1) = - w(Zmax_uint8) * lambda;
    index_counter = index_counter + 1;
    
    Ai_val(index_counter, 1) = e;
    Aj_val(index_counter, 1) = Zrange - 1;
    Aval_val(index_counter, 1) = w(Zmax_uint8) * lambda;
    index_counter = index_counter + 1;
    
    % Laplacian
    for idx=1:Zrange-2
        e = e + 1;
        weight_value = w(idx+1) * lambda;
        
        Ai_val(index_counter, 1) = e;
        Aj_val(index_counter, 1) = idx;
        Aval_val(index_counter, 1) = weight_value;
        index_counter = index_counter + 1;
        
        Ai_val(index_counter, 1) = e;
        Aj_val(index_counter, 1) = idx + 1;
        Aval_val(index_counter, 1) = -2 * weight_value;
        index_counter = index_counter + 1;
        
        Ai_val(index_counter, 1) = e;
        Aj_val(index_counter, 1) = idx + 2;
        Aval_val(index_counter, 1) = weight_value;
        index_counter = index_counter + 1;
    end
    
    Ai{NUM_IMAGES + 1} = Ai_val;
    Aj{NUM_IMAGES + 1} = Aj_val;
    Aval{NUM_IMAGES + 1} = Aval_val;
    Bval{NUM_IMAGES + 1} = Bval_val;
    
    Ai = vertcat(Ai{:});
    Aj = vertcat(Aj{:});
    Aval = vertcat(Aval{:});
    b = vertcat(Bval{:});
    fprintf('\t\tDone !'); toc
    
    fprintf('\t\tCreating sparse matrix. \n');
    %   A: Transform matrix
    %      Shape of matrix: [N x NUM_IMAGES + (256-2), 256 + N]
    %      # of non-zero  : (N x NUM_IMAGES) x 2, 254 x 3
    A = sparse(Ai, Aj, Aval, N * NUM_IMAGES + Zrange + 1, N + Zrange, N * NUM_IMAGES * 2 + Zrange * 3);
    fprintf('\t\tSolving LMS problem ... ');
    v = A \ b;

    g_stack{idx_c} = [v(1:Zrange-1); v(Zrange-1)];

    fprintf('Done !'); toc
end

figure(1);
subplot(1, 2, 1);
plot(Zmin_uint8:Zmax_uint8, g_stack{1}(1:Zrange), 'color', 'red')
hold on;
plot(Zmin_uint8:Zmax_uint8, g_stack{2}(1:Zrange), 'color', 'green')
plot(Zmin_uint8:Zmax_uint8, g_stack{3}(1:Zrange), 'color', 'blue')
axis([Zmin_uint8 Zmax_uint8 -inf inf])
hold off;
title(sprintf('Approximated G curve(Weight: %s)', WEIGHT_TYPE));

subplot(1, 2, 2);
plot(Zmin_uint8:Zmax_uint8, exp(g_stack{1}(1:Zrange)), 'color', 'red')
hold on;
plot(Zmin_uint8:Zmax_uint8, exp(g_stack{2}(1:Zrange)), 'color', 'green')
plot(Zmin_uint8:Zmax_uint8, exp(g_stack{3}(1:Zrange)), 'color', 'blue')
axis([Zmin_uint8 Zmax_uint8 -inf inf])
hold off;
title(sprintf('Approximated exp(G) curve(Weight: %s)', WEIGHT_TYPE));

fprintf('Done !  ');
toc

% Recovering linear images
fprintf('Recovering linear images ... ');

modified_g_stack = cell(3, 1);
for i=1:imc
    front = zeros(Zmin_uint8, 1);
    rear = ones(255 - Zmax_uint8, 1);
    modified_g_stack{i} = [front ; g_stack{i}; rear];
end

fprintf('\tReading images ... ');
exposure_stack = {};
for i=1:NUM_IMAGES
    image = imread(sprintf('exposure_stack/exposure%d.jpg', i));
    image = imresize(image, 0.2);
%     image(image < Zmin_uint8) = Zmin_uint8;
%     image(image > Zmax_uint8) = Zmax_uint8;
    exposure_stack(i, :) = {image};
end
[imh, imw, imc] = size(exposure_stack{1});
fprintf('Done !  '); toc

fprintf('\tMapping images ... \n');
image_stack = {};
parfor idx_im=1:NUM_IMAGES
    fprintf('\t  Processing image %d.\n', idx_im);
    current_image = exposure_stack{idx_im};
    im = zeros(imh, imw, imc);
    for idx_h=1:imh
        for idx_w=1:imw
            for idx_c=1:imc
                Zvalue = current_image(idx_h, idx_w, idx_c);
                im(idx_h, idx_w, idx_c) = exp(modified_g_stack{idx_c}(Zvalue+1));
            end
        end
    end
    image_stack(idx_im, :) = {im};
end
fprintf('Done !  '); toc

fprintf('\tSaving images ... ');
for idx_im=1:NUM_IMAGES
    if(~exist(sprintf('results/Q1_Linearization/linearized/%s', WEIGHT_TYPE), 'dir'))
        mkdir(sprintf('results/Q1_Linearization/linearized/%s', WEIGHT_TYPE));
    end
    im = image_stack{idx_im};
    save(sprintf('results/Q1_Linearization/linearized/%s/exposure%d.mat', WEIGHT_TYPE, idx_im), 'im');
end

fprintf('Done !  '); toc
fprintf('All process ended.\n');

