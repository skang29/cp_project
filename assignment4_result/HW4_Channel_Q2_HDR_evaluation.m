clear; clc; close all;
%% Q2. Evaluation of HDR (10 pts.)

UNIFORM = 1; TENT = 2; GAUSSIAN = 3;
LOGARITHMIC = 1; LINEAR = 2;
weight_type={'uniform', 'tent', 'gaussian'};
merge_type={'logarithmic', 'linear'};

image_stack = cell(3, 2);

position = [770 126  750 143;
            772 156  752 178;
            775 188  753 208;
            775 220  755 238;
            775 250  756 272;
            778 284  758 304];

for idx_weight=1:3
    for idx_merge=1:2
        matfile = load(sprintf('results/Q2_HDR/hdr_raw/%s_raw_%s.mat', weight_type{idx_weight}, merge_type{idx_merge}));
        im = matfile.im_hdr;
        
        im = rgb2xyz(im, 'ColorSpace', 'linear-rgb');
        image_stack{idx_weight, idx_merge} = im;
    end
end

intensity = zeros(3, 2, 6);

% Linear regression
e = 0;
figure;
for idx_weight=1:3
    for idx_merge=1:2
        e = e + 1;
        X = ones(6, 2);
        y = zeros(6, 1);
        for i=1:6
            intensity(idx_weight, idx_merge, i) = log(mean(mean(mean(image_stack{idx_weight, idx_merge}(position(i, 2):position(i, 4), position(i, 3):position(i, 1), 2)))));
 
            y(i, 1) = intensity(idx_weight, idx_merge, i);
            X(i, 2) = i;
        end
        % Linear regression solver
        b = X \ y;
        yCalc = X * b;
        
        Rsq = 1 - sum((y - yCalc).^2) / sum((y - mean(y)).^2);
        
        subplot(3, 2, e);
        plot(X(:, 2), yCalc);
        hold on;
        scatter(X(:, 2), y);
        hold off;
        title(sprintf('%s %s(Rsq: %.5f)', weight_type{idx_weight}, merge_type{idx_merge}, Rsq));
    end
end

