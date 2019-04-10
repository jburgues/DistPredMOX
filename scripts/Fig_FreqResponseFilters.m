%% Set root path
cd 'E:\OneDrive - IBEC\research\papers\2019\Bouts'

%% Load data
load(fullfile(cd, 'data', 'ExpConfig.mat'));
load(fullfile(cd, 'data', 'psd_signals.mat'));
load(fullfile(cd, 'data', 'Schmuker_filter.mat'));
load(fullfile(cd, 'data', 'LPD_filter.mat'));

%% Plot
lw = 1.5;
fig=createFig(0.55, 0.25);
hold on

% plot ideal differentiator
[H_ideal,f_ideal] = freqz(Fs*[1 -1], 1, 'whole', 6001, Fs);
plot(f_ideal-0.01,abs(H_ideal), 'k--', 'linewidth', lw); % x-offset by 0.01 for visual clarity

% plot schmuker filters
colors = {'b', 'c'};
for f=1:length(h_Smk)
    [H_Smk,f_Smk] = freqz(Fs*h_Smk{f}, 1, 'whole', 6001, Fs);
    plot(f_Smk,abs(H_Smk), colors{f}, 'linewidth', lw)
end

% plot javier filters
f_list = [1,3,4];
for f=length(f_list):-1:1
    [H_Jbc,f_Jbc] = freqz(Fs*h_Jbc{f_list(f)}, 1, 'whole', 6001, Fs);
    plot(f_Jbc,abs(H_Jbc), 'linewidth', lw)
end

% labels
xlim([-0.03,2.5])
ylim([-0.05, 13]);
xlabel('Frequency (Hz)')
ylabel('Magnitude (a.u.)')
legend('ideal differentiator', 'SMK_{\sigma=0.4 s, \tau=0.3 s}', ...
    'SMK_{\sigma=0.2 s, \tau=0.2 s}','LPD_{1.5 Hz}', 'LPD_{0.7 Hz}', 'LPD_{0.3 Hz}' ,...
    'd = 0.25 m at 0.10 m/s', 'd = 1.18 m at 0.10 m/s', ...
        'd = 0.25 m at 0.34 m/s' , 'd = 1.18 m at 0.34 m/s', 'fontsize', 11)
		
% Plot raw signals at 0.10 m/s on the background
s = 1;
m2 = mean(squeeze(power(:,s,2,:)),2);
m5 = mean(squeeze(power(:,s,5,:)),2);
yyaxis right;
N = length(x_crop);
f = 0:fs/N:fs/2;
p1 = plot(f,10*log10(m2));  
p2 = plot(f,10*log10(m5));   
p1.Color(4)=0.5;
p2.Color(4)=0.5;
% Plot raw signals at 0.34 m/s on the background
s = 2;
m2 = mean(squeeze(power(:,s,2,:)),2);
m5 = mean(squeeze(power(:,s,5,:)),2);
p3 = plot(f,10*log10(m2), 'r');  
p4 = plot(f,10*log10(m5), 'r');   
p3.Color(4)=0.5;
p4.Color(4)=0.5;
xlim([-0.03,2.5])
ylim([-42, 25]);

% print
filename = fullfile(cd, 'img', 'filter comparison.svg');
print (fig, '-painters', '-dsvg', '-r600', filename);
