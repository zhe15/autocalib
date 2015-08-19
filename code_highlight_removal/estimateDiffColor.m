function diffColor = estimateDiffColor(Iall, src_color, mask, shadow_mask, mode)
% One way is just to find the color which forms the largest angle with the
% source color; another way is to fit a plane through the source color, and
% then project all pixel colors onto the plane and find the one which is
% farest from the source color. I don't think there is much difference
% between the two naive methods.

if ~exist('mode','var')  mode = 1;  end
%% Method 1
if mode == 1
    num_img = length(Iall);
    [H W]   = size(mask);

    % Get all variables into proper shape
    Images = zeros(H*W, 3, num_img);
    for i = 1:num_img
        Images(:,:,i) = reshape(Iall{i},[H*W 3]);
    end
    shadow_mask = reshape(shadow_mask,[H*W num_img]);

    % Normalization
    src_color = src_color(:) / norm(src_color);
    Images = Images ./ repmat(sqrt(sum(Images.^2,2)),[1 3 1]);

    % Angular distances
    cosVal = zeros(H*W,num_img);
    for i = 1:num_img
        cosVal(:,i) = Images(:,:,i) * src_color;
    end

    % This step is a bit tricky. The main consideration is about the case when
    % some pixels are always in the shadow region.
    cosVal = cosVal + double(~shadow_mask);

    % The normalization step might produce NaN, this step will remove them.
    [~,Ind] = min(cosVal,[],2); % for each pixel, the color is in the Ind-th image

    diffColor = zeros(H*W,3);
    for i = 1:H*W
        diffColor(i,:) = Images(i,:,Ind(i));
    end
    diffColor = reshape(diffColor,[H W 3]);
    diffColor(repmat(~mask,[1 1 3])) = 0;

    % To do: the above cannot guarantee no NaN in diffColor.
end
%% Method 2
% This is extremely slow.
if mode == 2
    num_img = length(Iall);
    [H W]   = size(mask);

    % Get all variables into proper shape
    Images = zeros(H*W, 3, num_img);
    for i = 1:num_img
        Images(:,:,i) = reshape(Iall{i},[H*W 3]);
    end
    shadow_mask = reshape(shadow_mask,[H*W num_img]);

    % Normalization
    src_color = src_color(:) / norm(src_color);
    Images = Images ./ repmat(sqrt(sum(Images.^2,2)),[1 3 1]);

    Images(isnan(Images)) = 0;
    Images(isinf(Images)) = 0;

    for i = 1:H*W
        if mask(i) == 0  continue;  end
        if sum(shadow_mask(i,:)) > 0
            intensities = reshape(Images(i,:,:),[3 num_img]);
            % Remove those in shadow region
            intensities(:,shadow_mask(i,:)) = 0;
            % Fit a plane passing src_color
            [U S V] = svd((eye(3) - src_color*src_color')*intensities, 'econ');
            % Project onto the plane
            intensities = (eye(3) - U(:,3) * U(:,3)') * intensities;
            % Normalize
            intensities = intensities ./ repmat(sqrt(sum(intensities.^2,1)),[3 1]);
            % Find the one farest from src_color
            [~,ind] = min(src_color' * intensities);
            diffColor(i,:) = intensities(:,ind);
        else % All in shadow
            diffColor(i,:) = intensities(:,1) / norm(intensities(:,1));
        end
    end

    diffColor = reshape(diffColor,[H W 3]);

end

