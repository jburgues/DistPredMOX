function LPD = computeBoutsLPD(signals, h_LPD, cfg)

    %% Compute bouts using LPD filters
    LPD.amps = cell(cfg.n_wspd, cfg.n_dist, cfg.n_trials, cfg.n_fcut);
    LPD.bouts = cell(cfg.n_wspd, cfg.n_dist, cfg.n_trials, cfg.n_fcut);
    LPD.labels = zeros(cfg.n_wspd, cfg.n_dist, cfg.n_trials);
    for wspd=1:cfg.n_wspd
        for dist=1:cfg.n_dist
            for trial=1:cfg.n_trials
                fprintf('wspd: %d, dist: %d, trial: %d\n', wspd, dist, trial)
                x=squeeze(signals(wspd,dist,trial,:));

                % LPD filter 
                for f=1:cfg.n_fcut
                    % Obtain smoothed derivative
                    dyf_Jbc = filter(cfg.Fs*h_LPD{f}, 1, x);
                    delay_Jbc = mean(grpdelay(h_LPD{f}));
                    dyf_Jbc(1:delay_Jbc) = [];
                    % Find bouts
                    [LPD.bouts{wspd,dist,trial,f}, LPD.amps{wspd,dist,trial,f}] = computeBouts(dyf_Jbc);
                end
                LPD.labels(wspd,dist,trial) = cfg.dist_meters(dist);
            end
        end
    end

    %% Extract baseline bouts
    LPD.amps_bl = cell(cfg.n_wspd, cfg.n_dist, cfg.n_trials, cfg.n_fcut);
    for wspd=1:cfg.n_wspd
        for dist=1:cfg.n_dist
            for trial=1:cfg.n_trials
                for f=1:cfg.n_fcut
                    bouts = LPD.bouts{wspd, dist, trial, f};
                    amps = LPD.amps{wspd, dist, trial, f};
                    idx = (bouts(:,1)/cfg.Fs>cfg.t_bl(1)) & (bouts(:,2)/cfg.Fs<cfg.t_bl(2));
                    LPD.amps_bl{wspd,dist,trial,f} = amps(idx);                
                end
            end
        end
    end
        
    %% Compute mu+3sigma threshold
    LPD.thr_3sigma = zeros(cfg.n_wspd, cfg.n_fcut);
    LPD.pctl_3sigma = zeros(cfg.n_wspd, cfg.n_fcut); % percentile corresponding to 3sigma threshold
    LPD.thr_pctl99 = zeros(cfg.n_wspd, cfg.n_fcut); % percentile 99.87%
    for wspd=1:cfg.n_wspd
        for f=1:cfg.n_fcut
            C = LPD.amps_bl(wspd,:,:,f);
            abl = vertcat(C{:});
            [LPD.thr_3sigma(wspd,f), LPD.pctl_3sigma(wspd,f), LPD.thr_pctl99(wspd,f)] = computeThreeSigmaThreshold(abl)
        end
    end

    %% Extract gas bouts
    LPD.amps_gas = cell(cfg.n_wspd, cfg.n_dist, cfg.n_trials, cfg.n_fcut, cfg.n_win);
    for wspd=1:cfg.n_wspd
        for dist=1:cfg.n_dist
            for trial=1:cfg.n_trials
                for f=1:cfg.n_fcut
                    bouts = LPD.bouts{wspd, dist, trial, f};
                    amps = LPD.amps{wspd, dist, trial, f};
                    for win=1:cfg.n_win
                        t_start = cfg.t_gas(wspd,dist,1);
                        t_end = cfg.t_gas(wspd,dist,2)-cfg.winsize(win);
                        r = randsample(t_start:t_end,cfg.nr_of_chunks(win));
                        LPD.amps_gas{wspd,dist,trial,f,win} = cell(1,cfg.nr_of_chunks(win));
                        for i=1:cfg.nr_of_chunks(win)
                            idx = (bouts(:,1)/cfg.Fs>r(i)) & (bouts(:,2)/cfg.Fs<r(i)+cfg.winsize(win));
                            LPD.amps_gas{wspd,dist,trial,f,win}{i} = amps(idx);
                        end
                    end
                end
            end
        end
    end

    %% Save
    savename = fullfile(cfg.data_path, 'LPD_bouts_and_amps.mat');
    save(savename, 'LPD')