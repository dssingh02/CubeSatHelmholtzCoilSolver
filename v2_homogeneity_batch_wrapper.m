clear;

% physical parameters
I = [1,1,1,1]; % current in A
R = 1; % coil radius
dD_series = linspace(-0.045,0.06,9)';

n = 20; % curve parameter: must be an even integer
N = [100,100,100,100]; % number of turns
start_angle = 0; % coil start angle
end_angle = 2*pi; % coil end angle

% simulation parameters
num_elements = 1000;

params = cell(length(dD_series));
r_homogenous = NaN(length(dD_series), 2);

for param_iter = 1:length(dD_series)
    dD = dD_series(param_iter);

    D = 1/2+dD; % coil-to-coil separation

    % initialize coils
    [r{1}, dl{1}, t{1}] =  define_coils_squircle(3, n, R, D, ...
        start_angle, end_angle, num_elements);
    [r{2}, dl{2}, t{2}] =  define_coils_squircle(3, n, R, -D, ...
        start_angle, end_angle, num_elements);

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

    figure(5)
    clf;
    plot(dD_series, r_homogenous(:,1), '-o');
    hold on;
    plot(dD_series, r_homogenous(:,2), '-o');
    hold off;
end

save('runs\2022-09-29-simtest', 'dD_series', 'params', 'r_homogenous');


