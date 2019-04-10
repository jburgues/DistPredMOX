function [features, feat_names, labels] = computeMeanStdMax(t, signal, cfg)
    %% Compute mean, standard deviation and maximum response of signals.
    mx = zeros(cfg.n_wspd, cfg.n_dist, cfg.n_trials, cfg.n_win, max(cfg.nr_of_chunks));
    sx = zeros(cfg.n_wspd, cfg.n_dist, cfg.n_trials, cfg.n_win, max(cfg.nr_of_chunks));
    zx = zeros(cfg.n_wspd, cfg.n_dist, cfg.n_trials, cfg.n_win, max(cfg.nr_of_chunks));
    labels = zeros(cfg.n_wspd, cfg.n_dist, cfg.n_trials,cfg.n_win, max(cfg.nr_of_chunks));
    for wspd=1:cfg.n_wspd
        for dist=1:cfg.n_dist
            for trial=1:cfg.n_trials
                x=squeeze(signal(wspd,dist,trial,:));
                for win=1:cfg.n_win
                    t_start = cfg.t_gas(wspd,dist,1);
                    t_end = cfg.t_gas(wspd,dist,2)-cfg.winsize(win);
                    r = randsample(t_start:t_end,cfg.nr_of_chunks(win));
                    for i=1:cfg.nr_of_chunks(win)
                        tidx = (t>r(i)) & (t<r(i)+cfg.winsize(win));
                        F(trial, 1) = 
                        
                        mx(wspd,dist,trial,win,i) = mean(x(tidx));
                        sx(wspd,dist,trial,win,i) = std(x(tidx));
                        zx(wspd,dist,trial,win,i) = max(x(tidx));
                        
                        bc_SMK(wspd,dist,trial,win,i) = sum(SMK.amps_gas{wspd,dist,trial,win}{i}>cfg.thr_list(thr))/(cfg.winsize(win)/60);
                        
                        D(trial) = cfg.dist_meters(dist);
                        WS(trial) = wspd;
                        W(trial) = wspd;
                    end
                end                
            end
        end
    end

    % concatenate features in a cell array
    features = {mx, sx , zx}; 
    feat_names ={'Average response (MS)', 'Standard deviation (MS)', 'Maximum response (MS)'};
