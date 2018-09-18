## Assignment 1
### Question 1. Initials(5pts)

```matlab
% As the image is represented using Bayer Pattern,
% original image size is [im1, im2]
imSize = size(im1);
disp("Image information");
fprintf("Image size: %d x %d\n", imSize(1), imSize(2));
fprintf("Datatype: uint16\n");

% Convert image into double precision array
im1 = cast(im1, 'double');
```

**Results**
```
Image information
Image size: 2856 x 4290
Datatype: uint16
```

### Question 2. Linearization (5pts)
```matlab
% Convert im1 to range(0, 1)
im1 = (im1 - 2047) / (15000 - 2047);

disp('Linearization');
im1Max = max(max(im1));
im1Min = min(min(im1));
fprintf('Max: %.5f\n', im1Max);
fprintf('Min: %.5f\n', im1Min);

% Clipping
disp('Clipping');
im1(im1 > 1) = 1;
im1(im1 < 0) = 0;
im1Max = max(max(im1));
im1Min = min(min(im1));
fprintf('Max: %.5f\n', im1Max);
fprintf('Min: %.5f\n', im1Min);
```

**Results**
```
Max: 1.00000
Min: 0.00000
```

### Question 3. Identifying the correct Bayer Pattern (20pts)
```matlab
% Let's assume 2 by 2 Bayer Pattern to 1 pixel.
% To implement pseudo white balance, I divided every channel by max walue
% of each channel.
figure;
% Pattern if grbg
subplot(2, 2, 1);
red = [1 2]; green = [1 1]; blue = [2 1]; 
r = im1(red(1):2:end, red(2):2:end);
g = im1(green(1):2:end, green(2):2:end);
b = im1(blue(1):2:end, blue(2):2:end);
im_rgb = cat(3, r / max(max(r)), g/ max(max(g)), b/ max(max(b)));
imshow(min(1, im_rgb * 5));
title('GRBG');

% Pattern if rggb
subplot(2, 2, 2);
red = [1 1]; green = [2 1]; blue = [2 2];
r = im1(red(1):2:end, red(2):2:end);
g = im1(green(1):2:end, green(2):2:end);
b = im1(blue(1):2:end, blue(2):2:end);
im_rgb = cat(3, r / max(max(r)), g/ max(max(g)), b/ max(max(b)));
imshow(min(1, im_rgb * 5));
title('RGGB');

% Pattern if bggr
subplot(2, 2, 3);
red = [2 2]; green = [1 2]; blue = [1 1];
r = im1(red(1):2:end, red(2):2:end);
g = im1(green(1):2:end, green(2):2:end);
b = im1(blue(1):2:end, blue(2):2:end);
im_rgb = cat(3, r / max(max(r)), g/ max(max(g)), b/ max(max(b)));
imshow(min(1, im_rgb * 5));
title('BGGR');

% Pattern if gbrg
subplot(2, 2, 4);
red = [2 1]; green = [1 1]; blue = [1 2];
r = im1(red(1):2:end, red(2):2:end);
g = im1(green(1):2:end, green(2):2:end);
b = im1(blue(1):2:end, blue(2):2:end);
im_rgb = cat(3, r / max(max(r)), g/ max(max(g)), b/ max(max(b)));
imshow(min(1, im_rgb * 5));
title('GBRG');

disp('Correct Bayer Pattern: RGGB');

% Pattern if rggb
red = [1 1]; green_1 = [2 1]; green_2 = [1 2]; blue = [2 2];
r = im1(red(1):2:end, red(2):2:end);
g1 = im1(green_1(1):2:end, green_1(2):2:end);
g2 = im1(green_2(1):2:end, green_2(2):2:end);
b = im1(blue(1):2:end, blue(2):2:end);
```


**Results**
```
Correct Bayer Pattern: RGGB
```
![Alt text](/assignment1_result/figure1.png)


### Question 4. White balancing (20pts)
```matlab
figure;
im_rgb = cat(3, r, (g1 + g2) / 2, b);
subplot(2, 3, 2);
imshow(im_rgb);
title('Original');
subplot(2, 3, 5);
imshow(min(1, im_rgb * 5));

disp('White world assumption');
r = r / max(max(r));
g1 = g1 / max(max(max(g1)), max(max(g2)));
g2 = g2 / max(max(max(g1)), max(max(g2)));
b = b / max(max(b));
im_rgb = cat(3, r, (g1 + g2) / 2, b);
subplot(2, 3, 1);
imshow(im_rgb);
title('White World Assumption');
subplot(2, 3, 4);
imshow(min(1, im_rgb * 5));

disp('Gray world assumption');
r_avg = mean(mean(r));
g_avg = (mean(mean(g1)) + mean(mean(g2))) / 2;
b_avg = mean(mean(b));

r = r / r_avg * g_avg;
b = b / b_avg * g_avg;
im_rgb = cat(3, r, (g1 + g2) / 2, b);
subplot(2, 3, 3);
imshow(im_rgb);
title('Gray World Assumption');
subplot(2, 3, 6);
imshow(min(1, im_rgb * 5));
```

**Results**
![Alt text](/assignment1_result/figure2.png)

### Question 5. Demosaicing (25pts)
```matlab
interp_r = interp2(r, 1);
interp_g = interp2((g1+g2)/2, 1);
interp_b = interp2(b, 1);

im_rgb = cat(3, interp_r, interp_g, interp_b);
figure;
imshow(im_rgb);
title('Demosaicing');
```

**Results**
![Alt text](/assignment1_result/figure3.png)

### Question 6. Brightness adjustment and gamma correction (20pts)
```matlab
figure;
max_gray = max(max(rgb2gray(im_rgb)));
for i=0:8
    % Bright adjustment
    im_bright_adj = im_rgb * (1 + i * 0.01);
    adj_max_gray = max(max(rgb2gray(im_bright_adj)));
    
    % Gamma correction
    temp = (1 + 0.055) * power(im_bright_adj, 1/2.4) - 0.055;
    im_bright_adj(im_bright_adj >= 0.0031308) = temp(im_bright_adj >= 0.0031308);
    temp = 12.92 * im_bright_adj;
    im_bright_adj(im_bright_adj < 0.0031308) = temp(im_bright_adj < 0.0031308);
    
    subplot(3, 3, i+1);
    imshow(im_bright_adj);
    title(sprintf('Bright: %.2f%%', adj_max_gray / max_gray * 100));
end
```

**Results**
![Alt text](/assignment1_result/figure4.png)

### Question 7. Compression (5pts)
```matlab
imwrite(im_bright_adj, 'result_png.png');
imwrite(im_bright_adj, 'result_jpg.jpg', 'jpg', 'Quality', 95);
disp(imfinfo('result_png.png'));
disp(imfinfo('result_jpg.jpg'));
```

**Results**
![Alt text](/assignment1_result/result_png.png)
![Alt text](/assignment1_result/result_jpg.jpg)

```

                  Filename: 'F:\OneDrive\OneDrive_Y\OneDrive - 연세대학교 (Yonsei University)\3_Study\2_정규수업\2018년도 2학기\계산영상시스템\HW1\assignment1\repos\result_png.png'
               FileModDate: '18-Sep-2018 18:00:04'
                  FileSize: 14196077
                    Format: 'png'
             FormatVersion: []
                     Width: 4289
                    Height: 2855
                  BitDepth: 24
                 ColorType: 'truecolor'
           FormatSignature: [137 80 78 71 13 10 26 10]
                  Colormap: []
                 Histogram: []
             InterlaceType: 'none'
              Transparency: 'none'
    SimpleTransparencyData: []
           BackgroundColor: []
           RenderingIntent: []
            Chromaticities: []
                     Gamma: []
               XResolution: []
               YResolution: []
            ResolutionUnit: []
                   XOffset: []
                   YOffset: []
                OffsetUnit: []
           SignificantBits: []
              ImageModTime: '18 Sep 2018 08:59:58 +0000'
                     Title: []
                    Author: []
               Description: []
                 Copyright: []
              CreationTime: []
                  Software: []
                Disclaimer: []
                   Warning: []
                    Source: []
                   Comment: []
                 OtherText: []

           Filename: 'F:\OneDrive\OneDrive_Y\OneDrive - 연세대학교 (Yonsei University)\3_Study\2_정규수업\2018년도 2학기\계산영상시스템\HW1\assignment1\repos\result_jpg.jpg'
        FileModDate: '18-Sep-2018 18:00:04'
           FileSize: 2564529
             Format: 'jpg'
      FormatVersion: ''
              Width: 4289
             Height: 2855
           BitDepth: 24
          ColorType: 'truecolor'
    FormatSignature: ''
    NumberOfSamples: 3
       CodingMethod: 'Huffman'
      CodingProcess: 'Sequential'
            Comment: {}

```

Compression: 18%
