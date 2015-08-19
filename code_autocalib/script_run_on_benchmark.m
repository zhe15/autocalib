close all; clear; clc;
tic;
% datadir = ['../guangong'];
% datadir = ['../harvest'];
% datadir = ['../pot2'];
datadir = ['../reading'];

fprintf('Loading mask ...');
mask = imread([datadir filesep 'mask.png']);
mask = mask(:,:,1) > 0;
[H W] = size(mask);
fprintf(' Done.\n');

fprintf('Loading images ...');
d_file = find_sorted_filename(datadir, 'D', 'png');
s_file = find_sorted_filename(datadir, 'S', 'png');
Iall = {};
for i = 1:length(d_file)
    Iall{i} = im2double(imread(d_file{i}));
end
fprintf(' Done.\n');

% Detect shadow
fprintf('Detecting shadow region ...');
thres = 0.030;
vis_mask = detectShadow(Iall, thres, mask);
fprintf(' Done.\n');


vList = [1:length(d_file)];
diffImages_gray = zeros(H,W,length(vList));
for i = 1:length(vList)
    diffImages_gray(:,:,i) = mean(Iall{vList(i)},3);
end
clear Iall;

specImages_gray = zeros(H,W,length(vList));
for i = 1:length(vList)
    s_image = im2double(imread(s_file{vList(i)}));
    specImages_gray(:,:,i) = mean(s_image,3);
end

% Modify vis_mask
vis_mask = vis_mask(:,:,vList);

% Fill missing data
fprintf('Filling missing data ...');
[out_images, ign_inds] = fillMissingData(vis_mask, diffImages_gray);
fprintf('Done.\n');

% New mask
ign_mask = mask;
ign_mask(ign_inds) = 0;

% SVD
fprintf('SVD ...');
out_images(repmat(~ign_mask,[1 1 size(out_images,3)])) = 0;
out_images = reshape(out_images,H*W,[]);
[U,S,V] = svd(out_images','econ');
U = U(:,1:3);
S = S(1:3,1:3);
V = V(:,1:3);
Light = U * S;
G_normal = V;
fprintf('Done.\n');

fprintf('Recovering to GBR ...');
[G_normal, Light] = recover2GBR(G_normal, Light, ign_mask);

ambMat = diag([1 1 1]);       % concave / convex ambiguity
G_normal = G_normal * ambMat;
Light = Light * ambMat;

G_normal = G_normal ./ repmat(sqrt(sum(G_normal.^2,2)),[1 3]);
G_normal = reshape(G_normal,[H W 3]);
G_normal(repmat(~ign_mask,[1 1 3])) = 0;
assert(sum(isnan(G_normal(:))) + sum(isinf(G_normal(:))) == 0);
fprintf('Done.\n');


% [S_spec,L_spec,G_spec] = solveGBR_spec(reshape(G_normal,[H*W 3]),Light',reshape(specImages_gray,H*W,[]));

G_rank = reshape(G_normal,[H*W 3]); G_rank = G_rank(ign_mask(:),:);
L_rank = Light';
E = reshape(specImages_gray,H*W,[]); E = E(ign_mask(:),:);
G_final = coarse2fine(datadir,E,G_rank,L_rank,eye(3));


mytimer = toc;

R_normal = reshape(reshape(G_normal,[H*W 3]) * G_final', [H W 3]);
R_normal = R_normal ./ repmat(sqrt(sum(R_normal.^2,3)),[1 1 3]);
R_normal(repmat(~ign_mask,[1 1 3])) = 0;
assert(sum(isnan(R_normal(:))) + sum(isinf(R_normal(:))) == 0);
R_normal = reshape(R_normal,[H W 3]);

z = DepthMap_robust_fast(R_normal, ign_mask);
figure(2); imagesc(z); axis equal;
R_normal(:,:,1:2) = -R_normal(:,:,1:2);
save([datadir filesep 'recovered_normal_map.mat'], 'R_normal');

% % Integration
% S_normal = reshape(S_spec,[H W 3]);
% S_normal(repmat(~ign_mask,[1 1 3])) = 0;
% assert(sum(isnan(S_normal(:))) + sum(isinf(S_normal(:))) == 0);

depth2point(z, ign_mask, [datadir filesep 'depth.obj']);
