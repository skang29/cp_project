%% Q1. Toy problem (20 pts)
disp('Q1. Toy problem (20 pts) ...');
tic
toy_image = imread('data/toy_problem.png');
toy_image = im2double(toy_image);
[image_height, image_width] = size(toy_image);

im2var = zeros(image_height, image_width);
im2var(1:image_height * image_width) = 1:image_height * image_width;

figure(1);
subplot(2, 2, 1);
imshow(toy_image);
title('Input image');

% Matrices
H_ = image_height; W_ = image_width;
% Av - b
% A: Transform matrix[H x W x 2, H x W]      
% Number of non-zeros: 5 per each pixels
A = sparse([], [], [], H_ * W_ * 2, H_ * W_, H_ * W_ * 5);

% v: Target image [H x W]  
v = zeros(H_ * W_, 1);
    
% b: Gradients of x and y direction and a pixel [H x W x 2]
grad_h = zeros(size(toy_image), 'double');
grad_w = zeros(size(toy_image), 'double');

grad_h(2:end, :) = toy_image(2:end, :) - toy_image(1:end-1, :);
grad_w(:, 2:end) = toy_image(:, 2:end) - toy_image(:, 1:end-1);

figure(1);
subplot(2, 2, 3);
imshow(grad_h, [-1 1]);
title('Gradient (H direction)');
subplot(2, 2, 4);
imshow(grad_w, [-1 1]);
title('Gradient (W direction)');

b = zeros(H_ * W_ * 2, 1, 'double');

e = 1;
% Objective for 1st pixel
A(e, im2var(1, 1)) = 1;
b(e) = toy_image(1, 1);
e = e + 1;
A(e, im2var(1, 1)) = 1;
b(e) = toy_image(1, 1);

% Objective for grad h
for h=1:H_-1
    for w=1:W_
        e = e + 1;
        A(e, im2var(h+1, w)) = 1;
        A(e, im2var(h, w)) = -1;
        b(e) = grad_h(im2var(h+1, w));
    end
end

% Objective for grad w
for h=1:H_
    for w=1:W_-1
        e = e + 1;
        A(e, im2var(h, w+1)) = 1;
        A(e, im2var(h, w)) = -1;
        b(e) = grad_w(im2var(h, w+1));
    end
end

% Solve using MATLAB solver
v = A \ b;

reconstructed_image = reshape(v, [H_ W_]);
figure(1);
subplot(2, 2, 2);
imshow(reconstructed_image);
title('Reconstructed image');

reconstruction_error = sum(sum(abs(toy_image - reconstructed_image)));
disp('>> Reconstruction error:');
disp(reconstruction_error);

clearvars H_ W_;
toc
fprintf('Done !\n\n');