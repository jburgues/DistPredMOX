%%
cd 'E:\OneDrive - IBEC\research\papers\2019\Bouts'

%% Load data
load(fullfile(cd, 'data', 'ExpConfig.mat'));
load(fullfile(cd, 'data', 'RMSEP_SMK.mat'));

% config
wspd_train = 1;
wspd_test = 1;
win_plot = 1:4;

%% Schmuker's filter
% Compute average RMSEP across different chunks
rm = zeros(cfg.n_win, cfg.n_thr);
for win=1:cfg.n_win
    r = squeeze(RMSEP_SMK(wspd_train,wspd_test,win,:,1:cfg.nr_of_chunks(win)));
    rm(win,:)=squeeze(mean(r,2));
end

% Saturate RMSEP for visualization
r_max = 0.45;
rm(rm>r_max |isnan(rm)) = r_max;

% Plot
fig = createFig(0.55, 0.25); 
hold on
plot(cfg.thr_list,100*rm(win_plot,:))
xlabel('Threshold (MS/s)', 'fontsize', 10)
ylabel('RMSEP (cm)', 'fontsize', 10)
set(gca, 'xscale', 'log')
legend('10 s', '30 s', '60 s', '90 s', 'location', 'northwest')

% print
filename = fullfile(cd, 'img', 'svg', 'Bouts_RMSEP_vs_WinSize_SMK.svg');
print (fig, '-painters', '-dsvg', '-r600', filename);

%% LPD filter
% Compute average RMSEP across different chunks
f = 19;
rm = zeros(cfg.n_win, cfg.n_thr);
for win=1:cfg.n_win
    r = squeeze(RMSEP_LPD(wspd_train,wspd_test,win,f,:,1:cfg.nr_of_chunks(win)));
    rm(win,:)=squeeze(mean(r,2));
end

% Saturate RMSEP for visualization
r_max = 0.45;
rm(rm>r_max |isnan(rm)) = r_max;

% Plot 
fig = createFig(0.55, 0.25); 
hold on
plot(cfg.thr_list,100*rm(win_plot,:))
xlabel('Threshold (MS/s)', 'fontsize', 10)
ylabel('RMSEP (cm)', 'fontsize', 10)
set(gca, 'xscale', 'log')
legend('10 s', '30 s', '60 s', '90 s', 'location', 'northwest')

% print
filename = fullfile(cd, 'img', 'svg', 'Bouts_RMSEP_vs_WinSize_LPD19.svg');
print (fig, '-painters', '-dsvg', '-r600', filename);
  
  