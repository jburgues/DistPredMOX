function rmsecv = single_crossval(x,y,k,models)
% Function to perform double cross-validation
% x: matrix of features in the format [N trials x M distances]
% y: vector of labels in the format [N trials x M distances]
% k_outer: number of cross-validation folds in the outper loop
% k_inner: number of cross-validation folds in the inner loop
% model: structure containing models to be tested

n_samples = size(x,1);
n_models = length(models);
folds = cvpartition(n_samples,'KFold',k);
rmsecv = zeros(folds.NumTestSets, n_models);
for i=1:k
    % training set
    x_train = x(folds.training(i), :);
    y_train = y(folds.training(i), :); 
    % test set
    x_test = x(folds.test(i), :); 
    y_test = y(folds.test(i), :); 
    mdl = cell(1, n_models);
    for m=1:n_models
        % fit model
        mdl{m} = fitmdl(x_train, y_train, models{m}.logx, models{m}.logy, models{m}.order);
        % compute RMSECV
        yp = evalmdl(mdl{m}, x_test);
        rmsecv(i,m) = sqrt(mean( (yp-y_test(:)).^2 ) );
    end
end
