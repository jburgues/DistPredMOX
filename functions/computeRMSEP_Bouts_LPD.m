function RMSEP_SMK = computeRMSEP_Bouts_LPD(LPD, cfg)
% Function to compute the root mean squared error in prediction (RMSEP) associated to the bout frequency
% It assumes that the bouts and their amplitude have been already computed and are available in a .mat file.
warning('off','all');  % Turn off warning

%% Compute bout frequency using an amplitude threshold
LPD_bc = zeros(cfg.n_wspd, cfg.n_dist, cfg.n_trials, cfg.n_fcut, cfg.n_thr, cfg.n_win, max(cfg.nr_of_chunks));
LPD_labels = zeros(cfg.n_wspd, cfg.n_dist, cfg.n_trials, cfg.n_fcut, cfg.n_thr, cfg.n_win);
for wspd=1:cfg.n_wspd
    for dist=1:cfg.n_dist
        tic();
        fprintf('wspd: %d, dist: %d...', wspd, dist)
        for trial=1:cfg.n_trials
            for f=1:cfg.n_fcut
                for thr=1:cfg.n_thr
                    for win=1:cfg.n_win
                        for i=1:cfg.nr_of_chunks(win)
                            LPD_bc(wspd,dist,trial,f,thr,win,i) = sum(LPD.amps_gas{wspd,dist,trial,f,win}{i}>cfg.thr_list(thr))/(cfg.winsize(win)/60);
                            LPD_labels(wspd,dist,trial,f,thr,win) = cfg.dist_meters(dist);
                        end
                    end
                end  
            end
        end
        fprintf('elapsed time: %.1f\n', toc)
    end
end

clear LPD

save(fullfile(cfg.data_path, 'LPD_bc.mat'), 'LPD_bc', 'LPD_labels')

%% Split data into train and test (hold-out)
x_train = squeeze(LPD_bc(:,dist_fit,trials_train,:,:,:,:));
y_train = squeeze(LPD_labels(:,dist_fit,trials_train,:,:,:));
x_test = squeeze(LPD_bc(:,dist_fit,trials_test,:,:,:,:));
y_test = squeeze(LPD_labels(:,dist_fit,trials_test,:,:,:));

%% Compute RMSECV in k-fold cross-validation
RMSECV_LPD = zeros(cfg.n_wspd, cfg.n_win, cfg.n_fcut, cfg.n_thr, max(cfg.nr_of_chunks), cfg.k, cfg.n_mdl);
RMSECV_OPT_LPD = zeros(cfg.n_wspd, cfg.n_win, cfg.n_fcut, cfg.n_thr, max(cfg.nr_of_chunks));
MDL_OPT_LPD = cell(cfg.n_wspd, cfg.n_win, cfg.n_fcut, cfg.n_thr, max(cfg.nr_of_chunks));
M_OPT_LPD = zeros(cfg.n_wspd, cfg.n_win, cfg.n_fcut, cfg.n_thr, max(cfg.nr_of_chunks));
for wspd_train=1:cfg.n_wspd
    for f=1:cfg.n_fcut
        for thr=1:cfg.n_thr
            tic
            fprintf('wspd train: %d, f:%d, thr:%d...\n ', wspd_train,f,thr);
            for win=1:cfg.n_win
                for i=1:cfg.nr_of_chunks(win)
                    x = squeeze(x_train(wspd_train,:,:,f,thr,win,i));
                    y = squeeze(y_train(wspd_train,:,:,f,thr,win)); 
					
                    % k-fold cross-validation
                    [rmsecv, rmsecv_opt, mdl_opt] = single_crossval(x,y,cfg.k,cfg.models);
                    
                    % Refit optimum model using all training samples
                    mdl_opt = fitmdl(x, y, mdl_opt.logx,mdl_opt.logy, mdl_opt.order);
                    
                    % save data
                    RMSECV_LPD(wspd_train,win,f,thr,i,:,:) = rmsecv;
                    RMSECV_OPT_LPD(wspd_train,win,f,thr,i) = rmsecv_opt;
                    MDL_OPT_LPD{wspd_train,win,f,thr,i} = mdl_opt;
                    M_OPT_LPD(wspd_train,win,f,thr,i) = mdl_opt.num;
                end
            end
        end
        fprintf('Elapsed time: %.2f s\n', toc)
    end
end
                                        
save(fullfile(cfg.data_path, 'RMSECV_LPD.mat'), 'RMSECV_LPD')
save(fullfile(cfg.data_path, 'RMSECV_OPT_LPD.mat'), 'RMSECV_OPT_LPD')
save(fullfile(cfg.data_path, 'M_OPT_LPD.mat'), 'M_OPT_LPD')
save(fullfile(cfg.data_path, 'MDL_OPT_LPD.mat'), 'MDL_OPT_LPD')

%% Compute RMSEP in external validation
RMSEP_LPD = zeros(cfg.n_wspd, cfg.n_wspd, cfg.n_win, cfg.n_fcut, cfg.n_thr, max(cfg.nr_of_chunks));
for wspd_train=1:cfg.n_wspd
    for f=1:cfg.n_fcut
        tic
        fprintf('wspd train: %d, f:%d...\n ', wspd_train,f);
        for thr=1:cfg.n_thr
            for win=1:cfg.n_win
                for i=1:cfg.nr_of_chunks(win)
					mdl_opt = MDL_OPT_LPD{wspd_train,win,f,thr,i};

                    % compute RMSEP
                    for wspd_test=1:cfg.n_wspd
                        x = squeeze(x_test(wspd_test,:,:,f,thr,win,i));
                        y = squeeze(y_test(wspd_test,:,:,f,thr,win)); 
                        yp = evalmdl(mdl_opt, x);
                        RMSEP_LPD(wspd_train,wspd_test,win,f,thr,i) = sqrt(mean( (yp-y(:)).^2 ) );
                    end
                end
            end
        end
        fprintf('Elapsed time: %.2f s\n', toc)
    end
end

% save data to file
save(fullfile(cfg.data_path, 'RMSEP_LPD.mat'), 'RMSEP_LPD')

