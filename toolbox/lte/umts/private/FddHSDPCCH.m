



























function scram=FddHSDPCCH(config,nframes)

    validateUMTSParameter('HARQACK',config);
    validateUMTSParameter('CQI',config);
    harq=FddHSHARQACKEncoder(config);
    cqi=FddHSCQIEncoder(config);


    iqed=1;
    spreadCode=1;
    if any(config.Nmaxdpdch==[0,1,3,5])
        iqed=1i;
        if config.Nmaxdpdch==0
            spreadCode=33;
        elseif config.Nmaxdpdch==1
            spreadCode=64;
        else
            spreadCode=32;
        end
    end


    hsdpcch=repmat([double(harq),double(cqi)],1,nframes*5);

    symbols=FddULModulation(hsdpcch,'BPSK',iqed)/sqrt(2);
    spread=FddSpreading(symbols,256,spreadCode,1);
    scram=FddScrambling(spread,0,config.ScramblingCode,config.ScramblingOffset).';
end