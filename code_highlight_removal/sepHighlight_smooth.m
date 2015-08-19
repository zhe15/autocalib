function [diffImages, specImages] = sepHighlight_smooth(Iall,diffColor,src_color,mask,weight)

num_img = length(Iall);
num_pix = sum(mask(:));
[H W]   = size(mask);

mask = mask(:);

% Get Images into proper shape
Images = zeros(num_pix, 3, num_img);
for i = 1:num_img
    tempImage = reshape(Iall{i},[H*W 3]);
    Images(:,:,i) = tempImage(mask,:);
end
Images = permute(Images,[2 1 3]);

% Get diffuse color of each pixel into proper shape
diffColor = reshape(diffColor,[H*W 3]);
diffColor = diffColor(mask,:);
diffColor = permute(diffColor,[2 3 1]);

% Get source color into proper shape
srcColor = repmat(src_color(:),[1 1 num_pix]);

% Mat = [A; B]
M = [diffColor srcColor];
I = repmat(reshape([1:3*num_pix],3,1,num_pix), [1 2 1]);
J = repmat(reshape([1:2*num_pix],1,2,num_pix), [3 1 1]);
A = sparse(I(:), J(:), M(:));

if ~exist('weight','var') weight = 1/8; end
[B,b2] = buildLaplacianMat(reshape(mask,[H W]),weight,true);

Mat = [A; B];

diffImg = zeros(num_pix,3,num_img);
specImg = zeros(num_pix,3,num_img);

for i = 1:num_img

    b1 = Images(:,:,i);
    b = [b1(:); b2];
    x = Mat \ b;
    
    x = max(0, x);
    x = permute(reshape(x,[2 num_pix]),[2 1]);
    
    diffImg(:,:,i) = permute(diffColor,[3 1 2]) .* repmat(x(:,1),[1 3]);
    specImg(:,:,i) = permute(srcColor,[3 1 2]) .* repmat(x(:,2),[1 3]);

end

% Prepare outputs
diffImages = {};
specImages = {};

for i = 1:num_img
    tempImage = zeros(H*W,3);
    
    tempImage(mask,:) = specImg(:,:,i);
    specImages{i} = reshape(tempImage,[H W 3]);
    
    tempImage(mask,:) = diffImg(:,:,i);
    diffImages{i} = reshape(tempImage,[H W 3]);
end

end
