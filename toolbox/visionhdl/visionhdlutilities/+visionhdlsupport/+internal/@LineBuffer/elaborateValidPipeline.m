function validPipelineNet=elaborateValidPipeline(~,topNet,blockInfo,sigInfo,dataRate)





    booleanT=sigInfo.booleanT;

    depth=(ceil((blockInfo.effectiveKernelWidth/2)))-1;



    inPortNames{1}='validIn';
    inPortTypes(1)=booleanT;
    inPortRates(1)=dataRate;

    outPortNames={'validPipeOut','preProcessFlag','postProcessFlag'};
    outPortTypes=[booleanT,booleanT,booleanT];

    validPipelineNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','validPipeline',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes...
    );

    inSignals=validPipelineNet.PirInputSignals;
    validIn=inSignals(1);


    outSignals=validPipelineNet.PirOutputSignals;
    validPipeOut=outSignals(1);
    preProcessFlag=outSignals(2);
    postProcessFlag=outSignals(3);


    pirelab.getIntDelayComp(validPipelineNet,validIn,preProcessFlag,depth);
    pirelab.getIntDelayComp(validPipelineNet,preProcessFlag,validPipeOut,depth);
    pirelab.getIntDelayComp(validPipelineNet,validPipeOut,postProcessFlag,depth);
