function interpRB3Net=elabRB3(~,coreNet,blockInfo,sigInfo,dataRate)%#ok<INUSL>

    inType=sigInfo.inType.BaseType;
    inputWL=sigInfo.inputWL;
    inputFL=sigInfo.inputFL;
    twosCompT=pir_sfixpt_t(inputWL+1,-inputFL);%#ok<NASGU>
    shiftTwoT=pir_ufixpt_t(inputWL+2,-inputFL);%#ok<NASGU>
    shiftOneT=pir_ufixpt_t(inputWL+1,-inputFL);
    shiftOneRT=pir_ufixpt_t(inputWL+1,-inputFL-1);%#ok<NASGU>
    constantGainT=pir_ufixpt_t(inputWL+3,-inputFL);
    negGainT=pir_sfixpt_t(inputWL+3,-(inputFL+1));
    addT1=pir_sfixpt_t(inputWL+4,-(inputFL+1));
    addT2=pir_sfixpt_t(inputWL+5,-(inputFL+1));
    addT3=pir_ufixpt_t(inputWL+2,-inputFL);
    addT4=pir_sfixpt_t(inputWL+5,-(inputFL+1));
    addT5=pir_sfixpt_t(inputWL+6,-(inputFL+1));
    addT6=pir_sfixpt_t(inputWL+7,-(inputFL+1));
    addT7=pir_sfixpt_t(inputWL+8,-(inputFL+1));
    addT8=pir_ufixpt_t(inputWL+11,-(inputFL+4));
    inPortNames={'REG2IN','REG3IN','REG5IN','DATA3IN','REG7IN'...
    ,'REG9IN','REG10IN','REG12IN','REG14IN'};
    inPortTypes=[inType,inType,inType,inType,inType,inType,inType,inType,inType];
    inPortRates=[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate];

    outPortNames={'RB'};
    outPortTypes=[inType];%#ok<NBRAK>

    interpRB3Net=pirelab.createNewNetwork(...
    'Network',coreNet,...
    'Name','interpRB3',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes);
    inSignals=interpRB3Net.PirInputSignals;
    REG2IN=inSignals(1);
    REG3IN=inSignals(2);
    REG5IN=inSignals(3);
    DATA3IN=inSignals(4);
    REG7IN=inSignals(5);
    REG9IN=inSignals(6);
    REG10IN=inSignals(7);
    REG12IN=inSignals(8);
    REG14IN=inSignals(9);
    outSignal=interpRB3Net.PirOutputSignals;
    Gain1Out=interpRB3Net.addSignal2('Type',negGainT,'Name','GAIN1');
    Gain2CAST=interpRB3Net.addSignal2('Type',shiftOneT,'Name','GAIN2CAST');
    Gain2Out=interpRB3Net.addSignal2('Type',shiftOneT,'Name','GAIN2');
    Gain3CAST=interpRB3Net.addSignal2('Type',shiftOneT,'Name','GAIN3CAST');
    Gain3Out=interpRB3Net.addSignal2('Type',shiftOneT,'Name','GAIN3');
    Gain4Out=interpRB3Net.addSignal2('Type',negGainT,'Name','GAIN4');
    Gain5Out=interpRB3Net.addSignal2('Type',constantGainT,'Name','GAIN5');
    Gain6Out=interpRB3Net.addSignal2('Type',negGainT,'Name','GAIN6');
    Gain7CAST=interpRB3Net.addSignal2('Type',shiftOneT,'Name','GAIN7CAST');
    Gain7Out=interpRB3Net.addSignal2('Type',shiftOneT,'Name','GAIN7');
    Gain8CAST=interpRB3Net.addSignal2('Type',shiftOneT,'Name','GAIN8CAST');
    Gain8Out=interpRB3Net.addSignal2('Type',shiftOneT,'Name','GAIN8');
    Gain9Out=interpRB3Net.addSignal2('Type',negGainT,'Name','GAIN9');
    Gain9OutD=interpRB3Net.addSignal2('Type',negGainT,'Name','GAIN9');
    Gain10Out=interpRB3Net.addSignal2('Type',addT8,'Name','GAIN10');
    Gain10OutD=interpRB3Net.addSignal2('Type',addT8,'Name','GAIN10D');



    pirelab.getGainComp(interpRB3Net,REG2IN,Gain1Out,fi(-1.5,1,3,1),1,1);

    pirelab.getDTCComp(interpRB3Net,REG3IN,Gain2CAST);
    pirelab.getBitShiftComp(interpRB3Net,Gain2CAST,Gain2Out,'sll',1);
    pirelab.getDTCComp(interpRB3Net,REG5IN,Gain3CAST);
    pirelab.getBitShiftComp(interpRB3Net,Gain3CAST,Gain3Out,'sll',1);
    pirelab.getGainComp(interpRB3Net,DATA3IN,Gain4Out,fi(-1.5,1,3,1),1,1);
    pirelab.getGainComp(interpRB3Net,REG7IN,Gain5Out,fi(6,0,3,0),1,1);
    pirelab.getGainComp(interpRB3Net,REG9IN,Gain6Out,fi(-1.5,1,3,1),1,1);
    pirelab.getDTCComp(interpRB3Net,REG10IN,Gain7CAST);
    pirelab.getBitShiftComp(interpRB3Net,Gain7CAST,Gain7Out,'sll',1);
    pirelab.getDTCComp(interpRB3Net,REG12IN,Gain8CAST);
    pirelab.getBitShiftComp(interpRB3Net,Gain8CAST,Gain8Out,'sll',1);
    pirelab.getGainComp(interpRB3Net,REG14IN,Gain9Out,fi(-1.5,1,3,1),1,1);



    ADD1=interpRB3Net.addSignal2('Type',addT1,'Name','ADD1');
    ADD2=interpRB3Net.addSignal2('Type',addT1,'Name','ADD2');
    ADD3=interpRB3Net.addSignal2('Type',addT2,'Name','ADD3');
    ADD4=interpRB3Net.addSignal2('Type',addT3,'Name','ADD4');
    ADD1D=interpRB3Net.addSignal2('Type',addT1,'Name','ADD1');
    ADD2D=interpRB3Net.addSignal2('Type',addT1,'Name','ADD2');
    ADD3D=interpRB3Net.addSignal2('Type',addT2,'Name','ADD3');
    ADD4D=interpRB3Net.addSignal2('Type',addT3,'Name','ADD4');
    ADD5=interpRB3Net.addSignal2('Type',addT4,'Name','ADD5');
    ADD6=interpRB3Net.addSignal2('Type',addT5,'Name','ADD6');
    ADD5D=interpRB3Net.addSignal2('Type',addT4,'Name','ADD5');
    ADD6D=interpRB3Net.addSignal2('Type',addT5,'Name','ADD6');
    ADD7=interpRB3Net.addSignal2('Type',addT6,'Name','ADD7');
    ADD8=interpRB3Net.addSignal2('Type',addT7,'Name','ADD8');
    ADD9=interpRB3Net.addSignal2('Type',addT8,'Name','ADD9');


    pirelab.getAddComp(interpRB3Net,[Gain1Out,Gain2Out],ADD1,'Floor','Wrap');
    pirelab.getAddComp(interpRB3Net,[Gain3Out,Gain4Out],ADD2,'Floor','Wrap');
    pirelab.getAddComp(interpRB3Net,[Gain5Out,Gain6Out],ADD3,'Floor','Wrap');
    pirelab.getAddComp(interpRB3Net,[Gain7Out,Gain8Out],ADD4,'Floor','Wrap');



    pirelab.getUnitDelayComp(interpRB3Net,ADD1,ADD1D);
    pirelab.getUnitDelayComp(interpRB3Net,ADD2,ADD2D);
    pirelab.getUnitDelayComp(interpRB3Net,ADD3,ADD3D);
    pirelab.getUnitDelayComp(interpRB3Net,ADD4,ADD4D);


    pirelab.getAddComp(interpRB3Net,[ADD1D,ADD2D],ADD5,'Floor','Wrap');
    pirelab.getAddComp(interpRB3Net,[ADD3D,ADD4D],ADD6,'Floor','Wrap');



    pirelab.getIntDelayComp(interpRB3Net,Gain9Out,Gain9OutD,2);
    pirelab.getUnitDelayComp(interpRB3Net,ADD5,ADD5D);
    pirelab.getUnitDelayComp(interpRB3Net,ADD6,ADD6D);


    pirelab.getAddComp(interpRB3Net,[ADD5D,ADD6D],ADD7,'Floor','Wrap');
    pirelab.getAddComp(interpRB3Net,[ADD7,Gain9OutD],ADD8,'Floor','Wrap');



    pirelab.getDTCComp(interpRB3Net,ADD8,ADD9,'Nearest','Saturate');
    pirelab.getBitShiftComp(interpRB3Net,ADD9,Gain10Out,'srl',3);


    pirelab.getUnitDelayComp(interpRB3Net,Gain10Out,Gain10OutD);

    pirelab.getDTCComp(interpRB3Net,Gain10OutD,outSignal(1),'Nearest','Saturate');





























