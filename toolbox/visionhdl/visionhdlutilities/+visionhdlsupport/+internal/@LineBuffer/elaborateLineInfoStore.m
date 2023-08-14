function lineInfoNet=elaborateLineInfoStore(~,topNet,blockInfo,sigInfo,dataRate)








    booleanT=sigInfo.booleanT;
    lineStartT=sigInfo.lineStartT;

    inPortNames={'hStartIn','Unloading','frameEnd'};
    inPortTypes=[booleanT,booleanT,booleanT];
    inPortRates=[dataRate,dataRate,dataRate];
    outPortNames={'lineStartV'};
    outPortTypes=[lineStartT];

    lineInfoNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','LineInfoStore',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes...
    );

    inSignals=lineInfoNet.PirInputSignals;
    hStartIn=inSignals(1);
    Unloading=inSignals(2);
    frameEnd=inSignals(3);

    outSignals=lineInfoNet.PirOutputSignals;
    lineStartV=outSignals(1);


    inputMuxOut=lineInfoNet.addSignal2('Type',booleanT,'Name','InputMuxOut');
    zeroConstant=lineInfoNet.addSignal2('Type',booleanT,'Name','zeroConstant');

    pirelab.getConstComp(lineInfoNet,zeroConstant,0);
    pirelab.getSwitchComp(lineInfoNet,[hStartIn,zeroConstant],inputMuxOut,Unloading);

    shiftRegArray(1)=inputMuxOut;

    if blockInfo.KernelHeight<=3
        loadTo=3;
    elseif mod(blockInfo.KernelHeight,2)==0
        loadTo=floor(blockInfo.KernelHeight/2)+1;
    else
        loadTo=ceil(blockInfo.KernelHeight/2);
    end

    for ii=1:1:loadTo
        shiftRegArray(ii+1)=lineInfoNet.addSignal2('Type',booleanT,'Name',['lineStart',num2str(ii+1)]);
        pirelab.getUnitDelayEnabledResettableComp(lineInfoNet,shiftRegArray(ii),shiftRegArray(ii+1),hStartIn,frameEnd);
    end

    if blockInfo.KernelHeight<=3||(mod(blockInfo.KernelHeight,2)==0&&~blockInfo.BiasUp&&blockInfo.KernelHeight<=4)
        pirelab.getBitConcatComp(lineInfoNet,shiftRegArray(3:-1:2),lineStartV);
    else
        pirelab.getBitConcatComp(lineInfoNet,shiftRegArray(end:-1:3),lineStartV);
    end




