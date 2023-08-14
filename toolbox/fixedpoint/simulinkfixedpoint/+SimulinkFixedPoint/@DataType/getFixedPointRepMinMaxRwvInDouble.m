function[minRwvInDouble,maxRwvInDouble]=getFixedPointRepMinMaxRwvInDouble(dt)










    if isempty(dt.Signed)
        DAStudio.error('SimulinkFixedPoint:autoscaling:unspecifiedSign');
    end

    if dt.Signed
        maxRwvInDouble=dt.Bias+dt.Slope*(2^(-1+dt.WordLength)-1);
        minRwvInDouble=dt.Bias-dt.Slope*(2^(-1+dt.WordLength));
    else
        maxRwvInDouble=dt.Bias+dt.Slope*(2^(dt.WordLength)-1);
        minRwvInDouble=dt.Bias;
    end
