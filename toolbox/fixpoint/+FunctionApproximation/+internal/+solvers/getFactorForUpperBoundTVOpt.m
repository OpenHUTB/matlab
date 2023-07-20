function factor=getFactorForUpperBoundTVOpt(nD,interpolation,relaxThreshold)






    scale=1;
    if interpolation=="Flat"
        scale=2;
    end


    if relaxThreshold
        scale=scale*2.75;
    end


    factor=1+exp(-nD)*scale;
end
