function [t, signal] = getSignals(cfg)

    d = dir(cfg.data_path);
    signals_exist = regexp([d.name], 'signals.mat')>0;
    if signals_exist
        load(fullfile(cfg.data_path, 'signals.mat'))
    else
        [t, signal] = parseSignals(cfg);
        save(fullfile(data_path, 'signals.mat'), 't', 'signal') % save to .mat file
    end