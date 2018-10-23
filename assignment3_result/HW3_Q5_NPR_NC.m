clear; clc; close all;
%% Calculating gradients
image = imread('gradient_shop_data/human.png');
image = im2double(image);

u = image;
% ---------------------------------------------------
epsilon = 7e-2;
[imh, imw, imc] = size(image);

disp("Get gradients ...");
[Gx1, Gy1] = imgradientxy(image(:, :, 1), 'sobel');
[Gmag1, Gdir1] = imgradient(Gx1, Gy1);

[Gx2, Gy2] = imgradientxy(image(:, :, 2), 'sobel');
[Gmag2, Gdir2] = imgradient(Gx2, Gy2);

[Gx3, Gy3] = imgradientxy(image(:, :, 3), 'sobel');
[Gmag3, Gdir3] = imgradient(Gx3, Gy3);

Gmag = cat(3, Gmag1, Gmag2, Gmag3);
Gx = cat(3, Gx1, Gx2, Gx3);
Gy = cat(3, Gy1, Gy2, Gy3);

p_o = 90 - cat(3, Gdir1, Gdir2, Gdir3);
p_m = zeros(size(p_o));

figure;
subplot(1, 3, 1);
imshow(p_o, []);
title('Gradient orientation');
subplot(1, 3, 2);
imshow(p_m, []);
title('Normalized gradient magnitude');

for c=1:imc
    mu = conv2(Gmag(:, :, c), ones(5) / 25, 'same');
    sigma = stdfilt(Gmag(:, :, c), true(5));
    p_m(:, :, c) = (Gmag(:, :, c) - mu) ./ (sigma + epsilon);
end

% Input image gradients
u_h = Gy;
u_w = Gx;

% u_h = Gmag .* sin(pi / 180 * p_o);
% u_w = Gmag .* cos(pi / 180 * p_o);


disp("Done !");

%% Finding e_l, e_o
disp('Iterations ... ');

m_0 = zeros(size(image));
m_1 = zeros(size(image));

for iter=1:60
    fprintf("Iteration %d\n", iter);
   for h=1:imh
       for w=1:imw
           for c=1:imc
               center_h0 = round(h + sqrt(2) * cos(p_o(h, w, c) * pi / 180));
               center_w0 = round(w + sqrt(2) * sin(p_o(h, w, c) * pi / 180));
               center_h1 = round(h + sqrt(2) * cos(p_o(h, w, c) * pi / 180 + pi));
               center_w1 = round(w + sqrt(2) * sin(p_o(h, w, c) * pi / 180 + pi));
               temp_0 = 0;
               temp_1 = 0;
               for i_h=0:1
                   for i_w=0:1
                       q_h0 = max(min(imh, i_h + center_h0), 1);
                       q_w0 = max(min(imw, i_w + center_w0), 1);
                       q_h1 = max(min(imh, i_h + center_h1), 1);
                       q_w1 = max(min(imw, i_w + center_w1), 1);
                       temp_0 = temp_0 + 0.25 * exp(-power((p_o(h, w, c) - p_o(q_h0, q_w0, c)), 2)) / (2 * pi / 5) .* (m_0(q_h0, q_w0, c) + p_m(q_h0, q_w0, c));
                       temp_1 = temp_1 + 0.25 * exp(-power((p_o(h, w, c) - p_o(q_h1, q_w1, c)), 2)) / (2 * pi / 5) .* (m_1(q_h1, q_w1, c) + p_m(q_h1, q_w1, c));  
                   end
               end
               m_0(h, w, c) = temp_0;
               m_1(h, w, c) = temp_1;
           end
       end
   end
end

e_l = m_0 + m_1 + p_m;
e_o = p_o;

subplot(1, 3, 3);
imshow(e_l, []);
title('Long edge magnitude');

%% Non-photorealistic rendering
c1 = 1.9e-2;
c2 = 2;
sigma_npr = sqrt(pi / 10);

n_p = c2 * (1 - exp((e_l .* e_l) / (-2 * sigma_npr * sigma_npr)));

data = u;


g_h = u_h .* cos(e_o) .* cos(e_o) .* n_p;
g_w = u_w .* sin(e_o) .* sin(e_o) .* n_p;

H_ = imh; W_ = imw;
im2var = zeros(H_, W_);
im2var(1:H_ * W_) = 1:H_ * W_;

result = zeros(H_, W_, 3);

%% Defining A
disp('Creating matrix A');
A = sparse([], [], [], H_ * W_ * 3, H_ * W_, H_ * W_ * 6);

e = 0;
% Gradients for h direction
for h=1:H_ - 1
    for w=1:W_
        e = e + 1;
        A(e, im2var(h + 1, w)) = 1;
        A(e, im2var(h, w)) = -1;
    end
end

% Gradients for w direction
for h=1:H_
    for w=1:W_ - 1
        e = e + 1;
        A(e, im2var(h, w+1)) = 1;
        A(e, im2var(h, w)) = -1;
    end
end
%% Cut
% W initial condition
for h=1:H_
    e = e + 1;
    A(e, im2var(h, W_)) = 1;
    A(e, im2var(h, W_-1)) = -1;
end

% H initial condition
for w=1:W_
    e = e + 1;
    A(e, im2var(H_, w)) = 1;
    A(e, im2var(H_-1, w)) = -1;
end

% Data
for h=1:H_
    for w=1:W_
        e = e + 1;
        A(e, im2var(h, w)) = c1;
    end
end

%% Solver

for c=1:imc
    disp(['Creating matrices at channel ' num2str(c) ' ...']);
    % v: Target image [H x W] 
    v = zeros(H_ * W_, 1);
    
    % b: Gradients of x and y direction and a pixel [H x W x 2]
    b = zeros(H_ * W_ * 2, 1, 'double');
    
    e = 0;
    % Gradients for h direction
    for h=1:H_ - 1
        for w=1:W_
            e = e + 1;
            b(e) = g_h(h, w, c);
        end
    end
    % Gradients for w direction
    for h=1:H_
        for w=1:W_-1
            e = e + 1;
            b(e) = g_w(h, w, c);
        end
    end

    % W initial condition
    for h=1:H_
        e = e + 1;
        b(e) = g_w(h, W_, c);
    end

    % H initial condition
    for w=1:W_
        e = e + 1;
        b(e) = g_h(H_, w, c);
    end    
    
    % Data
    for h=1:H_
        for w=1:W_
            e = e + 1;
            b(e) = c1 * data(h, w, c);
        end
    end
    
    disp(['Start solving at channel ' num2str(c) ' ...']);
    v = A \ b;
    disp('Done !');
    
    result(:, :, c) = reshape(v, [H_ W_]);
end

figure;
subplot(1, 2, 1);
imshow(image);
title('Input');

subplot(1, 2, 2);
imshow(result);
title('NPR Result');

% ---------------------------------------------------