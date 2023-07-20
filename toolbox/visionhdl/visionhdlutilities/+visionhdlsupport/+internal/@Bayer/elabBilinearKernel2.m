function bilinearFilterNet2=elabBilinearKernel2(~,coreNet,blockInfo,sigInfo,dataRate)%#ok<INUSL>





    inType=sigInfo.inType.BaseType;
    inputWL=sigInfo.inputWL;
    inputFL=sigInfo.inputFL;
    shiftTwoT=pir_ufixpt_t(inputWL+4,-(inputFL+2));
    addT1=pir_ufixpt_t(inputWL+1,-inputFL);



    inPortNames={'REG6IN','DATA3','REG2IN','DATA1'};
    inPortTypes=[inType,inType,inType,inType];
    inPortRates=[dataRate,dataRate,dataRate,dataRate];

    outPortNames={'kernel2OUT'};
    outPortTypes=[inType];%#ok<NBRAK>

    bilinearFilterNet2=pirelab.createNewNetwork(...
    'Network',coreNet,...
    'Name','bilinearFilterKernel2',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes);

    inSignals=bilinearFilterNet2.PirInputSignals;
    REG6IN=inSignals(1);
    DATA3=inSignals(2);
    REG2IN=inSignals(3);
    DATA1=inSignals(4);

    outSignal=bilinearFilterNet2.PirOutputSignals;


    ADD1=bilinearFilterNet2.addSignal2('Type',addT1,'Name','ADD1');
    ADD2=bilinearFilterNet2.addSignal2('Type',addT1,'Name','ADD2');
    ADD1D=bilinearFilterNet2.addSignal2('Type',addT1,'Name','ADD1D');
    ADD2D=bilinearFilterNet2.addSignal2('Type',addT1,'Name','ADD2D');
    ADD3=bilinearFilterNet2.addSignal2('Type',shiftTwoT,'Name','ADD3');
    shiftOut=bilinearFilterNet2.addSignal2('Type',shiftTwoT,'Name','ADD3');

    pirelab.getAddComp(bilinearFilterNet2,[REG6IN,DATA3],ADD1,'Floor','Wrap');
    pirelab.getAddComp(bilinearFilterNet2,[REG2IN,DATA1],ADD2,'Floor','Wrap');


    pirelab.getUnitDelayComp(bilinearFilterNet2,ADD1,ADD1D);
    pirelab.getUnitDelayComp(bilinearFilterNet2,ADD2,ADD2D);


    pirelab.getAddComp(bilinearFilterNet2,[ADD1D,ADD2D],ADD3,'Floor','Wrap');


    pirelab.getBitShiftComp(bilinearFilterNet2,ADD3,shiftOut,'srl',2);

    pirelab.getDTCComp(bilinearFilterNet2,shiftOut,outSignal,'Nearest','Saturate');
