function RunMaxNet=elaborateRunningMax(this,topNet,blockInfo,sigInfo,inRate)








    inType=sigInfo.inType;
    boolType=pir_boolean_t();




    inPortNames={'ModK','dataIn','hStart'};
    inPortTypes=[boolType,inType,boolType];
    inPortRates=[inRate,inRate,inRate];
    outPortNames={'MaxVal'};
    outPortTypes=inType;


    RunMaxNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','RunningMax',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes);

    RunMaxNet.addComment('Running Max');



    inSignals=RunMaxNet.PirInputSignals;
    ModK=inSignals(1);
    dataIn=inSignals(2);
    hStartIn=inSignals(3);



    outSignals=RunMaxNet.PirOutputSignals;
    MaxVal=outSignals(1);


    dataREGIn=RunMaxNet.addSignal2('Type',inType,'Name','DataREGIn');
    MaxOut=RunMaxNet.addSignal2('Type',inType,'Name','MaxOut');
    MaxS=RunMaxNet.addSignal2('Type',inType,'Name','MaxS');

    ModKReg=RunMaxNet.addSignal2('Type',boolType,'Name','ModKReg');


    pirelab.getUnitDelayComp(RunMaxNet,ModK,ModKReg);
    pirelab.getMinMaxComp(RunMaxNet,[dataIn,dataREGIn],MaxOut,'MaxComp','max');
    pirelab.getUnitDelayResettableComp(RunMaxNet,MaxS,dataREGIn,hStartIn,'RMReg');
    pirelab.getSwitchComp(RunMaxNet,[MaxOut,dataIn],MaxS,ModKReg);

    pirelab.getWireComp(RunMaxNet,dataREGIn,MaxVal);












