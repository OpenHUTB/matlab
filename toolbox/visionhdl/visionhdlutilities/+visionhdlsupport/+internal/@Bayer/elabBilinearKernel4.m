function bilinearFilterNet4=elabBilinearKernel4(~,coreNet,blockInfo,sigInfo,dataRate)%#ok<INUSL>





    inType=sigInfo.inType.BaseType;
    inputWL=sigInfo.inputWL;
    inputFL=sigInfo.inputFL;
    addT1=pir_ufixpt_t(inputWL+2,-(inputFL+1));



    inPortNames={'REG4IN','DATA2IN'};
    inPortTypes=[inType,inType];
    inPortRates=[dataRate,dataRate];

    outPortNames={'kernel4OUT'};
    outPortTypes=[inType];%#ok<NBRAK>

    bilinearFilterNet4=pirelab.createNewNetwork(...
    'Network',coreNet,...
    'Name','bilinearFilterKernel4',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes);

    inSignals=bilinearFilterNet4.PirInputSignals;
    REG4IN=inSignals(1);
    DATA2IN=inSignals(2);


    outSignal=bilinearFilterNet4.PirOutputSignals;


    ADD1=bilinearFilterNet4.addSignal2('Type',addT1,'Name','ADD1');
    ADD1D=bilinearFilterNet4.addSignal2('Type',addT1,'Name','ADD1D');
    shiftOut=bilinearFilterNet4.addSignal2('Type',addT1,'Name','shiftOut');

    pirelab.getAddComp(bilinearFilterNet4,[REG4IN,DATA2IN],ADD1,'Floor','Wrap');


    pirelab.getUnitDelayComp(bilinearFilterNet4,ADD1,ADD1D);



    pirelab.getBitShiftComp(bilinearFilterNet4,ADD1D,shiftOut,'srl',1);

    pirelab.getDTCComp(bilinearFilterNet4,shiftOut,outSignal,'Nearest','Saturate');
