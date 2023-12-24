function bilinearFilterNet3=elabBilinearKernel3(~,coreNet,blockInfo,sigInfo,dataRate)%#ok<INUSL>
    inType=sigInfo.inType.BaseType;
    inputWL=sigInfo.inputWL;
    inputFL=sigInfo.inputFL;
    addT1=pir_ufixpt_t(inputWL+2,-(inputFL+1));

    inPortNames={'REG5IN','REG1IN'};
    inPortTypes=[inType,inType];
    inPortRates=[dataRate,dataRate];

    outPortNames={'kernel3OUT'};
    outPortTypes=[inType];%#ok<NBRAK>
    bilinearFilterNet3=pirelab.createNewNetwork(...
    'Network',coreNet,...
    'Name','bilinearFilterKernel3',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes);
    inSignals=bilinearFilterNet3.PirInputSignals;
    REG5IN=inSignals(1);
    REG1IN=inSignals(2);
    outSignal=bilinearFilterNet3.PirOutputSignals;
    ADD1=bilinearFilterNet3.addSignal2('Type',addT1,'Name','ADD1');
    ADD1D=bilinearFilterNet3.addSignal2('Type',addT1,'Name','ADD1D');
    shiftOut=bilinearFilterNet3.addSignal2('Type',addT1,'Name','shiftOut');
    pirelab.getAddComp(bilinearFilterNet3,[REG5IN,REG1IN],ADD1,'Floor','Wrap');
    pirelab.getUnitDelayComp(bilinearFilterNet3,ADD1,ADD1D);
    pirelab.getBitShiftComp(bilinearFilterNet3,ADD1D,shiftOut,'srl',1);
    pirelab.getDTCComp(bilinearFilterNet3,shiftOut,outSignal,'Nearest','Saturate');
