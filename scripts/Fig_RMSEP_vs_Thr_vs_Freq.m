%% Set root path
cd 'E:\OneDrive - IBEC\research\papers\2019\Bouts'

%% load data
load(fullfile(cd, 'data', 'config.mat'));
load(fullfile(cd, 'data', 'RMSEP.mat'))

%% Plot RMSEP for different f_cut and thr.
win=4;
r_max = 0.5; % maximum RMSECV (m) in visualization
wspd_list = [1 3];
color=colormap(jet(cfg.n_fcut));

fig = createFig(0.95, 0.28);
ax = zeros(1,length(wspd_list));
x0 = [0.07 0.52];
y0 = 0.18;
width=0.35;
height = 0.75;
med_window = 1; % moving average window
for w=1:length(wspd_list)
    wspd = wspd_list(w);
    axes(subplot('Position',[x0(w), y0, width, height]));
    colormap(jet(cfg.n_fcut))
    hold on
    grid on
	
    % Low Pass Differentiator
    for fcut=1:cfg.n_fcut
        f = getLPDindex(fcut, cfg);
        r = mean(squeeze(RMSEP(wspd, wspd, win, 1:cfg.nr_of_chunks(win), f))); % mean across chunks
        r(r>r_max | isnan(r))=r_max;
        plot(cfg.thr_list, 100*r, 'color', color(fcut,:), 'linestyle', '-','linewidth', 0.9);
    end
	
    % Schmuker filter
    f = getSMKindex(cfg);
    r = mean(squeeze(RMSEP(wspd, wspd, win, 1:cfg.nr_of_chunks(win), f))); % mean across chunks
    r(r>r_max | isnan(r))=r_max;
    plot(cfg.thr_list, 100*r, 'color', 'k', 'linestyle', '-', 'linewidth', 1.4);
	
    % 3-sigma threshold
%     [~,idx_3sigma]=min(abs(cfg.thr_list-SMK_thr.thr_3sigma(wspd)));
%     scatter(SMK.thr_3sigma(wspd), 100*r(idx_3sigma), 25, 'r', 'filled')  
    
    % labels    
    ylim([5, 100*r_max+1])
    xlim([0.9e-4, 10])
    xlabel('Threshold (MS/s)', 'fontsize',10)
    set(gca,'xscale', 'log')    
    title(sprintf('Wind speed: %d cm/s', round(100*cfg.wspd_ms(wspd))))
    if wspd==3
        caxis([0.1, 2.0])
        cbar=colorbar('position', [0.9 0.15 0.02 0.8], 'orientation', 'vertical');
        cbar.FontSize = 10;
        cbar.Label.String = 'Cut-off frequency (Hz)';
    end
    ylabel('RMSEP (cm)','fontsize',10)
    set(gca, 'fontsize',9)
    xticks([1e-4, 1e-3, 1e-2, 1e-1, 1e0, 1e1])
end

% print
filename = fullfile(cfg.img_path, 'svg', 'RMSEP_Bouts_vs_threshold.svg');
%print (fig, '-painters', '-dsvg', '-r600', filename);