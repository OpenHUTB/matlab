function interpRB2Net=elabRB2(~,coreNet,blockInfo,sigInfo,dataRate)%#ok<INUSL>





    inType=sigInfo.inType.BaseType;
    inputWL=sigInfo.inputWL;
    inputFL=sigInfo.inputFL;
    twosCompT=pir_sfixpt_t(inputWL+1,-inputFL);
    shiftTwoT=pir_ufixpt_t(inputWL+2,-inputFL);
    shiftOneT=pir_ufixpt_t(inputWL+1,-inputFL);%#ok<NASGU>
    shiftOneRT=pir_ufixpt_t(inputWL+1,-inputFL-1);
    constantGainT=pir_ufixpt_t(inputWL+3,-inputFL);
    ADDT1=pir_sfixpt_t(inputWL+2,-inputFL);
    ADDT2=pir_sfixpt_t(inputWL+4,-inputFL);
    ADDT3=pir_sfixpt_t(inputWL+5,-(inputFL+1));
    ADDT4=pir_sfixpt_t(inputWL+3,-(inputFL+1));
    ADDT5=pir_sfixpt_t(inputWL+3,-inputFL);
    ADDT6=pir_sfixpt_t(inputWL+5,-inputFL);
    ADDT7=pir_sfixpt_t(inputWL+6,-(inputFL+1));
    ADDT8=pir_sfixpt_t(inputWL+8,-(inputFL+1));
    ADDT9=pir_sfixpt_t(inputWL+9,-(inputFL+1));
    ADDT10=pir_ufixpt_t(inputWL+12,-(inputFL+4));


    inPortNames={'REG2IN','REG3IN','REG4IN','REG5IN','DATA3IN','REG7IN'...
    ,'REG9IN','REG10IN','REG11IN','REG12IN','REG14IN'};
    inPortTypes=[inType,inType,inType,inType,inType,inType,inType,inType,inType,inType,inType];
    inPortRates=[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate];

    outPortNames={'RB'};
    outPortTypes=[inType];%#ok<NBRAK>

    interpRB2Net=pirelab.createNewNetwork(...
    'Network',coreNet,...
    'Name','interpRB2',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes);

    inSignals=interpRB2Net.PirInputSignals;
    REG2IN=inSignals(1);
    REG3IN=inSignals(2);
    REG4IN=inSignals(3);
    REG5IN=inSignals(4);
    DATA3IN=inSignals(5);
    REG7IN=inSignals(6);
    REG9IN=inSignals(7);
    REG10IN=inSignals(8);
    REG11IN=inSignals(9);
    REG12IN=inSignals(10);
    REG14IN=inSignals(11);


    outSignal=interpRB2Net.PirOutputSignals;


    Gain1Out=interpRB2Net.addSignal2('Type',twosCompT,'Name','GAIN1OUT');
    Gain2Out=interpRB2Net.addSignal2('Type',twosCompT,'Name','GAIN2OUT');
    Gain3CAST=interpRB2Net.addSignal2('Type',shiftTwoT,'Name','Gain3CAST');
    Gain3Out=interpRB2Net.addSignal2('Type',shiftTwoT,'Name','GAIN3OUT');
    Gain4Out=interpRB2Net.addSignal2('Type',twosCompT,'Name','GAIN4OUT');
    Gain5CAST=interpRB2Net.addSignal2('Type',shiftOneRT,'Name','Gain5CAST');
    Gain5Out=interpRB2Net.addSignal2('Type',shiftOneRT,'Name','GAIN5OUT');
    Gain6Out=interpRB2Net.addSignal2('Type',constantGainT,'Name','GAIN6OUT');
    Gain7CAST=interpRB2Net.addSignal2('Type',shiftOneRT,'Name','Gain7CAST');
    Gain7Out=interpRB2Net.addSignal2('Type',shiftOneRT,'Name','GAIN7OUT');
    Gain8Out=interpRB2Net.addSignal2('Type',twosCompT,'Name','GAIN8OUT');
    Gain9CAST=interpRB2Net.addSignal2('Type',shiftTwoT,'Name','Gain9CAST');
    Gain9Out=interpRB2Net.addSignal2('Type',shiftTwoT,'Name','Gain9Out');
    ADD10=interpRB2Net.addSignal2('Type',ADDT9,'Name','ADD10');%#ok<NASGU>
    Gain10Out=interpRB2Net.addSignal2('Type',twosCompT,'Name','GAIN10OUT');
    Gain11Out=interpRB2Net.addSignal2('Type',twosCompT,'Name','GAIN11OUT');
    Gain11OutD=interpRB2Net.addSignal2('Type',twosCompT,'Name','GAIN11OUTD');
    Gain12Out=interpRB2Net.addSignal2('Type',ADDT10,'Name','GAIN12OUT');
    Gain12OutD=interpRB2Net.addSignal2('Type',ADDT10,'Name','GAIN12OUTD');

    pirelab.getGainComp(interpRB2Net,REG2IN,Gain1Out,fi(-1,1,2,0));
    pirelab.getGainComp(interpRB2Net,REG3IN,Gain2Out,fi(-1,1,2,0));
    pirelab.getDTCComp(interpRB2Net,REG4IN,Gain3CAST);
    pirelab.getBitShiftComp(interpRB2Net,Gain3CAST,Gain3Out,'sll',2);
    pirelab.getGainComp(interpRB2Net,REG5IN,Gain4Out,fi(-1,1,2,0));
    pirelab.getDTCComp(interpRB2Net,DATA3IN,Gain5CAST);
    pirelab.getBitShiftComp(interpRB2Net,Gain5CAST,Gain5Out,'srl',1);
    pirelab.getGainComp(interpRB2Net,REG7IN,Gain6Out,fi(5,0,3,0),1,1);
    pirelab.getDTCComp(interpRB2Net,REG9IN,Gain7CAST);
    pirelab.getBitShiftComp(interpRB2Net,Gain7CAST,Gain7Out,'srl',1);
    pirelab.getGainComp(interpRB2Net,REG10IN,Gain8Out,fi(-1,1,2,0));
    pirelab.getDTCComp(interpRB2Net,REG11IN,Gain9CAST);
    pirelab.getBitShiftComp(interpRB2Net,Gain9CAST,Gain9Out,'sll',2);
    pirelab.getGainComp(interpRB2Net,REG12IN,Gain10Out,fi(-1,1,2,0));
    pirelab.getGainComp(interpRB2Net,REG14IN,Gain11Out,fi(-1,1,2,0));


    ADD1=interpRB2Net.addSignal2('Type',ADDT1,'Name','ADD1OUT');
    ADD2=interpRB2Net.addSignal2('Type',ADDT2,'Name','ADD2OUT');
    ADD3=interpRB2Net.addSignal2('Type',ADDT3,'Name','ADD3OUT');
    ADD4=interpRB2Net.addSignal2('Type',ADDT4,'Name','ADD4OUT');
    ADD1D=interpRB2Net.addSignal2('Type',ADDT1,'Name','ADD1');
    ADD2D=interpRB2Net.addSignal2('Type',ADDT2,'Name','ADD2');
    ADD3D=interpRB2Net.addSignal2('Type',ADDT3,'Name','ADD3');
    ADD4D=interpRB2Net.addSignal2('Type',ADDT4,'Name','ADD4');
    ADD5=interpRB2Net.addSignal2('Type',ADDT5,'Name','ADD5OUT');
    ADD5D=interpRB2Net.addSignal2('Type',ADDT5,'Name','ADD5OUTD');
    ADD6=interpRB2Net.addSignal2('Type',ADDT6,'Name','ADD6OUT');
    ADD7=interpRB2Net.addSignal2('Type',ADDT7,'Name','ADD7OUT');
    ADD8=interpRB2Net.addSignal2('Type',ADDT2,'Name','ADD8OUT');
    ADD6D=interpRB2Net.addSignal2('Type',ADDT6,'Name','ADD6OUTD');
    ADD7D=interpRB2Net.addSignal2('Type',ADDT7,'Name','ADD7OUTD');
    ADD8D=interpRB2Net.addSignal2('Type',ADDT2,'Name','ADD8OUTD');
    ADD9=interpRB2Net.addSignal2('Type',ADDT8,'Name','ADD9');
    ADD10=interpRB2Net.addSignal2('Type',ADDT9,'Name','ADD10');
    ADD11=interpRB2Net.addSignal2('Type',ADDT10,'Name','ADD11');


    pirelab.getAddComp(interpRB2Net,[Gain1Out,Gain2Out],ADD1,'Floor','Wrap');
    pirelab.getAddComp(interpRB2Net,[Gain3Out,Gain4Out],ADD2,'Floor','Wrap');
    pirelab.getAddComp(interpRB2Net,[Gain5Out,Gain6Out],ADD3,'Floor','Wrap');
    pirelab.getAddComp(interpRB2Net,[Gain7Out,Gain8Out],ADD4,'Floor','Wrap');
    pirelab.getAddComp(interpRB2Net,[Gain9Out,Gain10Out],ADD5,'Floor','Wrap');



    pirelab.getUnitDelayComp(interpRB2Net,ADD1,ADD1D);
    pirelab.getUnitDelayComp(interpRB2Net,ADD2,ADD2D);
    pirelab.getUnitDelayComp(interpRB2Net,ADD3,ADD3D);
    pirelab.getUnitDelayComp(interpRB2Net,ADD4,ADD4D);
    pirelab.getUnitDelayComp(interpRB2Net,ADD5,ADD5D);

    pirelab.getUnitDelayComp(interpRB2Net,Gain11Out,Gain11OutD);

    pirelab.getAddComp(interpRB2Net,[ADD1D,ADD2D],ADD6,'Floor','Wrap');
    pirelab.getAddComp(interpRB2Net,[ADD3D,ADD4D],ADD7,'Floor','Wrap');
    pirelab.getAddComp(interpRB2Net,[ADD5D,Gain11OutD],ADD8,'Floor','Wrap');




    pirelab.getUnitDelayComp(interpRB2Net,ADD6,ADD6D,'REG6');
    pirelab.getUnitDelayComp(interpRB2Net,ADD7,ADD7D,'REG7');
    pirelab.getUnitDelayComp(interpRB2Net,ADD8,ADD8D,'REG8');



    pirelab.getAddComp(interpRB2Net,[ADD6D,ADD7D],ADD9);


    pirelab.getAddComp(interpRB2Net,[ADD9,ADD8D],ADD10,'Floor','Wrap');




    pirelab.getDTCComp(interpRB2Net,ADD10,ADD11,'Nearest','Saturate');
    pirelab.getBitShiftComp(interpRB2Net,ADD11,Gain12Out,'srl',3);


    pirelab.getUnitDelayComp(interpRB2Net,Gain12Out,Gain12OutD);

    pirelab.getDTCComp(interpRB2Net,Gain12OutD,outSignal(1),'Nearest','Saturate');



