%% Set root path
cd 'E:\OneDrive - IBEC\research\papers\2019\Bouts'

%% Load data
load(fullfile(cd, 'data', 'ExpConfig.mat'));
load(fullfile(cd, 'data', 'SMK_bc.mat'))
load(fullfile(cd, 'data', 'LPD_bc.mat'))
load(fullfile(cd, 'data', 'RMSEP_SMK.mat'))
load(fullfile(cd, 'data', 'RMSEP_LPD.mat'))

%% Plot regression Schmuker filter (bthr=3sigma) vs Low Pass Differentiator (f=8, bthr=0)
% Create Fig
fig=createFig(0.55, 0.33);
hold on
dist_plot = [1 2 3 4 6];
win = 4;
wspd = 3;
noise_scale=1.5;

% Schmuker filter
[~, idx_3sigma] = min(abs(cfg.thr_list-SMK.thr_3sigma(wspd)));
thr_plot = [1 idx_3sigma 318];
colors = {'000000' , '636363', 'bdbdbd'};
lw = [1.3, 0.9, 0.9];
phdl_Smk = zeros(1,3);
leg_Smk = cell(1,3);
model_opt_Smk = cell(1,3);
for i = 1:length(thr_plot)
    thr = thr_plot(i);
    x = squeeze(SMK_bc(wspd,dist_plot,:,thr,win,1));
    y = squeeze(SMK_labels(wspd,dist_plot,:,thr,win)); 
	
    % plot train samples
    x_train = x(:,cfg.trials_train);
    y_train = y(:,cfg.trials_train);
    noise = randn(size(y_train(:)))*noise_scale;
    color = hex2rgb(colors{i})/255;
    scatter(100*y_train(:)+noise,x_train(:),15,color, 'filled')
	
    % plot test samples
    x_test = x(:,cfg.trials_test);
    y_test = y(:,cfg.trials_test);
    noise = randn(size(y_test(:)))*noise_scale;
    scatter(100*y_test(:)+noise,x_test(:),15,color)
	
    % plot model line
    xp=0.95*min(x(:)):1:max(x(:));
	mdl = MDL_OPT_SMK{wspd,win,thr,1};
    yp = evalmdl(mdl, xp);
    phdl_Smk(i)=plot(100*yp,xp,'color',color, 'linewidth', lw(i));
    r = mean(squeeze(RMSEP_SMK(wspd,wspd,win,thr,:)));
    leg_Smk{i} = sprintf('SMK bthr=%.3f (RMSEP: %d cm)', thr_list(thr), round(100*r));
    model_opt_Smk{i} = mdl;
end

%% Low Pass Differentiator
f = 8;
thr = 1;
color = 'r';
lw = 1.3;
x = squeeze(LPD_bc(wspd,dist_plot,:,f,thr,win,1));
y = squeeze(LPD_labels(wspd,dist_plot,:,f,thr,win));
 
% plot train samples
x_train = x(:,cfg.trials_train);
y_train = y(:,cfg.trials_train);
noise = randn(size(y_train(:)))*noise_scale;
scatter(100*y_train(:)+noise,x_train(:),15,color, 'filled')

% plot test samples
x_test = x(:,cfg.trials_test);
y_test = y(:,cfg.trials_test);
noise = randn(size(y_test(:)))*noise_scale;
scatter(100*y_test(:)+noise,x_test(:),15,color)

% plot model line
xp=0.95*min(x(:)):1:max(x(:));
mdl = MDL_OPT_LPD{wspd,win,f,thr,1};
yp = evalmdl(mdl xp);
phdl_Jbc = plot(100*yp,xp,color, 'linewidth', lw);
r = mean(squeeze(RMSEP_LPD(wspd, wspd, win, f, thr, :)));
leg_Jbc = sprintf('LPD bthr=%.3f (RMSEP: %d cm)', thr, round(100*r));
model_opt_Jbc = mdl;

% Label axis
xticks(100*distance_meters(dist_plot))
xlabel('Distance (cm)', 'fontsize',11)
ylabel('Bout frequency (bouts/min)', 'fontsize',11)
set(gca, 'fontsize', 11)
xlim([20,150])
legend([phdl_Smk, phdl_Jbc], [leg_Smk, leg_Jbc])

% print
filename = fullfile(cd, 'img', 'svg', 'BoutFreq_SmkVsJbc.svg');
print (fig, '-painters', '-dsvg', '-r600', filename);
