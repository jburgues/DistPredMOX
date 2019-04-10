function [x_tr, y_tr, x_test, y_test] = splitTrainTest(x, y, cfg)

index    = cell(1, ndims(x));
index(:) = {':'};
index{2} = cfg.dist_fit; % the second dimension
index{3} = cfg.trials_train; % the third dimension

% Apply to training data
x_tr = x(index{:});  % Equivalent to: X(:, cfg.dist_fit, cfg.trials_train, :, :)
y_tr = y(index{:});  % Equivalent to: X(:, cfg.dist_fit, cfg.trials_train, :, :)

% Modify it and apply to test data
index{3} = cfg.trials_test; % the third dimension
x_test = x(index{:});  % Equivalent to: X(:, cfg.dist_fit, cfg.trials_train, :, :)
y_test = y(index{:});  % Equivalent to: X(:, cfg.dist_fit, cfg.trials_train, :, :)
