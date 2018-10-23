function result = poisson_blending(X_target, X_source, M_source, bbox)
    disp('Start blending')
    imc = 3;
    
    crop_target = X_target(bbox(1, 1):bbox(2, 1), ...
                           bbox(1, 2):bbox(2, 2), :);
    crop_mask = M_source(bbox(1, 1):bbox(2, 1), ...
                           bbox(1, 2):bbox(2, 2));
    crop_source = X_source(bbox(1, 1):bbox(2, 1), ...
                           bbox(1, 2):bbox(2, 2), :);


    H_ = bbox(2, 1) - bbox(1, 1) + 1;
    W_ = bbox(2, 2) - bbox(1, 2) + 1;

    im2var = zeros(H_, W_);
    im2var(1:H_ * W_) = 1:H_ * W_;

    result = zeros(H_, W_, 3);

    % Blending
    % Create matrix A
    disp('Creating matrix A');
    % Av - b
    % A: Transform matrix[H x W x 2, H x W]      
    % Number of non-zeros: 5 per each pixels
    A = sparse([], [], [], H_ * W_ * 2, H_ * W_, H_ * W_ * 5);

    e = 0;
    % Gradients for h direction
    for h=1:H_ - 1
        for w=1:W_
            e = e + 1;
            if(crop_mask(h, w)==0 && crop_mask(h+1, w) == 0)
                % TT case
                A(e, im2var(h, w)) = 1;
            elseif (crop_mask(h, w)==0 && crop_mask(h+1, w) == 1)
                % TS Case
                A(e, im2var(h, w)) = 1;
            elseif (crop_mask(h, w)==1 && crop_mask(h+1, w) == 0)
                % ST Case
                A(e, im2var(h, w)) = 1;
            else
                % SS Case
                A(e, im2var(h + 1, w)) = 1;
                A(e, im2var(h, w)) = -1;
            end
        end
    end
    % Gradients for w direction
    for h=1:H_
        for w=1:W_ - 1
            e = e + 1;
            if(crop_mask(h, w)==0 && crop_mask(h, w+1) == 0)
                % TT case
                A(e, im2var(h, w)) = 1;
            elseif (crop_mask(h, w)==0 && crop_mask(h, w+1) == 1)
                % TS Case
                A(e, im2var(h, w)) = 1;
            elseif (crop_mask(h, w)==1 && crop_mask(h, w+1) == 0)
                % ST Case
                A(e, im2var(h, w)) = 1;
            else
                % SS Case
                A(e, im2var(h, w+1)) = 1;
                A(e, im2var(h, w)) = -1;
            end
        end
    end
    
    % H initial condition
    for h=1:H_
        e = e + 1;
        A(e, im2var(h, W_)) = 1;
    end
    % W initial condition
    for w=1:W_
        e = e + 1;
        A(e, im2var(H_, w)) = 1;
    end
    toc
    disp("Done !");


    for c=1:imc
        disp(['Creating matrices at channel ' num2str(c) ' ...']);
        % v: Target image [H x W]  
        v = zeros(H_ * W_, 1);

        % b: Gradients of x and y direction and a pixel [H x W x 2]
        b = zeros(H_ * W_ * 2, 1, 'double');

        e = 0;
        % Gradients for h direction
        for h=1:H_ - 1
            for w=1:W_
                e = e + 1;
                if(crop_mask(h, w)==0 && crop_mask(h+1, w) == 0)
                    % TT case
                    b(e) = crop_target(h, w, c);
                elseif (crop_mask(h, w)==0 && crop_mask(h+1, w) == 1)
                    % TS Case
                    if(abs(crop_source(h+1, w, c) - crop_source(h, w, c)) > abs(crop_target(h+1, w, c) - crop_target(h, w, c)))
                        b(e) = crop_source(h+1, w, c) - crop_source(h, w, c) + crop_target(h, w, c);
                    else
                        b(e) = crop_target(h+1, w, c) - crop_target(h, w, c) + crop_target(h, w, c);
                    end
                elseif (crop_mask(h, w)==1 && crop_mask(h+1, w) == 0)
                    % ST Case
                    if(abs(crop_source(h+1, w, c) - crop_source(h, w, c)) > abs(crop_target(h+1, w, c) - crop_target(h, w, c)))
                        b(e) = crop_source(h+1, w, c) - crop_source(h, w, c) + crop_target(h, w, c);
                    else
                        b(e) = crop_target(h+1, w, c) - crop_target(h, w, c) + crop_target(h, w, c);
                    end
                else
                    % SS Case
                    if(abs(crop_source(h+1, w, c) - crop_source(h, w, c)) > abs(crop_target(h+1, w, c) - crop_target(h, w, c)))
                       b(e) = crop_source(h+1, w, c) - crop_source(h, w, c);
                    else
                        b(e) = crop_target(h+1, w, c) - crop_target(h, w, c);
                    end
                end
            end
        end
        % Gradients for w direction
        for h=1:H_
            for w=1:W_-1
                e = e + 1;
                if(crop_mask(h, w)==0 && crop_mask(h, w+1) == 0)
                    % TT case
                    b(e) = crop_target(h, w, c);
                elseif (crop_mask(h, w)==0 && crop_mask(h, w+1) == 1)
                    % TS Case
                    if(abs(crop_source(h, w+1, c) - crop_source(h, w, c)) > abs(crop_target(h, w+1, c) - crop_target(h, w, c)))
                        b(e) = crop_source(h, w+1, c) - crop_source(h, w, c) + crop_target(h, w, c);
                    else
                        b(e) = crop_target(h, w+1, c) - crop_target(h, w, c) + crop_target(h, w, c);
                    end
                elseif (crop_mask(h, w)==1 && crop_mask(h, w+1) == 0)
                    % ST Case
                    if(abs(crop_source(h, w+1, c) - crop_source(h, w, c)) > abs(crop_target(h, w+1, c) - crop_target(h, w, c)))
                        b(e) = crop_source(h, w+1, c) - crop_source(h, w, c) + crop_target(h, w, c);
                    else
                        b(e) = crop_target(h, w+1, c) - crop_target(h, w, c) + crop_target(h, w, c);
                    end
                else
                    % SS Case
                    if(abs(crop_source(h, w+1, c) - crop_source(h, w, c)) > abs(crop_target(h, w+1, c) - crop_target(h, w, c)))
                       b(e) = crop_source(h, w+1, c) - crop_source(h, w, c);
                    else
                        b(e) = crop_target(h, w+1, c) - crop_target(h, w, c);
                    end
                end
            end
        end

        % H initial condition
        for h=1:H_
            e = e + 1;
            b(e) = crop_target(h, W_);
        end

        % W initial condition
        for w=1:W_
            e = e + 1;
            b(e) = crop_target(H_, w);
        end    

        toc
        disp(['Start solving at channel ' num2str(c) ' ...']);
        v = A \ b;
        toc
        disp('Done !');

        result(:, :, c) = reshape(v, [H_ W_]);
    end

end