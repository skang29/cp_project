function result = reconstruct_from_laplacian_pyramid(pyramid, level)
    original_image = get_pyramid_image(pyramid, level);
    for i=1:level-1
        upsampled_image = imresize(original_image, 2, 'Antialiasing', false);
        residual_image = get_pyramid_image(pyramid, level - i);
        original_image = upsampled_image + residual_image;
    end
    
    result = original_image;
end