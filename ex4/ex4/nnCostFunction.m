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

%X [5000, 400]
%y [5000, 1]
%Theta1 [25, 401]
%Theta2 [10, 26]
%Layer1 [400]
%Layer2 [25]
%Layer3 [10]

a1 = [ones(m,1) X]; % result [5000, 401]
a2 = sigmoid(Theta1*a1'); % result in [25,5000]
a2 = [ones(1, m); a2]; %result in [26,5000]
a3 = sigmoid(Theta2*a2); % results in [10,5000]

K = num_labels;
Y = zeros(K, m); %result in [10,5000]
for i = 1:m
	Y(y(i), i) = 1;
end;

costPos = -Y .* log(a3) ; % result in [10,5000]
costNeg = -(1-Y) .*log(1-a3); % result in [10, 5000]

cost = costPos + costNeg;
J = (1/m) * sum(cost(:)); % result in [1,1]

% Part 1.4: regularization

Theta1Filtered = Theta1(:,2:end); % result [25, 400]
Theta2Filtered = Theta2(:,2:end); % result [10, 25]

%reg = (lambda / (2*m)) * (sumsq(Theta1Filtered(:)) + sumsq(Theta2Filtered(:)));
reg = lambda / (2*m) * ( sum( Theta1Filtered(:).^2 ) + sum( Theta2Filtered(:).^2) );

J = J + reg;

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

%X [5000, 400]
%y [5000, 1]
%Theta1 [25, 401]
%Theta2 [10, 26]
%Layer1 [400]
%Layer2 [25]
%Layer3 [10]
%Y [10,5000]

Delta1 = 0;
Delta2 = 0;

for t = 1:m
	% Step 1 - Forward propagation: z_i and a_i
	a1 = [1 X(t,:)]'; % [5000 400] => [1,400] => [1,401] => [401,1]
	z2 = Theta1 * a1; % [25, 401] * [401 1] => [25,1]
	a2 = [1; sigmoid(z2)]; % [25,1] => [26,1]
	z3 = Theta2 * a2; % [10, 26] * [26,1] => [10, 1]
	a3 = sigmoid(z3); % [10, 1]

	% Step 2a - Error calculations: output layer
	yt = Y(:,t); % [10,5000] => [10,1]
	d3 = a3 - yt; % [10,1] = [10,1] => [10,1]

	% Step 2b - Error calculations: hidden layers
	d2 = Theta2Filtered' * d3 .* sigmoidGradient(z2); % [25,10] * [10,1] => [25,1]

	% Step 3a - Gradient calculation using a_i and the error d_i
	Delta2 = Delta2 + d3 * a2';  % [10,1] * [1,26] => [10,26]
	Delta1 = Delta1 + d2 * a1'; % [25,1] * [1, 401] => [25, 401]
end;

% Step 3b - Gradient calculation: division by the number of training examples used
% Delta1 = [25, 401]
% Delta2 = [10, 26]
% Theta1_grad = [25, 401]
% Theta2_grad = [10, 26]
Theta1_grad = (1/m) * Delta1; % [25, 401]
Theta2_grad = (1/m) * Delta2; % [10,26]

%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%

Theta1_grad(:,2:end) = Theta1_grad(:,2:end) + ((lambda/m) * Theta1Filtered);
Theta2_grad(:,2:end) = Theta2_grad(:,2:end) + ((lambda/m) * Theta2Filtered);

% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)]; % size: 25*401 + 10 * 26 => a long column 

end
