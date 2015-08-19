function depth2point(z, ign_mask, filename)

% convert a depth map to 3D point cloud

[H W] = size(ign_mask);
inds = [1:H*W]';
inds = inds(ign_mask(:));

[h,w] = ind2sub([H W],inds);

d = z(ign_mask);

fid = fopen(filename,'w');
if fid < 0
    fprintf('cannot open %s for writing.\n', filename);
    return;
end

for i = 1:length(inds)
    fprintf(fid,'v %f %f %f\n',h(i),w(i),d(i));
end
fclose(fid);
