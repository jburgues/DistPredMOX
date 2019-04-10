function cfg = setConfig(root_path)
    %% Configuration file
    % Directory paths
    cfg.root_path = root_path;
    cfg.data_path = fullfile(cfg.root_path, 'data'); 
    cfg.img_path = fullfile(cfg.root_path, 'img'); 

    % Experiment configuration
    cfg.board = 5;
    cfg.sensor = 4;
    cfg.volt = 5;
    cfg.gas = 1;
    cfg.dist_meters = [0.25, 0.5, 0.98, 1.18, 1.40, 1.45];
    cfg.n_dist = length(cfg.dist_meters);
    cfg.n_trials = 20;
    cfg.trials_train = 1:14; % Trials used for model training
    cfg.trials_test = 15:20; % Trials used for model testing
    cfg.dist_fit = [1 2 3 4 6]; % Distances used for model fitting
    cfg.wspd_ms = [0.1, 0.21, 0.34];
    cfg.n_wspd = length(cfg.wspd_ms);
    cfg.Fs = 100; % sampling frequency (Hz)

    % Schmuker filter
    cfg.SMK_sigma = [0.3 0.2];
    cfg.SMK_tau = [0.4 0.2];

    % LPD filter
    cfg.LPD_Fpass = 0.1:0.1:2.0; % Hz 
    cfg.LPD_Fstop = cfg.LPD_Fpass+0.1; % Hz 
    cfg.LPD_Att = [1, 0]; % [pass band, stop band]
    cfg.LPD_Dev = [0.0001, 0.000001]; % Deviation of attenuation 40 dB -> SNR of 1%cfg.Fpass = Fpass;
    cfg.n_fcut = length(cfg.LPD_Fpass);

    cfg.t_bl = [0, 20];
    cfg.t_gas = zeros(cfg.n_wspd, cfg.n_dist, 2);
    cfg.t_gas(1, :, :) = [80 200; 80 200; 90 210; 100 220; 110 230; 110 230];
    cfg.t_gas(2, :, :) = [80 200; 80 200; 80 200; 80 200; 80 200; 90 210];
    cfg.t_gas(3, :, :) = [75 195; 75 195; 75 195; 75 195; 75 195; 75 195];
    cfg.winsize = [10, 30, 60, 90, 120];
    cfg.n_win = length(cfg.winsize);
    cfg.nr_of_chunks = [20, 10, 5, 3, 1]; % for sampling with replacement
    cfg.thr_list = logspace(-4, 1, 500);
    cfg.n_thr = length(cfg.thr_list);

    % Predictive models
    logx =  [0 0 0 0 1 1]; % Logarithm in x (independent variable)
    logy =  [0 0 0 1 0 1]; % Logarithm in y (dependent variable)
    order = [1 2 3 1 1 1]; % Order of the polynomial
    cfg.n_mdl = length(logx);
    cfg.models = cell(1, cfg.n_mdl);
    for m=1:cfg.n_mdl
        cfg.models{m}.logx = logx(m);
        cfg.models{m}.logy = logy(m);
        cfg.models{m}.order = order(m);
    end
    cfg.k = 5; % number of folds in cross-validation

    % Save to file
    save(fullfile(cfg.data_path, 'config.mat'), 'cfg')

