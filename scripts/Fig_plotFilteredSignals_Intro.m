%%
cd 'C:\Users\Los Prunos\Documents\Work\Papers\Paper bouts'
addpath(fullfile(cd, 'code', 'scripts'), fullfile(cd, 'code', 'functions'))

%% Load data
load(fullfile(cd, 'data', 'config.mat'));
load(fullfile(cd, 'data', 'filterSMK.mat'));
load(fullfile(cd, 'data', 'signals.mat'));

%% Set parameters
wspd = 2;
dist = 4;
trial = 2;
t_plot = [20, 90];

%% Compute filtered signals and bouts
x=squeeze(signal(wspd,dist,trial,:));
idx = (t>t_plot(1)) & (t<t_plot(2));

% Schmuker filter
dyf = filter(cfg.Fs*h_SMK{1},1,x);
delay = 205;
dyf(1:delay) = [];
[bouts, ~] = computeBouts(dyf);

%% Plot 
% plot raw signal
fig = createFig(0.9, 0.3, 'landscape');
p1=plot(t(idx),x(idx), 'k', 'linewidth', 1.5)
p1.Color(4) = 0.2;
ylabel('Response (MS)', 'fontsize', 12)

% create additional axis to plot derivative
yyaxis('right')
hold on

% plot filtered signal and bouts (LPD)
tt = t(1:end-delay);
idx = (tt>t_plot(1)) & (tt<t_plot(2));
yoffs = -0.05;
plot(t(idx),dyf(idx)+yoffs, 'k-', 'linewidth', 0.9)
for i=1:size(bouts,1)
    if (bouts(i,1)/cfg.Fs >= t_plot(1)) && (bouts(i,2)/cfg.Fs <= t_plot(2)) 
        scatter(t(bouts(i,1)), dyf(bouts(i,1))+yoffs, 14, 'r', 'filled')
        plot(t(bouts(i,1):bouts(i,2)), dyf(bouts(i,1):bouts(i,2))+yoffs, 'r-', 'linewidth', 1.5)
    end
end

% axes labels
yline(0, 'k-')   
xlabel('Time (s)', 'fontsize', 11) 
ylabel('Derivative (MS/s)', 'fontsize', 11)
%ylim([-0.23, 0.15])
set(gca, 'fontsize',11)

% print
filename = fullfile(cd, 'img', 'svg', sprintf('FilteredSignals_Intro.svg'));
print (fig, '-painters', '-dsvg', '-r600', filename);

