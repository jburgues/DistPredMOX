function h = FilterLPD_Schmuker(sigma, tau, Fs)
    %% Schmuker filter design
    % Gaussian filter
    N = 10*sigma*Fs;
    alpha = 5;
    w = gausswin(N, alpha);
    w = w/sum(w); % To force unit gain
    % Derivative
    dy = [1 -1];
    h = conv(w, dy);
    % EWMA filter
    alpha = 1-exp(log(0.5)/(tau*Fs));
    ewma=[];
    for k=0:1000
        ewma = [ewma alpha*(1-alpha)^k];
    end
    % Convolution
    h = conv(h, ewma);