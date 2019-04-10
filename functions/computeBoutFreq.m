function [bc,labels] = computeBoutFreq(x, h, Fs, thr, cfg)

% Apply low pass differentiator filter to x
dyf = filter(Fs*h,1,x,[],3); % filter along 3rd dimension
%delay = 205;
[Gd,F] = grpdelay(h,1,512,Fs);
delay = mean(Gd(F<1));
dyf(:,:,1:delay) = [];

[N, M ,T] = size(x);
% find bouts
for i=1:N
    for j=1:M
        [~, amps] = computeBouts(dyf(i,j,delay:end));
        winsize = T / Fs / 60; % minutes
        bc = sum(amps>thr)/winsize;
    end
end


%% Compute bout frequency using an amplitude threshold
bc = zeros(cfg.n_wspd, cfg.n_dist, cfg.n_trials, cfg.n_win, max(cfg.nr_of_chunks));
labels = zeros(cfg.n_wspd, cfg.n_dist, cfg.n_trials, cfg.n_win, max(cfg.nr_of_chunks));
for wspd=1:cfg.n_wspd
    for dist=1:cfg.n_dist
        for trial=1:cfg.n_trials
            for win=1:cfg.n_win
                for i=1:cfg.nr_of_chunks(win)
                    bc(wspd,dist,trial,win,i) = sum(amps_gas{wspd,dist,trial,win}{i}>cfg.thr_list(thr))/(cfg.winsize(win)/60);
                    labels(wspd,dist,trial,win,i) = cfg.dist_meters(dist);
                end
            end
        end
    end
end
