function stateFlagNet=elaborateStateFlagGen(~,topNet,blockInfo,sigInfo,dataRate)









    booleanT=sigInfo.booleanT;

    inPortNames={'hStartIn','hEndIn',' vStartIn','vEndIn','validIn','dumpControl','preProcess'};
    inPortTypes=[booleanT,booleanT,booleanT,booleanT,booleanT,booleanT,booleanT];
    inPortRates=[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate];
    outPortNames={'PrePadFlag','OnLineFlag','PostPadFlag','DumpingFlag','BlankingFlag','hStartOut','hEndOut','vStartOut','vEndOut','validOut'};
    outPortTypes=[booleanT,booleanT,booleanT,booleanT,booleanT,booleanT,booleanT,booleanT,booleanT,booleanT];

    stateFlagNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','LineInfoStore',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes...
    );

    inSignals=stateFlagNet.PirInputSignals;
    hStartIn=inSignals(1);
    hEndIn=inSignals(2);
    vStartIn=inSignals(3);
    vEndIn=inSignals(4);
    validIn=inSignals(5);
    dumpControl=inSignals(6);
    preProcess=inSignals(7);

    outSignals=stateFlagNet.PirOutputSignals;
    PrePadFlag=outSignals(1);
    OnLineFlag=outSignals(2);
    PostPadFlag=outSignals(3);
    DumpingFlag=outSignals(4);
    BlankingFlag=outSignals(5);
    hStartOut=outSignals(6);
    hEndOut=outSignals(7);
    vStartOut=outSignals(8);
    vEndOut=outSignals(9);
    validOut=outSignals(10);


    twoPixelsEdgeCase=(blockInfo.NumPixels==2&&mod(floor((blockInfo.KernelWidth-1)/2),2)==1&&blockInfo.KernelWidth>4);

    validTemp1=stateFlagNet.addSignal2('Type',booleanT,'Name','validTemp1');
    validTemp2=stateFlagNet.addSignal2('Type',booleanT,'Name','validTemp2');

    pirelab.getLogicComp(stateFlagNet,[validIn,dumpControl],validTemp1,'or');
    pirelab.getLogicComp(stateFlagNet,[hEndIn,validTemp1],validTemp2,'or');


    hStartFirstTap=stateFlagNet.addSignal2('Type',booleanT,'Name','hStartFirstTap');
    hStartFinalTap=stateFlagNet.addSignal2('Type',booleanT,'Name','hStartFinalTap');

    if strcmpi(blockInfo.PaddingMethod,'Symmetric')&&blockInfo.NumPixels==1
        pirelab.getIntDelayEnabledComp(stateFlagNet,hStartIn,hStartFirstTap,validTemp2,ceil(blockInfo.KernelWidth/2));
    elseif strcmpi(blockInfo.PaddingMethod,'Reflection')||(strcmpi(blockInfo.PaddingMethod,'Symmetric')&&twoPixelsEdgeCase)
        if blockInfo.NumPixels==1
            pirelab.getIntDelayEnabledComp(stateFlagNet,hStartIn,hStartFirstTap,validTemp2,ceil(blockInfo.KernelWidth/2)+1);
        else
            pirelab.getIntDelayEnabledComp(stateFlagNet,hStartIn,hStartFirstTap,validTemp2,2);
        end
    else
        pirelab.getUnitDelayEnabledComp(stateFlagNet,hStartIn,hStartFirstTap,validTemp2);
    end

    pirelab.getWireComp(stateFlagNet,hStartFirstTap,PrePadFlag);

    if strcmpi(blockInfo.PaddingMethod,'Reflection')&&blockInfo.NumPixels>1
        if blockInfo.KernelWidth<4
            pirelab.getIntDelayEnabledComp(stateFlagNet,hStartFirstTap,hStartFinalTap,validTemp2,floor(blockInfo.KernelWidth/2));
        elseif mod(blockInfo.KernelWidth,2)==0
            pirelab.getIntDelayEnabledComp(stateFlagNet,hStartFirstTap,hStartFinalTap,validTemp2,floor(blockInfo.KernelWidth/2)-1);
        else
            pirelab.getIntDelayEnabledComp(stateFlagNet,hStartFirstTap,hStartFinalTap,validTemp2,floor(blockInfo.KernelWidth/2));
        end
    elseif strcmpi(blockInfo.PaddingMethod,'Symmetric')&&twoPixelsEdgeCase
        pirelab.getIntDelayEnabledComp(stateFlagNet,hStartFirstTap,hStartFinalTap,validTemp2,ceil(blockInfo.KernelWidth/2)-1);
    elseif mod(blockInfo.KernelWidth,2)==0&&blockInfo.BiasUp
        pirelab.getIntDelayEnabledComp(stateFlagNet,hStartFirstTap,hStartFinalTap,validTemp2,floor(blockInfo.KernelWidth/2)-1);
    else
        pirelab.getIntDelayEnabledComp(stateFlagNet,hStartFirstTap,hStartFinalTap,validTemp2,floor(blockInfo.KernelWidth/2));
    end

    pirelab.getWireComp(stateFlagNet,hStartFinalTap,OnLineFlag);
    pirelab.getWireComp(stateFlagNet,hStartFinalTap,hStartOut);


    hEndFirstTap=stateFlagNet.addSignal2('Type',booleanT,'Name','hEndFirstTap');
    hEndSecondTap=stateFlagNet.addSignal2('Type',booleanT,'Name','hEndSecondTap');
    hEndFinalTap=stateFlagNet.addSignal2('Type',booleanT,'Name','hEndFinalTap');

    pirelab.getUnitDelayEnabledComp(stateFlagNet,hEndIn,hEndFirstTap,validTemp2);

    pirelab.getWireComp(stateFlagNet,hEndFirstTap,DumpingFlag);

    if strcmpi(blockInfo.PaddingMethod,'Symmetric')&&blockInfo.NumPixels==1
        if mod(blockInfo.KernelWidth,2)==0
            pirelab.getIntDelayEnabledComp(stateFlagNet,hEndFirstTap,hEndSecondTap,validTemp2,blockInfo.KernelWidth-3);
        else
            pirelab.getIntDelayEnabledComp(stateFlagNet,hEndFirstTap,hEndSecondTap,validTemp2,blockInfo.KernelWidth-2);
        end
    elseif strcmpi(blockInfo.PaddingMethod,'Reflection')||(strcmpi(blockInfo.PaddingMethod,'Symmetric')&&twoPixelsEdgeCase)
        if blockInfo.NumPixels==1
            if mod(blockInfo.KernelWidth,2)==0
                pirelab.getIntDelayEnabledComp(stateFlagNet,hEndFirstTap,hEndSecondTap,validTemp2,blockInfo.KernelWidth-2);
            else
                pirelab.getIntDelayEnabledComp(stateFlagNet,hEndFirstTap,hEndSecondTap,validTemp2,blockInfo.KernelWidth-1);
            end
        else
            if mod(blockInfo.KernelWidth,2)==0
                pirelab.getIntDelayEnabledComp(stateFlagNet,hEndFirstTap,hEndSecondTap,validTemp2,(floor(blockInfo.KernelWidth/2))-1);
            else
                pirelab.getIntDelayEnabledComp(stateFlagNet,hEndFirstTap,hEndSecondTap,validTemp2,(floor(blockInfo.KernelWidth/2)));
            end
        end
    elseif blockInfo.KernelWidth<=4&&blockInfo.BiasUp&&mod(blockInfo.KernelWidth,2)==0
        pirelab.getUnitDelayComp(stateFlagNet,hEndFirstTap,hEndSecondTap);
    elseif mod(blockInfo.KernelWidth,2)==0&&blockInfo.BiasUp
        pirelab.getIntDelayEnabledComp(stateFlagNet,hEndFirstTap,hEndSecondTap,validTemp2,(floor(blockInfo.KernelWidth/2))-2);
    elseif blockInfo.KernelWidth==3
        pirelab.getUnitDelayComp(stateFlagNet,hEndFirstTap,hEndSecondTap,validTemp2);
    else
        pirelab.getIntDelayEnabledComp(stateFlagNet,hEndFirstTap,hEndSecondTap,validTemp2,(floor(blockInfo.KernelWidth/2))-1);
    end

    pirelab.getWireComp(stateFlagNet,hEndSecondTap,PostPadFlag);
    pirelab.getWireComp(stateFlagNet,hEndSecondTap,hEndOut);

    if strcmpi(blockInfo.PaddingMethod,'Symmetric')&&blockInfo.NumPixels==1
        if mod(blockInfo.KernelWidth,2)==0
            pirelab.getIntDelayEnabledComp(stateFlagNet,hEndSecondTap,hEndFinalTap,validTemp2,ceil(blockInfo.KernelWidth/2)+1);
        else
            pirelab.getIntDelayEnabledComp(stateFlagNet,hEndSecondTap,hEndFinalTap,validTemp2,ceil(blockInfo.KernelWidth/2));
        end
    elseif strcmpi(blockInfo.PaddingMethod,'Reflection')||(strcmpi(blockInfo.PaddingMethod,'Symmetric')&&twoPixelsEdgeCase)
        if blockInfo.NumPixels==1
            if mod(blockInfo.KernelWidth,2)==0
                pirelab.getIntDelayEnabledComp(stateFlagNet,hEndSecondTap,hEndFinalTap,validTemp2,ceil(blockInfo.KernelWidth/2)+1);
            else
                pirelab.getIntDelayEnabledComp(stateFlagNet,hEndSecondTap,hEndFinalTap,validTemp2,ceil(blockInfo.KernelWidth/2));
            end
        else
            if mod(blockInfo.KernelWidth,2)~=0
                pirelab.getIntDelayEnabledComp(stateFlagNet,hEndSecondTap,hEndFinalTap,validTemp2,ceil(blockInfo.KernelWidth/2)+1);
            else
                pirelab.getIntDelayEnabledComp(stateFlagNet,hEndSecondTap,hEndFinalTap,validTemp2,ceil(blockInfo.KernelWidth/2));
            end
        end
    elseif mod(blockInfo.KernelWidth,2)==0&&blockInfo.BiasUp
        pirelab.getIntDelayEnabledComp(stateFlagNet,hEndSecondTap,hEndFinalTap,validTemp2,ceil(blockInfo.KernelWidth/2)+1);
    else
        pirelab.getIntDelayEnabledComp(stateFlagNet,hEndSecondTap,hEndFinalTap,validTemp2,ceil(blockInfo.KernelWidth/2));
    end

    pirelab.getWireComp(stateFlagNet,hEndFinalTap,BlankingFlag);



    if strcmpi(blockInfo.PaddingMethod,'Reflection')||(strcmpi(blockInfo.PaddingMethod,'Symmetric')&&twoPixelsEdgeCase)
        if blockInfo.NumPixels==1||(blockInfo.NumPixels>1&&mod(blockInfo.KernelWidth,2)==0&&blockInfo.KernelWidth>=4)
            pirelab.getIntDelayEnabledComp(stateFlagNet,vStartIn,vStartOut,validTemp2,ceil(blockInfo.KernelWidth/2)+1);
        else
            pirelab.getIntDelayEnabledComp(stateFlagNet,vStartIn,vStartOut,validTemp2,ceil(blockInfo.KernelWidth/2)+2);
        end
    else
        pirelab.getIntDelayEnabledComp(stateFlagNet,vStartIn,vStartOut,validTemp2,ceil(blockInfo.KernelWidth/2));
    end


    if strcmpi(blockInfo.PaddingMethod,'Symmetric')&&blockInfo.NumPixels==1
        if mod(blockInfo.KernelWidth,2)==0
            pirelab.getIntDelayEnabledComp(stateFlagNet,vEndIn,vEndOut,validTemp2,(blockInfo.KernelWidth)-2);
        else
            pirelab.getIntDelayEnabledComp(stateFlagNet,vEndIn,vEndOut,validTemp2,(blockInfo.KernelWidth)-1);
        end
    elseif strcmpi(blockInfo.PaddingMethod,'Reflection')||(strcmpi(blockInfo.PaddingMethod,'Symmetric')&&twoPixelsEdgeCase)
        if blockInfo.NumPixels==1
            if mod(blockInfo.KernelWidth,2)==0
                pirelab.getIntDelayEnabledComp(stateFlagNet,vEndIn,vEndOut,validTemp2,(blockInfo.KernelWidth)-1);
            else
                pirelab.getIntDelayEnabledComp(stateFlagNet,vEndIn,vEndOut,validTemp2,(blockInfo.KernelWidth));
            end
        else
            if mod(blockInfo.KernelWidth,2)==0
                pirelab.getIntDelayEnabledComp(stateFlagNet,vEndIn,vEndOut,validTemp2,floor(blockInfo.KernelWidth/2));
            else
                pirelab.getIntDelayEnabledComp(stateFlagNet,vEndIn,vEndOut,validTemp2,floor(blockInfo.KernelWidth/2)+1);
            end
        end
    elseif(blockInfo.KernelWidth<=4&&blockInfo.BiasUp)||blockInfo.KernelWidth==3
        pirelab.getIntDelayEnabledComp(stateFlagNet,vEndIn,vEndOut,validTemp2,2);
    elseif mod(blockInfo.KernelWidth,2)==0&&blockInfo.BiasUp
        pirelab.getIntDelayEnabledComp(stateFlagNet,vEndIn,vEndOut,validTemp2,floor(blockInfo.KernelWidth/2)-1);
    else
        pirelab.getIntDelayEnabledComp(stateFlagNet,vEndIn,vEndOut,validTemp2,floor(blockInfo.KernelWidth/2));
    end

    validFirstTap=stateFlagNet.addSignal2('Type',booleanT,'Name','validFirstTap');
    validFinalTap=stateFlagNet.addSignal2('Type',booleanT,'Name','validFinalTap');
    validGate1=stateFlagNet.addSignal2('Type',booleanT,'Name','validGate1');
    validGate2=stateFlagNet.addSignal2('Type',booleanT,'Name','validGate2');
    validGate3=stateFlagNet.addSignal2('Type',booleanT,'Name','validGate3');
    validGate4=stateFlagNet.addSignal2('Type',booleanT,'Name','validGate4');
    validGate5=stateFlagNet.addSignal2('Type',booleanT,'Name','validGate5');
    notPreProcess=stateFlagNet.addSignal2('Type',booleanT,'Name','notPreProcess');

    if strcmpi(blockInfo.PaddingMethod,'Symmetric')&&blockInfo.NumPixels==1
        pirelab.getIntDelayEnabledComp(stateFlagNet,validIn,validFirstTap,validTemp2,(blockInfo.KernelWidth));
    elseif strcmpi(blockInfo.PaddingMethod,'Reflection')||(strcmpi(blockInfo.PaddingMethod,'Symmetric')&&twoPixelsEdgeCase)
        if blockInfo.NumPixels==1
            pirelab.getIntDelayEnabledComp(stateFlagNet,validIn,validFirstTap,validTemp2,(blockInfo.KernelWidth)+1);
        else
            if mod(blockInfo.KernelWidth,2)==0
                pirelab.getIntDelayEnabledComp(stateFlagNet,validIn,validFirstTap,validTemp2,floor(blockInfo.KernelWidth/2));
            else
                pirelab.getIntDelayEnabledComp(stateFlagNet,validIn,validFirstTap,validTemp2,floor(blockInfo.KernelWidth/2)+1);
            end
        end
        pirelab.getIntDelayEnabledComp(stateFlagNet,validFirstTap,validFinalTap,validTemp2,1);
    elseif blockInfo.KernelWidth<=4&&blockInfo.BiasUp&&mod(blockInfo.KernelWidth,2)==0
        pirelab.getIntDelayEnabledComp(stateFlagNet,validIn,validFirstTap,validTemp2,ceil(blockInfo.KernelWidth/2));
    elseif blockInfo.KernelWidth==3
        pirelab.getIntDelayEnabledComp(stateFlagNet,validIn,validFirstTap,validTemp2,2);
    elseif mod(blockInfo.KernelWidth,2)==0&&blockInfo.BiasUp
        pirelab.getIntDelayEnabledComp(stateFlagNet,validIn,validFirstTap,validTemp2,floor(blockInfo.KernelWidth/2)-1);
    else
        pirelab.getIntDelayEnabledComp(stateFlagNet,validIn,validFirstTap,validTemp2,floor(blockInfo.KernelWidth/2));
    end


    pirelab.getLogicComp(stateFlagNet,[hStartFirstTap,validFirstTap],validGate1,'and');
    pirelab.getLogicComp(stateFlagNet,preProcess,notPreProcess,'not');
    pirelab.getLogicComp(stateFlagNet,[validFirstTap,notPreProcess],validGate2,'and');
    pirelab.getLogicComp(stateFlagNet,[validGate1,validGate2],validGate3,'or');
    pirelab.getLogicComp(stateFlagNet,[hStartFinalTap,validGate3],validGate4,'or');
    if strcmpi(blockInfo.PaddingMethod,'Reflection')||(strcmpi(blockInfo.PaddingMethod,'Symmetric')&&twoPixelsEdgeCase)
        pirelab.getLogicComp(stateFlagNet,[validFinalTap,validGate4],validGate5,'or');
        pirelab.getWireComp(stateFlagNet,validGate5,validOut);
    else
        pirelab.getWireComp(stateFlagNet,validGate4,validOut);
    end
