function [f, power] = computeFFT(signal, Fs)

    % Take fourier transform
    y = fft(signal);
    N = length(signal);   % number of samples
    % Crop fft
    y = y(1:N/2+1);
    % Compute power spectral density
    psdx = (1/(Fs*N)) * abs(y).^2;
    psdx(2:end-1) = 2*psdx(2:end-1);
    f = 0:Fs/N:Fs/2;
    % Store into output variable
    power = psdx;

