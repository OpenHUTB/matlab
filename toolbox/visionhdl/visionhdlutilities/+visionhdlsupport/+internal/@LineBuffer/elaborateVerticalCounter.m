function verCountNet=elaborateVerticalCounter(~,topNet,blockInfo,sigInfo,dataRate,M)%#ok<INUSD>






    inType=sigInfo.inType;%#ok<NASGU>
    booleanT=sigInfo.booleanT;
    lineStartT=sigInfo.lineStartT;%#ok<NASGU>
    countT=sigInfo.countT;
    dataVType=sigInfo.dataVType;%#ok<NASGU>



    inPortNames={'frameEnd','unloading','running','lineStart'};
    inPortTypes=[booleanT,booleanT,booleanT,booleanT];
    inPortRates=[dataRate,dataRate,dataRate,dataRate];
    outPortNames={'VCount'};
    outPortTypes=countT;



    verCountNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','Vertical Padding Counter',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes...
    );

    inSignals=verCountNet.PirInputSignals;
    frameEnd=inSignals(1);
    unloading=inSignals(2);
    running=inSignals(3);
    lineStart=inSignals(4);

    outSignals=verCountNet.PirOutputSignals;
    VCount=outSignals(1);

    runningStart=verCountNet.addSignal2('Type',booleanT,'Name','runningStart');
    unloadingStart=verCountNet.addSignal2('Type',booleanT,'Name','unloadingStart');

    pirelab.getLogicComp(verCountNet,[unloading,lineStart],unloadingStart,'and');
    pirelab.getLogicComp(verCountNet,[running,lineStart],runningStart,'and');

    verticalPadCount=verCountNet.addSignal2('Type',countT,'Name','VerticalPadCounter');
    prePad=verCountNet.addSignal2('Type',booleanT,'Name','prePad');

    if mod(blockInfo.KernelHeight,2)==0&&blockInfo.BiasUp
        pirelab.getCompareToValueComp(verCountNet,verticalPadCount,prePad,'<',floor(blockInfo.KernelHeight/2)-1);
    elseif strcmpi(blockInfo.PaddingMethod,'Reflection')&&blockInfo.KernelTwo
        pirelab.getCompareToValueComp(verCountNet,verticalPadCount,prePad,'<',floor(blockInfo.KernelHeight/2)-1);
    else
        pirelab.getCompareToValueComp(verCountNet,verticalPadCount,prePad,'<',floor(blockInfo.KernelHeight/2));
    end

    runCountEn=verCountNet.addSignal2('Type',booleanT,'Name','runCountEn');
    pirelab.getLogicComp(verCountNet,[runningStart,prePad],runCountEn,'and');

    verCountEn=verCountNet.addSignal2('Type',booleanT,'Name','verCountEn');

    pirelab.getLogicComp(verCountNet,[runCountEn,unloadingStart],verCountEn,'or');

    pirelab.getCounterComp(verCountNet,[frameEnd,verCountEn],verticalPadCount,'Free running',...
    0,1,[],true,false,true,false,'Vertical Counter',0);

    pirelab.getWireComp(verCountNet,verticalPadCount,VCount);

