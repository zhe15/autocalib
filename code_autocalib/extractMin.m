function [lambda,mu,nu,minCost] = extractMin(ratio,lambda_set,mu_set,nu_set)
% update: add an output variable minCost

% Preprocessing, set NaN and -1 to maximum
for imgId = 1:size(ratio,4)
    tmp = ratio(:,:,:,imgId);
    tmp(isnan(tmp)) = -1;
    tmp(isinf(tmp)) = -1;
    tmp(tmp<0) = max(ratio(:));  % heavy penalty. updated on Feb 17, 2012
    ratio(:,:,:,imgId) = tmp;
end

ave_ratio = mean(ratio,4);
[tmp,indR] = min(ave_ratio(:));
minCost = tmp(1);

% update: handle the case that all fail
% Oct 25, 2011
if tmp(1) < 0
    lambda = lambda_set(round(length(lambda_set)/2));
    mu = mu_set(round(length(mu_set)/2));
    nu = nu_set(round(length(nu_set)/2));
    return;
end

[x y z] = ind2sub(size(ave_ratio),indR(1));
lambda = lambda_set(x);
mu = mu_set(y);
nu = nu_set(z);

end
