close all; clear; clc;

% Load images(Iall), light color(L) and mask(mask)

% Detect shadow
fprintf('Detecting shadow region ...');
thres = 0.030;
vis_mask = detectShadow(Iall, thres, mask);
fprintf('Done.\n');

% Find diffuse color
fprintf('Estimating diffuse colors ...');
diffColor = estimateDiffColor(Iall, L, mask, vis_mask);
assert(all(~isnan(diffColor(:)) & ~isinf(diffColor(:))));
fprintf('Done.\n');

% Separation
fprintf('Separating highlights ...');
spec_smooth = 1.0;
[diffImages, specImages] = sepHighlight_smooth(Iall,diffColor,L,mask,spec_smooth);
fprintf('Done.\n');
