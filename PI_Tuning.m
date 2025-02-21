clc; 
clear; 
close all;

% Plant Transfer Function 
s = tf('s');
plant = 3.3 / (s^2 * 0.02 * (2.5e-6) + (0.02/300) * s + 1);

% Target crossover frequency and phase margin
wc = 10;  % Desired crossover frequency in rad/s
pm = 60;  % Desired phase margin in degrees

% Use "pidtune" for initial K_p and K_i values 
parameters = pidtune(plant, 'PI', wc);
Kp = parameters.Kp;
Ki = parameters.Ki;

% Ensure Kp0 and Ki0 are positive
if Kp <= 0, Kp = 1e-3; end
if Ki <= 0, Ki = 1e-3; end

% Optimization using fmincon
options = optimoptions('fmincon', 'Display', 'iter', 'Algorithm', 'sqp');

% Initial guess
x0 = [Kp, Ki];

% Bounds for Kp and Ki
lb = [Kp*0.1, Ki*0.1];
ub = [Kp*10, Ki*10];

% Constraint function
nonlincon = @(x) enforce_constraints(x, plant, wc, pm);

% Optimize
optimal_params = fmincon(@(x) cost_function(x, plant, wc), x0, [], [], [], [], lb, ub, nonlincon, options);

% Extract optimal Kp and Ki
optimal_Kp = optimal_params(1);
optimal_Ki = optimal_params(2);

% Define optimized PI controller
C_optimal = pid(optimal_Kp, optimal_Ki);

% Closed-loop system
loop_transfer = C_optimal * plant;
closed_loop = feedback(loop_transfer, 1);

% Compute margins
[gm, pm, wcg, wcp] = margin(loop_transfer);

% Display results
fprintf('Optimal Kp: %.6f\n', optimal_Kp);
fprintf('Optimal Ki: %.6f\n', optimal_Ki);
fprintf('Achieved crossover frequency: %.2f rad/s\n', wcp);
fprintf('Achieved phase margin: %.2f°\n', pm);

% Plot Bode and Step Response
figure;
margin(loop_transfer);
title('Bode Plot of Optimized PI Controller');

figure;
step(closed_loop);
title('Step Response with Optimized PI Controller');

%% Cost function (minimize deviation from wc_target)
function cost = cost_function(x, plant, wc_target)
    Kp = x(1);
    Ki = x(2);
    C = pid(Kp, Ki);
    loop_transfer = C * plant;

    % Compute actual crossover frequency
    [~, ~, ~, wcp] = margin(loop_transfer);
    
    % Penalize deviation from wc_target
    cost = (wcp - wc_target)^2;
end

%% Constraint function (ensure phase margin >= pm_target)
function [c, ceq] = enforce_constraints(x, plant, wc_target, pm_target)
    Kp = x(1);
    Ki = x(2);
    C = pid(Kp, Ki);
    loop_transfer = C * plant;

    % Compute actual crossover frequency and phase margin
    [gm, pm, wcg, wcp] = margin(loop_transfer);

    % Constraints:
    % 1. Phase margin should be >= pm_target (should be non-negative)
    c = pm_target - pm;

    % 2. Enforce the crossover frequency to match wc_target (equality constraint)
    ceq = wcp - wc_target;
end
