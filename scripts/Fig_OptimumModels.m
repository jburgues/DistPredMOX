%%
addpath(fullfile(cd, 'code', 'scripts'), fullfile(cd, 'code', 'functions'))

%% Load data
load(fullfile(cd, 'data', 'config.mat'));
load(fullfile(cd, 'data', 'modelValidation.mat'));
load(fullfile(cd, 'data', 'modelFitting.mat'));

%% Plot models vs threshold vs cut-off frequency
wspd = 1;
win = 4;
mo_Jbc = squeeze(M_OPT_LPD(wspd,win,:,:,1));

fig=createFig(0.55, 0.25);
surf(thr_list,Fpass,mo_Jbc);
set(gca,'XScale','log');
shading interp
view(2)
xlim([1e-4, 10])
xticks([1e-4, 1e-3, 1e-2, 1e-1, 1e0, 1e1]);
ylim([0.1, 2])
cb=colorbar();
cb.Ticks=[1 2 3 4 5 6];
cb.TickLabels = {'Linear', 'Poly2', 'Poly3', 'Exp', 'Log', 'Power'};
xlabel('Threshold (MS/s)', 'fontsize',10)
ylabel('Cut-off frequency (Hz)')

% Plot line connecting optimum thresholds at each f_cut
hold on
thropt = zeros(1, n_fcut);
for f=1:n_fcut
    r = squeeze(RMSEP_LPD(wspd, wspd, win, f, :, :));
	r = mean(r,2);
    [m,idx]=min(r(:));
    thropt(f) = thr_list(idx);
end
plot3(thropt, Fpass, 6*ones(1,20), 'r-')
plot3(thropt, Fpass, 6*ones(1,20), 'r.')

% print
filename = fullfile(cd, 'img', 'png', 'OptimumModels.png');
print (fig, '-painters', '-dpng', '-r600', filename);
