function result = get_pyramid_image(pyramid, index)
    im_size = size(pyramid);
    im_size = im_size(1);
    
    sum_width = 0;
    width = im_size;
    for i=1:index - 1
        sum_width = sum_width + width;
        width = width / 2;
    end
    
    result = pyramid(1:width, sum_width + 1:sum_width + width, :);    
end