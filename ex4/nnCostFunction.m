function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%


% Expand the 'y' output values into a matrix of single values
eye_matrix = eye(num_labels);
y_matrix = eye_matrix(y,:); % Extract row y, all column

% m is the number of tranning set
m = size(X, 1);

% -------------------------------------------------------------
% Part 1: Perform the feedforward propagation
a1 = [ones(m, 1) X];
z2 = a1 * transpose(Theta1);
a2 = [ones(m, 1) sigmoid(z2)];
z3 = a2 * transpose(Theta2);
a3 = sigmoid(z3);

% Compute the unregularized cost
J_val = 1/m * (((-y_matrix) .* log(a3)) - ((1 - y_matrix) .* log((1 - a3))));

% Sum over all elements
J = sum(sum(J_val));

% Compute the regularized component of the cost
% Remove the bias of Theta1 and Theta2
J_val_reg = lambda / (2 * m) * (sum(sum(power(Theta1(:, 2:end), 2))) + sum(sum(power(Theta2(:, 2:end), 2))));

% Add the regularization term
J = J + J_val_reg;

% -------------------------------------------------------------
% Part 2: Gradient Computation: Backpropagation 

% Let:
% m = the number of training examples
% n = the number of training features, including the initial bias unit.
% h = the number of units in the hidden layer - NOT including the bias unit
% r = the number of output classifications

% Perform forward propagation, as above

% d3 is the difference between a3 and the y_matrix
% The dimensions are the same as both, (m x r)
d3 = a3 - y_matrix;

% d2 is the product of d3 and Theta2(no bias)
% The size is (m x r) * (r x h) --> (m x h)
d2 = (d3 * Theta2(:, 2:end)) .* sigmoidGradient(z2);

% Delta1 is the product of d2 and a1
% The size is (h x m) * (m x n) --> (h x n)
Delta1 = transpose(d2) * a1;

% Delta2 is the product of d3 and a2
% The size is (r x m) * (m x [h+1]) --> (r x [h+1])
Delta2 = transpose(d3) * a2;

% The unregularized gradients
Theta1_grad = 1/m * Delta1;
Theta2_grad = 1/m * Delta2;

% -------------------------------------------------------------
% Part 3: Regularization of the gradient

% Should not be regularizing the bias term
% Set the first column of Theta1 and Theta2 to all-zeros
Theta1(:, 1) = 0;
Theta2(:, 1) = 0;

% Scale each Theta matrix by lambda / m
% Then add it to the unregularized Theta
Theta1_grad = Theta1_grad + ((lambda / m) * Theta1);
Theta2_grad = Theta2_grad + ((lambda / m) * Theta2);


% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];


end
