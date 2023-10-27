% ENME 337 Assignment 2, Ahmed Almousawi, 30140399, ahmed.almousawi1@ucalgary.ca
clc
clear

% Assumptions:
% The ride distribution is completely even (avg. 3.75 fares / hr, 30 trips
% in 8 hours)
% Only 80% of the total time is spent driving passengers
% No vehicular depreciation (tires, general repairs, etc.) occurs
% No tips from passengers

% Let t represent the number of regular hours worked
syms t

disp('Hello, welcome to the ENME 337 Uber profit maximizer!')
disp('For each of the following inputs, enter a value. If nothing is inputted, the default value (shown in square brackets) will be used.')

hours_worked = input('Please enter the amount of hours you want to work [8]:\n');
if isempty(hours_worked)
    hours_worked = 8;
end
t_rush = hours_worked - t;

% Create a variable t_pax, the decimal percentage of time spent with a
% passenger in the car

t_pax = input('Please enter the percentage of time spent with a passanger, in decimal form [0.8]: \n');
if isempty(t_pax)
    t_pax = 0.8;
end


reg_drive_time = t_pax * t;
rush_drive_time = t_pax * (t_rush);

% Get the car-related parameters (speed, fuel consumption, fuel cost)
reg_speed = input('Please enter the average speed during regular hours, in km/hr [70]: \n');
if isempty(reg_speed)
    reg_speed = 70;
end

rush_speed = input('Please enter the average speed during rush hours, in km/hr [30]: \n');
if isempty(rush_speed)
   rush_speed = 30;
end

% Fuel Consumption (L/km)
reg_fuel = input('Please enter the average fuel consumption during regular hours, in L/km [8/100]: \n');
if isempty(reg_fuel)
   reg_fuel = 8/100;
end

rush_fuel = input('Please enter the average fuel consumption during rush hours, in L/km [12/100]: \n');
if isempty(rush_fuel)
   rush_fuel = 12/100;
end

fuel_cost = input('Please enter the cost of fuel, in $/L [1.30]: \n');
if isempty(fuel_cost)
   fuel_cost = 1.3; % ($/L)
end

% Get the Uber-defined parameters (fare, fare/km, rush surcharge, rush
% surcharge/km)
reg_fare = input('Please enter the regular fare when within 2 km, in $ [10]: \n');
if isempty(reg_fare)
   reg_fare = 10;
end

reg_per_km = input('Please enter the regular fare after 2 km, in $/km [3]: \n');
if isempty(reg_per_km)
   reg_per_km = 3;
end

rush_surcharge = input('Please enter the rush fare surcharge when within 2 km, in $ [5]: \n');
if isempty(rush_surcharge)
   rush_surcharge = 5;
end

rush_per_km_surcharge = input('Please enter the rush fare surcharge after 2 km, in $/km [1.8]: \n');
if isempty(rush_per_km_surcharge)
   rush_per_km_surcharge = 1.8;
end

% I wanted to use the floor function for accuracy here but it doesnt really
% differentiate properly
reg_trips = 3.75 * t;
rush_trips = 3.75 * t_rush;
% Calculate average distance travelled per trip
reg_dist_per_trip = reg_drive_time * reg_speed / reg_trips;
rush_dist_per_trip = rush_drive_time * rush_speed / rush_trips;

% Calculate the revenue for each (passanger) trip
reg_revenue_per_trip = reg_fare + reg_per_km * (reg_dist_per_trip - 2);
rush_revenue_per_trip = reg_fare + reg_per_km * (rush_dist_per_trip - 2) + rush_surcharge + rush_per_km_surcharge * (rush_dist_per_trip - 2);

total_rev = reg_trips * reg_revenue_per_trip + rush_trips * rush_revenue_per_trip;

% Expenses 
% We use t and average speed instead of the trip distance calculated above
% in order to account for distance travelled without passengers.
reg_expense_per_trip = t * reg_speed * reg_fuel * fuel_cost;
rush_expense_per_trip = t_rush * rush_speed * rush_fuel * fuel_cost;

total_expense = reg_expense_per_trip + rush_expense_per_trip;

% Make the profit function and plot it
syms profit(t)
profit(t) = total_rev - total_expense;
profit(t) = collect(profit(t));

figure(1);
prof_plot = fplot(profit(t), [0 hours_worked]);
title('Profit versus Regular Hours Worked')
xlabel('Regular Hours Worked')
ylabel('Profit ($)')

% Take the derivative of the profit function and plot it
derivative = diff(profit(t));
figure(2);
fplot(derivative, [0 hours_worked])
title('Change in Profit versus Regular Hours Worked')
xlabel('Regular Hours Worked')
ylabel('Change in Profit ($)')

% With the default parameters, the derivative is a straight line, and
% therefore cannot be solved. Thus, we create a fallback if the derivative
% produces an empty sym.

optimal_time = solve(derivative, t);

% If the derivative has no solution, get the maximum profit from the profit 
% graph and get the t value associated with it.

if isempty(optimal_time)
    maximum_profit = max(prof_plot.YData);
    eqn = maximum_profit == profit(t);
    optimal_time = solve(eqn);
end

rounded_time = round(4*optimal_time)/4;
fprintf('The optimal time is to drive %.2f hours during regular hours and %.2f hours during rush hours. \n', optimal_time, (8-optimal_time));
fprintf('Rounding to the nearest quarter hour, you should drive %.2f hours during regular hours and %.2f hours during rush hours. \n', rounded_time, (8-rounded_time));
fprintf('This gives the maximum profit of $%.2f\n', profit(rounded_time))