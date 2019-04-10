function [bouts, amps] = extractBouts(x, h, Fs)
    
% Apply low pass differentiator filter to x
dyf = filter(Fs*h,1,x,[],4); % filter along 4th dimension
[Gd,F] = grpdelay(h,1,512,Fs);
Gd(1) = [];
F(1) = [];
delay = mean(Gd(F<1)); % get group delay from low frequencies.

[N, M, K, ~] = size(x);
bouts = cell(N,M,K);
amps = cell(N,M,K);
% find bouts
for i=1:N
    for j=1:M
        for k=1:K
            [bouts{i,j,k}, amps{i,j,k}] = computeBouts(dyf(i,j,k,delay:end));
        end
    end
end
    