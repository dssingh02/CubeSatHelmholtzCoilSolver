%% constants

% physical constants
mu0 = 4*pi*10^(-7);

% plotting colors
clrs = [174,118,163;25,101,176;123,175,222;144,201,135;247,240,86;241,147,45;
    220,5,12;209,187,215;136,46,114;82,137,199;78,178,101;202,224,171;
    246,193,65;232,96,28;119,119,119];
clrs = clrs./255;

%% solve field in a volume

Z_plane = 0;

x_q = 0;
y_q = 0;
z_q = 0;

[X,Y,Z] = meshgrid(x_q, y_q, z_q);

domain_r = [X(:), Y(:), Z(:)];

[B] = solve_B_iterative(r, dl, t, I, N, domain_r, mu0);

%% unwrap field in the volume

B_x = B(:,1);
B_y = B(:,2);
B_z = B(:,3);

B_x = reshape(B_x, [length(x_q), length(y_q), length(z_q)]);
B_y = reshape(B_y, [length(x_q), length(y_q), length(z_q)]);
B_z = reshape(B_z, [length(x_q), length(y_q), length(z_q)]);
B_mag = sqrt(B_x.^2 + B_y.^2 + B_z.^2);

B_x(B_mag > 10^-3) = NaN;
B_y(B_mag > 10^-3) = NaN;
B_z(B_mag > 10^-3) = NaN;
B_mag(B_mag > 10^-3) = NaN;
