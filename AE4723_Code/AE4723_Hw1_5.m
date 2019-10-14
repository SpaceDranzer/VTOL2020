%% Problem 5
clc;clear all;close all;
% determine expressions for accelerated climbing turn maneuver

% Start with gross motion equations for accelerated flight
% x: T - D - W*sin(gamma) = m*V_dot
% y: L*sin(phi) = m*V*cos(gamma)*psi_dot
% z: L*cos(phi) - W*cos(gamma) = m*V*gamma_dot

% Plot motion of plane (assuming properties of Gulfstream IV) to check if
% equations satisfy constant acceleration and radius of curvature

% Define aircraft properties
W = 73000;      % lbf
S = 950;        % ft^2
Cd0 = 0.015;    % unitless
K = 0.0797;     % unitless
W2S = W/S;      % lbf/ft^2

% Initial conditions
h(1) = 1000;        % altitude, ft
x(1) = 0;           % ft
y(1) = 0;           % ft
psi = 0;            % initial heading, radians
V = 300;            % initial velocity, ft/s

% Proerties of trajectory
gamma = 1;          % flight path angle, degrees
Cos = cosd(gamma);
Sin = sind(gamma);
a0 = 1;             % acceleration, ft/s^2
R = 3000;           % radius of curvature, ft
Cl = 1.6;           % coefficient of lift constant (multiplied by angle of attack to return true coefficient of lift), unitless
g = 32.15;          % acceleration of gravity, ft/s^2

% Setup numerical integration
dt = 0.01;          % seconds
time = 0:dt:240;    % seconds
range = ones(size(time));   % used to plot constants against time
% Setup vectors to record data (to plot later)
V_theoretical = V + a0*time;
V_net(1) = V;       % ft/s
V_dot(1) = a0;
psi_net(1) = psi;   % radians
Velocity(:,1) = [V*Cos*cos(psi); V*Cos*sin(psi); V*Sin];    % ft/s
r(1) = R;           % ft

for i = 2:numel(time)
    % Split velocity into directional components
    Velocity(:,i) = [V*Cos*cos(psi); V*Cos*sin(psi); V*Sin];
    % Find current position (based on previous velocity)
    x(i) = x(i-1) + Velocity(1,i-1)*dt;
    y(i) = y(i-1) + Velocity(2,i-1)*dt;
    h(i) = h(i-1) + Velocity(3,i-1)*dt;
    % Find density of atmosphere at given altitude
    [~,rho] = Std_Atm_Model(h(i),0); 
    % Dynamic pressure (lbf/ft^2)
    Q = 0.5*rho*V^2;
    % Angle of attack (radians)
    alpha = (W2S/(Q*Cl))*sqrt(Cos^2 + (V^4/(g*R)^2));
    % Bank angle (Degrees)
    phi(i) = atand(V^2/(R*g));
    % Required thrust (lbf)
    T(i) = W*(Sin + a0/g)+ Q*S*(Cd0 + K*alpha^2*Cl^2);
    % Drag experienced by aircraft at current velocity and altitude (lbf)
    D = Q*S*(Cd0 + K*(alpha*Cl)^2);
    % Lift generated by aircraft (lbf)
    L = Q*S*Cl*alpha;
    % Load factor (unitless)
    n = L/W;
    % Radius of curvature (ft); generated to see if it stays constant
    r(i) = V^2/(g*sqrt(n^2 - 1));
    % acceleration along velocity vector (ft/s^2); should equal a0
    V_dot(i) = (T(i) - D - W*Sin)/(W/g);
    % Rate of change of heading angle (rad/s)
    psi_dot = V/r(i);
    % Heading (rad)
    psi = psi + psi_dot*dt;
    % Concatentate headings
    psi_net(i) = psi;
    % Calculate airspeed (ft/s)
    V = V + V_dot(i)*dt;
    % Concatenate airspeeds
    V_net(i) = V;    
end
% Plot velocity vs. Time
figure
plot(time,V_net,'b', time, V_theoretical,'r--')
xlabel('Time (seconds)')
ylabel('Airspeed (ft/s)');
title('Velocity vs. Time')
legend('Numerically Integrated Airspeed','Theoretical Airspeed')

% Plot acceleration vs. Time
figure
plot(time,V_dot,'b', time, a0*range,'r--')
xlabel('Time (seconds)')
ylabel('Acceleration (ft/s^2)');
title('Acceleration vs. Time')
legend('Numerically Integrated Acceleration','Theoretical Acceleration')

% Plot radius of curveature vs. time
figure
plot(time,r,'b', time, (R)*range,'r*')
xlabel('Time (seconds)')
ylabel('Radius of Curvature (ft)');
title('R vs. Time')
legend('Numerically Integrated Radius','Theoretical Radius')

% Plot bank angle vs. time
figure
plot(time(2:end),phi(2:end))
xlabel('Time (seconds)')
ylabel('Bank Angle (degrees)');
title('Phi vs. Time')

% Plot components of velocity vs. time
figure
subplot(311);plot(time,Velocity(1,:))
ylabel('Vx (ft/s)');
title('Velocity Components vs. Time')
subplot(312);plot(time,Velocity(2,:))
ylabel('Vy (ft/s)');
subplot(313);plot(time,Velocity(3,:))
ylabel('Vz (ft/s)');
xlabel('t (s)');


% Plot position vs. time
figure
plot3(x,y,h)
xlabel('x (ft)')
ylabel('y (ft)')
zlabel('h (ft)')
title('Climbing Turn')
