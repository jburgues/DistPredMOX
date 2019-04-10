function [LPD_bc, LPD_labels] = computeBoutFreq_LPD(amps_gas, cfg)
    
%% Compute bout frequency using an amplitude threshold
LPD_bc = zeros(cfg.n_wspd, cfg.n_dist, cfg.n_trials, cfg.n_fcut, cfg.n_thr, cfg.n_win, max(cfg.nr_of_chunks));
LPD_labels = zeros(cfg.n_wspd, cfg.n_dist, cfg.n_trials, cfg.n_fcut, cfg.n_thr, cfg.n_win);
for wspd=1:cfg.n_wspd
    for dist=1:cfg.n_dist
        tic();
        fprintf('wspd: %d, dist: %d...', wspd, dist)
        for trial=1:cfg.n_trials
            for f=1:cfg.n_fcut
                for thr=1:cfg.n_thr
                    for win=1:cfg.n_win
                        for i=1:cfg.nr_of_chunks(win)
                            LPD_bc(wspd,dist,trial,f,thr,win,i) = sum(amps_gas{wspd,dist,trial,f,win}{i}>cfg.thr_list(thr))/(cfg.winsize(win)/60);
                        LPD_labels(wspd,dist,trial,f,thr,win) = cfg.dist_meters(dist);
                        end
                    end
                end
            end
        end
        fprintf('elapsed time: %.1f\n', toc)
    end
end

% save data
save(fullfile(cfg.data_path, 'LPD_bc.mat'), 'LPD_bc', 'LPD_labels')
