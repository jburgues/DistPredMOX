%% Set root path
cd 'E:\OneDrive - IBEC\research\papers\2019\Bouts'

%% Load data
load(fullfile(cd, 'data', 'ExpConfig.mat'));
load(fullfile(cd, 'data', 'signals.mat'));

%% config
t_gas = [120 200]; % timeframe [t_start, t_end] for plot

%% Compute FFT
power = zeros(1+diff(t_gas)*Fs/2, cfg.n_wspd, cfg.n_dist, cfg.n_trials);
for wspd=1:cfg.n_wspd
    for dist=1:cfg.n_dist
        for trial=1:cfg.n_trials
            % select part of the signal corresponding to the stable gas release 
			x=squeeze(signal(wspd,dist,trial,:));
			tidx = (t>=t_gas(1)) & (t<=(t_gas(2))); 
            x_crop = x(tidx);
            % Take fourier transform
            power(:,wspd,dist,trial) = computeFFT(x_crop, Fs);
        end
    end
end

%% Plot all trials of a single distance
fig=createFig(0.55, 0.25);
hold on;
wspd_plot = [1 3]; % wind speed for plot
dist_plot = [2 5]; % distance for plot
colors = ['r', 'm';
		'b', 'c'];
leg_str = {};
for w=1:length(wspd_plot)
	wspd = wspd_plot(w);
	for d=1:length(dist_plot)
		dist = dist_plot(d);
		m = mean(squeeze(power(:,wspd,dist,:)),2); % mean across trials
		plot(f,10*log10(m), colors(wspd,d)); 
		leg_str = {leg_str sprintf('d = %d cm at %d cm/s', 100*cfg.dist_meters(dist), 100*cfg.wspd_ms(wspd))};
	end
end
  
% Labels
grid on
xlabel('Frequency (Hz)')
ylabel('Power/Frequency (dB/Hz)')
xlim([-0.5, 50])
ylim([-60, 0])
legend(leg_str, 'fontsize', 12)

% print
filename = fullfile(cd, 'img', 'svg', 'power spectrum.svg');
print (fig, '-painters', '-dsvg', '-r600', filename);