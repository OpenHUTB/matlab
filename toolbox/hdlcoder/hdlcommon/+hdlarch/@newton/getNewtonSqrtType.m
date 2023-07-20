function rsqrtoutType=getNewtonSqrtType(hInSignals)










    din=hInSignals(1);
    inputType=din.Type;
    inputWL=inputType.WordLength;
    inputFL=-inputType.FractionLength;

    rsqrtoutFL=inputWL;
    rsqrtoutIntL=ceil(inputFL/2);
    rsqrtoutWL=rsqrtoutFL+rsqrtoutIntL;










    if rsqrtoutWL<7
        rsqrtoutWL=7;
    end

    rsqrtoutType=pir_ufixpt_t(rsqrtoutWL,-rsqrtoutFL);


