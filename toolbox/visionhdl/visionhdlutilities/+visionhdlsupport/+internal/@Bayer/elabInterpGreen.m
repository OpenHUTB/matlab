function interpGreenNet=elabInterpGreen(~,coreNet,blockInfo,sigInfo,dataRate)%#ok<INUSL>

    inType=sigInfo.inType.BaseType;
    inputWL=sigInfo.inputWL;
    inputFL=sigInfo.inputFL;
    twosCompT=pir_sfixpt_t(inputWL+1,-inputFL);
    shiftTwoT=pir_ufixpt_t(inputWL+2,-inputFL);
    shiftOneT=pir_ufixpt_t(inputWL+1,-inputFL);
    addT1=pir_sfixpt_t(inputWL+2,-inputFL);
    addT2=pir_ufixpt_t(inputWL+3,-inputFL);
    addT3=pir_ufixpt_t(inputWL+2,-inputFL);
    addT4=pir_sfixpt_t(inputWL+3,-inputFL);
    addT5=pir_ufixpt_t(inputWL+4,-inputFL);
    addT6=pir_sfixpt_t(inputWL+6,-inputFL);
    addT7=pir_sfixpt_t(inputWL+7,-inputFL);
    addT8=pir_ufixpt_t(inputWL+10,-(inputFL+3));


    inPortNames={'REG2IN','REG9IN','REG14IN','REG7IN','REG6IN','REG8IN','REG4IN','REG11IN','DATA3'};
    inPortTypes=[inType,inType,inType,inType,inType,inType,inType,inType,inType];
    inPortRates=[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate];
    outPortNames={'G'};
    outPortTypes=[inType];%#ok<NBRAK>

    interpGreenNet=pirelab.createNewNetwork(...
    'Network',coreNet,...
    'Name','interpGreen',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes);

    inSignals=interpGreenNet.PirInputSignals;
    REG2IN=inSignals(1);
    REG9IN=inSignals(2);
    REG14IN=inSignals(3);
    REG7IN=inSignals(4);
    REG6IN=inSignals(5);
    REG8IN=inSignals(6);
    REG4IN=inSignals(7);
    REG11IN=inSignals(8);
    DATA3=inSignals(9);

    outSignal=interpGreenNet.PirOutputSignals;
    Gain1Out=interpGreenNet.addSignal2('Type',twosCompT,'Name','GAIN1OUT');
    Gain2Out=interpGreenNet.addSignal2('Type',twosCompT,'Name','GAIN2OUT');
    Gain3Out=interpGreenNet.addSignal2('Type',twosCompT,'Name','GAIN3OUT');
    Gain4Out=interpGreenNet.addSignal2('Type',twosCompT,'Name','GAIN4OUT');
    Gain5CAST=interpGreenNet.addSignal2('Type',shiftTwoT,'Name','GAIN5CAST');
    Gain5Out=interpGreenNet.addSignal2('Type',shiftTwoT,'Name','GAIN5OUT');
    Gain6CAST=interpGreenNet.addSignal2('Type',shiftOneT,'Name','GAIN6CAST');
    Gain6Out=interpGreenNet.addSignal2('Type',shiftOneT,'Name','GAIN6OUT');
    Gain7CAST=interpGreenNet.addSignal2('Type',shiftOneT,'Name','GAIN7CAST');
    Gain7Out=interpGreenNet.addSignal2('Type',shiftOneT,'Name','GAIN7OUT');
    Gain8CAST=interpGreenNet.addSignal2('Type',shiftOneT,'Name','GAIN8CAST');
    Gain8Out=interpGreenNet.addSignal2('Type',shiftOneT,'Name','GAIN8OUT');
    Gain9CAST=interpGreenNet.addSignal2('Type',shiftOneT,'Name','GAIN9CAST');
    Gain9Out=interpGreenNet.addSignal2('Type',shiftOneT,'Name','GAIN9OUT');
    Gain9OutD=interpGreenNet.addSignal2('Type',shiftOneT,'Name','GAIN9OUTD');
    Gain10Out=interpGreenNet.addSignal2('Type',addT8,'Name','GAIN10');
    Gain10OutD=interpGreenNet.addSignal2('Type',addT8,'Name','GAIN10D');
    pirelab.getGainComp(interpGreenNet,REG2IN,Gain1Out,fi(-1,1,2,0),1,1);
    pirelab.getGainComp(interpGreenNet,DATA3,Gain2Out,fi(-1,1,2,0),1,1);
    pirelab.getGainComp(interpGreenNet,REG9IN,Gain3Out,fi(-1,1,2,0),1,1);
    pirelab.getGainComp(interpGreenNet,REG14IN,Gain4Out,fi(-1,1,2,0),1,1);

    pirelab.getDTCComp(interpGreenNet,REG7IN,Gain5CAST);
    pirelab.getBitShiftComp(interpGreenNet,Gain5CAST,Gain5Out,'sll',2);

    pirelab.getDTCComp(interpGreenNet,REG6IN,Gain6CAST);
    pirelab.getBitShiftComp(interpGreenNet,Gain6CAST,Gain6Out,'sll',1);
    pirelab.getDTCComp(interpGreenNet,REG8IN,Gain7CAST);
    pirelab.getBitShiftComp(interpGreenNet,Gain7CAST,Gain7Out,'sll',1);
    pirelab.getDTCComp(interpGreenNet,REG4IN,Gain8CAST);
    pirelab.getBitShiftComp(interpGreenNet,Gain8CAST,Gain8Out,'sll',1);
    pirelab.getDTCComp(interpGreenNet,REG11IN,Gain9CAST);
    pirelab.getBitShiftComp(interpGreenNet,Gain9CAST,Gain9Out,'sll',1);



    ADD1=interpGreenNet.addSignal2('Type',addT1,'Name','ADD1');
    ADD2=interpGreenNet.addSignal2('Type',addT1,'Name','ADD2');
    ADD3=interpGreenNet.addSignal2('Type',addT2,'Name','ADD3');
    ADD4=interpGreenNet.addSignal2('Type',addT3,'Name','ADD4');
    ADD1D=interpGreenNet.addSignal2('Type',addT1,'Name','ADD1');
    ADD2D=interpGreenNet.addSignal2('Type',addT1,'Name','ADD2');
    ADD3D=interpGreenNet.addSignal2('Type',addT2,'Name','ADD3');
    ADD4D=interpGreenNet.addSignal2('Type',addT3,'Name','ADD4');
    ADD5=interpGreenNet.addSignal2('Type',addT4,'Name','ADD5');
    ADD6=interpGreenNet.addSignal2('Type',addT5,'Name','ADD6');
    ADD5D=interpGreenNet.addSignal2('Type',addT4,'Name','ADD5D');
    ADD6D=interpGreenNet.addSignal2('Type',addT5,'Name','ADD6D');
    ADD7=interpGreenNet.addSignal2('Type',addT6,'Name','ADD7');
    ADD8=interpGreenNet.addSignal2('Type',addT7,'Name','ADD8');
    ADD9=interpGreenNet.addSignal2('Type',addT8,'Name','ADD9');



    pirelab.getAddComp(interpGreenNet,[Gain1Out,Gain2Out],ADD1,'Floor','Wrap');
    pirelab.getAddComp(interpGreenNet,[Gain3Out,Gain4Out],ADD2,'Floor','Wrap');
    pirelab.getAddComp(interpGreenNet,[Gain5Out,Gain6Out],ADD3,'Floor','Wrap');
    pirelab.getAddComp(interpGreenNet,[Gain7Out,Gain8Out],ADD4,'Floor','Wrap');


    pirelab.getUnitDelayComp(interpGreenNet,ADD1,ADD1D);
    pirelab.getUnitDelayComp(interpGreenNet,ADD2,ADD2D);
    pirelab.getUnitDelayComp(interpGreenNet,ADD3,ADD3D);
    pirelab.getUnitDelayComp(interpGreenNet,ADD4,ADD4D);

    pirelab.getAddComp(interpGreenNet,[ADD1D,ADD2D],ADD5,'Floor','Wrap');
    pirelab.getAddComp(interpGreenNet,[ADD3D,ADD4D],ADD6,'Floor','Wrap');


    pirelab.getUnitDelayComp(interpGreenNet,ADD5,ADD5D);
    pirelab.getUnitDelayComp(interpGreenNet,ADD6,ADD6D);
    pirelab.getIntDelayComp(interpGreenNet,Gain9Out,Gain9OutD,2);


    pirelab.getAddComp(interpGreenNet,[ADD5D,ADD6D],ADD7,'Floor','Wrap');


    pirelab.getAddComp(interpGreenNet,[ADD7,Gain9OutD],ADD8,'Floor','Wrap');



    pirelab.getDTCComp(interpGreenNet,ADD8,ADD9,'Nearest','Saturate');
    pirelab.getBitShiftComp(interpGreenNet,ADD9,Gain10Out,'srl',3);


    pirelab.getUnitDelayComp(interpGreenNet,Gain10Out,Gain10OutD);

    pirelab.getDTCComp(interpGreenNet,Gain10OutD,outSignal(1),'Nearest','Saturate');














