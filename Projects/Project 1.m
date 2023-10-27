% ENME 337 Project 1, Ahmed Almousawi, 30140399, ahmed.almousawi1@ucalgary.ca
clc
clear

% Part A

syms t

V = (24 * pi * 10^2) + (4/3 * pi * 10^3) - (pi * (10 - t)^2 * 24 + 4/3 * pi * (10-1.5*t)^3) == 42.27/0.101;

% Solve for all of the roots.
roots = vpasolve(V, t);

% Solve for t more directly, using the [-Inf, Inf] to exclude any non-real
% answers.
cyl_thickness = double(vpasolve(V, t, [-Inf, Inf]));
sph_thickness = 1.5 * cyl_thickness;
fprintf('Solving the equation produces the following three roots.\n')
disp(roots)
fprintf('Naturally, the real root is the solution we need.\n')
fprintf('Thus, the cylinderical thickness is %.4f in. and the head thickness is %.4f in. \n', cyl_thickness, sph_thickness)

% Part B
syms p

% Create an array of pressures from 100 - 400 psi with 5 psi increments.
pressures = 100:5:400;

% Create the two thickness equations from the lab manual
t_cyl = 10 * (exp(p/(20000 * 1)) - 1);
t_sph = 10 * (exp((0.5 * p)/(20000 * 1)) - 1);

% Creates two new arrays for minimum thickness by substituting p with the 
% pressure values from above.
min_cyl_thickness = double(vpa(subs(t_cyl, p, pressures), 5));
min_sph_thickness = double(vpa(subs(t_sph, p, pressures), 5));


% Finds the values where the thickness doesn't exceed ASME requirements.
allowed_cyl = find(min_cyl_thickness < cyl_thickness);
allowed_sph = find(min_sph_thickness < sph_thickness);

% Takes the shorter array, as fewer allowed values means that it will be
% the limiting factor in the design.
if length(allowed_cyl) < length(allowed_sph)
    p_limited_index = length(allowed_cyl);
else
    p_limited_index = length(allowed_sph);
end

% Gets the maximum pressure
max_p = pressures(p_limited_index);

% Plots the min. allowable thickness lines versus pressure. When the
% minimum thickness exceeds the actual thickness, the line turns red.
figure(1)
a_cyl = plot(pressures(1:p_limited_index+1), min_cyl_thickness(1:p_limited_index+1), '-o');
title('Minimum Allowable Thickness versus Pressure')
xlabel('Pressure (psi)')
ylabel('Thickness (in)')
hold on
a_sph = plot(pressures, min_sph_thickness, '-square');
da_cyl = plot(pressures(p_limited_index+1:61), min_cyl_thickness(p_limited_index+1:61), '-or');
yline(cyl_thickness, 'r:')
hold off
legend([a_cyl a_sph da_cyl], {'Allowed Cylinder Thickness', 'Allowed Hemispherical Thickness', 'Disallowed Cylinder Thickness'}, 'Location','northwest')

% Alternate plot that instead shows when the entire tank no longer meets
% expecations
%{
figure(2)
a_cyl = plot(pressures(1:p_limited_index), min_cyl_thickness(1:p_limited_index), '-o');
title('Minimum Allowable Thickness versus Pressure')
xlabel('Pressure (psi)')
ylabel('Thickness (in)')
hold on
a_sph = plot(pressures(1:p_limited_index), min_sph_thickness(1:p_limited_index), '-square');
da_cyl = plot(pressures(p_limited_index:61), min_cyl_thickness(p_limited_index:61), '-or');
da_sph = plot(pressures(p_limited_index:61), min_sph_thickness(p_limited_index:61), '-squarer');
hold off
legend([a_cyl a_sph da_cyl da_sph], {'Allowed Cylinder Thickness', 'Allowed Hemispherical Thickness', 'Disallowed Cylinder Thickness', 'Disallowed Hemispherical Thickness'})
%}

fprintf('The allowable internal pressure range for the tank is from 0 - %.0f psi. \n', max_p)
if max_p < 400
disp('This tank does NOT meet the thickness requirements for the desired operating range.')
end
