% clear

%% constants

% physical constants
mu0 = 4*pi*10^(-7);

% physical parameters
I = [1,1,1,1]; % current in A
R = 1; % coil radius
dD = 0.01;
D = 1/2+dD; % coil-to-coil separation
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
% [r{3}, dl{3}, t{3}] =  define_coils_squircle(1, n, R, D, ...
%     start_angle, end_angle, num_elements);
% [r{4}, dl{4}, t{4}] =  define_coils_squircle(1, n, R, -D, ...
%     start_angle, end_angle, num_elements);

num_coils = length(r);

%% solve field in a volume

Z_plane = 0;

x_q = linspace(-0.8,0.8,40);
y_q = linspace(-0.8,0.8,40);
z_q = linspace(-0.8,0.8,40);

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

%% calculate homogenous volume

% get center magnitude and direction
B_x_mid = interp3(X,Y,Z,B_x,0,0,0);
B_y_mid = interp3(X,Y,Z,B_y,0,0,0);
B_z_mid = interp3(X,Y,Z,B_z,0,0,0);
B_mag_mid = sqrt(B_x_mid^2 + B_y_mid^2 + B_z_mid^2);

% calculate relative magnitude deviation
mag_dev_frac = abs(((B_mag) - (B_mag_mid))/(B_mag_mid));
mag_dev_threshold = 0.01;

% calculate direction deviation in degrees
center_unit_vec = [B_x_mid, B_y_mid, B_z_mid];
center_unit_vec = center_unit_vec/norm(center_unit_vec);
dir_dev_deg = real(acos((center_unit_vec(:,1)*B_x + center_unit_vec(:,2)*B_y + center_unit_vec(:,3)*B_z)./sqrt(B_x.^2 + B_y.^2 + B_z.^2)));
dir_dev_deg = rad2deg(dir_dev_deg);
dir_dev_deg_threshold = 1;


% plot slice
figure(1)
clf;
[x_slice,y_slice,z_slice] = meshgrid(x_q,y_q,0.3);
slice(X,Y,Z,mag_dev_frac,x_slice,y_slice,z_slice,'nearest');
colormap jet
colorbar
caxis([0,0.1])

figure(2)
clf;
[x_slice,y_slice,z_slice] = meshgrid(x_q,y_q,0.3);
slice(X,Y,Z,dir_dev_deg,x_slice,y_slice,z_slice,'nearest');
colormap jet
colorbar
caxis([0,5])


%% Plot field lines in a volume

[startX,startY,startZ] = meshgrid([-0.8:0.2:0.8],[-0.8:0.2:0.8],0.8);
verts = stream3(X,Y,Z,B_x,B_y,B_z,startX,startY,startZ);

[startX,startY,startZ] = meshgrid(-0.8,[-0.8:0.2:0.8],[-0.8:0.2:0.8]);
verts2 = stream3(X,Y,Z,B_x,B_y,B_z,startX,startY,startZ);

[fo,vo] = isosurface(X,Y,Z,mag_dev_frac,mag_dev_threshold);                            

[x_s,y_s,z_s] = sphere;
r_iso = sqrt(vo(:,1).^2 + vo(:,2).^2 + vo(:,3).^2);
r_s_mag = min(r_iso(:));

x_s = x_s*r_s_mag;
y_s = y_s*r_s_mag;
z_s = z_s*r_s_mag;

figure(3)
clf;
hold on;
for i = 1:length(r)
    plot3(r{i}(:,1),r{i}(:,2),r{i}(:,3));
end
lineobj = streamline(verts);
% lineobj2 = streamline(verts2);
for i = 1:length(lineobj)
    lineobj(i).LineWidth = 1;
    lineobj(i).Color = [clrs(6,:),0.4];
end
% for i = 1:length(lineobj2)
%     lineobj2(i).LineWidth = 1;
%     lineobj2(i).Color = [clrs(6,:),0.4];
% end
p1 = patch('Faces', fo, 'Vertices', vo);       
p1.FaceColor = 'red';
p1.FaceAlpha = 0.2;
p1.LineStyle = 'none';
s = surf(x_s,y_s,z_s);
s.FaceColor = 'g';
s.EdgeAlpha = 0;
s.FaceAlpha = 0.4;
hold off;
xlabel('x (m)')
ylabel('y (m)')
zlabel('z (m)')
view(-30,30)
axis image;

[fo,vo] = isosurface(X,Y,Z,dir_dev_deg,dir_dev_deg_threshold);                            

[x_s,y_s,z_s] = sphere;
r_iso = sqrt(vo(:,1).^2 + vo(:,2).^2 + vo(:,3).^2);
r_s_dir = min(r_iso(:));

x_s = x_s*r_s_dir;
y_s = y_s*r_s_dir;
z_s = z_s*r_s_dir;

figure(4)
clf;
hold on;
for i = 1:length(r)
    plot3(r{i}(:,1),r{i}(:,2),r{i}(:,3));
end
lineobj = streamline(verts);
% lineobj2 = streamline(verts2);
for i = 1:length(lineobj)
    lineobj(i).LineWidth = 1;
    lineobj(i).Color = [clrs(6,:),0.4];
end
% for i = 1:length(lineobj2)
%     lineobj2(i).LineWidth = 1;
%     lineobj2(i).Color = [clrs(6,:),0.4];
% end
p1 = patch('Faces', fo, 'Vertices', vo);       
p1.FaceColor = 'red';
p1.FaceAlpha = 0.2;
p1.LineStyle = 'none';
s = surf(x_s,y_s,z_s);
s.FaceColor = 'g';
s.EdgeAlpha = 0;
s.FaceAlpha = 0.4;
hold off;
xlabel('x (m)')
ylabel('y (m)')
zlabel('z (m)')
view(-30,30)
axis image;
