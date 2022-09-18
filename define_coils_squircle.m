function [r, dl, r_tan] =  define_coils_squircle(axial_axis, n, R, D, ...
    start_angle, end_angle, num_el)
% Generate a parametrized coil with the shape of a squircle.
%
% Syntax: [r, dl, t] =  define_coils_squircle(axial_axis, n, R, D, N)
%
% Inputs:
%    axial_axis - Which axis aligns with the coil axial direction
%                   (x = 1, y = 2, z = 3; default = z-axis)
%    n - Squircle shape power parameter
%    R - Squircle radius
%    D - Distance from axis-plane
%    N - Number of discretized elements
%    start_angle - Start angle of squircle parametrization
%    end_angle - End angle of squircle parametrization
%
% Outputs:
%    r  - Discretized coil positions (num_el x 3)
%    dl - Coil lengths of each element (num_el x 1)
%    t  - Normalized tangent vectors for each element (num_el x 3)
%
% Author: Devdigvijay Singh, Princeton University
% Email: dssingh@princeton.edu
% Website: http://www.dave-singh.me
% Last revision: 13-September-2022

t = linspace(start_angle, end_angle, num_el)';
dt = t(2)-t(1);

r_radial = R*((cos(t)).^n + (sin(t)).^n).^(-1/n); % r(t)
drdt = R*((cos(t)).^n + (sin(t)).^n).^(-1/n - 1).*...
    ( sin(t).*((cos(t)).^(n-1)) - cos(t).*((sin(t)).^(n-1))); % dr(t)/dt
dl = sqrt((r_radial).^2 + (drdt).^2)*dt;

r = [ones(length(r_radial),1)*D, r_radial.*cos(t), r_radial.*sin(t)];
r_tan = [zeros(length(r_radial),1), drdt.*cos(t) - r_radial.*sin(t), ...
    drdt.*sin(t) + r_radial.*cos(t)];

if (axial_axis == 1)
    rot_mat = [1 0 0; 0 1 0; 0 0 1];
elseif (axial_axis == 2)
    rot_mat = [0 -1 0; 1 0 0; 0 0 1];
else
    rot_mat = [0 0 1; 0 1 0; -1 0 0];
end

r = (rot_mat*r')';
r_tan = (rot_mat*r_tan')';

r_tan = r_tan./sqrt(r_tan(:,1).^2 + r_tan(:,2).^2 + r_tan(:,3).^2);


end