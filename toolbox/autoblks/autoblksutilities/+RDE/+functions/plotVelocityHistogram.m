function plotVelocityHistogram(data,~)









    v=data.v;
    opMode=data.opMode;

    hold on;
    histogram(v(opMode=='urban')*3.6,'NumBins',10);
    histogram(v(opMode=='rural')*3.6,'NumBins',10);
    histogram(v(opMode=='motorway')*3.6,'NumBins',10);
    hold off;
    grid on;
    xlabel('Velocity (km/h)');
    ylabel('Occurrences ()');
    legend({'urban','rural','motorway'});

end



