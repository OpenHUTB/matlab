function hNewC=elaborate(this,hN,hC)


    CInfo=this.getBlockInfo(hC);

    hDataIn=hC.SLInputSignals(1);
    initval=pirelab.getTypeInfoAsFi(hDataIn.Type,'Nearest','Saturate',CInfo.InitialCondition,false);
    initval=pirelab.getTypeInfoAsFi(hDataIn.Type,'Floor','Wrap',initval,false);


    hNewC=pirelab.getDeserializer1DComp(hN,hC.SLInputSignals,hC.SLOutputSignals,...
    CInfo.Ratio,CInfo.IdleCycles,initval,CInfo.startInPort,CInfo.validInPort,CInfo.validOutPort,hC.Name);

end



