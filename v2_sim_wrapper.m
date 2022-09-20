clear;

%% constants

% physical constants
mu0 = 4*pi*10^(-7);

% physical parameters
I = [1,1,1,1]; % current in A
R = 1; % coil radius
D = 1/2; % coil-to-coil separation
n = 20; % curve parameter: must be an even integer
N = [100,100,100,100]; % number of turns
start_angle = 0; % coil start angle
end_angle = 2*pi; % coil end angle

% simulation parameters
num_elements = 1000;

% plotting colors
clrs = [174,118,163;25,101,176;123,175,222;144,201,135;247,240,86;241,147,45;
    220,5,12;209,187,215;136,46,114;82,137,199;78,178,101;202,224,171;
    246,193,65;232,96,28;119,119,119];
clrs = clrs./255;

%% initialize coils
[r{1}, dl{1}, t{1}] =  define_coils_squircle(3, n, R, D, ...
    start_angle, end_angle, num_elements);
[r{2}, dl{2}, t{2}] =  define_coils_squircle(3, n, R, -D, ...
    start_angle, end_angle, num_elements);
[r{3}, dl{3}, t{3}] =  define_coils_squircle(1, n, R, D, ...
    start_angle, end_angle, num_elements);
[r{4}, dl{4}, t{4}] =  define_coils_squircle(1, n, R, -D, ...
    start_angle, end_angle, num_elements);

%% solve field on a plane

Z_plane = 0;

x_q = linspace(-2,2,100);
y_q = linspace(-2,2,100);
z_q = linspace(Z_plane,Z_plane,1);

[X,Y,Z] = meshgrid(x_q, y_q, z_q);

domain_r = [X(:), Y(:), Z(:)];

% solve sheet - plane

[B] = solve_B_iterative(r, dl, t, I, N, domain_r, mu0);

% unwrap sheet - plane

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

% Plot results

q_scale_factor = 1000;

figure(1)
clf;
subplot(3,3,[1,2,4,5,7,8])
hold on;
for i = 1:length(r)
    plot3(r{i}(:,1),r{i}(:,2),r{i}(:,3));
end
p = patch(2*[1 -1 -1 1], 2*[1 1 -1 -1], Z_plane*[1 1 1 1], [1 1 1 1]);
p.FaceAlpha = 0.2;
q = quiver3(X(:), Y(:), Z(:)-0.01, ...
    q_scale_factor*B_x(:), q_scale_factor*B_y(:), q_scale_factor*B_z(:));
q.AutoScale = 'off';
q.Color = 'r';
hold off;
xlabel('x (m)')
ylabel('y (m)')
zlabel('x (m)')
view(-30,30)
axis image;
xlim([-2,2])
ylim([-2,2])
zlim([-2,2])

title(sprintf('%i coils, N = %i turns, I = %.2f A, n_{shape} = %i, ',...
    length(r), N(1), I(1), n))

subplot(3,3,3)
imagesc(x_q, y_q, B_x)
axis image;
cbar = colorbar;
cbar.Label.String = 'B_x (T)';
caxis(2*[-10^-4,10^-4])
xlabel('x (m)')
ylabel('y (m)')

subplot(3,3,6)
imagesc(x_q, y_q, B_y)
axis image;
cbar = colorbar;
cbar.Label.String = 'B_y (T)';
caxis(2*[-10^-4,10^-4])
xlabel('x (m)')
ylabel('y (m)')

subplot(3,3,9)
imagesc(x_q, y_q, B_z)
axis image;
cbar = colorbar;
cbar.Label.String = 'B_z (T)';
caxis(2*[-10^-4,10^-4])
xlabel('x (m)')
ylabel('y (m)')


%% solve field on a plane - loop through

% vid = VideoWriter('run_1.mp4', 'MPEG-4');
% vid.FrameRate = 29.97;

% open(vid);
for Z_plane = linspace(-2,2,300)
    x_q = linspace(-2,2,100);
    y_q = linspace(-2,2,100);
    z_q = linspace(Z_plane,Z_plane,1);

    [X,Y,Z] = meshgrid(x_q, y_q, z_q);

    domain_r = [X(:), Y(:), Z(:)];

    % solve sheet - plane

    [B] = solve_B_iterative(r, dl, t, I, N, domain_r, mu0);

    % unwrap sheet - plane

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

    % Plot results

    q_scale_factor = 1000;

    figure(1)
    clf;
    subplot(3,3,[1,2,4,5,7,8])
    hold on;
    for i = 1:length(r)
        plot3(r{i}(:,1),r{i}(:,2),r{i}(:,3));
    end
    p = patch(2*[1 -1 -1 1], 2*[1 1 -1 -1], Z_plane*[1 1 1 1], [1 1 1 1]);
    p.FaceAlpha = 0.2;
    q = quiver3(X(:), Y(:), Z(:)-0.01, ...
        q_scale_factor*B_x(:), q_scale_factor*B_y(:), q_scale_factor*B_z(:));
    q.AutoScale = 'off';
    q.Color = 'r';
    hold off;
    xlabel('x (m)')
    ylabel('y (m)')
    zlabel('x (m)')
    view(-30,30)
    axis image;
    xlim([-2,2])
    ylim([-2,2])
    zlim([-2,2])

    title(sprintf('%i coils, N = %i turns, I = %.2f A, n_{shape} = %i, Z_{plane} = %.3f m',...
        length(r), N(1), I(1), n, Z_plane))

    subplot(3,3,3)
    imagesc(x_q, y_q, B_x)
    axis image;
    cbar = colorbar;
    cbar.Label.String = 'B_x (T)';
    caxis(2*[-10^-4,10^-4])
    xlabel('x (m)')
    ylabel('y (m)')

    subplot(3,3,6)
    imagesc(x_q, y_q, B_y)
    axis image;
    cbar = colorbar;
    cbar.Label.String = 'B_y (T)';
    caxis(2*[-10^-4,10^-4])
    xlabel('x (m)')
    ylabel('y (m)')

    subplot(3,3,9)
    imagesc(x_q, y_q, B_z)
    axis image;
    cbar = colorbar;
    cbar.Label.String = 'B_z (T)';
    caxis(2*[-10^-4,10^-4])
    xlabel('x (m)')
    ylabel('y (m)')

%     img = getframe(gcf);
%     vid.writeVideo(img);
end

% close(vid)

%% solve field in a volume

Z_plane = 0;

x_q = linspace(-2,2,100);
y_q = linspace(-2,2,100);
z_q = linspace(-2,2,100);

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

%% Plot field lines in a volume

[startX,startY,startZ] = meshgrid([-2:0.4:2],[-2:0.4:2],2);
verts = stream3(X,Y,Z,B_x,B_y,B_z,startX,startY,startZ);

[startX,startY,startZ] = meshgrid(-2,[-2:0.4:2],[-2:0.4:2]);
verts2 = stream3(X,Y,Z,B_x,B_y,B_z,startX,startY,startZ);

figure(1)
clf;
hold on;
for i = 1:length(r)
    plot3(r{i}(:,1),r{i}(:,2),r{i}(:,3));
end
lineobj = streamline(verts);
lineobj2 = streamline(verts2);
for i = 1:length(lineobj)
    lineobj(i).LineWidth = 2;
    lineobj(i).Color = [clrs(6,:),0.4];
end
for i = 1:length(lineobj2)
    lineobj2(i).LineWidth = 2;
    lineobj2(i).Color = [clrs(6,:),0.4];
end
hold off;
xlabel('x (m)')
ylabel('y (m)')
zlabel('z (m)')
view(-30,30)
axis image;
xlim([-2,2])
ylim([-2,2])
zlim([-2,2])

title(sprintf('%i coils, N = %i turns, I = %.2f A, n_{shape} = %i',...
        length(r), N(1), I(1), n))



