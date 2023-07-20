function lineAverageNet=elaborateLineSpaceAverager(~,topNet,blockInfo,sigInfo,dataRate)








    booleanT=sigInfo.booleanT;
    countT=sigInfo.aveType;
    STAGE1T=pir_ufixpt_t(countT.WordLength+1,0);
    STAGE2T=pir_ufixpt_t(countT.WordLength+2,0);


    inPortNames={'InBetween','InLine'};
    inPortTypes=[booleanT,booleanT];
    inPortRates=[dataRate,dataRate];
    outPortNames={'LineSpaceAverage'};
    outPortTypes=[countT];

    lineAverageNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','LineSpaceAverager',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes...
    );

    inSignals=lineAverageNet.PirInputSignals;
    InBetween=inSignals(1);
    InLine=inSignals(2);


    outSignals=lineAverageNet.PirOutputSignals;
    LineSpaceAverage=outSignals(1);

    LineSpaceCounter=lineAverageNet.addSignal2('Type',countT,'Name','LineSpaceCounter');

    pirelab.getCounterComp(lineAverageNet,[InLine,InBetween],LineSpaceCounter,'Free running',...
    0,1,[],true,false,true,false,'Read Count',0);


    LineSpaceCounterD1=lineAverageNet.addSignal2('Type',countT,'Name','LineSpaceCounterD1');
    LineSpaceCounterD2=lineAverageNet.addSignal2('Type',countT,'Name','LineSpaceCounterD2');
    LineSpaceCounterD3=lineAverageNet.addSignal2('Type',countT,'Name','LineSpaceCounterD3');
    LineSpaceCounterD4=lineAverageNet.addSignal2('Type',countT,'Name','LineSpaceCounterD4');


    pirelab.getUnitDelayEnabledComp(lineAverageNet,LineSpaceCounter,LineSpaceCounterD1,InLine);
    pirelab.getUnitDelayEnabledComp(lineAverageNet,LineSpaceCounterD1,LineSpaceCounterD2,InLine);
    pirelab.getUnitDelayEnabledComp(lineAverageNet,LineSpaceCounterD2,LineSpaceCounterD3,InLine);
    pirelab.getUnitDelayEnabledComp(lineAverageNet,LineSpaceCounterD3,LineSpaceCounterD4,InLine);

    AddTerm1=lineAverageNet.addSignal2('Type',STAGE1T,'Name','AddTerm1');
    AddTerm2=lineAverageNet.addSignal2('Type',STAGE1T,'Name','AddTerm2');
    AddTerm3=lineAverageNet.addSignal2('Type',STAGE2T,'Name','AddTerm3');
    GainOut=lineAverageNet.addSignal2('Type',STAGE2T,'Name','AddTerm3');

    AddTerm1REG=lineAverageNet.addSignal2('Type',STAGE1T,'Name','AddTerm1REG');
    AddTerm2REG=lineAverageNet.addSignal2('Type',STAGE1T,'Name','AddTerm2REG');
    AddTerm3REG=lineAverageNet.addSignal2('Type',STAGE2T,'Name','AddTerm3REG');
    GainOutREG=lineAverageNet.addSignal2('Type',STAGE2T,'Name','AddTerm3REG');





    pirelab.getAddComp(lineAverageNet,[LineSpaceCounterD1,LineSpaceCounterD2],AddTerm1,'Floor',...
    'Wrap');

    pirelab.getUnitDelayComp(lineAverageNet,AddTerm1,AddTerm1REG);

    pirelab.getAddComp(lineAverageNet,[LineSpaceCounterD3,LineSpaceCounterD4],AddTerm2,'Floor',...
    'Wrap');

    pirelab.getUnitDelayComp(lineAverageNet,AddTerm2,AddTerm2REG);


    pirelab.getAddComp(lineAverageNet,[AddTerm1REG,AddTerm2REG],AddTerm3,'Floor',...
    'Wrap');

    pirelab.getUnitDelayComp(lineAverageNet,AddTerm3,AddTerm3REG);




    pirelab.getBitShiftComp(lineAverageNet,AddTerm3REG,GainOut,'srl',2);

    pirelab.getUnitDelayComp(lineAverageNet,GainOut,GainOutREG);

    pirelab.getDTCComp(lineAverageNet,GainOutREG,LineSpaceAverage,'Floor','Wrap');
















