function bilinearFilterNet1=elabBilinearKernel1(~,coreNet,blockInfo,sigInfo,dataRate)%#ok<INUSL>

    inType=sigInfo.inType.BaseType;
    inputWL=sigInfo.inputWL;
    inputFL=sigInfo.inputFL;
    shiftTwoT=pir_ufixpt_t(inputWL+4,-(inputFL+2));
    addT1=pir_ufixpt_t(inputWL+1,-inputFL);
    inPortNames={'REG5IN','REG4IN','DATA2','REG1IN'};
    inPortTypes=[inType,inType,inType,inType];
    inPortRates=[dataRate,dataRate,dataRate,dataRate];

    outPortNames={'kernel1OUT'};
    outPortTypes=[inType];%#ok<NBRAK>
    bilinearFilterNet1=pirelab.createNewNetwork(...
    'Network',coreNet,...
    'Name','bilinearFilterKernel1',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes);
    inSignals=bilinearFilterNet1.PirInputSignals;
    REG5IN=inSignals(1);
    REG4IN=inSignals(2);
    DATA2=inSignals(3);
    REG1IN=inSignals(4);
    outSignal=bilinearFilterNet1.PirOutputSignals;
    ADD1=bilinearFilterNet1.addSignal2('Type',addT1,'Name','ADD1');
    ADD2=bilinearFilterNet1.addSignal2('Type',addT1,'Name','ADD2');
    ADD1D=bilinearFilterNet1.addSignal2('Type',addT1,'Name','ADD1D');
    ADD2D=bilinearFilterNet1.addSignal2('Type',addT1,'Name','ADD2D');
    ADD3=bilinearFilterNet1.addSignal2('Type',shiftTwoT,'Name','ADD3');
    shiftOut=bilinearFilterNet1.addSignal2('Type',shiftTwoT,'Name','ADD3');
    pirelab.getAddComp(bilinearFilterNet1,[REG5IN,REG4IN],ADD1,'Floor','Wrap');
    pirelab.getAddComp(bilinearFilterNet1,[DATA2,REG1IN],ADD2,'Floor','Wrap');
    pirelab.getUnitDelayComp(bilinearFilterNet1,ADD1,ADD1D);
    pirelab.getUnitDelayComp(bilinearFilterNet1,ADD2,ADD2D);
    pirelab.getAddComp(bilinearFilterNet1,[ADD1D,ADD2D],ADD3,'Floor','Wrap');

    pirelab.getBitShiftComp(bilinearFilterNet1,ADD3,shiftOut,'srl',2);
    pirelab.getDTCComp(bilinearFilterNet1,shiftOut,outSignal,'Nearest','Saturate');

