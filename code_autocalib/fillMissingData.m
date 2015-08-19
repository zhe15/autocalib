function [out_images, ign_inds] = fillMissingData(vis_mask, I)

[H W num_img] = size(vis_mask);
dataMat = permute(reshape(I,[H*W num_img]),[2 1]);

full_inds  = find(sum(vis_mask,3) == num_img);  % no entry missing
incpl_inds = find(sum(vis_mask,3) < num_img & sum(vis_mask,3) >= 3);    % can be completed
ign_inds   = find(sum(vis_mask,3) < 3); % just ignore these pixels

full_Data  = dataMat(:,full_inds);
incpl_Data = dataMat(:,incpl_inds);

incpl_Mask = permute(reshape(vis_mask,[H*W num_img]),[2 1]);
incpl_Mask = incpl_Mask(:,incpl_inds);

[U,S,V] = svd(full_Data,'econ');
S = S(1:3,1:3);
U = U(:,1:3);   % Each column is a basis function

% algorithm
% basis to be projected to
U_star = U * S; % size = numx3

for i = 1:size(incpl_Data,2)
    tempData = incpl_Data(:,i);
    tempMask = incpl_Mask(:,i);
    tempU = U_star;
    tempU(~tempMask,:) = 0;
    c = U_star * (pinv(tempU) * tempData);
    tempData(~tempMask) = c(~tempMask);
    % Modify the original data
    incpl_Data(:,i) = c;
%     % Only fill in the missing entries
%     incpl_Data(:,i) = tempData;
end
dataMat(:,incpl_inds) = incpl_Data;

% Prepare outputs
out_images = reshape(permute(dataMat,[2 1]),[H W num_img]);
