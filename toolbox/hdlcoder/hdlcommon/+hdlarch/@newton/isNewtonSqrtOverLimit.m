function isover=isNewtonSqrtOverLimit(hInSignals)




    rsqrtoutType=hdlarch.newton.getNewtonSqrtType(hInSignals);
    rsqrtoutWL=rsqrtoutType.WordLength;
    rsqrtoutFL=-rsqrtoutType.FractionLength;
    maxLength=max(rsqrtoutWL,rsqrtoutFL);

    if maxLength>128;
        isover=true;
    else
        isover=false;
    end

