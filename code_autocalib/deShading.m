function [brdf_val,valid_inds] = deShading(intensities,s,normals)
% update: handle multiple images
% Oct 04, 2011
% update: valid_inds indicates brdf_val > 0
% Oct 31, 2011

% normalization
if numel(s) == 3
    s = s(:)';
elseif size(s,1) == 3
    s = s';
end

% Update: remove the following normalization step since gbrTransform is
% updated.
% Oct 14, 2012
% s = s ./ repmat(sqrt(sum(s.^2,2)),[1 3]);
% normals = normals ./ repmat(sqrt(sum(normals.^2,2)),[1 3]);

% shading
shading_val = normals * s';

% brdf
brdf_val = intensities ./ shading_val;

% at positions where shading is near zero, the BRDF estimation will not be
% accurate.
% 1e-6 corresponds to 89.999 deg, which is quite large. Try 0.0872 (85 deg)
valid_inds = abs(shading_val) > 1e-6;

% only preserve positive brdf_val
valid_inds = valid_inds & (brdf_val > 0);
end
