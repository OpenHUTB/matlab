function cNet=elaborateVanHerkErosion(this,topNet,blockInfo,sigInfo,inRate)










    inputWL=sigInfo.inputWL;
    inputFL=sigInfo.inputFL;
    inType=sigInfo.inType;
    boolType=pir_boolean_t();
    cBits=ceil(log2(blockInfo.kWidth));
    countT=pir_ufixpt_t(cBits,0);
    controlType=pir_ufixpt_t(2,0);
    sigInfo.controlType=controlType;
    sigInfo.countT=countT;
    Neighborhood=blockInfo.Neighborhood;



    inPortNames={'DataIn','hStartIn','hEndIn','vStartIn','vEndIn','validIn','processDataIn'};
    inPortTypes=[inType,boolType,boolType,boolType,boolType,boolType,boolType];
    inPortRates=[inRate,inRate,inRate,inRate,inRate,inRate,inRate];
    outPortNames={'dataOut','hStartOut','hEndOut','vStartOut','vEndOut','validOut'};
    outPortTypes=[inType,boolType,boolType,boolType,boolType,boolType];


    cNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','DilationCore',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes);

    cNet.addComment('Find local maxima in grayscale image');



    inSignals=cNet.PirInputSignals;
    dataIn=inSignals(1);
    hStartIn=inSignals(2);
    hEndIn=inSignals(3);
    vStartIn=inSignals(4);
    vEndIn=inSignals(5);
    validIn=inSignals(6);
    processDataIn=inSignals(7);

    outSignals=cNet.PirOutputSignals;
    dataOut=outSignals(1);
    hStartOut=outSignals(2);
    hEndOut=outSignals(3);
    vStartOut=outSignals(4);
    vEndOut=outSignals(5);
    validOut=outSignals(6);



    dataInREG=cNet.addSignal2('Type',inType,'Name','DataInREG');
    dataInREGT=cNet.addSignal2('Type',inType,'Name','DataInREG');
    validInREG=cNet.addSignal2('Type',boolType,'Name','ValidInREG');
    processDataReg=cNet.addSignal2('Type',boolType,'Name','ProcessDataReg');
    hEndOutREG=cNet.addSignal2('Type',boolType,'Name','hEndOutREG');
    newFrameOR=cNet.addSignal2('Type',boolType,'Name','newFrameOR');
    newFrame=cNet.addSignal2('Type',boolType,'Name','newFrame');



    pirelab.getUnitDelayComp(cNet,dataIn,dataInREG);
    pirelab.getUnitDelayComp(cNet,dataInREG,dataInREGT);
    pirelab.getUnitDelayComp(cNet,processDataIn,validInREG);

    ModK=cNet.addSignal2('Type',boolType,'Name','ModK');
    bufferComplete=cNet.addSignal2('Type',boolType,'Name','BufferComplete');
    bufferCompleteREG=cNet.addSignal2('Type',boolType,'Name','BufferCompleteREG');








    MirrorUnitControlNet=this.elaborateMirrorUnitControl(cNet,blockInfo,sigInfo,inRate);

    ControlOut=cNet.addSignal2('Type',controlType,'Name','MirrorControl');

    MirrorUnitControlIn=[newFrame,validInREG];
    MirrorUnitControlOut=[ModK,ControlOut];

    pirelab.instantiateNetwork(cNet,MirrorUnitControlNet,MirrorUnitControlIn,...
    MirrorUnitControlOut,'MirrorUnitControl');




    mirrorNet=this.elaborateMirrorBuffer(cNet,blockInfo,sigInfo,inRate);


    MirrorUnit1In=[dataInREGT,newFrame,ControlOut,validInREG,bufferComplete];

    MirrorUnit1Out=cNet.addSignal2('Type',inType,'Name','MirrorUnit1Out');

    pirelab.instantiateNetwork(cNet,mirrorNet,MirrorUnit1In,...
    MirrorUnit1Out,'MirrorBufferOne');




    RunningMaxNet=this.elaborateRunningMax(cNet,blockInfo,sigInfo,inRate);
    ModKREG=cNet.addSignal2('Type',boolType,'Name','ModK');
    pirelab.getIntDelayComp(cNet,ModK,ModKREG,3);


    RunningMaxIn=[ModKREG,MirrorUnit1Out,newFrame];
    RunningMaxOut=cNet.addSignal2('Type',inType,'Name','RunningMaxOut');

    pirelab.instantiateNetwork(cNet,RunningMaxNet,RunningMaxIn,RunningMaxOut,'BackwardMax');

    validBuffered=cNet.addSignal2('Type',boolType,'Name','validBuffered');
    controlBuffered=cNet.addSignal2('Type',controlType,'Name','ControlBuffered');


    pirelab.getIntDelayComp(cNet,validInREG,validBuffered,blockInfo.kWidth+3);
    pirelab.getIntDelayComp(cNet,ControlOut,controlBuffered,blockInfo.kWidth+3);




    hEndREG=cNet.addSignal2('Type',boolType,'Name','hEndREG');

    pirelab.getIntDelayEnabledResettableComp(cNet,bufferComplete,bufferCompleteREG,validInREG,hEndOutREG,blockInfo.kWidth+4);

    MirrorUnit2In=[RunningMaxOut,newFrame,controlBuffered,validBuffered,bufferCompleteREG];
    MirrorUnit2Out=cNet.addSignal2('Type',inType,'Name','MirrorUnit2Out');
    MirrorUnit2OutREG=cNet.addSignal2('Type',inType,'Name','MirrorUnit2OutREG');

    pirelab.instantiateNetwork(cNet,mirrorNet,MirrorUnit2In,...
    MirrorUnit2Out,'MirrorBufferTwo');




    pirelab.getWireComp(cNet,MirrorUnit2Out,MirrorUnit2OutREG);




    forwardDataValid=cNet.addSignal2('Type',inType,'Name','forwardDataValid');
    forwardMax=cNet.addSignal2('Type',inType,'Name','forwardMax');


    pirelab.getUnitDelayEnabledResettableComp(cNet,dataInREG,forwardDataValid,validInREG,hEndOutREG,'DataValidReg');

    ForwardRunningMaxIn=[ModK,forwardDataValid,hEndOut];

    pirelab.instantiateNetwork(cNet,RunningMaxNet,ForwardRunningMaxIn,forwardMax,'ForwardMax');



    pirelab.getUnitDelayEnabledResettableComp(cNet,ModK,bufferComplete,ModK,hEndOut);




    forwardBufferNet=this.elaborateForwardBufferMax(cNet,blockInfo,sigInfo,inRate);
    validInREGFB=cNet.addSignal2('Type',boolType,'Name','ValidREG');
    bufferCompleteOR=cNet.addSignal2('Type',boolType,'Name','ValidREG');
    validOutPre=cNet.addSignal2('Type',boolType,'Name','ValidOutPre');
    pirelab.getIntDelayComp(cNet,processDataIn,validInREGFB,3);
    pirelab.getLogicComp(cNet,[validInREGFB,bufferComplete],bufferCompleteOR,'or');
    forwardBufferIn=[forwardMax,bufferCompleteOR,bufferComplete,hEndOut];

    forwardBufferOut=cNet.addSignal2('Type',inType,'Name','ForwardBufferOut');

    forwardMaxREG=cNet.addSignal2('Type',inType,'Name','ForwardMaxREG');
    backwardMaxREG=cNet.addSignal2('Type',inType,'Name','BackwardMaxREG');


    pirelab.getLogicComp(cNet,[hEndOutREG,validInREG],newFrameOR,'or');

    pirelab.getSwitchComp(cNet,[processDataIn,hEndOutREG],newFrame,newFrameOR);


    pirelab.instantiateNetwork(cNet,forwardBufferNet,forwardBufferIn,forwardBufferOut,'ForwardBuffer');
    pirelab.getIntDelayComp(cNet,forwardBufferOut,forwardMaxREG,7);

    if blockInfo.kWidth==8
        pirelab.getWireComp(cNet,hEndOut,hEndOutREG);
    else
        pirelab.getIntDelayComp(cNet,hEndOut,hEndOutREG,2);
    end
    pirelab.getUnitDelayEnabledResettableComp(cNet,MirrorUnit2OutREG,backwardMaxREG,bufferCompleteREG,hEndOutREG);

    dataOutREG=cNet.addSignal2('Type',inType,'Name','DataOutReg');
    dataOutPre=cNet.addSignal2('Type',inType,'Name','DataOutPre');
    dataMerge=cNet.addSignal2('Type',inType,'Name','DataOutReg');
    constLow=cNet.addSignal2('Type',inType,'Name','ConstantLow');
    pirelab.getConstComp(cNet,constLow,0);

    pirelab.getMinMaxComp(cNet,[forwardMaxREG,backwardMaxREG],dataMerge,'MergeStreamMax','min');









    if(mod(blockInfo.kWidth,2))==0
        pirelab.getIntDelayComp(cNet,dataMerge,dataOutREG,ceil(blockInfo.kWidth/2)+2);
    elseif(mod(blockInfo.kWidth,2))==1
        pirelab.getIntDelayComp(cNet,dataMerge,dataOutREG,ceil(blockInfo.kWidth/2)-1);
    end




    pipelineConst=3;
    pipeDataDelay=9;
    if(mod(blockInfo.kWidth,2))==0
        pirelab.getSwitchComp(cNet,[constLow,dataOutREG],dataOutPre,validOutPre);
        pirelab.getUnitDelayComp(cNet,dataOutPre,dataOut);
        pirelab.getIntDelayComp(cNet,hStartIn,hStartOut,(blockInfo.kWidth*2)+pipelineConst+pipeDataDelay);
        pirelab.getIntDelayComp(cNet,hEndIn,hEndREG,((blockInfo.kWidth*2))-1+pipelineConst+pipeDataDelay);
        pirelab.getIntDelayComp(cNet,hEndREG,hEndOut,1);
        pirelab.getIntDelayComp(cNet,vStartIn,vStartOut,(blockInfo.kWidth*2)+pipelineConst+pipeDataDelay);
        pirelab.getIntDelayComp(cNet,vEndIn,vEndOut,(blockInfo.kWidth*2)+pipelineConst+pipeDataDelay);
        pirelab.getIntDelayComp(cNet,validIn,validOutPre,(blockInfo.kWidth*2)-1+pipelineConst+pipeDataDelay);
        pirelab.getUnitDelayComp(cNet,validOutPre,validOut);

    else

        pirelab.getIntDelayComp(cNet,dataOutREG,dataOutPre,4);
        pirelab.getIntDelayComp(cNet,hStartIn,hStartOut,(blockInfo.kWidth*2)+pipelineConst+pipeDataDelay);
        pirelab.getIntDelayComp(cNet,hEndIn,hEndREG,((blockInfo.kWidth*2))-1+pipelineConst+pipeDataDelay);
        pirelab.getIntDelayComp(cNet,hEndREG,hEndOut,1);
        pirelab.getIntDelayComp(cNet,vStartIn,vStartOut,(blockInfo.kWidth*2)+pipelineConst+pipeDataDelay);
        pirelab.getIntDelayComp(cNet,vEndIn,vEndOut,(blockInfo.kWidth*2)+pipelineConst+pipeDataDelay);
        pirelab.getIntDelayComp(cNet,validIn,validOutPre,(blockInfo.kWidth*2)-1+pipelineConst+pipeDataDelay);
        pirelab.getUnitDelayComp(cNet,validOutPre,validOut);
        pirelab.getSwitchComp(cNet,[constLow,dataOutPre],dataOut,validOut);





    end




















