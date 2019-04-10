%%
cd 'E:\OneDrive - IBEC\research\papers\2019\Bouts'

%% Load data
load(fullfile(cd, 'data', 'config.mat'));
load(fullfile(cd, 'data', 'RMSEP_SMK.mat'));
load(fullfile(cd, 'data', 'SMK_bouts.mat'), 'SMK_thr');

%% config
win = 4;
r_max = 0.5; % maximum RMSECV (m)

%% Generate table
for wspd=1:cfg.n_wspd
    %% Find optimum values of SMK filter
    r = mean(squeeze(RMSEP_SMK(wspd, wspd, win, :, :)),2); % mean across chunks
    r(r>r_max | isnan(r))=r_max;
    % Optimum  model
    [m,idx_opt]=min(r(:));
    SMK_thr_opt = cfg.thr_list(idx_opt);
    SMK_mo_opt = squeeze(M_OPT_SMK(wspd,win,idx_opt,:));
    SMK_rmsep_opt = m;
    % 3sigma threshold
    [~, idx_3sigma] = min(abs(cfg.thr_list-SMK_thr.thr_3sigma(wspd)));
    SMK_mo_3sigma = squeeze(M_OPT_SMK(wspd,win,idx_3sigma,:));
    SMK_rmsep_3sigma = r(idx_3sigma);
    
    %% Find optimum values of LPD filter
    r = squeeze(mean(squeeze(RMSEP_LPD(wspd, wspd, win, :, :, :)),3)); % mean across chunks
    r(r>r_max | isnan(r))=r_max;
    % Optimum  model
    [m,idx_opt]=min(r(:));
    [f_opt, thr_opt] = ind2sub(size(r), idx_opt);
    LPD_f_opt = cfg.Fpass(f_opt);
    LPD_thr_opt = cfg.thr_list(thr_opt);
    LPD_mo_opt = squeeze(M_OPT_LPD(wspd,win,f_opt,thr_opt,:));
    LPD_rmsep_opt = m;
    
    %% Print to console
    fprintf('wspd %d cm/s\n', 100*cfg.wspd_ms(wspd))
    fprintf('LPD Filter (optimum) | f: %.1f, thr: %.3f, mdl: %d, RMSEP: %.2f\n', ...
                LPD_f_opt, LPD_thr_opt, LPD_mo_opt, LPD_rmsep_opt)
    fprintf('SMK Filter (optimum) | thr: %.3f, mdl: %d, RMSEP: %.2f\n', ...
                SMK_thr_opt, SMK_mo_opt, SMK_rmsep_opt)
    fprintf('SMK Filter (3sigma) | thr: %.3f, mdl: %d, RMSEP: %.2f\n', ...
                SMK_thr.thr_3sigma(wspd), SMK_mo_3sigma, SMK_rmsep_3sigma)
    fprintf('------------------------------------------\n')
end


