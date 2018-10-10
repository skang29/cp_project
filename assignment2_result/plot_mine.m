% figure
% plot(freq, abs(fft_pf_disp(:, 1:512, 1:512, 3)));
% hold on
% title('Frequency response on time axis');
% xlabel('Hz');
% ylabel('Amplitude');
% set(gca, 'XMinorTick', 'on');
% hold off

a = sum(sum(sum(abs(fft_pf_disp(:, 1:64, 1+256+128+64:512+256+128+64, 1:1)), 4), 3), 2);
plot(freq, abs(a))
set(gca, 'XMinorTick', 'on');