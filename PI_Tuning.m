clc; clear; close all;

% Define the plant transfer function
s = tf('s');
plant = 50 / (s^2 * 0.02 * (2.5e-6) + (0.02/300) * s + 1);

% Target crossover frequency and phase margin
wc_target = 10;  % Desired crossover frequency in rad/s
pm_target = 60;  % Desired phase margin in degrees

% Initial PI tuning using pidtune with target crossover frequency
C0 = pidtune(plant, 'PI', wc_target);
Kp0 = C0.Kp;
Ki0 = C0.Ki;

% Ensure Kp0 and Ki0 are positive
if Kp0 <= 0, Kp0 = 1e-3; end
if Ki0 <= 0, Ki0 = 1e-3; end

% Optimization using fmincon
options = optimoptions('fmincon', 'Display', 'iter', 'Algorithm', 'sqp');

% Initial guess
x0 = [Kp0, Ki0];

% Bounds for Kp and Ki
lb = [Kp0*0.1, Ki0*0.1];
ub = [Kp0*10, Ki0*10];

% Constraint function
nonlincon = @(x) enforce_constraints(x, plant, wc_target, pm_target);

% Optimize
optimal_params = fmincon(@(x) cost_function(x, plant, wc_target), x0, [], [], [], [], lb, ub, nonlincon, options);

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
