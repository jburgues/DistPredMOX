function h_SMK = designFilterSMK(cfg)

    %% Schmuker filter design
    h_SMK = cell(1, length(cfg.SMK_sigma));
    for f=1:length(cfg.SMK_sigma)
        h_SMK{f} = FilterLPD_Schmuker(cfg.SMK_sigma(f), cfg.SMK_tau(f), cfg.Fs);
    end

    % Plot frequency response
    plotFilter = false;
    if plotFilter        
        figure;
        hold on
        for f=1:length(cfg.SMK_sigma)
            [H_Smk,f_Smk] = freqz(cfg.Fs*h_SMK{f}, 1, 'whole', 6001, cfg.Fs);
            plot(f_Smk,(abs(H_Smk)))
        end    
        % plot ideal frequency response
        [H_ideal,f_ideal] = freqz([1 -1]*cfg.Fs, 1, 'whole', 6001, cfg.Fs);
        plot(f_ideal,abs(H_ideal), 'k')
        % axis labels
        xlim([-0.1 3])
        ylim([-0.05, 4])
        xlabel('Frequency (Hz)')
        ylabel('Magnitude (a.u.)')
        title('Schmuker filter')
    end

    % Save filters to mat
    save(fullfile(cfg.data_path, 'filterSMK.mat'), 'h_SMK');
