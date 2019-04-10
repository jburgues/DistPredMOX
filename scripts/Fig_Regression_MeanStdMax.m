%% Load data
load(fullfile(cd, 'data', 'config.mat'));
load(fullfile(cd, 'data', 'mean_var_max.mat'));
load(fullfile(cd, 'data', 'RMSEP_meanStdMax.mat'));

% set config
win = 4;
color = (1/255)*[255 0 0; 51, 153, 51; 0 0 255];
noise_scale = 2;
ylims = [20 100; 0 6; 20 110];

% plot
n_feat = length(features);
fig=createFig(1.4, 0.33);
for feat=1:n_feat
    subplot(1,n_feat,feat)
    hold on
    phdl = zeros(1, cfg.n_wspd);
    leg = cell(1, cfg.n_wspd);
    model_opt = cell(1, cfg.n_wspd);
    for wspd=1:cfg.n_wspd
        x = squeeze(features{feat}(wspd,dist_fit,:,win));
        y = squeeze(labels(wspd,dist_fit,:));
        
        % plot train samples
        x_train = x(:,1:14);
        y_train = y(:,1:14);
        noise = randn(size(y_train(:)))*noise_scale;
        scatter(100*y_train(:)+noise,x_train(:),15,color(wspd,:), 'filled')
        
        % plot test samples
        x_test = x(:,15:20);
        y_test = y(:,15:20);
        noise = randn(size(y_test(:)))*noise_scale;
        scatter(100*y_test(:)+noise,x_test(:),15,color(wspd,:))
        
        % plot model line
        xp=0.5*min(x(:)):0.1:max(x(:));
        yp = evalmdl(MDL_OPT{feat,wspd,win}, xp);
        phdl(wspd)=plot(100*yp,xp,'color', color(wspd,:));
        r = squeeze(RMSEP(feat, wspd, win));
        leg{wspd} = sprintf('LPD (RMSEP: %d cm)', round(100*r));
        model_opt{wspd} = MDL_OPT{feat,wspd,win};
    end
    % Label axis
    xticks(100*distance_meters(dist_fit))
    xlabel('Distance (cm)', 'fontsize',11)
    ylabel(feat_names{feat}, 'fontsize',11)
    set(gca, 'fontsize', 11)
    xlim([20,150])
    ylim(ylims(feat,:))
    legend(phdl, leg);
end   

% print
filename = fullfile(cd, 'img', 'svg', 'Regression_MeanVarMax.svg');
%print (fig, '-painters', '-dsvg', '-r600', filename);