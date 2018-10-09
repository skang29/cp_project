## Assignment 2
### Experimental settings
#### Image resizing
Because of limitation of RAM, I resized image to specific width and height as power of 2.

### Q1. Initials and color transformation (5 pts)

```matlab
%% Q1. Initials and color transformation (5 pts)
disp('Q1. Initials and color transformation (5 pts) ...');
tic
IMAGE_SIZE = 512;
LAPLACIAN_LEVEL = 5;
SIGMA = 1;

% Read video
video_path = './data/face.mp4';

v = VideoReader(video_path);

height = v.Height;
width = v.Width;

original_video_height = v.Height;
original_video_width = v.Width;

num_frames = v.NumberOfFrames;
video_fps = v.FrameRate;

v = VideoReader(video_path);
frames = zeros(num_frames, IMAGE_SIZE, IMAGE_SIZE, 3);

for i=1:num_frames
    % Read frame
    temp = readFrame(v);
    temp = double(temp);
    if i==1
        figure(1);
        subplot(2, 2, 1);
        imshow(temp / 255.);
        title('Original');
    end
    
    % Resize image
    temp = imresize(temp, [IMAGE_SIZE IMAGE_SIZE], 'Antialiasing', true);
    if i==1
        figure(1);
        subplot(2, 2, 2);
        imshow(temp / 255.);
        title('Resized');
    end
    
    % Re-range
    temp = temp / 255.;
    if i==1
        figure(1);
        subplot(2, 2, 3);
        imshow(temp);
        title('Re-ranged');
    end

    % Color space transformation
    temp = rgb2ntsc(temp);
    if i==1
        figure(1);
        subplot(2, 2, 4);
        imshow(abs(temp), []);
        title('YIQ color space');
    end
    
    frames(i, :, :, :) = temp;
end
toc
disp('Done !');
```

**Results**
![Alt text](/assignment2_result/Figure/figure1.png)

### Q2. Laplacian pyramid (20 pts)
```matlab
%% Q2. Laplacian pyramid (20 pts)
disp('Q2. Laplacian pyramid (20 pts) ...');
tic
dummy_pyramid = laplacian_pyramid(squeeze(frames(1, :, :, :)), LAPLACIAN_LEVEL, SIGMA);
dummy_size = size(dummy_pyramid);
pyramid_frames = zeros(num_frames, dummy_size(1), dummy_size(2), dummy_size(3));

figure;
for i=1:num_frames
    pyramid_frames(i, :, :, :) = laplacian_pyramid(squeeze(frames(i, :, :, :)), LAPLACIAN_LEVEL, SIGMA);
    if i==1
        imshow(squeeze(pyramid_frames(1, :, :, :)), []);
        title("Laplacian pyramid");
    end
end
toc
disp('Done !');
```

**Results**
![Alt text](/assignment2_result/Figure/figure2.png)

### Q3. Temporal filtering (30 pts), Q4. Extracting the frequency band of interest (30 pts)
```matlab
disp('Q3. Temporal filtering (30 pts) AND');
disp('Q4. Extracting the frequency band of interest (30 pts) ...');
tic

% Fourier Transform params
Fs = video_fps;      % Sampling freq.
Ts = 1 / Fs;         % Sampling period
L = num_frames;      % Sample length
t = (0:L - 1) * Ts;   % Time vector

% FFT with zero padding
fft_num_frames = num_frames;
l_pad = 2 * fft_num_frames; % Modified num_frames
dummy_size = size(pyramid_frames);
fft_pyramid_frames = fft(pyramid_frames, l_pad, 1);

fft_pf_disp = fft_pyramid_frames(1:l_pad/2+1, :, :, :);
fft_pf_disp = fft_pf_disp / fft_num_frames;
fft_pf_disp(2:end-1, :, :, :) = 2 * fft_pf_disp(2:end-1, :, :, :);
freq = 0:Fs/l_pad:Fs/2;

figure;
subplot(3, 1, 1);
plot(freq, abs(fft_pf_disp(:, 1, 1, 3)));
hold on
title('Frequency response on time axis');
xlabel('Hz');
ylabel('Amplitude');
set(gca, 'XMinorTick', 'on');
hold off

toc
tic
% Add './src' path to utilize BWBPF
addpath('./src');

% butterworthBanpassFilter(Fs, N, Fc1, Fc2)
%   Fs : Sampling rate [Hz]
%   N  : Order
%   Fc1: 1st cut-off freq. [Hz]
%   Fc2: 2nd cut-off freq. [Hz]
Hd = butterworthBandpassFilter(Fs, 256, 0.83, 1.0);
fftHd = freqz(Hd, fft_num_frames + 1);
subplot(3, 1, 2);
plot(freq, abs(fftHd));
hold on
title('Butterworth BPF Response');
xlabel('Hz');
ylabel('Amplitude');
ylim([0 1.2]);
set(gca, 'XMinorTick', 'on');
hold off

% Multiplication params for each layer
alpha = [0 0 0 0 100];

alpha = alpha / sum(alpha) * 10;
total_dims = size(fft_pyramid_frames);
total_width = total_dims(3);

alpha_matrix = ones(IMAGE_SIZE, total_width, 3);
alpha_matrix(:, :, 1) = zeros(IMAGE_SIZE, total_width);

width_idx = 1;
ORIGINAL_LEVEL = nextpow2(IMAGE_SIZE);
for i=1:LAPLACIAN_LEVEL
    new_width_idx = width_idx+pow2(ORIGINAL_LEVEL-i+1);
    alpha_matrix(:, width_idx:new_width_idx-1, :) = alpha(i) * alpha_matrix(:, width_idx:new_width_idx-1, :);
    width_idx = new_width_idx;
end

% Creating filter
fftHdFull = zeros(l_pad, 1);
fftHdFull(1:fft_num_frames+1) = fftHd;
fftHdFull(fft_num_frames+2:end) = fftHd(end-1:-1:2);
% Filtering
[drop, height, width, channel] = size(fft_pyramid_frames);
for c=1:channel
    for w=1:width
        for h=1:height
            fft_pyramid_frames(:, h, w, c) = ...
                fft_pyramid_frames(:, h, w, c) .* (1 + fftHdFull * alpha_matrix(h, w, c));
        end
    end
end

fft_pf_disp = fft_pyramid_frames(1:l_pad/2+1, :, :, :);
fft_pf_disp = fft_pf_disp / fft_num_frames;
fft_pf_disp(2:end-1, :, :, :) = 2 * fft_pf_disp(2:end-1, :, :, :);
freq = 0:Fs/l_pad:Fs/2;
subplot(3, 1, 3);
plot(freq, abs(fft_pf_disp(:, 1, 1, 3)));
hold on
title('Magnified frequency response');
xlabel('Hz');
ylabel('Amplitude');
set(gca, 'XMinorTick', 'on');
hold off

figure;
imshow(alpha_matrix / max(max(max(alpha_matrix))));
title("Magnification matrix");

toc
disp('Done !');
```

**Results**
![Alt text](/assignment2_result/Figure/figure4.png)
![Alt text](/assignment2_result/Figure/figure3.png)


### Q5. Image reconstruction (20 pts)
```matlab
%% Q5. Image reconstruction (20 pts)
disp('Q5. Image reconstruction (20 pts) ...');
tic

% Inverse FFT
pyramid_frames = real(ifft(fft_pyramid_frames, l_pad, 1));

new_frames = zeros([num_frames, original_video_height original_video_width 3], 'uint8');
for i=1:num_frames
    % Reconstruct image
    temp = reconstruct_from_laplacian_pyramid(squeeze(pyramid_frames(i, :, :, :)), LAPLACIAN_LEVEL);
    
    % Revert color space
    temp = ntsc2rgb(temp);
    
    % Rescale
    temp = temp * 255.;
    
    % Resize image
    temp = imresize(temp, [original_video_height original_video_width], 'Antialiasing', true);
    
    % Clip values
    temp(temp > 255.) = 255;
    temp(temp < 0. ) = 0;
    
    % Change data type
    temp = uint8(temp);
    
    new_frames(i, :, :, :) = temp;
end
toc
tic
% Write video
v = VideoWriter('Result.avi');
open(v);

for i=1:num_frames
    writeVideo(v, squeeze(new_frames(i, :, :, :)));
end

close(v);

toc
disp('Done !');
disp('All process finished.');
```

**Results**
Face
<div align="center">
  <a href="https://www.youtube.com/watch?v=NSufEH1AI3o"><img src="https://img.youtube.com/vi/NSufEH1AI3o/0.jpg" alt="IMAGE ALT TEXT"></a>
</div>


Baby
<div align="center">
  <a href="https://www.youtube.com/watch?v=RFR_mHK_9eo"><img src="https://img.youtube.com/vi/RFR_mHK_9eo/0.jpg" alt="IMAGE ALT TEXT"></a>
</div>

Failure case
<div align="center">
  <a href="https://www.youtube.com/watch?v=LgpJuGK6ZcY"><img src="https://img.youtube.com/vi/LgpJuGK6ZcY/0.jpg" alt="IMAGE ALT TEXT"></a>
</div>

### BONUS. My Own Video
I took a video of my hand. A figure below is displaying sum of fourier transformed frame data. As the figure shows, amplitude between 0.75Hz and 1.00Hz is informative in consideration that low frequency is not meaningful. Thus, I amplified my video using BW bandpass filter which passing frequency is 0.7-1.00Hz and I successfully amplified my hands color shift due to my heart beat. 0.75Hz-1.00Hz indicates 60-80bps which is the general heart beat rate of a human.

**Results**
Original
<div align="center">
  <a href="https://www.youtube.com/watch?v=cOUpuEkFAE0"><img src="https://img.youtube.com/vi/cOUpuEkFAE0/0.jpg" alt="IMAGE ALT TEXT"></a>
</div>


Amplified
<div align="center">
  <a href="https://www.youtube.com/watch?v=BYtgJRo1Mwk"><img src="https://img.youtube.com/vi/BYtgJRo1Mwk/0.jpg" alt="IMAGE ALT TEXT"></a>
</div>
