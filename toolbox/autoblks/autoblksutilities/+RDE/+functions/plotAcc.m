function plotAcc(data,~)









    v=data.v;
    opMode=data.opMode;
    a=[nan;(v(3:end)-v(1:end-2))/2;nan];

    hold on;
    gscatter(v*3.6,a,opMode,[0,0.4470,0.7410;0.8500,0.3250,0.0980;0.9290,0.6940,0.1250]);
    hold off;
    grid on;
    xlabel('Speed (km/h)');
    ylabel('Accel (m/s^2)');
    legend('show','Location','best');

end


