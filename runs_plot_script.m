clear;

%% homogeneity tests
% import circle data (n = 2)
load runs\2022-09-29-sim1.mat
dD_circle = [dD_series'];
r_h_circle = [r_homogenous];

load runs\2022-09-29-sim2.mat
dD_circle = [dD_circle; dD_series'];
r_h_circle = [r_h_circle; r_homogenous];

[dD_circle, idx] = sort(dD_circle);
r_h_circle = r_h_circle(idx,:);

% import squircle data (n = 20)
load runs\2022-09-29-sim3.mat
dD_squircle = [dD_series];
r_h_squircle = r_homogenous;

load runs\2022-09-29-sim4.mat
dD_squircle = [dD_squircle; dD_series];
r_h_squircle = [r_h_squircle; r_homogenous];

[dD_squircle, idx] = sort(dD_squircle);
r_h_squircle = r_h_squircle(idx,:);

plt_sym = '-.';

figure(1)
clf;
hold on;
p1 = plot(dD_circle, r_h_circle(:,1), 'r-x', 'LineWidth',1);
p3 = plot(dD_squircle, r_h_squircle(:,1), 'b-x', 'LineWidth',1);
p2 = plot(dD_circle, r_h_circle(:,2), 'r--s', 'LineWidth',1);
p4 = plot(dD_squircle, r_h_squircle(:,2), 'b--s', 'LineWidth',1);
hold off;
ylim([0.1,0.5])

p1.DisplayName = 'Circular coils (Magnitude)';
p2.DisplayName = 'Circular coils (Direction)';
p3.DisplayName = 'Square coils (Magnitude)';
p4.DisplayName = 'Square coils (Direction)';

lgd = legend();
lgd.Location = 'south';

xlabel('Displacement from Conventional Coil Separation (m)')
ylabel('Radius of Homogeneous Field Sphere (m)')

%% direction tests

load runs\2022-09-29-sim5.mat

figure(5)
clf;
hold on;
p1 = plot(theta_series, r_homogenous(:,1), 'b-x', 'LineWidth',1);
p2 = plot(theta_series, r_homogenous(:,2), 'b--s', 'LineWidth',1);
hold off;

p1.DisplayName = 'Square coils (Magnitude)';
p2.DisplayName = 'Square coils (Direction)';
ylim([0.1,0.5])

lgd = legend();
lgd.Location = 'south';

xlabel('Theta (rad)')
ylabel('Radius of Homogeneous Field Sphere (m)')

figure(6)
clf;
plot(theta_series, theta_sim, 'b-o', 'LineWidth',1);

xlabel('Desired theta (rad)')
ylabel('Simulated theta (rad)')
