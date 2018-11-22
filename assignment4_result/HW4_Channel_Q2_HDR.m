clear; clc; close all;
%% Q2. Merge exposure stack into HDR image (15 pts.)
% Parameters

% Running code
clear; clc; close all;
for file_type={'rendered', 'raw'}
    for weight_type={'uniform', 'tent', 'gaussian'}
        for merge_type={'logarithmic', 'linear'}
            fprintf("%s %s %s\n", file_type{1}, weight_type{1}, merge_type{1});
            HDRWrapper(file_type{1}, weight_type{1}, merge_type{1}, 16);
        end
    end
end
