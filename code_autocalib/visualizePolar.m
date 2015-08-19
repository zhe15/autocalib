function theta_phi_map = visualizePolar(theta_h,phi_d,brdf_val)
% Measure angles in degree, make sure they are in the right range and they
% are at integer positions.
% The function should deal with the case that theta_h and phi_d are not
% integers.
% For the moment, the implementation is a simple one, just rounding theta_h
% and phi_d to the nearest points.

phi_d    = mod(round(phi_d*180/pi),360);
theta_h  = round(min(max(theta_h*180/pi,0),90));
brdf_val = max(brdf_val,0);

validness = theta_h > 0;

phi_d    = phi_d(validness);
theta_h  = theta_h(validness);
brdf_val = brdf_val(validness,:);

W_inds = phi_d + 1; % phi_d  : [0 359]
H_inds = theta_h;   % theta_h: [1  90]

inds = sub2ind([90,360],H_inds,W_inds);

% update: handle multiple brdf_val sets
% Nov 03, 2011 by Wu Zhe
brdf_num = size(brdf_val,2);
theta_phi_map = zeros(90,360,brdf_num);

for i = 1:brdf_num
    tmp_map = zeros(90,360);
    tmp_map(inds) = brdf_val(:,i);
    theta_phi_map(:,:,i) = tmp_map;
end

end
