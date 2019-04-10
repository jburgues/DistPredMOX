function [MDL_OPT_LPD, RMSECV_OPT_LPD] = computeRMSECV_Bouts_LPD(x_train, y_train, cfg)

% Compute RMSECV in k-fold cross-validation
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
