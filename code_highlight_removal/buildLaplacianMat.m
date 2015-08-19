function [B,b] = buildLaplacianMat(mask,weight,mode)
% mode is used for deciding which part (diffuse / specular) is enfoced
% smoothness constraint.

num_pix = sum(mask(:));

% Find the pixels with constraints
se = strel('disk',1);
v_mask = imerode(mask,se);

% index and value of entries of sparse matrix
I = zeros(sum(v_mask(:)),5);
J = I;
M = I;

% Center
t_mask = v_mask(mask);

I = repmat(find(t_mask),[1 5]);
M(:,1) = -4;
M(:,2:end) = 1;
J(:,1) = I(:,1) * 2;

% Left
t_mask = circshift(v_mask,[0 -1]);
t_mask = t_mask(mask);

J(:,2) = find(t_mask) * 2;

% Right
t_mask = circshift(v_mask,[0 1]);
t_mask = t_mask(mask);

J(:,3) = find(t_mask) * 2;

% Up
t_mask = circshift(v_mask,[-1 0]);
t_mask = t_mask(mask);

J(:,4) = find(t_mask) * 2;

% Down
t_mask = circshift(v_mask,[1 0]);
t_mask = t_mask(mask);

J(:,5) = find(t_mask) * 2;

if ~mode
    J = J - 1;
end

B = sparse(I(:),J(:),M(:),num_pix,2*num_pix) * weight;
b = zeros(num_pix,1);
end
