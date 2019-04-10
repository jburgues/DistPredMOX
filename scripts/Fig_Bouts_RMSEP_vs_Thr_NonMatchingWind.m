%% Set root path
cd 'C:\Users\Los Prunos\Documents\Work\Papers\Paper bouts'
addpath(fullfile(cd, 'code', 'scripts'), fullfile(cd, 'code', 'functions'))

%% Load data
load(fullfile(cd, 'data', 'config.mat'));
load(fullfile(cd, 'data', 'bouts.mat'));
load(fullfile(cd, 'data', 'modelValidation.mat'));
load(fullfile(cd, 'data', 'modelFitting.mat'), 'M_OPT');

%% config
wspd_train = 2;
win = 4;

% Compute average RMSEP across different chunks
f = getSMKindex(cfg);
r = squeeze(RMSEP(wspd_train,:,win,1:cfg.nr_of_chunks(win),f));
rm = squeeze(mean(r,2)); % mean across chunks

% Saturate RMSEP for visualization
r_max = 0.5;
rm(isnan(rm))=r_max;

rmm = mean(rm); % mean across test wind speeds

%% Plot
fig=createFig(0.5, 0.3);
plot(cfg.thr_list, 100*rm)
hold on
box off
grid on
plot(cfg.thr_list, 100*rmm, 'k')
xlabel('Threshold (MS/s)', 'fontsize', 10)
ylabel('RMSEP (cm)', 'fontsize', 10)
set(gca, 'xscale', 'log')
legend('test: 10 cm/s', 'test: 21 cm/s', 'test: 34 cm/s', 'average', 'location', 'northwest')
ylim([12, 77])
xlim([1e-3, 1])

% Annotate 3sigma threshold with a red circle
[~,idx_3sigma]=min(abs(cfg.thr_list-thr_3sigma(wspd_train)));
scatter(cfg.thr_list(idx_3sigma)*ones(1,3), 100*rm(:,idx_3sigma), 20, 'r', 'filled')

% Annotate threshold with minimum RMSEP
[m,idx] = min(100*rmm);
scatter(cfg.thr_list(idx), m, 20, 'k', 'filled')
m_opt=M_OPT(wspd_train,win,1:cfg.nr_of_chunks(win),f);
m_opt(idx)

% print
filename = fullfile(cd, 'img', 'svg', 'RMSEP_SMK_vs_Thr_NonMatchingWind.svg');
%print (fig, '-painters', '-dsvg', '-r600', filename);
