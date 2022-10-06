clear;

% physical parameters
R = 1; % coil radius
dD = 0.05;
D = 1/2+dD; % coil-to-coil separation
n = 20; % curve parameter: must be an even integer
N = [100,100,100,100]; % number of turns
start_angle = 0; % coil start angle
end_angle = 2*pi; % coil end angle

% simulation parameters
num_elements = 1000;

% initialize coils
[r{1}, dl{1}, t{1}] =  define_coils_squircle(1, n, R, D, ...
    start_angle, end_angle, num_elements);
[r{2}, dl{2}, t{2}] =  define_coils_squircle(1, n, R, -D, ...
    start_angle, end_angle, num_elements);
[r{3}, dl{3}, t{3}] =  define_coils_squircle(2, n, R, D, ...
    start_angle, end_angle, num_elements);
[r{4}, dl{4}, t{4}] =  define_coils_squircle(2, n, R, -D, ...
    start_angle, end_angle, num_elements);

theta_series = linspace(0,pi/2,10)';
params = cell(length(theta_series));
r_homogenous = NaN(length(theta_series), 2);
theta_sim = NaN(length(theta_series), 1);

for param_iter = 1:length(theta_series)
    I1 = 1*cos(theta_series(param_iter));
    I2 = 1*sin(theta_series(param_iter));

    I = [I1,I1,I2,I2]; % current in A

    num_coils = length(r);

    v2_sim_wrapper_batch
    c_params.I = I;
    c_params.R = R;
    c_params.D = D;
    c_params.n = n;
    c_params.start_angle = start_angle;
    c_params.end_angle = end_angle;
    c_params.num_elements = num_elements;
    c_params.num_coils = num_coils;
    c_params.coils = r;

    params{param_iter} = c_params;

    r_homogenous(param_iter,1) = r_s_mag;
    r_homogenous(param_iter,2) = r_s_dir;

    theta_sim(param_iter) = atan2(B_y_mid, B_x_mid);

    figure(5)
    clf;
    plot(theta_series, r_homogenous(:,1), '-o');
    hold on;
    plot(theta_series, r_homogenous(:,2), '-o');
    hold off;

    figure(6)
    clf;
    plot(theta_series, theta_sim, '-o');

end

save('runs\2022-09-29-sim5', 'theta_series', 'params', 'r_homogenous', 'theta_sim');


