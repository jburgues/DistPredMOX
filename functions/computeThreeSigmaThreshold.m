function [thr_3s, pctl_3s, thr_99_87] = computeThreeSigmaThreshold(amps_bl)
    
    % mu+3sigma threshold
    thr_3s = mean(amps_bl) + 3*std(amps_bl);
    % Percentile of mu+3sigma 
    [ff,x] = ecdf(amps_bl);
    [~, x_3s] = min(abs(x-thr_3s));
    pctl_3s = ff(x_3s);

    % 99.97 percentile
    thr_99_87 = prctile(amps_bl, 99.87);