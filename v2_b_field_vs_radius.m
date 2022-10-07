clear;

clear;

% physical parameters
I = [1,1,1,1]; % current in A
R_series = linspace(0.1,1,100); % coil radius
dD_series = 0.05*R_series;

n = 20; % curve parameter: must be an even integer
N = [100,100,100,100]; % number of turns
start_angle = 0; % coil start angle
end_angle = 2*pi; % coil end angle

% simulation parameters
num_elements = 1000;

params = cell(length(R_series), 1);
mid_B_field = NaN(length(R_series), 3);

for param_iter = 1:length(R_series)
    R = R_series(param_iter);
    dD = dD_series(param_iter);

    D = R/2+dD; % coil-to-coil separation

    % initialize coils
    [r{1}, dl{1}, t{1}] =  define_coils_squircle(3, n, R, D, ...
        start_angle, end_angle, num_elements);
    [r{2}, dl{2}, t{2}] =  define_coils_squircle(3, n, R, -D, ...
        start_angle, end_angle, num_elements);

    num_coils = length(r);

    v2_sim_wrapper_batch_2
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

    mid_B_field(param_iter,1) = B_x;
    mid_B_field(param_iter,2) = B_y;
    mid_B_field(param_iter,3) = B_z;

    figure(5)
    clf;
    plot(R_series, sqrt(mid_B_field(:,1).^2 + mid_B_field(:,2).^2 + mid_B_field(:,3).^2),...
        '-');
end

save('runs\2022-10-07-squircle-Bmax-vs-R', 'R_series', 'params', 'mid_B_field');


