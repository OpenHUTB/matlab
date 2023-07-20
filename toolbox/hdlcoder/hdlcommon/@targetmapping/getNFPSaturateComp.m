function satComp=getNFPSaturateComp(hN,hInSignals,hOutSignals,lowerLimit,upperLimit,name)






    assert(numel(lowerLimit)==numel(upperLimit));
    uSignal=hInSignals(1);
    inType=uSignal.Type;
    inRate=uSignal.SimulinkRate;

    ySignal=hOutSignals(1);
    outType=ySignal.Type;






    if(outType.isArrayType&&~inType.isArrayType)
        muxOutType=pirelab.createPirArrayType(inType,outType.Dimensions);
        [outdimlen,~]=pirelab.getVectorTypeInfo(ySignal);


        muxOutSig=hN.addSignal(muxOutType,'Satmux_out');
        muxOutSig.SimulinkRate=inRate;
        muxInSignals=repmat(uSignal,1,outdimlen);
        muxName=sprintf('%s_Mux',name);
        pirelab.getMuxComp(hN,muxInSignals,muxOutSig,muxName);


        uSignal=muxOutSig;
        inType=uSignal.Type;
    end


    hN.addSignal(inType,'LowerLimit_out');
    lowerConstSig=hN.addSignal(inType,'Lowerlimit_out');
    lowerConstSig.SimulinkRate=inRate;

    lowerConstName=sprintf('%s_LowerConst',name);
    pirelab.getConstComp(hN,lowerConstSig,lowerLimit,lowerConstName);

    hN.addSignal(inType,'UpperLimit_out');
    upperConstSig=hN.addSignal(inType,'Upperlimit_out');
    upperConstSig.SimulinkRate=inRate;

    upperConstName=sprintf('%s_UpperConst',name);
    pirelab.getConstComp(hN,upperConstSig,upperLimit,upperConstName);



    hNewInSignals=[upperConstSig,uSignal,lowerConstSig];
    satComp=targetmapping.getNFPSaturationDynamicComp(hN,hNewInSignals,hOutSignals,name);
end