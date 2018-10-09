function result = laplacian_pyramid(img, level, sigma)
    % Shape estimation
    im_size = size(img);
    im_size = im_size(1);
    
    width = 0;
    for i=1:level
        width = width + im_size / power(2, i - 1);
    end
    
    % Result pre-allocation
    result = ones(im_size, width, 3) * 0.5;

    original_image = img;
    width_index = 1;    
    for i=1:level-1
        % Gaussian, Downsampling
        filtered_image = imgaussfilt(original_image, sigma);
        downsampled_image = imresize(filtered_image, 0.5, 'Antialiasing', false);
        
        % Upsampling
        upsampled_image = imresize(downsampled_image, 2, 'Antialiasing', false);
        
        % Residual image        
        residual_image = original_image - upsampled_image;
        
        c_size = size(residual_image);
        c_size = c_size(1);

        result(1:c_size, width_index:width_index + c_size - 1, :) = residual_image;
        
        width_index = width_index + c_size;
        original_image = downsampled_image;
    end

    c_size = size(original_image);
    c_size = c_size(1);
    result(1:c_size, width_index:width_index + c_size - 1, :) = original_image;
end
