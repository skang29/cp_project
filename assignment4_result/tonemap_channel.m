function I_tonemapped = tonemap_channel(K, B, I_HDR)
epsilon = 1e-4;

I_mean_HDR = exp(mean(mean(log(I_HDR + epsilon))));
I_norm_HDR = K / I_mean_HDR * I_HDR;
disp(size(I_norm_HDR))
I_norm_white = B * max(max(I_norm_HDR));
I_norm_white_square = I_norm_white * I_norm_white;
disp(I_norm_white_square)

I_tonemapped = I_norm_HDR .* (1 + I_norm_HDR /I_norm_white_square) ./ (1 + I_norm_HDR);
end
