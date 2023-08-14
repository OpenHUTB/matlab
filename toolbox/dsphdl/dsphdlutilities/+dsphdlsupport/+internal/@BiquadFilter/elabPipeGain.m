function outputsig=elabPipeGain(~,net,blockInfo,gain,input,valid,name)




    inputType=input.Type;
    inputRate=input.SimulinkRate;
    inWL=inputType.WordLength;
    inFL=inputType.FractionLength;
    gainWL=gain.WordLength;
    gainFL=-1*gain.FractionLength;

    prodType=net.getType('FixedPoint','Signed',true,...
    'WordLength',inWL+gainWL,...
    'FractionLength',inFL+gainFL);

    numPre1=net.addSignal(inputType,['numPre1',name]);
    numPre1.SimulinkRate=inputRate;
    numPre2=net.addSignal(inputType,['numPre2',name]);
    numPre2.SimulinkRate=inputRate;
    prod=net.addSignal(prodType,['prod',name]);
    prod.SimulinkRate=inputRate;
    numPost1=net.addSignal(prodType,['numPost1',name]);
    numPost1.SimulinkRate=inputRate;
    numPost2=net.addSignal(prodType,['numPost2',name]);
    numPost2.SimulinkRate=inputRate;

    pirelab.getUnitDelayEnabledComp(net,input,numPre1,valid,['numPre',name,'Reg1']);
    pirelab.getUnitDelayEnabledComp(net,numPre1,numPre2,valid,['numPre',name,'Reg2']);
    pirelab.getGainComp(net,numPre2,prod,gain,...
    blockInfo.gainMode,blockInfo.gainOptimMode);
    pirelab.getUnitDelayEnabledComp(net,prod,numPost1,valid,['numPost',name,'Reg1']);
    pirelab.getUnitDelayEnabledComp(net,numPost1,numPost2,valid,['numPost',name,'Reg2']);
    outputsig=numPost2;
end
