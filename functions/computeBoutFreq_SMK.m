function [SMK_bc, SMK_labels] = computeBoutFreq_SMK(amps_gas, cfg)
    
    %% Compute bout frequency using an amplitude threshold
    SMK_bc = zeros(cfg.n_wspd, cfg.n_dist, cfg.n_trials, cfg.n_thr, cfg.n_win, max(cfg.nr_of_chunks));
    SMK_labels = zeros(cfg.n_wspd, cfg.n_dist, cfg.n_trials, cfg.n_thr, cfg.n_win);
    for wspd=1:cfg.n_wspd
        for dist=1:cfg.n_dist
            tic();
            fprintf('wspd: %d, dist: %d...', wspd, dist)
            for trial=1:cfg.n_trials
                for thr=1:cfg.n_thr
                    for win=1:cfg.n_win
                        for i=1:cfg.nr_of_chunks(win)
                            SMK_bc(wspd,dist,trial,thr,win,i) = sum(amps_gas{wspd,dist,trial,win}{i}>cfg.thr_list(thr))/(cfg.winsize(win)/60);
                            SMK_labels(wspd,dist,trial,thr,win) = cfg.dist_meters(dist);
                        end
                    end
                end             
            end
            fprintf('elapsed time: %.1f\n', toc)
        end
    end

    clear SMK

    save(fullfile(cfg.data_path, 'SMK_bc.mat'), 'SMK_bc', 'SMK_labels')