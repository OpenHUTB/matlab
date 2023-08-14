function applyReductionNW=processReductionComps(p)

















    applyReductionNW=[];

    topNW=p.getTopNetwork;
    portInfo=streamingmatrix.getStreamedPorts(topNW);
    if isempty(portInfo.streamedInPorts)
        return
    end
    tag=portInfo.streamedInPorts(1).data.getStreamingMatrixTag;
    origImageSize=[tag.getOrigNumRows,tag.getOrigNumCols];

    if isempty(origImageSize)
        return
    end


    ntwrks=p.Networks;
    for ii=1:numel(ntwrks)
        forIterNW=ntwrks(ii);
        nwComps=forIterNW.instances;
        if isForIteratorNetwork(forIterNW)
            assert(numel(nwComps)==1,'Only one instance of iterator network expected.');
        end
        if isReductionNW(forIterNW,origImageSize)


            handleReductionNW(forIterNW,nwComps);
        elseif isForIteratorNetwork(forIterNW)&&...
            ~isIteratingStreamedSignal(forIterNW,origImageSize)


            streamForIterComp(nwComps);

            nwComp=forIterNW.instances;
            rate=nwComp.PirInputSignals(1).SimulinkRate;
            setRateRecursively(forIterNW,rate);
        end
    end

end

function out=isAnySignalOfSize(signals,sz)

    out=false;
    for ii=1:numel(signals)
        type=signals(ii).Type;
        if isa(type,'hdlcoder.tp_array')
            if isequal(sz,type.Dimensions)
                out=true;
                break;
            end
        end
    end

end

function out=isIteratingStreamedSignal(N,reductionSigSize)



    out=false;
    if~isForIteratorNetwork(N)
        return
    end


    if isAnySignalOfSize(N.PirInputSignals,reductionSigSize)||...
        isAnySignalOfSize(N.PirOutputSignals,reductionSigSize)
        out=true;
        return;
    end


    for i=1:numel(N.PirInputPorts)
        if N.PirInputPorts(i).hasStreamingMatrixTag
            tag=N.PirInputPorts(i).getStreamingMatrixTag;
            if tag.getOrigNumCols>0
                out=true;
                return
            end
        end
    end

end

function isForIter=isForIteratorNetwork(N)
    isForIter=false;
    try
        hasTag=N.hasForIterDataTag;
        if hasTag
            tag=N.getForIterDataTag;
            isForIter=tag.getIterations~=0;
        end
    catch
    end
end

function reduction=isReductionNW(forIterNW,origImageSize)




    reduction=false;
    if~isForIteratorNetwork(forIterNW)
        return
    end

    tag=forIterNW.getForIterDataTag;
    isIteratorFun=tag.isIteratorFun();
    if~isIteratorFun
        return
    end

    in1Type=forIterNW.PirInputSignals(1).Type;
    in1Size=[];
    if isa(in1Type,'hdlcoder.tp_array')
        in1Size=in1Type.Dimensions;
        if numel(in1Size)==1
            in1Size=[1,in1Size];
        end
    end
    numIterations=tag.getIterations();
    if~isequal(in1Size,origImageSize)||numIterations~=prod(in1Size)


        return
    end

    reduction=true;

end

function newNic=convertForIterToRegularNetwork(forIterNW,forIterInstance,name)


    for ii=1:numel(forIterInstance.PirInputSignals)
        rate=forIterInstance.PirInputSignals(ii).SimulinkRate;
        forIterNW.PirInputSignals(ii).SimulinkRate=rate;
    end


    for jj=(ii+1):numel(forIterNW.PirInputSignals)
        forIterNW.PirInputSignals(jj).SimulinkRate=rate;
    end

    for ii=1:numel(forIterInstance.PirOutputSignals)
        forIterNW.PirOutputSignals(ii).SimulinkRate=...
        forIterInstance.PirOutputSignals(ii).SimulinkRate;
    end

    newNic=pirelab.instantiateNetwork(forIterInstance.Owner,forIterNW,...
    forIterInstance.PirInputSignals,...
    forIterInstance.PirOutputSignals,name);


    for ii=1:numel(forIterInstance.PirInputSignals)
        inSignal=forIterInstance.PirInputSignals(ii);
        inSignal.disconnectReceiver(forIterInstance.PirInputPorts(ii));
    end
    for ii=1:numel(forIterInstance.PirOutputSignals)
        outSignal=forIterInstance.PirOutputSignals(ii);
        outSignal.disconnectDriver(forIterInstance.PirOutputPorts(ii));
    end


    parentNW=forIterInstance.Owner;
    parentNW.removeComponent(forIterInstance);

    tag=forIterNW.getForIterDataTag;
    tag.setIterations(1);

end

function setRateRecursively(nw,rate)

    signals=nw.Signals;
    for s=1:numel(signals)
        signals(s).SimulinkRate=rate;
    end

    comps=nw.Components;
    for ii=1:numel(comps)
        if isa(comps(ii),'hdlcoder.ntwk_instance_comp')
            setRateRecursively(comps(ii).ReferenceNetwork,rate);
        end
    end

end

function[lastPixel,validInSignal]=createValidSignalForReductionComp(forIterNW,inImageSize)


    fidt=forIterNW.getForIterDataTag;
    counterComp=fidt.getIterationCounter;
    assert(isa(counterComp,'hdlcoder.hdlcounter_comp'));




    counterOutputSignal=counterComp.PirOutputSignals;
    lastPixel=forIterNW.addSignal(pir_boolean_t,'lastPixel');
    pirelab.getCompareToValueComp(forIterNW,counterOutputSignal,...
    lastPixel,'==',inImageSize,'checkLastPixel');



    validOutSignal=forIterNW.addSignal(pir_boolean_t,'lastPixel');
    pirelab.getUnitDelayEnabledComp(forIterNW,lastPixel,validOutSignal,...
    lastPixel,'validOutput',0);

    assert(numel(forIterNW.PirOutputPorts)==1);
    op=forIterNW.addOutputPort("orig_valid_output");
    validOutSignal.addReceiver(op);


    smt=forIterNW.PirOutputPorts(1).getStreamingMatrixTag;
    smt.setValidPort(forIterNW.PirOutputPorts(2));


    numOrigInputs=numel(forIterNW.PirInputPorts);
    validInSignals(numOrigInputs)=validOutSignal;
    for i=1:numOrigInputs
        validInSignals(i)=forIterNW.addSignal(pir_boolean_t,'validInput');

        validInPort=forIterNW.addInputPort("validInput");
        validInSignals(i).addDriver(validInPort);


        smt=forIterNW.PirInputPorts(i).getStreamingMatrixTag;
        smt.setValidPort(validInPort);
    end

    validEnableForCounterSignal=validInSignals(1);
    for i=2:numOrigInputs
        newSig=forIterNW.addSignal(pir_boolean_t,'counter_enable');
        pirelab.getLogicComp(forIterNW,[validEnableForCounterSignal,validInSignals(i)],...
        newSig,'and','and');
        validEnableForCounterSignal=newSig;
    end


    counterComp.setEnablePort(1);
    enablePort=counterComp.addInputPort('enable');
    validEnableForCounterSignal.addReceiver(enablePort);

    validInSignal=validInSignals(1);

end


function[newComp,validOutSignal]=streamForIterComp(forIterComp)











    forNW=forIterComp.ReferenceNetwork;

    tag=forNW.getForIterDataTag;
    numIterations=tag.getIterations;

    newComp=convertForIterToRegularNetwork(forNW,forIterComp,forIterComp.Name);



    compInSignals=newComp.PirInputSignals;
    forNWInSignals=forNW.PirInputSignals;
    forNWInPorts=forNW.PirInputPorts;
    validInSignals=cell(1,numel(compInSignals));
    inputEnable=forNW.addSignal(pir_boolean_t,'inputEnable');
    for ii=1:numel(compInSignals)

        forNWInSignal=forNWInSignals(ii);

        validPort=forNW.addInputPort('valid');
        validInSignals{ii}=forNW.addSignal(pir_boolean_t,'validInput');
        validInSignals{ii}.addDriver(validPort);


        smt=forNWInPorts(ii).getStreamingMatrixTag;
        smt.setValidPort(validPort);

        if isDrivenByConstantSource(compInSignals(ii))

            continue
        end


        insertEnabledDelay(forNWInSignal,inputEnable,forNW.PirInputPorts(ii),forNW);
    end

    addSelectorForKernelFirstInput(forNW,tag.getIterationCounter);


    if numel(validInSignals)>1
        validInSignal=forNW.addSignal(pir_boolean_t,'validInput');
        pirelab.getLogicComp(forNW,[validInSignals{:}],...
        validInSignal,'and','and');
    else
        validInSignal=validInSignals{1};
    end


    validHold=forNW.addSignal(pir_boolean_t,'validHold');
    countSignal=forNW.addSignal(pir_unsigned_t(32),'count_output');
    resetValid=forNW.addSignal(pir_boolean_t,'resetValid');
    resetPort=true;
    loadPort=false;
    enabPort=true;
    dirPort=false;
    pirelab.getCounterComp(forNW,[resetValid,validHold],countSignal,...
    'Count limited',0,1,numIterations,...
    resetPort,loadPort,enabPort,dirPort,...
    'IterCounter');
    resetStates=pirelab.getCompareToZero(forNW,countSignal);



    pirelab.getCompareToValueComp(forNW,countSignal,...
    resetValid,'==',numIterations,'resetValid');


    pirelab.getUnitDelayEnabledResettableComp(forNW,validInSignal,...
    validHold,validInSignal,resetValid,'ValidStore',0);
    validHoldNot=forNW.addSignal(pir_boolean_t,'validHoldNot');
    pirelab.getLogicComp(forNW,validHold,validHoldNot,'not','not');
    pirelab.getLogicComp(forNW,[validInSignal,validHoldNot],inputEnable,'and','and');



    comps=forNW.Components;
    for ii=1:numel(comps)
        if isa(comps(ii),'hdlcoder.hdlcounter_comp')&&...
            numel(comps(ii).PirInputSignals)==0
            replaceWithResettableCounter(forNW,comps(ii),resetStates);
        end
        if isa(comps(ii),'hdlcoder.integerdelay_comp')
            replaceWithResettableDelay(forNW,comps(ii),resetStates);
        end
    end





    outputLatency=numIterations+2;
    holdOutput(forNW,resetValid);


    validOutSignal=forNW.addSignal(pir_boolean_t,'ValidOut');
    pirelab.getUnitDelayEnabledComp(forNW,resetValid,validOutSignal,...
    resetValid,'validOutput',0);

    op=forNW.addOutputPort("validoutput");
    validOutSignal.addReceiver(op);

    dataOutputPort=forNW.PirOutputPorts(1);
    smt=dataOutputPort.getStreamingMatrixTag;
    smt.setValidPort(op);

    rate=newComp.PirInputSignals(1).SimulinkRate;
    setRateRecursively(forNW,rate);


    setOutputLatency(forNW,outputLatency,1);
    setOutputLatency(forNW,outputLatency,2);


    newComp.reflectReferenceNetworkInterface;
end

function holdOutput(nw,enableSignal)



    port=nw.PirOutputPorts(1);
    origOutputSignal=nw.PirOutputSignals(1);
    origOutputSignal.disconnectReceiver(port);
    newOutputSignal=nw.addSignal(origOutputSignal.Type,'output');
    newOutputSignal.addReceiver(port);


    pirelab.getUnitDelayEnabledComp(nw,origOutputSignal,newOutputSignal,...
    enableSignal,'IteratorOutput',0);
end

function setEnabledOutputLatency(nw,outputLatency,outportIdx)

    bufferComp=insertWireCompBefore(nw.PirOutputSignals(outportIdx),...
    nw.PirOutputPorts(outportIdx));
    bufferComp.setEnabledOutputDelay(outputLatency);
end

function setOutputLatency(nw,outputLatency,outportIdx)

    bufferComp=insertWireCompBefore(nw.PirOutputSignals(outportIdx),...
    nw.PirOutputPorts(outportIdx));
    bufferComp.setOutputDelay(outputLatency);
end

function addSelectorForKernelFirstInput(nw,counter)



    kernelInstance=[];
    comps=nw.Components;
    for ii=1:numel(comps)
        if isa(comps(ii),'hdlcoder.ntwk_instance_comp')
            kernelInstance=comps(ii);
            break;
        end
    end

    assert(~isempty(kernelInstance));

    instanceInType=kernelInstance.PirInputSignals(1).Type;
    kernelNWInType=kernelInstance.ReferenceNetwork.PirInputSignals(1).Type;

    if~instanceInType.isArrayType||kernelNWInType.isArrayType||...
        ~instanceInType.BaseType.isEqual(kernelNWInType)




        return;
    end

    sig=kernelInstance.PirInputSignals(1);
    port=kernelInstance.PirInputPorts(1);
    sig.disconnectReceiver(port);

    outType=sig.Type;
    assert(isa(outType,'hdlcoder.tp_array'));
    outType=outType.BaseType;
    selectorOutput=nw.addSignal(outType,sig.Name);
    pirelab.getSelectorComp(nw,[sig,counter.PirOutputSignal],...
    selectorOutput,'one-based',{'Index vector (port)'},{1:3},{'1'},'1');

    selectorOutput.addReceiver(port);
end

function insertEnabledDelay(origInputSignal,enableSignal,port,network)

    origInputSignal.disconnectDriver(port);

    newInputSignal=network.addSignal(origInputSignal.Type,'delayed');
    newInputSignal.addDriver(port);


    pirelab.getUnitDelayEnabledComp(network,newInputSignal,origInputSignal,...
    enableSignal,'IteratorInput',0);

end

function replaceWithResettableCounter(N,comp,resetSignal)




    outputSignal=comp.PirOutputSignals(1);
    outputSignal.disconnectDriver(comp.PirOutputPorts(1));
    initVal=comp.getCountFrom;
    stepVal=comp.getCountStep;
    finalVal=comp.getCountMax;
    resetPort=true;
    loadPort=false;
    enabPort=false;
    dirPort=false;
    pirelab.getCounterComp(N,resetSignal,outputSignal,...
    'Count limited',initVal,stepVal,finalVal,...
    resetPort,loadPort,enabPort,dirPort,...
    comp.Name);
end

function replaceWithResettableDelay(N,comp,resetSignal)

    inputSignal=comp.PirInputSignals;
    if numel(inputSignal)>1

        return;
    end
    inputSignal.disconnectReceiver(comp.PirInputPorts(1));

    outputSignal=comp.PirOutputSignals(1);
    outputSignal.disconnectDriver(comp.PirOutputPorts(1));

    pirelab.getUnitDelayResettableComp(N,inputSignal,outputSignal,...
    resetSignal,comp.Name);

end

function out=isDrivenByConstantSource(inSignal)
    srcPort=inSignal.getDrivers;
    srcComp=srcPort.Owner;
    out=false;
    if isa(srcComp,'hdlcoder.mconstant_comp')
        out=true;
    end
end

function[reductionComp,inImageSize]=...
    handleReductionNW(reductionNW,reductionInstance)



    for ii=1:numel(reductionNW.Components)
        if isa(reductionNW.Components(ii),'hdlcoder.integerdelay_comp')
            feedbackDelay=reductionNW.Components(ii);
            break;
        end
    end

    tag=reductionNW.getForIterDataTag;
    inImageSize=tag.getIterations();
    [lastPixelSignal,validInSignal]=...
    createValidSignalForReductionComp(reductionNW,inImageSize);
    reductionComp=convertForIterToRegularNetwork(reductionNW,reductionInstance,'ReductionNW');



    feedbackDelayInput=feedbackDelay.PirInputSignals(1);
    feedbackDelayInput.disconnectReceiver(feedbackDelay.PirInputPorts(1));
    feedbackDelayNewInput=reductionNW.addSignal(feedbackDelayInput.Type,'kernelOut');
    feedbackDelayNewInput.addReceiver(feedbackDelay.PirInputPorts(1));
    pirelab.getSwitchComp(reductionNW,[feedbackDelayInput,feedbackDelay.PirOutputSignals(1)],...
    feedbackDelayNewInput,validInSignal,'validSwitch','~=',0);



    holdOutput(reductionNW,lastPixelSignal);

    rate=reductionComp.PirInputSignals(1).SimulinkRate;
    setRateRecursively(reductionNW,rate);


    setEnabledOutputLatency(reductionNW,inImageSize,1);
    setEnabledOutputLatency(reductionNW,inImageSize,2);

    setStreamedSignalsToScalar(reductionNW);


    reductionComp.reflectReferenceNetworkInterface;

end

function setStreamedSignalsToScalar(nw)


    s=nw.PirInputSignals(1);
    scalarType=s.Type.BaseType;
    s.Type=scalarType;



    receivingPort=s.getReceivers;
    receivingComp=receivingPort.Owner;
    while~isa(receivingComp,'hdlcoder.ntwk_instance_comp')&&...
        ~isa(receivingComp,'hdlcoder.network')
        s=receivingComp.PirOutputSignals(1);
        s.Type=scalarType;
        receivingPort=s.getReceivers;
        receivingComp=receivingPort.Owner;
    end

end

function hC=insertWireCompBefore(hInSignals,port)
    hN=port.Owner;
    hInSignals.disconnectReceiver(port);
    hOutSignals=hN.addSignal(hInSignals.Type,'buffer');
    hC=pirelab.getWireComp(hN,hInSignals,hOutSignals);
    hOutSignals.addReceiver(port);
end








