function [theta_h, phi_d, validness] = parameterize(s,v,normals)
% update: extend to multiple images taken from the same view point

% normalization
if numel(s) == 3
    s = s(:)';
elseif size(s,1) == 3
    s = s';
end
v = repmat(v(:)',[size(s,1) 1]);

% Update: remove the following normalization step since gbrTransform is
% updated. Further assume v is normalized.
% Oct 14, 2012
% s = s ./ repmat(sqrt(sum(s.^2,2)),[1 3]);
% v = repmat(v(:)'/norm(v),[size(s,1) 1]);
% normals = normals ./ repmat(sqrt(sum(normals.^2,2)),[1 3]);

% half vector (and exception)
h = s + v;
h = h ./ repmat(sqrt(sum(h.^2,2)),[1 3]);
% update: handle exceptions by providing validness instead of throwing an error
% Oct 9, 2011
validness = (sum(isnan(h)|isinf(h),2) == 0);

% theta_h
theta_h = acos(min(max(normals*h',-1),1));

% phi_d
% new axis expressed in the original reference frame
axis_x = cross(h,v); axis_x = axis_x ./ repmat(sqrt(sum(axis_x.^2,2)),[1 3]);
axis_y = cross(h,axis_x); axis_y = axis_y ./ repmat(sqrt(sum(axis_y.^2,2)),[1 3]);
axis_z = h;

phi_d = zeros(size(theta_h));
for i = 1:size(s,1)
    rot_mat = [axis_x(i,:)', axis_y(i,:)', axis_z(i,:)'];

    % normals expressed in the new reference frame
    new_normals = normals * rot_mat;

    phi_d(:,i) = mod(atan2(new_normals(:,2),new_normals(:,1)),2*pi);
end

end
