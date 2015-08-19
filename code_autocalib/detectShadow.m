function vis_mask = detectShadow(Iall, thres, mask)
% This is the most naive way of detecting shadow: global thresholding.

num     = length(Iall);
[H W C] = size(Iall{1});
if ~exist('mask','var') mask = true(H,W); end

Igray = zeros(H*W,num);
for i = 1:num
    Igray(:,i) = reshape(mean(Iall{i},3),[H*W 1]);
end
Igray = Igray / max(Igray(:)) * 3;  % a magic number

if ~exist('thres','var') thres = 0.025; end

vis_mask = reshape(Igray > thres, [H W num]);
vis_mask = vis_mask & repmat(mask,[1 1 num]);

