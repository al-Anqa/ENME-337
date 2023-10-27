% ENME 337 Assignment 1, Ahmed Almousawi, 30140399, ahmed.almousawi1@ucalgary.ca
% Gets an A matrix, validates it, gets a B matrix, and 
clc
clear
% Get the A matrix from the user
input_matrix = input('Please enter a scalar or square matrix below:\n');

% Check if the input is valid -- terminates the program otherwise
validated_input = inputValidator(input_matrix);

% Gathers the B (solution) matrix as an input
% We also get the size to verify that the solution is mathematically
% obtainable
[m_val, n_val] = size(validated_input);
b_vector = input('Please enter the solution (column) vector below:\n');
[m_sol, n_sol] = size(b_vector);

% While loop that checks for a valid B matrix input
while iscolumn(b_vector) == false || m_val ~= m_sol
    fprintf('You have inputed: \n')
    disp(b_vector)
    fprintf('This vector is invalid. Please enter a %d x 1  (column) vector below:\n', m_val)
    b_vector = input('');    
end
% Solves for X using the inputs above. The r variable exists solely to
% surpress a warning message.
[x_vector,r] = linsolve(validated_input, b_vector);

% Creates an augmented matrix to check for the number of solutions
% Based on: https://www.math.ucla.edu/~archristian/notes/linear-algebra/rank-and-matrix-algebra.pdf
aug_matrix = [validated_input b_vector];

% Check for no solution
if rank(aug_matrix) > rank(validated_input)
    fprintf('The A matrix: \n')
    disp(validated_input)
    fprintf('has no solutions when the B matrix is: \n')
    disp(b_vector)

% Check unique solution
elseif rank(validated_input) == m_val
    fprintf('The matrix has the following unique solution: \n')
    disp(x_vector)

% Checks for infinite solutions
elseif rank(validated_input) < m_val
    fprintf('The matrix has infinite solutions. One of the solutions is: \n')
    disp(x_vector)
end


function valid_input=inputValidator(user_input)

% Checks if the input is a character array, terminates if true.
if ischar(user_input) == true
    fprintf('You have inputed: \n')
    disp(user_input)
    error('You have provided an invalid input (character array input). The program will now terminate.')

% Checks if string array, terminates if true.
elseif isstring(user_input) == true
    fprintf('You have inputed: \n')
    disp(user_input)
    error('You have provided an invalid input (string array input). The program will now terminate.')

% Checks if the user has entered an empty input, terminates if true.
elseif isempty(user_input) ==  1
    fprintf('You have inputed: \n')
    disp(user_input)
    error('You have provided an invalid input (empty input). The program will now terminate.')

% Checks if the user has entered an scalar input, terminates if true.
elseif isscalar(user_input) == true
    fprintf('You have inputed: \n')
    disp(user_input)
    error('You have provided an invalid input (scalar input). The program will now terminate.')

% Checks if the input is a matrix
elseif ismatrix(user_input) == true
    [m, n] = size(user_input);
    fprintf('You have inputed the following %d x %d matrix: \n', m, n)
    disp(user_input)
    
    % Checks if the matrix is square
    % If no, terminate program. If yes, consider it a valid input.
    if m == n
        valid_input = user_input;
    elseif m ~= n
        error('You have provided an invalid input (non-square matrix). The program will now terminate.')
    end
else
    error('You have provided an invalid input (nonsense input). The program will now terminate.')
end
end