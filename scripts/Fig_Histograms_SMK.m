%% Set root path
cd 'C:\Users\Los Prunos\Documents\Work\Papers\Paper bouts'
addpath(fullfile(cd, 'code', 'scripts'), fullfile(cd, 'code', 'functions'))

%% Load data
load(fullfile(cd, 'data', 'config.mat'));
load(fullfile(cd, 'data', 'bouts.mat'));
load(fullfile(cd, 'data', 'modelValidation.mat'));

%% Extract baseline bouts
amps_bl = cell(cfg.n_wspd, cfg.n_dist, cfg.n_trials);
smk_idx = 21;
for wspd=1:cfg.n_wspd
    for dist=1:cfg.n_dist
        for trial=1:cfg.n_trials
            b = bouts{wspd, dist, trial, smk_idx};
            a = amps{wspd, dist, trial, smk_idx};
            idx = (b(:,1)/cfg.Fs>cfg.t_bl(1)) & (b(:,2)/cfg.Fs<cfg.t_bl(2));
            amps_bl{wspd,dist,trial} = a(idx); 
        end
    end
end

%% Extract gas bouts
amps_gas = cell(cfg.n_wspd, cfg.n_dist, cfg.n_trials);
smk_idx = 21;
for wspd=1:cfg.n_wspd
    for dist=1:cfg.n_dist
        for trial=1:cfg.n_trials
            b = bouts{wspd, dist, trial, smk_idx};
            a = amps{wspd, dist, trial, smk_idx};
            idx = (b(:,1)/cfg.Fs>cfg.t_gas(wspd,dist,1)) & (b(:,2)/cfg.Fs<cfg.t_gas(wspd,dist,2));
            amps_gas{wspd,dist,trial} = a(idx); 
        end
    end
end
    
%% Compute mu+3sigma threshold
thr_3sigma = zeros(1,cfg.n_wspd);
pctl_3sigma = zeros(1,cfg.n_wspd);
thr_pctl99 = zeros(1,cfg.n_wspd);
for wspd=1:cfg.n_wspd
    C = amps_bl(wspd,:,:);
    abl = vertcat(C{:});
    [thr_3sigma(wspd), pctl_3sigma(wspd), thr_pctl99(wspd)] = computeThreeSigmaThreshold(abl);
end

%% Compute optimum threshold at each wind speed
win = 4;
f = getSMKindex(cfg);
thr_opt = zeros(1,cfg.n_wspd);
for wspd=1:cfg.n_wspd
    r=mean(squeeze(RMSEP(wspd,wspd,win,1:cfg.nr_of_chunks(win),f)));
    [~, idx] = min(r);
    thr_opt(wspd) = cfg.thr_list(idx);
end

%% Plot histogram of bout amplitudes at different distnaces and wind speeds
wspd = [1 3]; % wind speeds to plot
dist_plot = [6 3 1]; % distances to plot
xlims = [0.0, 10.0; 0.0, 10.0]; % x-limits at each wind speed.
colors = {'fdae6b', 'e6550d',
        '99d8c9', '2ca25f'; 
        '9ecae1', '3182bd'; 
        '9ebcda', '8856a7'};
alph = [0.6 0.6];
norm = 'probability';

% baseline
fig = createFig(0.6, 0.3);
ax = zeros(1,4);
ax(1) = subplot(4,1,1);
hold on
C = amps_bl(wspd,:,:);
abl = vertcat(C{:});
abl(abl<0)=0;
h = histogram(ax(1),abl,logspace(-6,1,100), 'Normalization', norm);
h.EdgeColor = 'none';
h.FaceColor = hex2rgb('8856a7')/255;
h.FaceAlpha = 0.8;
xlim(xlims(2,:))
set(gca, 'xscale', 'log', 'yscale', 'log', 'fontsize', 9)
yticks([1e-3, 1e-2, 1e-1])
xticks([1e-6, 1e-5, 1e-4, 1e-3, 1e-2, 1e-1, 1e0, 1e1])
vline(thr_3sigma(wspd(1)),'k-')
vline(thr_opt(wspd),'r-')

% gas
cnt = 2;
for d=1:length(dist_plot)
    ax(cnt) = subplot(4,1,cnt);
    hold on
    leg_str = cell(1, length(wspd));
    for w=1:length(wspd)
        C = amps_gas(wspd(w),dist_plot(d),:);
        abl = vertcat(C{:});
        abl(abl<0)=0;
        h = histogram(ax(cnt),abl,logspace(-6,1,100), 'Normalization', norm);
        h.EdgeColor = 'none';
        h.FaceColor = hex2rgb(colors{d,w})/255;
        h.FaceAlpha = alph(w);
        leg_str{w} = sprintf('%d cm/s', round(100*cfg.wspd_ms(wspd(w))));
    end
    cnt=cnt+1;
    xlim(xlims(2,:))  
    xticks([1e-6, 1e-5, 1e-4, 1e-3, 1e-2, 1e-1, 1e0, 1e1])
    set(gca, 'xscale', 'log', 'yscale', 'log', 'fontsize', 9)
    legend(leg_str, 'location', 'northwest')
    if d==length(dist_plot)
         xlabel('Bout amplitude (MS/s)', 'fontsize', 10)
    end
end 

% print
filename = fullfile(cd, 'img', 'svg', 'HistBoutAmpl_Smk.svg');
%print (fig, '-painters', '-dsvg', '-r600', filename);