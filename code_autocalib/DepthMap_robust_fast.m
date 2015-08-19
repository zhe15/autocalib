function z = DepthMap_robust_fast( n, mask )
% The function will reconstruct a surface in the masked region by
% integrating the normal field given by n.
% Choice 1: no boundary condition is enforced;
% Choice 2: Dirichlet boundary condition (boundary values are forced to be
% zero in the implementation;
% Choice 3: Neumann boundary condition, which is to be implemented later.

applyDirichlet = true;

[H W] = size(mask);

% Find the boundary
% This is a mask for pixels on which dx can be enforced.
mask_r = circshift(circshift(mask,[0 1]) & mask, [0 -1]);
% This is a mask for pixels on which dy can be enforced. (notice the
% coordinate system)
mask_u = circshift(circshift(mask,[-1 0]) & mask, [1 0]);

% Build the matrix
I_r = [find(mask_r); find(mask_r)];
J_r = [find(mask_r); find(mask_r)+H];
M_r = [-1*ones(sum(mask_r(:)),1); ones(sum(mask_r(:)),1)];
A_r = sparse(I_r,J_r,M_r,H*W,H*W);

I_u = [find(mask_u); find(mask_u)];
J_u = [find(mask_u); find(mask_u)-1];
M_u = [-1*ones(sum(mask_u(:)),1); ones(sum(mask_u(:)),1)];
A_u = sparse(I_u,J_u,M_u,H*W,H*W);

A = [A_r; A_u];

%-------------------------------------------------------------------------%
% Handle gradient more robustly
% Adapted from Neil's code
maxpq = 10; % maxpq = 16;
[p,q] = n2pq(n(:,:,1),n(:,:,2),n(:,:,3));
p(~mask(:)) = 0; q(~mask(:)) = 0;
pqnorm = sqrt(p.^2+q.^2);

inds = pqnorm(:)>maxpq;
p(inds) = maxpq*p(inds)./pqnorm(inds);
q(inds) = maxpq*q(inds)./pqnorm(inds);
%-------------------------------------------------------------------------%
mask_edge = imdilate(~mask,strel('disk',1)) & mask;
if applyDirichlet
    A(:,mask_edge(:)) = 0;
end

% Main solver
x = A \ [p(:); q(:)];

% Make sure the object's height is above zero and the rest parts are zero.
z(~mask) = 0;
if applyDirichlet
    z(mask_edge) = 0;
end
x = x - min(x);
z(~mask) = 0;
if applyDirichlet
    z(mask_edge) = 0;
end

z = reshape(x,[H W]);

z(~mask) = NaN;
