function ratio = removeGBR(S_hat,L_hat,E_hat,lambda_set,mu_set,nu_set)
% S_hat is the normal fields and need to be normalized;
% L_hat contains all light information;
% E_hat is the specular components in all images.

% update: parallel computing
%*************************************************************************%
% ratio might be very large, size of it had better be kept within
% 20x20x20x50

L_len = length(lambda_set);
M_len = length(mu_set);
N_len = length(nu_set);
nums  = L_len * M_len * N_len;
num_img = size(E_hat,2);

ratio = zeros(nums,num_img);

[P1 P2 P3] = ind2sub([L_len M_len N_len],[1:nums]');
lambda_set = lambda_set(P1);
mu_set     = mu_set(P2);
nu_set     = nu_set(P3);

thres1 = 0.05;
thres2 = 0.20;

parfor param_ind = 1:nums
    fprintf('param_ind = %d / %d ...\n',param_ind,nums);
    
    lambda = lambda_set(param_ind);
    mu = mu_set(param_ind);
    nu = nu_set(param_ind);


    [S_hat0,L_hat0] = gbrTransform(lambda,mu,nu,S_hat,L_hat);
    [brdf_val,valid_inds] = deShading(E_hat,L_hat0,S_hat0);
    [theta_h, phi_d, validness] = parameterize(L_hat0,[0 0 1],S_hat0);
    
    ratio_tmp = zeros(1,num_img);
    for img_ind = 1:num_img
        if ~validness(img_ind) ratio_tmp(img_ind) = -1; continue; end
        
        valid_inds_tmp = valid_inds(:,img_ind);
        brdf_val_tmp   = brdf_val(valid_inds_tmp,img_ind);
        theta_h_tmp    = theta_h(valid_inds_tmp, img_ind);
        phi_d_tmp      = phi_d(valid_inds_tmp,   img_ind);
        spec_val_tmp   = E_hat(valid_inds_tmp,   img_ind);

        % arrange brdf values and specular values on a 2D grid
        plot_tmp = visualizePolar(theta_h_tmp,phi_d_tmp,[brdf_val_tmp spec_val_tmp]);

        row_sums = sum(plot_tmp(:,:,2),2);  % use spec_val to determine
        if sum(row_sums(1:10)) < thres1 * sum(row_sums)
            ratio_tmp(img_ind) = -1;
        elseif sum(row_sums(1:20)) < thres2 * sum(row_sums)
            ratio_tmp(img_ind) = -1;
        else
            ratio_tmp(img_ind) = varmethod2(plot_tmp(:,:,1)); % use brdf_val for cost
        end
    end
    ratio(param_ind,:) = ratio_tmp;
end

ratio = reshape(ratio,[L_len M_len N_len num_img]);
