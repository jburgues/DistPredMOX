function h_LPD = designFilterLPD(cfg)

    % Digital differentiator design
    h_LPD = cell(1, cfg.n_fcut);
    for f=1:cfg.n_fcut
        fprintf('f: %d\n', f);
        h_LPD{f} = FilterLPD_Javier(cfg.LPD_Fpass(f), cfg.LPD_Fstop(f), cfg.LPD_Att, cfg.LPD_Dev, cfg.Fs);
    end

    % Plot frequency response
    plotFilter = false;
    if plotFilter 
        figure; 
        hold on
        % Plot low pass differentiator
        for f=1:cfg.n_fcut
            [H_LPD{f},f_Jbc] = freqz(cfg.Fs*h_LPD{f}, 1, 'whole', 6001, cfg.Fs);
            plot(f_Jbc,(abs(H_LPD{f})))        
        end
        % plot ideal frequency response
        [H_ideal,f_ideal] = freqz(cfg.Fs*[1 -1], 1, 'whole', 6001, cfg.Fs);
        plot(f_ideal,abs(H_ideal), 'k')
        % axis labels
        xlim([-0.1 3]);
        ylim([-0.05, 15])
        xlabel('Frequency (Hz)')
        ylabel('Magnitude (a.u.)')
        title('Low Pass Differentiator')
    end

    % Save filters to mat
    save(fullfile(cfg.data_path, 'filterLPD.mat'), 'h_LPD');