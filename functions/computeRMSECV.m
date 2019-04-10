function [RMSECV, RMSECV_OPT, MDL_OPT, M_OPT] = computeRMSECV(x_train, y_train, cfg)

% Compute RMSECV in k-fold cross-validation
RMSECV = zeros(cfg.n_wspd, cfg.n_win, max(cfg.nr_of_chunks), cfg.k, cfg.n_mdl);
RMSECV_OPT = zeros(cfg.n_wspd, cfg.n_win, max(cfg.nr_of_chunks));
MDL_OPT = cell(cfg.n_wspd, cfg.n_win, max(cfg.nr_of_chunks));
M_OPT = zeros(cfg.n_wspd, cfg.n_win, max(cfg.nr_of_chunks));
for wspd_train=1:cfg.n_wspd
    for win=1:cfg.n_win
        for i=1:cfg.nr_of_chunks(win)
            x = squeeze(x_train(wspd_train,:,:,win,i));
            y = squeeze(y_train(wspd_train,:,:,win,i)); 

            % k-fold cross-validation
            rmsecv = single_crossval(x,y,cfg.k,cfg.models);
            RMSECV(wspd_train,win,i,:,:) = rmsecv;

            % select model that minimizes the average rmsecv across
            % folds
            rmsecv_per_model = mean(rmsecv); % mean across folds
            [rmsecv_opt, m_opt] = min(rmsecv_per_model);
            RMSECV_OPT(wspd_train,win,i) = rmsecv_opt;
            M_OPT(wspd_train,win,i) = m_opt;
            
            % Refit optimum model using all training samples
            mdl_opt = cfg.models{m_opt};
            mdl_opt_refit = fitmdl(x, y, mdl_opt.logx,mdl_opt.logy, mdl_opt.order);				
            MDL_OPT{wspd_train,win,i} = mdl_opt_refit;            
        end
    end
end
