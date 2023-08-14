function PSNet=elaborateMultiPixelProcessMask(~,topNet,blockInfo,sigInfo,dataRate,M)






    booleanT=sigInfo.booleanT;
    countT=sigInfo.loadCountT;



    inPortNames={'processIn','hStart','hEnd'};
    inPortTypes=[booleanT,booleanT,booleanT];
    inPortRates=[dataRate,dataRate,dataRate];
    outPortNames={'processOut'};
    outPortTypes=booleanT;



    PSNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','Multi Pixel Process Mask',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes...
    );

    inSignals=PSNet.PirInputSignals;
    processIn=inSignals(1);
    hStart=inSignals(2);
    hEnd=inSignals(3);


    outSignals=PSNet.PirOutputSignals;
    processOut=outSignals(1);



    evenKernelConstant=double(mod(blockInfo.KernelWidth,2)==0);

    if mod(blockInfo.KernelWidth,2)==0
        if(mod((floor(blockInfo.KernelWidth/2))-1,blockInfo.NumPixels))==0||~blockInfo.BiasUp
            evenBiasConstant=1;
        else
            evenBiasConstant=0;
        end
    else
        evenBiasConstant=0;
    end



    if blockInfo.KernelWidth==4
        if blockInfo.BiasUp==false
            PrePadValue=1;
            PostPadValue=3;
            EndOfLineValue=3;
        else
            PrePadValue=1;
            PostPadValue=2;
            EndOfLineValue=3;
        end

    else
        paddingCycles=ceil(floor(blockInfo.KernelWidth/2)/blockInfo.NumPixels)-1;
        PrePadValue=floor(blockInfo.KernelWidth/2)-1-paddingCycles-evenKernelConstant+evenBiasConstant;
        PostPadValue=floor(blockInfo.KernelWidth/2)-evenKernelConstant+evenBiasConstant;
        EndOfLineValue=blockInfo.KernelWidth-1-evenKernelConstant+evenBiasConstant;
    end


    OnLine=PSNet.addSignal2('Type',booleanT,'Name','OnLine');
    PrePadding=PSNet.addSignal2('Type',booleanT,'Name','PrePadding');
    PostPadding=PSNet.addSignal2('Type',booleanT,'Name','PostPadding');
    PostOrPrePad=PSNet.addSignal2('Type',booleanT,'Name','PostOrPrePad');
    PrePadStart=PSNet.addSignal2('Type',booleanT,'Name','PrePadStart');
    PostPadStart=PSNet.addSignal2('Type',booleanT,'Name','PostPadStart');
    ProcessGate=PSNet.addSignal2('Type',booleanT,'Name','ProcessGate');
    NOTPrePadding=PSNet.addSignal2('Type',booleanT,'Name','NOTPrePadding');
    processPrePad=PSNet.addSignal2('Type',booleanT,'Name','processPrePad');
    counterEnb=PSNet.addSignal2('Type',booleanT,'Name','CounterEnb');
    EndLine=PSNet.addSignal2('Type',booleanT,'Name','EndLine');
    EndOfPadding=PSNet.addSignal2('Type',booleanT,'Name','EndOfPadding');


    pirelab.getUnitDelayEnabledResettableComp(PSNet,hStart,OnLine,hStart,hEnd,'OnLine',0,'',true,'',-1,true);
    pirelab.getUnitDelayEnabledResettableComp(PSNet,PrePadStart,PrePadding,PrePadStart,hEnd,'Prepadding',0,'',true,'',-1,true);
    pirelab.getUnitDelayEnabledResettableComp(PSNet,hEnd,EndLine,hEnd,EndOfPadding,'EndLine',0,'',true,'',-1,true);
    pirelab.getLogicComp(PSNet,PrePadding,NOTPrePadding,'not');
    pirelab.getLogicComp(PSNet,[processIn,NOTPrePadding],processPrePad,'and');
    if blockInfo.KernelWidth==4
        pirelab.getLogicComp(PSNet,[processPrePad,EndLine],counterEnb,'or');
    else
        pirelab.getLogicComp(PSNet,[processPrePad,EndLine,PrePadStart],counterEnb,'or');
    end


    processDataCount=PSNet.addSignal2('Type',countT,'Name','processDataCount');
    pirelab.getCounterComp(PSNet,[EndOfPadding,counterEnb],processDataCount,'Free running',...
    0,1,[],true,false,true,false,'Padding Counter',0);

    pirelab.getCompareToValueComp(PSNet,processDataCount,EndOfPadding,'==',EndOfLineValue,'processCountEndCompare');
    pirelab.getCompareToValueComp(PSNet,processDataCount,PrePadStart,'==',PrePadValue,'processCountStartCompare');
    pirelab.getCompareToValueComp(PSNet,processDataCount,PostPadStart,'<=',PostPadValue,'processCountStartCompare');


    OnlineOrPrePad=PSNet.addSignal2('Type',booleanT,'Name','OnlineOrPrePad');


    pirelab.getLogicComp(PSNet,[OnLine,PrePadding],OnlineOrPrePad,'or');

    if blockInfo.KernelWidth==4
        pirelab.getLogicComp(PSNet,[PostPadStart,NOTPrePadding],PostPadding,'and');
    else
        pirelab.getLogicComp(PSNet,[PostPadStart,EndLine],PostPadding,'and');
    end
    pirelab.getLogicComp(PSNet,[OnlineOrPrePad,PostPadding],PostOrPrePad,'or');
    pirelab.getLogicComp(PSNet,[PostOrPrePad,PrePadStart],ProcessGate,'or');
    pirelab.getLogicComp(PSNet,[ProcessGate,processIn],processOut,'and');



