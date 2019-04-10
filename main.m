%% Main file
addpath(fullfile(cd, 'code', 'scripts'), fullfile(cd, 'code', 'functions'))

% Define configuration
cfg = setConfig(cd);

% Parse signals
[t, signal] = getSignals(cfg);

% Set seed for reproducibility
rng(178)

%% Compute bouts
% Design filters
loadFilters = true;
if loadFilters
    load(fullfile(cfg.data_path, 'filterLPD.mat'));
    load(fullfile(cfg.data_path, 'filterSMK.mat'));
else
    h_SMK = designFilterSMK(cfg);
    h_LPD = designFilterLPD(cfg);
end

% concatenate 
H = [h_LPD h_SMK{1}];
n_h = length(H);

% Compute bouts
loadBouts = true;
if loadBouts
    load(fullfile(cfg.data_path, 'bouts.mat'));
else
    bouts = cell(cfg.n_wspd, cfg.n_dist, cfg.n_trials, n_h);
    amps = cell(cfg.n_wspd, cfg.n_dist, cfg.n_trials, n_h);
    delay = zeros(1, n_h);
    fprintf('Computing bouts... ')
    for h = 1:n_h
        fprintf('h = %d / %d\n', h, n_h)
        [bouts(:,:,:,h), amps(:,:,:,h), delay(h)] = extractBouts(signal, H{h}, cfg.Fs);
    end
    % save data
    save(fullfile(cfg.data_path, 'bouts.mat'), 'bouts', 'amps', 'delay')
    fprintf('Done!\n')
end

%% Compute feature matrix
fprintf('Computing feature matrix...\n')
n_spl = cfg.n_wspd*cfg.n_dist*cfg.n_trials*sum(cfg.nr_of_chunks);
n_feat = n_h*cfg.n_thr+3;
X = zeros(n_spl, n_feat);
y = zeros(n_spl, 1);
tr = zeros(n_spl, 1);
ch = zeros(n_spl, 1);
ws = zeros(n_spl, 1);
wd = zeros(n_spl, 1);
spl = 1;
for wspd=1:cfg.n_wspd
    for win=1:cfg.n_win
        fprintf('wspd: %d, win: %d\n', wspd, win)       
        for chunk=1:cfg.nr_of_chunks(win)         
            for dist=1:cfg.n_dist
                t_start = cfg.t_gas(wspd,dist,1);
                t_end = cfg.t_gas(wspd,dist,2)-cfg.winsize(win);
                r = randsample(t_start:t_end,cfg.nr_of_chunks(win));
                t_chunk = [r(chunk), r(chunk)+cfg.winsize(win)];
                tidx = (t>t_chunk(1)) & (t<t_chunk(2));
                for trial=1:cfg.n_trials
                    x = squeeze(signal(wspd,dist,trial,tidx));
                    X(spl, 1) = mean(x); 
                    X(spl, 2) = std(x);
                    X(spl, 3) = max(x);
                    f_cnt = 4;
                    for h=1:n_h
                        b = bouts{wspd,dist,trial,h};
                        a = amps{wspd,dist,trial,h};
                        bidx = (b(:,1)/cfg.Fs>t_chunk(1)) & (b(:,2)/cfg.Fs<t_chunk(2));
                        for thr=1:cfg.n_thr
                            bfreq = sum(a(bidx)>cfg.thr_list(thr))*60/cfg.winsize(win);
                            X(spl, f_cnt) = bfreq;
                            f_cnt = f_cnt + 1;
                        end
                    end
                    y(spl) = cfg.dist_meters(dist);
                    tr(spl) = trial;
                    ws(spl) = wspd;
                    ch(spl) = chunk;
                    wd(spl) = win;
                    spl = spl + 1;
                end
            end
        end
    end
end

% save data
save(fullfile(cfg.data_path, 'featureMatrix.mat'), 'X', 'y', 'tr', 'ws', 'wd', 'ch', 'n_feat')

%% Build predictive models
fprintf('Building predictive models...\n')

% Iterate
RMSECV = zeros(cfg.n_wspd, cfg.n_win, max(cfg.nr_of_chunks), n_feat, cfg.k, cfg.n_mdl);
RMSECV_OPT = zeros(cfg.n_wspd, cfg.n_win, max(cfg.nr_of_chunks), n_feat);
M_OPT = zeros(cfg.n_wspd, cfg.n_win, max(cfg.nr_of_chunks), n_feat);
MDL_OPT = cell(cfg.n_wspd, cfg.n_win, max(cfg.nr_of_chunks), n_feat);
for wspd=1:cfg.n_wspd
    for win=1:cfg.n_win     
        for chunk=1:cfg.nr_of_chunks(win)
            tic();
            fprintf('wspd: %d, win: %d, chunk: %d...', wspd, win, chunk)  
            spl_train = (ws==wspd) & (wd==win) & (ch==chunk) & ...
                        ismember(y,cfg.dist_meters(cfg.dist_fit)) & ...
                        ismember(tr,cfg.trials_train);
            for f=1:n_feat
                Xtrain = X(spl_train,f);
                ytrain = y(spl_train);

                % k-fold cross-validation
                rmsecv = single_crossval(Xtrain,ytrain,cfg.k,cfg.models);

                % select model that minimizes average rmsecv across folds
                rmsecv_per_model = mean(rmsecv); % mean across folds
                [rmsecv_opt, m_opt] = min(rmsecv_per_model);

                % Refit optimum model using all training samples
                mdl_opt = cfg.models{m_opt};
                mdl_opt_refit = fitmdl(Xtrain, ytrain, mdl_opt.logx,mdl_opt.logy, mdl_opt.order);				

                % Save data
                RMSECV(wspd,win,chunk,f,:,:) = rmsecv;
                MDL_OPT{wspd,win,chunk,f} = mdl_opt_refit; 
                RMSECV_OPT(wspd,win,chunk,f) = rmsecv_opt;
                M_OPT(wspd,win,chunk,f) = m_opt;
            end
            fprintf('elapsed time: %.2f s\n', toc())  
        end
    end
end

% save data
save(fullfile(cfg.data_path, 'modelFitting.mat'), 'RMSECV', 'MDL_OPT', 'RMSECV_OPT', 'M_OPT')

%% Validate predictive models
fprintf('Validating predictive models...\n')

% Load fitting data
fprintf('Loading fitting data...')
load(fullfile(cfg.data_path, 'featureMatrix.mat'));
load(fullfile(cfg.data_path, 'modelFitting.mat'));
fprintf('Done!\n')

% Iterate
RMSEP = zeros(cfg.n_wspd, cfg.n_wspd, cfg.n_win, max(cfg.nr_of_chunks), n_feat);
for wspd_tr=1:cfg.n_wspd
    for win=1:cfg.n_win     
        for chunk=1:cfg.nr_of_chunks(win)
            tic();
            fprintf('wspd: %d, win: %d, chunk: %d...', wspd_tr, win, chunk)  
            for f=1:n_feat                
                % Select optimum model
                mdl = MDL_OPT{wspd_tr,win,chunk,f};
                
                % Select test samples
                for wspd_test=1:cfg.n_wspd
                    spl_test = (ws==wspd_test) & (wd==win) & (ch==chunk) & ...
                                ismember(y,cfg.dist_meters(cfg.dist_fit)) & ...
                                ismember(tr,cfg.trials_test);
                    Xtest = X(spl_test,f);
                    ytest = y(spl_test);
                    % Evaluate model
                    yp = evalmdl(mdl, Xtest);
                    % Compute RMSEP
                    RMSEP(wspd_tr, wspd_test, win, chunk, f) = sqrt(mean( (yp-ytest(:)).^2 ) ); 
                end
            end
            fprintf('elapsed time: %.2f s\n', toc())  
        end
    end
end

% save data
save(fullfile(cfg.data_path, 'modelValidation.mat'), 'RMSEP')
