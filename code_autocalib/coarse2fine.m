function G_final = coarse2fine(datadir,E_hat,S_hat0,L_hat0,G_init)

outputdir = [datadir filesep 'ratio'];
if ~exist(outputdir,'dir') mkdir(outputdir); end

lambda_set1 = [-0.9:0.1:0.9];
mu_set1 = [-0.9:0.1:0.9];
nu_set1 = [-0.9:0.1:0.9];
lambda_set2 = [-0.2:0.04:0.2];
mu_set2 = [-0.2:0.04:0.2];
nu_set2 = [-0.2:0.04:0.2];
lambda_set3 = [-0.08:0.01:0.08];
mu_set3 = [-0.08:0.01:0.08];
nu_set3 = [-0.08:0.01:0.08];

lambda_set = {};
lambda_set{1} = lambda_set1;
lambda_set{2} = lambda_set2;
lambda_set{3} = lambda_set3;
mu_set = {};
mu_set{1} = mu_set1;
mu_set{2} = mu_set2;
mu_set{3} = mu_set3;
nu_set = {};
nu_set{1} = nu_set1;
nu_set{2} = nu_set2;
nu_set{3} = nu_set3;

save([outputdir filesep 'params.mat'],'lambda_set','mu_set','nu_set');

G_init = G_init / G_init(end);
lambda_tmp = G_init(1,1);
mu_tmp = G_init(1,3);
nu_tmp = G_init(2,3);

matlabpool open 4
% update: parallel computing
% s_mlp = matlabpool('size');
% if s_mlp == 0
%     matlabpool open 8
% end
for k = 1:3
    ratio = removeGBR(S_hat0,L_hat0,E_hat,lambda_set{k}+lambda_tmp,mu_set{k}+mu_tmp,nu_set{k}+nu_tmp);
    [lambda_tmp,mu_tmp,nu_tmp,minCost] = extractMin(ratio,lambda_set{k}+lambda_tmp,mu_set{k}+mu_tmp,nu_set{k}+nu_tmp);
    filename = [outputdir filesep 'step' int2str(k) '.mat'];
    save(filename,'ratio','lambda_tmp','mu_tmp','nu_tmp','minCost');
end
% if s_mlp == 0
%     matlabpool close
% end
matlabpool close

G_final = [lambda_tmp 0 mu_tmp;
           0 lambda_tmp nu_tmp;
           0       0        1];
G_rank = G_final;
save([outputdir filesep 'G_rank.mat'],'G_rank');


