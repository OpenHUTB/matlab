function hNewC=elaborate(~,hN,hC)



    assert(hN.hasForIterDataTag);
    fidt=hN.getForIterDataTag;


    iterations=fidt.getIterations;
    assert(iterations>0);


    hSL=hC.SimulinkHandle;
    isZeroBased=strcmp(get_param(hSL,'IndexMode'),'Zero-based');
    if isZeroBased
        countFromVal=0;
        countToVal=iterations-1;
    else
        countFromVal=1;
        countToVal=iterations;
    end



    if isempty(hC.SLOutputSignals)

        wordLength=ceil(log2(countToVal+1));
        outType=pir_unsigned_t(wordLength);

        hOutSignal=hN.addSignal;
        hOutSignal.SimulinkHandle=0;
        hOutSignal.SimulinkRate=0;
        hOutSignal.Type=outType;
    else
        hOutSignal=hC.SLOutputSignals;
    end


    cntComp=pirelab.getCounterComp(hN,[],hOutSignal...
    ,'Count limited'...
    ,countFromVal...
    ,1...
    ,countToVal...
    ,false...
    ,false...
    ,false...
    ,false...
    ,hC.Name...
    ,countFromVal...
    );


    fidt.setIterationCounter(cntComp);

    hNewC=cntComp;

end


