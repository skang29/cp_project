%% Q1. Initials and color transformation (5 pts)
disp('Q1. Initials and color transformation (5 pts) ...');
tic
IMAGE_SIZE = 512;
LAPLACIAN_LEVEL = 5;
SIGMA = 1;

% Read video
video_path = './data/mine.mp4';

v = VideoReader(video_path);

height = v.Height;
width = v.Width;

original_video_height = v.Height;
original_video_width = v.Width;

num_frames = v.NumberOfFrames;
video_fps = v.FrameRate;

disp(num_frames);

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

%% Q3. Temporal filtering (30 pts), Q4. Extracting the frequency band of interest (30 pts)
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
plot(freq, abs(fft_pf_disp(:, 20, 512+128, 3)));
hold on
title('Frequency response on time axis');
xlabel('Hz');
ylabel('Amplitude');
set(gca, 'XMinorTick', 'on');
hold off

toc