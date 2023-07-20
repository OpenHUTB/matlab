function interpRB1Net=elabRB1(~,coreNet,blockInfo,sigInfo,dataRate)%#ok<INUSL>





    inType=sigInfo.inType.BaseType;
    inputWL=sigInfo.inputWL;
    inputFL=sigInfo.inputFL;
    twosCompT=pir_sfixpt_t(inputWL+1,-inputFL);
    shiftTwoT=pir_ufixpt_t(inputWL+2,-inputFL);
    shiftOneT=pir_ufixpt_t(inputWL+1,-inputFL);%#ok<NASGU>
    shiftOneRT=pir_ufixpt_t(inputWL+1,-inputFL-1);
    constantGainT=pir_ufixpt_t(inputWL+3,-inputFL);
    addT1=pir_sfixpt_t(inputWL+3,-inputFL-1);
    addT2=pir_sfixpt_t(inputWL+2,-inputFL);
    addT3=pir_ufixpt_t(inputWL+4,-inputFL);
    addT4=pir_sfixpt_t(inputWL+3,-inputFL);
    addT5=pir_sfixpt_t(inputWL+4,-inputFL-1);
    addT6=pir_sfixpt_t(inputWL+5,-inputFL);
    addT7=pir_sfixpt_t(inputWL+6,-inputFL-1);
    addT8=pir_sfixpt_t(inputWL+7,-inputFL-1);
    addT9=pir_ufixpt_t(inputWL+10,-inputFL-4);


    inPortNames={'REG2IN','REG3IN','REG5IN','DATA3IN','REG6IN','REG7IN'...
    ,'REG8IN','REG9IN','REG10IN','REG12IN','REG14IN'};
    inPortTypes=[inType,inType,inType,inType,inType,inType,inType,inType,inType,inType,inType];
    inPortRates=[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate];

    outPortNames={'RB'};
    outPortTypes=[inType];%#ok<NBRAK>

    interpRB1Net=pirelab.createNewNetwork(...
    'Network',coreNet,...
    'Name','interpRB1',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes);

    inSignals=interpRB1Net.PirInputSignals;
    REG2IN=inSignals(1);
    REG3IN=inSignals(2);
    REG5IN=inSignals(3);
    DATA3IN=inSignals(4);
    REG6IN=inSignals(5);
    REG7IN=inSignals(6);
    REG8IN=inSignals(7);
    REG9IN=inSignals(8);
    REG10IN=inSignals(9);
    REG12IN=inSignals(10);
    REG14IN=inSignals(11);

    outSignal=interpRB1Net.PirOutputSignals;


    Gain1CAST=interpRB1Net.addSignal2('Type',shiftOneRT,'Name','GAIN1CAST');
    Gain1Out=interpRB1Net.addSignal2('Type',shiftOneRT,'Name','GAIN1OUT');
    Gain2Out=interpRB1Net.addSignal2('Type',twosCompT,'Name','GAIN2OUT');
    Gain3Out=interpRB1Net.addSignal2('Type',twosCompT,'Name','GAIN3OUT');
    Gain4Out=interpRB1Net.addSignal2('Type',twosCompT,'Name','GAIN4OUT');
    Gain5CAST=interpRB1Net.addSignal2('Type',shiftTwoT,'Name','GAIN5CAST');
    Gain5Out=interpRB1Net.addSignal2('Type',shiftTwoT,'Name','GAIN5OUT');
    Gain6Out=interpRB1Net.addSignal2('Type',constantGainT,'Name','GAIN6OUT');
    Gain7CAST=interpRB1Net.addSignal2('Type',shiftTwoT,'Name','GAIN7CAST');
    Gain7Out=interpRB1Net.addSignal2('Type',shiftTwoT,'Name','GAIN7OUT');
    Gain8Out=interpRB1Net.addSignal2('Type',twosCompT,'Name','GAIN8OUT');
    Gain9Out=interpRB1Net.addSignal2('Type',twosCompT,'Name','GAIN9OUT');
    Gain10Out=interpRB1Net.addSignal2('Type',twosCompT,'Name','GAIN10OUT');
    Gain11CAST=interpRB1Net.addSignal2('Type',shiftOneRT,'Name','GAIN11CAST');
    Gain11Out=interpRB1Net.addSignal2('Type',shiftOneRT,'Name','GAIN11OUT');
    Gain11OutD=interpRB1Net.addSignal2('Type',shiftOneRT,'Name','GAIN11OUTD');
    Gain12Out=interpRB1Net.addSignal2('Type',addT9,'Name','GAIN12OUT');
    Gain12OutD=interpRB1Net.addSignal2('Type',addT9,'Name','GAIN12OUTD');



    pirelab.getDTCComp(interpRB1Net,REG2IN,Gain1CAST);
    pirelab.getBitShiftComp(interpRB1Net,Gain1CAST,Gain1Out,'srl',1);
    pirelab.getGainComp(interpRB1Net,REG3IN,Gain2Out,fi(-1,1,2,0),1,1);
    pirelab.getGainComp(interpRB1Net,REG5IN,Gain3Out,fi(-1,1,2,0),1,1);
    pirelab.getGainComp(interpRB1Net,DATA3IN,Gain4Out,fi(-1,1,2,0),1,1);
    pirelab.getDTCComp(interpRB1Net,REG6IN,Gain5CAST);
    pirelab.getBitShiftComp(interpRB1Net,Gain5CAST,Gain5Out,'sll',2);
    pirelab.getGainComp(interpRB1Net,REG7IN,Gain6Out,fi(5,0,3,0),1,1);
    pirelab.getDTCComp(interpRB1Net,REG8IN,Gain7CAST);
    pirelab.getBitShiftComp(interpRB1Net,Gain7CAST,Gain7Out,'sll',2);
    pirelab.getGainComp(interpRB1Net,REG9IN,Gain8Out,fi(-1,1,2,0),1,1);
    pirelab.getGainComp(interpRB1Net,REG10IN,Gain9Out,fi(-1,1,2,0),1,1);
    pirelab.getGainComp(interpRB1Net,REG12IN,Gain10Out,fi(-1,1,2,0),1,1);
    pirelab.getDTCComp(interpRB1Net,REG14IN,Gain11CAST);
    pirelab.getBitShiftComp(interpRB1Net,Gain11CAST,Gain11Out,'srl',1);


    ADD1=interpRB1Net.addSignal2('Type',addT1,'Name','ADD1');
    ADD2=interpRB1Net.addSignal2('Type',addT2,'Name','ADD2');
    ADD3=interpRB1Net.addSignal2('Type',addT3,'Name','ADD3');
    ADD4=interpRB1Net.addSignal2('Type',addT4,'Name','ADD4');
    ADD1D=interpRB1Net.addSignal2('Type',addT1,'Name','ADD1');
    ADD2D=interpRB1Net.addSignal2('Type',addT2,'Name','ADD2');
    ADD3D=interpRB1Net.addSignal2('Type',addT3,'Name','ADD3');
    ADD4D=interpRB1Net.addSignal2('Type',addT4,'Name','ADD4');
    ADD5=interpRB1Net.addSignal2('Type',addT2,'Name','ADD5');
    ADD5D=interpRB1Net.addSignal2('Type',addT2,'Name','ADD5D');
    ADD6=interpRB1Net.addSignal2('Type',addT5,'Name','ADD6');
    ADD7=interpRB1Net.addSignal2('Type',addT6,'Name','ADD7');
    ADD8=interpRB1Net.addSignal2('Type',addT1,'Name','ADD8');
    ADD6D=interpRB1Net.addSignal2('Type',addT5,'Name','ADD6D');
    ADD7D=interpRB1Net.addSignal2('Type',addT6,'Name','ADD7D');
    ADD8D=interpRB1Net.addSignal2('Type',addT1,'Name','ADD8D');
    ADD9=interpRB1Net.addSignal2('Type',addT7,'Name','ADD9');
    ADD10=interpRB1Net.addSignal2('Type',addT8,'Name','ADD10');
    ADD11=interpRB1Net.addSignal2('Type',addT9,'Name','ADD11');



    pirelab.getAddComp(interpRB1Net,[Gain1Out,Gain2Out],ADD1,'Floor','Wrap');
    pirelab.getAddComp(interpRB1Net,[Gain3Out,Gain4Out],ADD2,'Floor','Wrap');
    pirelab.getAddComp(interpRB1Net,[Gain5Out,Gain6Out],ADD3,'Floor','Wrap');
    pirelab.getAddComp(interpRB1Net,[Gain7Out,Gain8Out],ADD4,'Floor','Wrap');
    pirelab.getAddComp(interpRB1Net,[Gain9Out,Gain10Out],ADD5,'Floor','Wrap');

    pirelab.getUnitDelayComp(interpRB1Net,ADD1,ADD1D);
    pirelab.getUnitDelayComp(interpRB1Net,ADD2,ADD2D);
    pirelab.getUnitDelayComp(interpRB1Net,ADD3,ADD3D);
    pirelab.getUnitDelayComp(interpRB1Net,ADD4,ADD4D);
    pirelab.getUnitDelayComp(interpRB1Net,ADD5,ADD5D);
    pirelab.getUnitDelayComp(interpRB1Net,Gain11Out,Gain11OutD);


    pirelab.getAddComp(interpRB1Net,[ADD1D,ADD2D],ADD6,'Floor','Wrap');
    pirelab.getAddComp(interpRB1Net,[ADD3D,ADD4D],ADD7,'Floor','Wrap');
    pirelab.getAddComp(interpRB1Net,[ADD5D,Gain11OutD],ADD8,'Floor','Wrap');


    pirelab.getUnitDelayComp(interpRB1Net,ADD6,ADD6D);
    pirelab.getUnitDelayComp(interpRB1Net,ADD7,ADD7D);
    pirelab.getUnitDelayComp(interpRB1Net,ADD8,ADD8D);



    pirelab.getAddComp(interpRB1Net,[ADD6D,ADD7D],ADD9,'Floor','Wrap');



    pirelab.getAddComp(interpRB1Net,[ADD9,ADD8D],ADD10,'Floor','Wrap');



    pirelab.getDTCComp(interpRB1Net,ADD10,ADD11,'Nearest','Saturate');
    pirelab.getBitShiftComp(interpRB1Net,ADD11,Gain12Out,'srl',3);


    pirelab.getUnitDelayComp(interpRB1Net,Gain12Out,Gain12OutD);

    pirelab.getDTCComp(interpRB1Net,Gain12OutD,outSignal(1),'Nearest','Saturate');







