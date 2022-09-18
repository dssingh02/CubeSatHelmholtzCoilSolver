clear;

%% constants

% physical constants
mu0 = 4*pi*10^(-7);

% physical parameters
I = 1.5; % current in A
R = 1; % coil radius
D = 1; % coil-to-coil separation
n = 2; % curve parameter: must be an even integer
N = 100; % number of turns

% simulation parameters
num_elements = 1000;

%% initialization

% parametrization variable
t = linspace(0,2*pi,num_elements)';
% t = t(1:end-1)'; % remove last element
dt = t(2)-t(1);

r = R*((cos(t)).^n + (sin(t)).^n).^(-1/n); % r(t)
drdt = R*((cos(t)).^n + (sin(t)).^n).^(-1/n - 1).*( sin(t).*((cos(t)).^(n-1)) - cos(t).*((sin(t)).^(n-1))); % dr(t)/dt
dl = sqrt((r).^2 + (drdt).^2)*dt;

% coil element positions
coils_r{1} = [r.*cos(t), r.*sin(t),  ones(length(r),1)*D/2]; % top coil
coils_r{2} = [r.*cos(t), r.*sin(t), -ones(length(r),1)*D/2]; % bottom coil

% coil tangents
coils_t{1} = [drdt.*cos(t) - r.*sin(t), drdt.*sin(t) + r.*cos(t), zeros(length(r),1)];
coils_t{2} = [drdt.*cos(t) - r.*sin(t), drdt.*sin(t) + r.*cos(t), zeros(length(r),1)];

% normalization coil tangents
for i = 1:length(coils_t)
    coils_t{i} = coils_t{i}./sqrt(coils_t{i}(:,1).^2 + coils_t{i}(:,2).^2 + coils_t{i}(:,3).^2);
end

% query points
x_q = linspace(-2*R,2*R,1000);
y_q = zeros(length(x_q),1);
z_q = zeros(length(x_q),1);

r_q = [x_q(:), y_q(:), z_q(:)];

% plot coils and query points
figure(1)
clf;
hold on;
for i = 1:length(coils_r)
    plot3(coils_r{i}(:,1),coils_r{i}(:,2),coils_r{i}(:,3));
    quiver3(coils_r{i}(:,1),coils_r{i}(:,2),coils_r{i}(:,3),coils_t{i}(:,1),coils_t{i}(:,2),coils_t{i}(:,3));
end
plot3(r_q(:,1),r_q(:,2),r_q(:,3),'r');
hold off;
view(-30,30)
axis image;

% computation
B = zeros(length(r_q),3);

tic
for i = 1:length(coils_r)
    for j = 1:length(r_q)
        r_q_temp = repmat(r_q(j,:), [length(coils_r{i}), 1]);
        r_rel = (r_q_temp-coils_r{i});
        temp_integral = dl.*cross(coils_t{i},r_rel)./sqrt(r_rel(:,1).^2 + r_rel(:,2).^2 + r_rel(:,3).^2).^3;
        B_temp = (mu0/(4*pi))*I*sum(temp_integral,1);
        B_temp = B_temp*N;
        B(j,:) = B(j,:) + B_temp;
    end
end
toc

% results
figure(2)
clf;
hold on;
plot(repmat(x_q(:),[1,3]), 10000*B)
hold off;


