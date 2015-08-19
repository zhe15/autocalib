function [normals,lights] = gbrTransform(lambda,mu,nu,normals,lights)
% Transform the normals field and light directions by a GBR.
% The returned variables are not normalized.
% The function can handle mutiple light directions, as long as the variable
% lights is a 3xf matrix.

G = [lambda 0 mu;
     0 lambda nu;
     0      0 1];
normals = normals * G';
lights  = inv(G') * lights;

% Update: add the following normalization step to for faster speed.
% Oct 14, 2012
normals = normals ./ repmat(sqrt(sum(normals.^2,2)),[1 3]);
lights  = lights ./ repmat(sqrt(sum(lights.^2,1)),[3 1]);

end
