% ENME 337 Assignment 3, Ahmed Almousawi, 30140399, ahmed.almousawi1@ucalgary.ca
clc
clear

syms k x

drawing_area = 15 * 12;

boundary_curve = -k * x^2 + 12 * k * x;

integral_1 = int(boundary_curve, 0, 12);

% We need the integral of the boundry curve to be half of the overall area

eqn_a = 0.5 * drawing_area ==  integral_1;


% Get the necessary k value and substitute it into the boundary equation
k_true = solve(eqn_a);
boundary_curve = subs(boundary_curve, k, k_true);

% Now, make an array with the values of the curve from 0 to 12
selected_points = linspace(0, 12, 1000);
boundary_points = subs(boundary_curve, x, selected_points);

subplot(1, 2, 1);
rectangle("Position", [0 0 12 15], 'FaceColor', [1 0 0])
hold on
fplot(boundary_curve, [0 12], 'b');
axis([-1 13 -1 16])
fill(selected_points, boundary_points, 'b')
hold off

% Create a new boundary equation, with parameter p

syms p

% This curve is just something I thought looked cool on desmos.
new_curve = p * sqrt(x)+ 0.5 * x * p;
integral_2 = int(new_curve, 0, 12);

% Once more, integral of this curve must be half the area

eqn_b = 0.5 * drawing_area ==  integral_2;
p_true = solve(eqn_b);

new_curve = subs(new_curve, p, p_true);
new_points = subs(new_curve, x, selected_points);

% This differs from above because the function doesn't end at (12, 0), so
% we have to add two end points to "fill" the area underneath the curve
% against the axis
new_points = [0, new_points, 0];
selected_points = [0, selected_points, 12];


subplot(1, 2, 2);
rectangle("Position", [0 0 12 15], 'FaceColor', [1 0 0])
hold on
fplot(new_curve, [0 12]);
axis([-1 13 -1 16])
fill(selected_points, new_points, 'b')
hold off