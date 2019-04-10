function RMSEP = computeRMSEP(MDL_OPT, x_test, y_test, cfg)
% Function to compute the root mean squared error in prediction (RMSEP) associated to the mean, variance and maximum response
% It assumes that these three statistical descriptors have been already computed and are available in a .mat file.

%% Compute RMSEP in external validation
RMSEP = zeros(cfg.n_wspd, cfg.n_wspd, cfg.n_win, max(cfg.nr_of_chunks));
for wspd_train=1:cfg.n_wspd
    for win=1:cfg.n_win
        for i=1:cfg.nr_of_chunks(win)
            mdl_opt = MDL_OPT{wspd_train,win,i};                                
            for wspd_test=1:cfg.n_wspd
                x = squeeze(x_test(wspd_test,:,:,win,i));
                y = squeeze(y_test(wspd_test,:,:,win,i)); 
                yp = evalmdl(mdl_opt, x);
                RMSEP(wspd_train, wspd_test, win, i) = sqrt(mean( (yp-y(:)).^2 ) );
            end            
        end
    end
end

