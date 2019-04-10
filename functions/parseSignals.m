function [t, signal] = parseSignals(cfg)
    % read signals from a csv file and save it into a .mat file
    signal = zeros(cfg.n_wspd, cfg.n_dist, cfg.n_trials, 26000);
    for wspd=1:cfg.n_wspd
        logcsv = sprintf('signals_spd%d_gas%d_volt%d_sensor%d_board%d.csv', wspd, ...
                                        cfg.gas, cfg.volt, cfg.sensor, cfg.board);
        filename = fullfile(cd, 'data', logcsv);
        tbl = readtable(filename, 'ReadVariableNames', true);
        t = tbl.time;
        for dist=1:cfg.n_dist
            fprintf('wspd: %d, dist: %d\n', wspd, dist)
            for trial=1:cfg.n_trials
                eval(sprintf('x = tbl.d%dt%d;',dist,trial));              
                signal(wspd,dist,trial,:) = x;
            end
        end
    end
end