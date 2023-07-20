function satComp=getNFPSaturationDynamicComp(hN,hInSignals,hOutSignals,name)






    assert(numel(hInSignals)==3);
    uSignal=hInSignals(2);
    upSignal=hInSignals(1);
    loSignal=hInSignals(3);
    ySignal=hOutSignals(1);

    inType=uSignal.Type;
    inRate=uSignal.SimulinkRate;

    relOpOutType=pir_boolean_t;
    if inType.isArrayType

        relOpOutType=pirelab.createPirArrayType(relOpOutType,inType.Dimensions);
    end


    upperRelOpOutSig=hN.addSignal(relOpOutType,'UpperRelop_out');
    upperRelOpOutSig.SimulinkRate=inRate;

    upperRelOpName=sprintf('%s_UpperRelop',name);
    pirelab.getRelOpComp(hN,[uSignal,loSignal],upperRelOpOutSig,'<',0,upperRelOpName);


    lowerRelOpOutSig=hN.addSignal(relOpOutType,'LowerRelop_out');
    lowerRelOpOutSig.SimulinkRate=inRate;

    lowerRelOpName=sprintf('%s_LowerRelop',name);
    pirelab.getRelOpComp(hN,[uSignal,upSignal],lowerRelOpOutSig,'>',0,lowerRelOpName);


    switch1OutSig=hN.addSignal(inType,'Switch1_out');
    switch1OutSig.SimulinkRate=inRate;

    switch1Name=sprintf('%s_Switch1',name);
    pirelab.getSwitchComp(hN,[loSignal,uSignal],switch1OutSig,upperRelOpOutSig,...
    switch1Name,'~=',0,'Floor','Wrap');


    switch2OutSig=hN.addSignal(inType,'Switch2_out');
    switch2OutSig.SimulinkRate=inRate;

    switch2Name=sprintf('%s_Switch2',name);
    satComp=pirelab.getSwitchComp(hN,[upSignal,switch1OutSig],ySignal,lowerRelOpOutSig,...
    switch2Name,'~=',0,'Floor','Wrap');
end

