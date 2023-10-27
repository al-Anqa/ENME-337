% ENME 337 Assignment 4, Ahmed Almousawi, 30140399, ahmed.almousawi1@ucalgary.ca
clc
clear

temperatures = [145 130 103 90];
times = [0 620 2266 3482];

subplot(2, 1, 1)
plot(times, temperatures, '*-')
title('Experimental Temperatures vs. Time')
xlabel('Time [s]')
ylabel('Temperature [°F]')

times_interp = 0:20:3482;
temp_interp = interp1(times, temperatures, times_interp, 'spline');

% Gets the equation for the interpolated polynomial
ip = spline(times_interp, temp_interp);

% Gets the inverse spline in order to solve for the t for 120 F
inv_ip = spline(temp_interp, times_interp);
t_120 = ppval(inv_ip, 120);

subplot(2, 1, 2)
plot(times, temperatures, 'b*', 'linewidth',1.1')
hold on
plot(times_interp, temp_interp, '--r.')
plot(t_120, ppval(ip, t_120), 'xk', 'linewidth',2)
line([0, t_120], [120, 120], 'color','black','linestyle','--', 'linewidth', 1.1)
line([t_120, t_120], [0, 120], 'color','black','linestyle','--', 'linewidth', 1.1)
legend('Experimental Temperatures', 'Interpolated Temperatures', '120 °F', Location='southeast')
title('Experimental and Interpolated Temperatures vs. Time')
xlabel('Time [s]')
ylabel('Temperature [°F]')
hold off

fprintf('The drink reaches 120 °F after %.2f seconds. \n', t_120)
fprintf('This can also be represented as %.0f minutes and %.2f seconds \n', floorDiv(t_120, 60), t_120 - floorDiv(t_120, 60) * 60)

