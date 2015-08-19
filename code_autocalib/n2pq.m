% function [p,q] = n2pq(nx,ny,nz)
%
% Converts unit vectors on the Gauss sphere (e.g., surface normals) to
% gradient coordinates (p,q).
%
% Warning : Anywhere that nz == 0 will cause numerical precision errors.
function [p,q] = n2pq(nx,ny,nz)

nz(abs(nz(:))<eps) = eps;
p = -nx./nz;
q = -ny./nz;
