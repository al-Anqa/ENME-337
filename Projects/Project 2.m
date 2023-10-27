% ENME 337 Project 2, Ahmed Almousawi, 30140399, ahmed.almousawi1@ucalgary.ca
clc
clear

% Part A
% Short for wind profile data
wpd = readmatrix('WindProfileData.xlsx', Range='B2:I110');

frict_v = @(z, z_0, u) ((0.4 * u) / log(z/z_0));
stab_corr = @(z, z_0, u, f) (log(z./z_0) - (0.4 * u)./f);

% Creates a matrix where col. 1 is time and col. 2 is frict_v @ z=10m
frict_v_10m = [wpd(:, 1), frict_v(10, 0.05, wpd(:, 2))];

% 6*8+1 is because each hour has 6 parts + one row for t=0
fprintf('The friction velocity at 10m and 8:00 is %.3f m/s \n', frict_v_10m(6 * 8 + 1, 2))

% A5, A6
stab_corr_60m = stab_corr(60, 0.05, wpd(:, 4), frict_v_10m(:, 2));
fprintf('The stability correction at 60m and 8:00 is %.3f \n', stab_corr_60m(6 * 8 + 1))

% A7
figure(1)
subplot(2, 1, 1)
plot(frict_v_10m(:, 1), frict_v_10m(:, 2))
title('Friction Velocity (10 m) vs. Time')
xlabel('Time (hr)')
ylabel('Friction Velocity (m/s)')
legend('Friction Velocity', 'Location','southeast')

subplot(2, 1, 2)
plot(wpd(:, 1), stab_corr_60m)
title('Stability Correction Factor (60 m) vs. Time')
xlabel('Time (hr)')
ylabel('Stability Correction Factor')
legend('Stability Correction Factor', 'Location','southeast')

%  Part B

% Get the calculated z_0 by plugging in the velocity at 10m, the height
% (10m), the velocity at 40m and the height (40m)
calculated_z_0 = SolveSimult(wpd(:, 2), 10, wpd(:, 3), 40);

figure(2)
plot(wpd(:, 1), calculated_z_0)
title('Calculated Roughness Length vs. Time')
xlabel('Time (hrs)')
ylabel('Surface Roughness Length (m)')
legend('Surface Roughness Length (m)', 'Location','northeast')
grid on

fprintf('The surface roughness at 8:00 is %.3f m/s \n', calculated_z_0(6 * 8 + 1))

% Part C

% Get the u_cubed values by... cubing the u. Then get RD by dividing them
% against eachother.
u_cube_10m = (wpd(:, 2)).^3;
u_cube_160m = (wpd(:, 8)).^3;
relative_diff = u_cube_160m ./ u_cube_10m;

% C3, C4
figure(3)
subplot(3, 1, 1)
plot(wpd(:, 1), u_cube_160m)
title('Wind Speed Cubed (160m) vs. Time')
xlabel('Time (hr)')
ylabel('Wind Speed Cubed [(m/s)^3)]')
legend('Wind Speed Cubed (160m)', 'Location','southeast')

subplot(3, 1, 2)
plot(wpd(:, 1), u_cube_10m)
title('Wind Speed Cubed (10m) vs. Time')
xlabel('Time (hr)')
ylabel('Wind Speed Cubed [(m/s)^3)]')
legend('Wind Speed Cubed (10m)', 'Location','southeast')

subplot(3, 1, 3)
plot(wpd(:, 1), relative_diff)
title('Relative Difference in Wind Speed Cubed (160m vs. 10m) vs. Time')
xlabel('Time (hr)')
ylabel('Relative Difference')
legend('Relative Difference', 'Location','southeast')

fprintf('The relative difference in wind speed cubed between 160m and 10m is %.3f \n', relative_diff(6 * 8 + 1))

% Part D
% The index for t = 8 hrs is 49, calculated above as 6 * 8 + 1

wind_speed_night_10m = wpd(1:49, 2);
wind_speed_day_10m = wpd(50:109, 2);

wind_speed_dist = 1:0.1:15;

% D4
mean_10m = mean(wpd(:, 2));
std_10m = std(wpd(:, 2));

mean_night_10m = mean(wind_speed_night_10m);
std_night_10m = std(wind_speed_night_10m);

mean_day_10m = mean(wind_speed_day_10m);
std_day_10m = std(wind_speed_day_10m);
% D5
normal_dist = pdf('Normal', wind_speed_dist, mean(wind_speed_dist), std(wind_speed_dist));

normal_dist_10m = pdf('Normal', wpd(:, 2), mean_10m, std_10m);
normal_dist_night_10m = pdf('Normal', wind_speed_night_10m, mean_night_10m, std_night_10m);
normal_dist_day_10m = pdf('Normal', wind_speed_day_10m, mean_day_10m, std_day_10m);
% D6
fprintf('The mean and std. dev. for windspeed at 10m is %.2f and %.2f, respectively. \n', mean_10m, std_10m)
fprintf('The mean and std. dev. for windspeed during the night for 10m is %.2f and %.2f, respectively. \n', mean_night_10m, std_night_10m)
fprintf('The mean and std. dev. for windspeed during the day for 10m is %.2f and %.2f, respectively. \n', mean_day_10m, std_day_10m)

% D7
% Line of best fit steps taken from 
% https://www.mathworks.com/matlabcentral/answers/377139-how-to-plot-best-fit-line#answer_300116

figure(4)
subplot(3, 1, 1)
scatter(wpd(:, 2), normal_dist_10m)
coeff_all = polyfit(wpd(:, 2), normal_dist_10m, 6);
x_points_all = linspace(min(wpd(:, 2)), max(wpd(:, 2)), 1000);
y_points_all = polyval(coeff_all, x_points_all);
hold on
plot(x_points_all, y_points_all, 'b--')
hold off
title('Distribution of Wind Speeds (10m) from 0:00 to 18:00')
xlabel('Wind Speed (m/s)')
ylabel('Probability Density')
legend('Probability Density of Wind Speed (10m)', 'Line of Best Fit', 'Location','southeast')

subplot(3, 1, 2)
scatter(wind_speed_night_10m, normal_dist_night_10m)
coeff_night = polyfit(wind_speed_night_10m, normal_dist_night_10m, 6);
x_points_night = linspace(min(wind_speed_night_10m), max(wind_speed_night_10m), 1000);
y_points_night = polyval(coeff_night, x_points_night);
hold on
plot(x_points_night, y_points_night, 'b--')
hold off
title('Distribution of Wind Speeds (10m) from 0:00 to 8:00')
xlabel('Wind Speed (m/s)')
ylabel('Probability Density')
legend('Probability Density of Wind Speed (10m)', 'Line of Best Fit', 'Location','southeast')

subplot(3, 1, 3)
scatter(wind_speed_day_10m, normal_dist_day_10m)
coeff_day = polyfit(wind_speed_day_10m, normal_dist_day_10m, 6);
x_points_day = linspace(min(wind_speed_day_10m), max(wind_speed_day_10m), 1000);
y_points_day = polyval(coeff_day, x_points_day);
hold on
plot(x_points_day, y_points_day, 'b--')
hold off
title('Distribution of Wind Speeds (10m) from 8:00 to 18:00')
xlabel('Wind Speed (m/s)')
ylabel('Probability Density')
legend('Probability Density of Wind Speed (10m)', 'Line of Best Fit', 'Location','southeast')

% Part B Function
function z_0 = SolveSimult(u_1, z_1, u_2, z_2)
z_0 = exp((u_2 .* log(z_1) - u_1 .* log(z_2)) ./ (u_2 - u_1));
end