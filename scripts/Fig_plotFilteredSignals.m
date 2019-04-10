%%
cd 'C:\Users\Los Prunos\Documents\Work\Papers\Paper bouts'
addpath(fullfile(cd, 'code', 'scripts'), fullfile(cd, 'code', 'functions'))

%% Load data
load(fullfile(cd, 'data', 'config.mat'));
load(fullfile(cd, 'data', 'filterSMK.mat'));
load(fullfile(cd, 'data', 'filterLPD.mat'));
load(fullfile(cd, 'data', 'signals.mat'));

%% Set parameters
wspd = 3;
dist = 3;
trial = 1;
t_plot = [120, 180];

%% Compute filtered signals and bouts
x=squeeze(signal(wspd,dist,trial,:));
idx = (t>t_plot(1)) & (t<t_plot(2));

% Schmuker filter
dyf_Smk = filter(cfg.Fs*h_SMK{1},1,x);
delay_Smk = 205;
dyf_Smk(1:delay_Smk) = [];
[pn_Smk, ~] = computeBouts(dyf_Smk);

% LPD filter
f_cut = 8;
dyf_Jbc = filter(cfg.Fs*h_LPD{f_cut}, 1, x);
delay_Jbc = mean(grpdelay(h_LPD{f_cut}));
dyf_Jbc(1:delay_Jbc) = [];
[pn_Jbc, ~] = computeBouts(dyf_Jbc);

%% Plot 
% plot raw signal
fig = createFig(0.9, 0.28, 'landscape');
p1=plot(t(idx),x(idx), 'k');
p1.Color(4) = 0.2;
ylabel('Response (MS)', 'fontsize', 12)

% create additional axis to plot derivative
yyaxis('right')
hold on

% plot filtered signal and bouts (Smk)
tt = t(1:end-delay_Smk);
idx = (tt>t_plot(1)) & (tt<t_plot(2));
plot(t(idx),dyf_Smk(idx), 'k-', 'linewidth', 0.6)
for i=1:length(pn_Smk)
    bout = pn_Smk(i,:);
    if (bout(:,1)/cfg.Fs >= t_plot(1)) && (bout(:,2)/cfg.Fs <= t_plot(2)) 
        scatter(t(bout(:,1)), dyf_Smk(bout(:,1)), 14, 'k', 'filled')
        plot(t(bout(:,1):bout(:,2)), dyf_Smk(bout(:,1):bout(:,2)), 'k-', 'linewidth', 1.5)
    end
end

% plot filtered signal and bouts (LPD)
tt = t(1:end-delay_Jbc);
idx = (tt>t_plot(1)) & (tt<t_plot(2));
yoffs = -0.05;
plot(t(idx),dyf_Jbc(idx)+yoffs, 'r-', 'linewidth', 0.6)
for i=1:length(pn_Jbc)
    bout = pn_Jbc(i,:);
    if (bout(:,1)/cfg.Fs >= t_plot(1)) && (bout(:,2)/cfg.Fs <= t_plot(2)) 
        scatter(t(bout(:,1)), dyf_Jbc(bout(:,1))+yoffs, 14, 'r', 'filled')
        plot(t(bout(:,1):bout(:,2)), dyf_Jbc(bout(:,1):bout(:,2))+yoffs, 'r-', 'linewidth', 1.5)
    end
end

% axes labels
yline(0, 'k-')   
xlabel('Time (s)', 'fontsize', 11) 
ylabel('Derivative (MS/s)', 'fontsize', 11)
ylim([-0.23, 0.15])
set(gca, 'fontsize',11)

% print
filename = fullfile(cd, 'img', 'svg', sprintf('FilteredSignals_wspd%d_dist%d_trial%d.svg',wspd,dist,trial));
%print (fig, '-painters', '-dsvg', '-r600', filename);

