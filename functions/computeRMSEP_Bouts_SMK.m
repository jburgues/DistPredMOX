function RMSEP_SMK = computeRMSEP_Bouts_SMK(SMK, cfg)
% Function to compute the root mean squared error in prediction (RMSEP) associated to the bout frequency
% It assumes that the bouts and their amplitude have been already computed and are available in a .mat file.
warning('off','all');  % Turn off warning

%% Compute bout frequency using an amplitude threshold
SMK_bc = zeros(cfg.n_wspd, cfg.n_dist, cfg.n_trials, cfg.n_thr, cfg.n_win, max(cfg.nr_of_chunks));
SMK_labels = zeros(cfg.n_wspd, cfg.n_dist, cfg.n_trials, cfg.n_thr, cfg.n_win);
for wspd=1:cfg.n_wspd
    for dist=1:cfg.n_dist
        tic();
        fprintf('wspd: %d, dist: %d...', wspd, dist)
        for trial=1:cfg.n_trials
            for thr=1:cfg.n_thr
                for win=1:cfg.n_win
                    for i=1:cfg.nr_of_chunks(win)
                        SMK_bc(wspd,dist,trial,thr,win,i) = sum(SMK.amps_gas{wspd,dist,trial,win}{i}>cfg.thr_list(thr))/(cfg.winsize(win)/60);
                        SMK_labels(wspd,dist,trial,thr,win) = cfg.dist_meters(dist);
                    end
                end
            end             
        end
        fprintf('elapsed time: %.1f\n', toc)
    end
end

clear SMK

save(fullfile(cfg.data_path, 'SMK_bc.mat'), 'SMK_bc', 'SMK_labels')

%% Split data into train and test (hold-out)
x_train = squeeze(SMK_bc(:,cfg.dist_fit,cfg.trials_train,:,:,:)); 
y_train = squeeze(SMK_labels(:,cfg.dist_fit,cfg.trials_train,:,:));
x_test = squeeze(SMK_bc(:,cfg.dist_fit,cfg.trials_test,:,:,:));
y_test = squeeze(SMK_labels(:,cfg.dist_fit,cfg.trials_test,:,:));

%% Compute RMSECV in k-fold cross-validation
RMSECV_SMK = zeros(cfg.n_wspd, cfg.n_win, cfg.n_thr, max(cfg.nr_of_chunks), cfg.k, cfg.n_mdl);
RMSECV_OPT_SMK = zeros(cfg.n_wspd, cfg.n_win, cfg.n_thr, max(cfg.nr_of_chunks));
MDL_OPT_SMK = cell(cfg.n_wspd, cfg.n_win, cfg.n_thr, max(cfg.nr_of_chunks));
M_OPT_SMK = zeros(cfg.n_wspd, cfg.n_win, cfg.n_thr, max(cfg.nr_of_chunks));
for wspd_train=1:cfg.n_wspd
    for thr=1:cfg.n_thr
        if rem(thr,10)==0
            fprintf('wspd train: %d, thr:%d... ', wspd_train,thr);
        end
        for win=1:cfg.n_win
            rmsecv_im = zeros(max(cfg.nr_of_chunks), cfg.n_mdl);
            for i=1:cfg.nr_of_chunks(win)
                x = squeeze(x_train(wspd_train,:,:,thr,win,i));
                y = squeeze(y_train(wspd_train,:,:,thr,win)); 
				
                % k-fold cross-validation
                rmsecv_km = single_crossval(x,y,cfg.k,cfg.models);                
                RMSECV_SMK(wspd_train,win,thr,i,:,:) = rmsecv_km;                
                rmsecv_im(i,:) = mean(rmsecv_km); % mean across folds;
            end
            
            % select model that minimizes the average rmsecv across chunks
            rmsecv_per_model = mean(rmsecv_im); % mean across chunks
            [rmsecv_opt, m_opt] = min(rmsecv_per_model);
            RMSECV_OPT(feat,wspd_train,win) = rmsecv_opt;
				
            % Refit optimum model using all training samples
            mdl_opt = cfg.models{m_opt};
            mdl_opt_refit = fitmdl(x, y, mdl_opt.logx,mdl_opt.logy, mdl_opt.order);				
            MDL_OPT_SMK{wspd_train,win,thr} = mdl_opt_refit;
                
                RMSECV_SMK(wspd_train,win,thr,i,:,:) = rmsecv;
                RMSECV_OPT_SMK(wspd_train,win,thr,i) = rmsecv_opt;
                
                % Refit optimum model using all training samples
                mdl_opt = fitmdl(x, y, mdl_opt.logx,mdl_opt.logy, mdl_opt.order);
                MDL_OPT_SMK{wspd_train,win,thr,i} = mdl_opt;
                M_OPT_SMK(wspd_train,win,thr,i) = mdl_opt.num;				
        end
        if rem(thr,10)==0
            fprintf('Elapsed time: %.2f s\n', toc)
            tic
        end
    end
end

% save data to file
save(fullfile(cfg.data_path, 'RMSECV_SMK.mat'), 'RMSECV_SMK', 'RMSECV_OPT_SMK', ...
                                            'MDL_OPT_SMK', 'M_OPT_SMK')
        
%% Compute RMSEP in external validation
RMSEP_SMK = zeros(cfg.n_wspd, cfg.n_wspd, cfg.n_win, cfg.n_thr, max(cfg.nr_of_chunks));
for wspd_train=1:cfg.n_wspd
    for thr=1:cfg.n_thr
        if rem(thr,10)==0
            fprintf('wspd train: %d, thr:%d... ', wspd_train,thr);
        end
        for win=1:cfg.n_win
            for i=1:cfg.nr_of_chunks(win)
                mdl_opt = MDL_OPT_SMK{wspd_train,win,thr,i};
                
                % compute RMSEP
                for wspd_test=1:cfg.n_wspd
                    x = squeeze(x_test(wspd_test,:,:,thr,win,i));
                    y = squeeze(y_test(wspd_test,:,:,thr,win)); 
                    yp = evalmdl(mdl_opt, x);
                    RMSEP_SMK(wspd_train,wspd_test,win,thr,i) = sqrt(mean( (yp-y(:)).^2 ) );
                end
            end
        end
        if rem(thr,10)==0
            fprintf('Elapsed time: %.2f s\n', toc)
            tic
        end
    end
end

% save data to file
save(fullfile(cfg.data_path, 'RMSEP_SMK.mat'), 'RMSEP_SMK')

