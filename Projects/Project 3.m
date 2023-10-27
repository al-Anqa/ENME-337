% ENME 337 Assignment 4, Ahmed Almousawi, 30140399, ahmed.almousawi1@ucalgary.ca
clc
clear

global seg_length num_nodes m g k  b_type initial_length connect_mat
seg_length = 0.1;
num_nodes = 10;
m = 2;
g = 9.81;
k = 10000;

%b_type = 0;
b_type = input('Please select your beam type. For a canilever beam, input 0. Else, for a fixed beam, input 1\n');

while b_type ~= 0 && b_type ~= 1
    fprintf('You have entered an invalid input!\n')
    b_type = input('Please select your beam type. For a canilever beam, input 0. Else, for a fixed beam, input 1\n');
end


if num_nodes < 4 || mod(num_nodes, 2) ~= 0
    fprintf('The number of nodes is not compatible. Please enter an even number that is 4 or greater.')
end
% A3
beam_init = transpose([repelem(0:seg_length:(num_nodes/2 - 1) * seg_length, 2); repmat([0, -seg_length], 1, num_nodes/2)]);
% A4, 5

connect_mat = zeros(num_nodes, num_nodes);
for y=1:size(connect_mat, 2)
    if y ~= num_nodes
    connect_mat(y, y+1) = 1;
    end
    if y ~= num_nodes - 1 && y ~= num_nodes
    connect_mat(y, y+2) = 1;
    end
end

figure(1)
image(connect_mat,'CDataMapping','scaled')
title("Connectivity Matrix for " + num_nodes + " Nodes")
xticks([])
yticks([])

% A6
initial_length = zeros(num_nodes, num_nodes);
range = 1:num_nodes;
for seg_num = range
    if ismember(seg_num - 2, range) == 1
        initial_length(seg_num, seg_num - 2) = seg_length;
    end
    if ismember(seg_num + 2, range) == 1
        initial_length(seg_num, seg_num + 2) = seg_length;
    end
    % Checks if number is even 
    if mod(seg_num,2)==0
        if ismember(seg_num + 1, range) == 1
            initial_length(seg_num, seg_num + 1) = seg_length * sqrt(2);
        end
        if ismember(seg_num - 1, range) == 1
            initial_length(seg_num, seg_num - 1) = seg_length;
        end
    end
    % Now check if the number is odd
    if mod(seg_num,2)==1
        if ismember(seg_num - 1, range) == 1
            initial_length(seg_num, seg_num - 1) = seg_length * sqrt(2);
        end
        if ismember(seg_num + 1, range) == 1
            initial_length(seg_num, seg_num + 1) = seg_length;
        end
    end
end

% A7
[seg_row, seg_col] = find(connect_mat > 0);

% A10
figure(2)
plotbeam(beam_init, 'Initial Beam')

% B2
lb = -Inf(1, num_nodes * 2 - 8);
ub = Inf(1, num_nodes * 2 - 8);
if b_type == 0
    lb = [reshape(beam_init(1, :), [1, 2]), reshape(beam_init(2, :), [1, 2]), lb , -Inf, -Inf, -Inf, -Inf];
    ub = [reshape(beam_init(1, :), [1, 2]) + 1e-5, reshape(beam_init(2, :), [1, 2]) + 1e-5, ub , Inf, Inf, Inf, Inf];
else
    lb = [reshape(beam_init(1, :), [1, 2]), reshape(beam_init(2, :), [1, 2]), lb , reshape(beam_init(num_nodes - 1, :), [1, 2]), reshape(beam_init(num_nodes, :), [1, 2])];
    ub = [reshape(beam_init(1, :), [1, 2]) + 1e-5, reshape(beam_init(2, :), [1, 2]) + 1e-5, ub , reshape(beam_init(num_nodes - 1, :), [1, 2]) + 1e-5, reshape(beam_init(num_nodes, :), [1, 2]) + 1e-5];
end


% Need to reshape the beam like this to match the (x1, y1, x2, y2, ... )
% format of the lb, ub.
beam_init_2 = zeros(1, num_nodes * 2);
for row = 1:length(beam_init)
    % This makes each row of the beam_init array become two elements in the
    % beam_init_2 array. (I.e 1 becomes elem. 1 and 2. 2 becomes elem. 3 
    % and 4...)
    beam_init_2(2 * row - 1 : 2 * row) = beam_init(row, :);
end

% B3
beam_eqm = fmincon(@calc_energy,beam_init_2, [], [], [], [], lb, ub);

% B4
fprintf('The energy of the initial beam configuration is %.2f J\n', calc_energy(beam_init))
fprintf('The energy of the final beam configuration is %.2f J\n', calc_energy(beam_eqm))

% B5
figure(3)
plotbeam(beam_eqm, 'Equillibrium Beam')

% A8
function len = updated_seg_length(points)
    [~, size_c] = size(points);
    if size_c ~= 2
        points = reshape(points, 2, [])';
    end

    len = sqrt((points(:, 1)' - points(:,1)).^2 + (points(:, 2)' - points(:,2)).^2);
end

% A9
function plotbeam(points, str_title)
global seg_length b_type connect_mat initial_length

% Reshape the array into a 2 x [] to get the points in the format [x1, y1;
% x2, y2; ...]
[~, size_c] = size(points);
if size_c ~= 2
    points = reshape(points, 2, [])';
end

% Formats plot to make it look nicer
axis padded
axis equal
title(str_title)
xticks([])
yticks([])
hold on

% Adds left wall for both beam types, and adds a right wall for fixed beams. 
xline(0, LineWidth=2)
if b_type == 1
    xline(max(points(:, 1)), LineWidth=2)
end

% Adds "legend" in the form of a note
txt = {'Black: No Change','Blue: Tension', 'Red: Compression'};
text(seg_length,(0.5 * seg_length),txt)

updated_length = updated_seg_length(points);
% Iterates through the connectivity matrix to find all the segments that
% exist. Then, we plot them according to the change in length.
for i = 1:length(connect_mat)
    col = find(connect_mat(i, :));
   for j = col
       seg = line([points(i, 1), points(j, 1)], [points(i, 2), points(j, 2)], 'LineWidth', 2);
       d_length = updated_length(i, j) - initial_length(i, j);
       % Must round to a few decimals to mitigate issues with small decimals
       d_length = round(d_length, 10);
       % Checks for the change in length to determine the state of the
       % member
       if d_length > 0
           % Tension
           seg.Color = "b";
       elseif d_length < 0
           % Compression
           seg.Color = "r";
       elseif d_length == 0
           % No change
           seg.Color = "k";
       end      
   end
end
% Finally, plot nodes. 
scatter(points(:, 1), points(:, 2), 600, 'k.' )
hold off
end

% B1
function E = calc_energy(points)

global m g k connect_mat initial_length

% Expected input is a 1 x num_nodes * 2 vector in the form [x1, y1, x2, y2, ...].
% Then, get the y values by selecting all even indicies. Then, get the
% energy from compression using the change in length.

E = sum(points(2:2:end) * m * g) + 0.5 * sum(k * connect_mat .* (updated_seg_length(points) - initial_length).^2, "all");
end

% As per the Run and Time function in MATLAB, the code takes 0.88 seconds
% to run on average.
