wspd=3;
figure;
yoffs= linspace(0,20,20);
t_gas = zeros(n_wspd, n_dist, 2);
t_gas(1, :, :) = [80 200; 80 200; 90 210; 100 220; 110 230; 110 230];
t_gas(2, :, :) = [80 200; 80 200; 80 200; 80 200; 80 200; 90 210];
t_gas(3, :, :) = [75 195; 75 195; 75 195; 75 195; 75 195; 75 195];
for dist=1:6
    subplot(2,3,dist)
    for trial=1:n_trials        
        hold on
        plot(t, yoffs(trial)+squeeze(signal(wspd,dist,trial,:))');     
        vline(t_gas(wspd,dist,:))
    end
    title(sprintf('Dist: %d', dist))
end