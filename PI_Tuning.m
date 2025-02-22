clc; 
clear; 
close all;

wc = 20; %% Crossover Frequency 
s = tf('s');
plant = 36 / (s^2 * 0.02 * (2.5e-6) + (0.02/300) * s + 1);
opts = pidtuneOptions('PhaseMargin', 90, 'DesignFocus','disturbance-rejection'); 
[C,info] = pidtune(plant,'pi',wc,opts);

figure 
margin(C*plant)
