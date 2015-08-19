% function [S,L,Pscale,Q] = recover2GBR(S_tmp,L_tmp,height,width,m)
function [S, L] = recover2GBR(S, L, mask)
% S = S_tmp * Pscale
% L = Q * L_tmp
% I read thru this part, which is an implementation of the following paper
% Shape and Albedo from Multiple Images using Integrability
% One thing to note is the coordinate system. Another thing is that the
% implementation is actually forcing the whole image integrable, which is
% obviously not true in many cases. A modification might be removing the
% integrability constraint on background pixels by providing a mask.
% Commented by Wu Zhe on Oct 25, 2011

% Several updates:
% The inputs are updated: a mask is used instead of of height, width, m;
% shape of L and S are modified;
% Coordinate system is updated so positve y is pointing upward;
% One thing learnt from a CVPR2012 paper is that it might be useful to
% smooth e1, e2 and e3 before taking gradients.
% Oct 09, 2012

[H W] = size(mask);

% e1 = zeros(H*W, 1);
% e2 = zeros(H*W, 1);
% e3 = zeros(H*W, 1);
% 
% e1(mask(:)) = S(:,1);
% e2(mask(:)) = S(:,2);
% e3(mask(:)) = S(:,3);

e1 = S(:,1);
e2 = S(:,2);
e3 = S(:,3);

e1m = reshape(e1, [H W]);
e2m = reshape(e2, [H W]);
e3m = reshape(e3, [H W]);

% This is fine for apple_hdr, pear_hdr, pear2, duck. Not for fish
% This is also for ping pong. Updated on March 19, 2013
smooth_kernel = fspecial('gaussian',[25 25],2);
% smooth_kernel = fspecial('gaussian',[5 5], 1);
e1m = imfilter(e1m, smooth_kernel, 'same');
e2m = imfilter(e2m, smooth_kernel, 'same');
e3m = imfilter(e3m, smooth_kernel, 'same');

[e1x, e1y] = gradient(e1m);
[e2x, e2y] = gradient(e2m);
[e3x, e3y] = gradient(e3m);

% Adjustment due to different coordinate systemss
e1y = -e1y;
e2y = -e2y;
e3y = -e3y;

e1x = reshape(e1x, [H*W 1]);
e2x = reshape(e2x, [H*W 1]);
e3x = reshape(e3x, [H*W 1]);

e1y = reshape(e1y, [H*W 1]);
e2y = reshape(e2y, [H*W 1]);
e3y = reshape(e3y, [H*W 1]);

e1e2x = e1 .* e2x;
e2e1x = e2 .* e1x;
e1e3x = e1 .* e3x;
e3e1x = e3 .* e1x;
e2e3x = e2 .* e3x;
e3e2x = e3 .* e2x;

e1e2y = e1 .* e2y;
e2e1y = e2 .* e1y;
e1e3y = e1 .* e3y;
e3e1y = e3 .* e1y;
e2e3y = e2 .* e3y;
e3e2y = e3 .* e2y;

tx1 = e1e2x - e2e1x;
tx2 = e1e3x - e3e1x;
tx3 = e2e3x - e3e2x;

ty1 = e1e2y - e2e1y;
ty2 = e1e3y - e3e1y;
ty3 = e2e3y - e3e2y;

A = [tx1, tx2, tx3, -ty1, -ty2, -ty3];

%*************************************************************************%
% Remove background pixels and constraints on the boundary
% updated on Oct 25, 2011
mask = imerode(mask,strel('disk',1));
A = A(mask(:),:);
%*************************************************************************%
[uA, dA, vA] = svd(A,'econ');
solvec = vA(:, size(vA, 2));

% A temporary guess for the three unknowns (Just give some random numbers)
% updated on Oct 09, 2012
% a1 = rand(1); a2 = rand(1); a3 = rand(1);
a1 = 0.5; a2 = 0.5; a3 = 0.5;

P_inv = [-solvec(3), solvec(6),  a1; ...
          solvec(2),-solvec(5),  a2; ...
         -solvec(1), solvec(4),  a3];
P = inv(P_inv);
%*************************************************************************%
% S: p x 3, L: m x 3
S = S * P';
L = L * P_inv;

% Make sure normals are pointing towards the camera
if mean(S(mask(:),3)) < 0
    S(:,3) = - S(:,3);
    L(:,3) = - L(:,3);
end

% Why always normalize results??
% Normalization
% S = S ./ repmat(sqrt(sum(S.^2,2)),[1 3]);
% L = L ./ repmat(sqrt(sum(L.^2,1)),[3 1]);
