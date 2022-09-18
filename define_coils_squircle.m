function [r, dl, t] =  define_coils_squircle(axial_axis, n, R, D, ...
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
t = [drdt.*cos(t) - r.*sin(t), drdt.*sin(t) + r.*cos(t), zeros(length(r),1)];

if (axial_axis == 1)
    r = [r(:,1), r(:,2), r(:,3)];
    t = [t(:,1), t(:,2), t(:,3)];
elseif (axial_axis == 2)
    r = [r(:,3), r(:,1), r(:,2)];
    t = [t(:,3), t(:,1), t(:,2)];
else
    r = [r(:,2), r(:,3), r(:,1)];
    t = [t(:,2), t(:,3), t(:,1)];
end

t = t./sqrt(t(:,1).^2 + t(:,2).^2 + t(:,3).^2);


end