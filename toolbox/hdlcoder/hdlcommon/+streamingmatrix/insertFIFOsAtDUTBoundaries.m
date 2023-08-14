



function insertFIFOsAtDUTBoundaries(gp,inputFIFOSize,outputFIFOSize)


    gp.doDeadLogicElimination;

    dut=gp.getTopNetwork;



    dut.renderCodegenPir(true);

    smps=pushCompsIntoSMPs(dut);
    if isempty(smps)
        return;
    end

    portInfo=streamingmatrix.getStreamedPorts(dut);


    portInfo=addReadySignals(dut,portInfo);

    [smpInputs,smpOutputs]=partitionStreamedPortsBySMP(portInfo,smps);

    for i=1:numel(smps)
        inputs=smpInputs(i);
        streamedOutputs=smpOutputs{i};

        assert(numel(inputs.streamed)>0);

        readySignal=addInputFIFOs(dut,inputs,inputFIFOSize);

        addOutputFIFOs(dut,streamedOutputs,readySignal,outputFIFOSize);

        addEnablePort(smps(i),readySignal);
    end

    streamingmatrix.setAllShouldDraw(gp.getTopPirCtx);
end




function smps=pushCompsIntoSMPs(hN)
    comps=hN.Components;


    smps=comps;
    smpIdx=1;

    nonSmpComps=comps;
    nonSmpIdx=1;

    for i=1:numel(comps)
        comp=comps(i);
        if isSMP(comp)
            smps(smpIdx)=comp;
            smpIdx=smpIdx+1;
        else
            nonSmpComps(nonSmpIdx)=comp;
            nonSmpIdx=nonSmpIdx+1;
        end
    end

    smps(smpIdx:end)=[];
    nonSmpComps(nonSmpIdx:end)=[];



    adjustmentMade=true;


    while adjustmentMade
        adjustmentMade=false;


        newNonSmpComps=nonSmpComps;
        newNonSmpIdx=1;

        for i=1:numel(nonSmpComps)

            comp=nonSmpComps(i);

            if pushCompIntoDrivingSMP(comp)
                adjustmentMade=true;
            else
                newNonSmpComps(newNonSmpIdx)=comp;
                newNonSmpIdx=newNonSmpIdx+1;
            end
        end

        nonSmpComps=newNonSmpComps(1:newNonSmpIdx-1);
    end



    for smpIdx=1:numel(smps)
        smp=smps(smpIdx);
        smpRefNum=smp.RefNum;
        nwRefNum=smp.Owner.RefNum;

        for inSigIdx=1:numel(smp.PirInputSignals)
            inSig=smp.PirInputSignals(inSigIdx);


            driver=inSig.getDrivers;
            assert(isscalar(driver)&&strcmp(driver.Owner.RefNum,nwRefNum));


            receivers=inSig.getReceivers;
            for rcvIdx=1:numel(receivers)
                assert(strcmp(receivers(rcvIdx).Owner.RefNum,smpRefNum));
            end
        end

        for outSigIdx=1:numel(smp.PirOutputSignals)
            outSig=smp.PirOutputSignals(outSigIdx);


            receiver=outSig.getReceivers;
            assert(isscalar(receiver)&&strcmp(receiver.Owner.RefNum,nwRefNum));
        end
    end
end




function isit=isSMP(comp)
    isit=~isa(comp,'hdlcoder.network')&&...
    comp.isNetworkInstance&&comp.ReferenceNetwork.isStreamingMatrixPartition;
end


function success=pushCompIntoDrivingSMP(comp)
    numIn=numel(comp.PirInputSignals);
    if numIn==0
        success=false;
        return;
    end



    smpNIC=comp.PirInputSignals(1).getDrivers.Owner;
    if~isSMP(smpNIC)
        success=false;
        return;
    end

    for i=2:numIn
        thisSmpNIC=comp.PirInputSignals(i).getDrivers.Owner;
        if~strcmp(smpNIC.RefNum,thisSmpNIC.RefNum)
            success=false;
            return;
        end
    end

    hTopN=smpNIC.Owner;
    hN=smpNIC.ReferenceNetwork;






    inSigsInNetwork=comp.PirInputSignals;

    for i=1:numIn
        inSig=comp.PirInputSignals(i);
        smpPort=inSig.getDrivers;
        portIdx=smpPort.PortIndex;
        inSigsInNetwork(i)=hN.PirOutputSignals(portIdx+1);

        inSig.disconnectReceiver(comp.PirInputPorts(i));
        if isempty(inSig.getReceivers)
            hTopN.removeSignal(inSig);
            hN.removeOutputPort(portIdx);
            smpNIC.removeOutputPort(portIdx);
        end
    end


    numOut=numel(comp.PirOutputSignals);
    outSigsInNetwork=comp.PirOutputSignals;

    for i=1:numOut
        outSig=comp.PirOutputSignals(i);

        newNwPort=hN.addOutputPort(outSig.Name);
        outSigsInNetwork(i)=hN.addSignal(outSig);
        outSigsInNetwork(i).addReceiver(newNwPort);

        smpNIC.reflectReferenceNetworkInterface;
        newSmpPort=smpNIC.PirOutputPorts(newNwPort.PortIndex+1);
        outSig.disconnectDriver(comp.PirOutputPorts(i));
        outSig.addDriver(newSmpPort);
    end


    hN.acquireComp(comp);


    for i=1:numIn
        inSigsInNetwork(i).addReceiver(comp.PirInputPorts(i));
    end

    for i=1:numOut
        outSigsInNetwork(i).addDriver(comp.PirOutputPorts(i));
    end

    success=true;
end




function portInfo=addReadySignals(hN,portInfo)

    for i=1:numel(portInfo.streamedInPorts)
        dataPort=portInfo.streamedInPorts(i).data;


        smt=dataPort.getStreamingMatrixTag;
        readyPort=hN.addOutputPort([dataPort.Name,'_ready']);
        smt.setReadyPort(readyPort);
        portInfo.streamedInPorts(i).ready=readyPort;

        dataSig=dataPort.Signal;
        rate=dataSig.SimulinkRate;
        readySignal=addSignal(hN,pir_boolean_t,[dataSig.Name,'_ready'],rate);
        readySignal.addReceiver(readyPort);
    end

    for i=1:numel(portInfo.streamedOutPorts)
        dataPort=portInfo.streamedOutPorts(i).data;


        smt=dataPort.getStreamingMatrixTag;
        readyPort=hN.addInputPort([dataPort.Name,'_ready']);
        smt.setReadyPort(readyPort);
        portInfo.streamedOutPorts(i).ready=readyPort;

        dataSig=dataPort.Signal;
        rate=dataSig.SimulinkRate;
        readySignal=addSignal(hN,pir_boolean_t,[dataSig.Name,'_ready'],rate);
        readySignal.addDriver(readyPort);
    end
end





function[smpInputs,smpOutputs]=partitionStreamedPortsBySMP(portInfo,smps)
    allStreamedInputs=portInfo.streamedInPorts;
    nonStreamedInputs=portInfo.nonStreamedInPorts;
    allStreamedOutputs=portInfo.streamedOutPorts;

    numSMPs=numel(smps);
    numIn=numel(allStreamedInputs);
    numInNonstreamed=numel(nonStreamedInputs);
    numOut=numel(allStreamedOutputs);


    exPt=smps(1).Owner.PirOutputPort(1);
    smpInputs=struct(...
    'streamed',repmat({repmat(streamingmatrix.StreamedPortInfo,1,numIn)},1,numSMPs),...
    'nonstreamed',repmat({repmat(exPt,1,numInNonstreamed)},1,numSMPs));
    smpOutputs=repmat({repmat(streamingmatrix.StreamedPortInfo,1,numOut)},1,numSMPs);



    for i=1:numSMPs
        smpRefNum=smps(i).RefNum;

        streamedInIdx=1;
        for j=1:numIn
            signal=allStreamedInputs(j).data.Signal;

            receivingComp=signal.getReceivers.Owner;
            if strcmp(receivingComp.RefNum,smpRefNum)
                smpInputs(i).streamed(streamedInIdx)=allStreamedInputs(j);
                streamedInIdx=streamedInIdx+1;
            end
        end

        nonStreamedInIdx=1;
        for j=1:numInNonstreamed
            signal=nonStreamedInputs(j).Signal;

            receivingPorts=signal.getReceivers;
            if numel(receivingPorts)==1&&strcmp(receivingPorts.Owner.RefNum,smpRefNum)
                smpInputs(i).nonstreamed(nonStreamedInIdx)=nonStreamedInputs(j);
                nonStreamedInIdx=nonStreamedInIdx+1;
            end
        end

        outputIdx=1;
        for j=1:numOut
            signal=allStreamedOutputs(j).data.Signal;

            drivingComp=signal.getDrivers.Owner;
            if strcmp(drivingComp.RefNum,smpRefNum)
                smpOutputs{i}(outputIdx)=allStreamedOutputs(j);
                outputIdx=outputIdx+1;
            end
        end


        smpInputs(i).streamed(streamedInIdx:end)=[];
        smpInputs(i).nonstreamed(nonStreamedInIdx:end)=[];
        smpOutputs{i}(outputIdx:end)=[];
    end
end


function readySig=addInputFIFOs(hN,inputs,fifoSize)
    numStreamedIn=numel(inputs.streamed);
    numNonStreamedIn=numel(inputs.nonstreamed);
    rate=inputs.streamed(1).data.Signal.SimulinkRate;

    newValidSig=addSignal(hN,pir_boolean_t,'valid',rate);
    readySig=addSignal(hN,pir_boolean_t,'ready',rate);


    newDataSigs(numStreamedIn+numNonStreamedIn)=newValidSig;


    for i=1:numStreamedIn
        dataSig=inputs.streamed(i).data.Signal;
        validSig=inputs.streamed(i).valid.Signal;

        newDataSigs(i)=hN.addSignal(dataSig);

        newDataSigs(i).acquireReceivers(dataSig);
        newValidSig.acquireReceivers(validSig);
    end


    for i=1:numNonStreamedIn
        dataSig=inputs.nonstreamed(i).Signal;
        newDataSigs(numStreamedIn+i)=hN.addSignal(dataSig);
        newDataSigs(numStreamedIn+i).acquireReceivers(dataSig);
    end


    createInputFIFONIC(hN,...
    inputs,newDataSigs,readySig,newValidSig,fifoSize);
end


function hNIC=createInputFIFONIC(hTopN,inputs,...
    topOutputDataSigs,topReadySig,topValidSig,fifoSize)
    streamedInputs=inputs.streamed;
    numStreamedIn=numel(inputs.streamed);
    numNonStreamedIn=numel(inputs.nonstreamed);
    numNwIO=numStreamedIn*2+numNonStreamedIn+1;

    rate=topReadySig.SimulinkRate;


    ioRates=repmat(rate,1,numNwIO);

    inputNames=cell(1,numNwIO);
    inputTypes=repmat(pir_boolean_t,1,numNwIO);
    outputNames=cell(1,numNwIO);
    outputTypes=repmat(pir_boolean_t,1,numNwIO);

    topInSigs(numNwIO)=topReadySig;
    topInSigs(1)=topReadySig;
    topOutSigs(numNwIO)=topValidSig;

    inputNames{1}='ready';
    outputNames{end}='valid';

    for i=1:numStreamedIn
        dataSig=inputs.streamed(i).data.Signal;
        name=dataSig.Name;
        baseNwIdx=i*2-1;

        inputNames{baseNwIdx+1}=[name,'_in'];
        inputNames{baseNwIdx+2}=[name,'_valid'];
        inputTypes(baseNwIdx+1)=dataSig.Type;

        outputNames{baseNwIdx}=[name,'_out'];
        outputNames{baseNwIdx+1}=[name,'_ready'];
        outputTypes(baseNwIdx)=dataSig.Type;

        topInSigs(baseNwIdx+1)=dataSig;
        topInSigs(baseNwIdx+2)=inputs.streamed(i).valid.Signal;
        topOutSigs(baseNwIdx)=topOutputDataSigs(i);
        topOutSigs(baseNwIdx+1)=inputs.streamed(i).ready.Signal;
    end

    for i=1:numNonStreamedIn
        dataSig=inputs.nonstreamed(i).Signal;
        name=dataSig.Name;
        baseNwIdx=numStreamedIn*2+i;

        inputNames{baseNwIdx+1}=[name,'_in'];
        inputTypes(baseNwIdx+1)=dataSig.Type;

        outputNames{baseNwIdx}=[name,'_out'];
        outputTypes(baseNwIdx)=dataSig.Type;

        topInSigs(baseNwIdx+1)=dataSig;
        topOutSigs(baseNwIdx)=topOutputDataSigs(numStreamedIn+i);
    end

    hN=pirelab.createNewNetwork('Network',hTopN,...
    'Name','Input FIFOs',...
    'InportNames',inputNames,...
    'InportTypes',inputTypes,...
    'InportRates',ioRates,...
    'OutportNames',outputNames,...
    'OutportTypes',outputTypes,...
    'OutportRates',ioRates);
    hTopN.copyOptimizationOptions(hN,false);
    hNIC=pirelab.instantiateNetwork(hTopN,hN,...
    topInSigs,topOutSigs,'Input_FIFOs');


    validOutSig=hN.PirOutputSignals(end);


    shouldReadIn=validOutSig;

    hasDataSigs(numStreamedIn)=validOutSig;

    for i=1:numStreamedIn
        baseNwIdx=i*2-1;
        name=streamedInputs(i).data.Signal.Name;

        dataIn=hN.PirInputSignals(baseNwIdx+1);
        validIn=hN.PirInputSignals(baseNwIdx+2);

        dataOut=hN.PirOutputSignals(baseNwIdx);
        readyOut=hN.PirOutputSignals(baseNwIdx+1);


        hasDataSigs(i)=instantiateInputFIFO(hN,name,rate,fifoSize,...
        dataIn,validIn,shouldReadIn,...
        dataOut,readyOut);
    end


    nonStreamedValidIn=hN.PirInputSignals(3);

    for i=1:numNonStreamedIn
        baseNwIdx=numStreamedIn*2+i;
        name=inputs.nonstreamed(i).Signal.Name;

        dataIn=hN.PirInputSignals(baseNwIdx+1);
        dataOut=hN.PirOutputSignals(baseNwIdx);

        instantiateNonStreamedInputFIFO(hN,name,rate,fifoSize,...
        dataIn,nonStreamedValidIn,shouldReadIn,...
        dataOut);
    end



    pirelab.getLogicComp(hN,[hasDataSigs,hN.PirInputSignals(1)],validOutSig,'and');
end


function topHasDataOut=instantiateInputFIFO(hTopN,name,rate,fifoSize,...
    topDataIn,topValidIn,topShouldReadIn,...
    topDataOut,topReadyOut)

    hN=pirelab.createNewNetwork('Network',hTopN,...
    'Name',[name,'_FIFO'],...
    'InportNames',{[name,'_in'],'valid_in','should_read'},...
    'InportTypes',[topDataIn.Type,pir_boolean_t,pir_boolean_t],...
    'InportRates',repmat(rate,1,3),...
    'OutportNames',{[name,'_out'],'ready_out','has_data'},...
    'OutportTypes',[topDataOut.Type,pir_boolean_t,pir_boolean_t],...
    'OutportRates',repmat(rate,1,3));
    hTopN.copyOptimizationOptions(hN,false);

    topHasDataOut=addSignal(hTopN,pir_boolean_t,[name,'_buffer_has_data'],rate);
    pirelab.instantiateNetwork(hTopN,hN,...
    [topDataIn,topValidIn,topShouldReadIn],[topDataOut,topReadyOut,topHasDataOut],...
    [name,'_FIFO']);

    [dataIn,validIn,shouldReadIn]=dealArr(hN.PirInputSignals);
    [dataOut,readyOut,hasDataOut]=dealArr(hN.PirOutputSignals);



    emptySig=addSignal(hN,pir_boolean_t,'buffer_empty',rate);
    fullSig=addSignal(hN,pir_boolean_t,'buffer_full',rate);

    pirelab.getLogicComp(hN,emptySig,hasDataOut,'not');
    pirelab.getLogicComp(hN,fullSig,readyOut,'not');

    createFIFOComps(hN,...
    [dataIn,validIn,shouldReadIn],[dataOut,emptySig,fullSig],...
    fifoSize);
end


function instantiateNonStreamedInputFIFO(hTopN,name,rate,fifoSize,...
    topDataIn,topValidIn,topShouldReadIn,topDataOut)

    hN=pirelab.createNewNetwork('Network',hTopN,...
    'Name',[name,'_FIFO'],...
    'InportNames',{[name,'_in'],'valid_in','should_read'},...
    'InportTypes',[topDataIn.Type,pir_boolean_t,pir_boolean_t],...
    'InportRates',repmat(rate,1,3),...
    'OutportNames',{[name,'_out']},...
    'OutportTypes',topDataOut.Type,...
    'OutportRates',rate);
    hTopN.copyOptimizationOptions(hN,false);

    pirelab.instantiateNetwork(hTopN,hN,...
    [topDataIn,topValidIn,topShouldReadIn],topDataOut,...
    [name,'_FIFO']);

    [dataIn,validIn,shouldReadIn]=dealArr(hN.PirInputSignals);
    dataOut=hN.PirOutputSignals;

    createFIFOComps(hN,...
    [dataIn,validIn,shouldReadIn],dataOut,...
    fifoSize);
end


function addOutputFIFOs(hN,streamedOutputs,readySig,fifoSize)
    numOut=numel(streamedOutputs);


    newDataSigs(numOut)=readySig;
    newValidSigs(numOut)=readySig;



    for i=1:numOut
        dataSig=streamedOutputs(i).data.Signal;
        validSig=streamedOutputs(i).valid.Signal;

        newDataSigs(i)=hN.addSignal(dataSig);
        newValidSigs(i)=hN.addSignal(validSig);


        dataDrivingPort=dataSig.getDrivers;
        dataSig.disconnectDriver(dataDrivingPort);
        newDataSigs(i).addDriver(dataDrivingPort);


        validDrivingPort=validSig.getDrivers;
        validSig.disconnectDriver(validDrivingPort);
        newValidSigs(i).addDriver(validDrivingPort);
    end


    createOutputFIFONIC(hN,streamedOutputs,...
    newDataSigs,newValidSigs,readySig,fifoSize);
end


function hNIC=createOutputFIFONIC(hTopN,streamedOutputs,...
    topInputDataSigs,topInputValidSigs,topReadySig,fifoSize)
    numStreamedOut=numel(streamedOutputs);
    numNwIn=numStreamedOut*3;
    numNwOut=numStreamedOut*2+1;

    rate=topReadySig.SimulinkRate;


    inputNames=cell(1,numNwIn);
    inputTypes=repmat(pir_boolean_t,1,numNwIn);
    inputRates=repmat(rate,1,numNwIn);
    outputNames=cell(1,numNwOut);
    outputTypes=repmat(pir_boolean_t,1,numNwOut);
    outputRates=repmat(rate,1,numNwOut);

    topInSigs(numNwIn)=topReadySig;
    topOutSigs(numNwOut)=topReadySig;
    topOutSigs(1)=topReadySig;

    outputNames{1}='ready';

    for i=1:numStreamedOut
        dataSig=streamedOutputs(i).data.Signal;
        name=dataSig.Name;
        baseNwInIdx=(i-1)*3+1;
        baseNwOutIdx=i*2;

        inputNames{baseNwInIdx}=[name,'_in'];
        inputNames{baseNwInIdx+1}=[name,'_valid_in'];
        inputNames{baseNwInIdx+2}=[name,'_ready'];
        inputTypes(baseNwInIdx)=dataSig.Type;

        outputNames{baseNwOutIdx}=[name,'_out'];
        outputNames{baseNwOutIdx+1}=[name,'_valid_out'];
        outputTypes(baseNwOutIdx)=dataSig.Type;

        topInSigs(baseNwInIdx)=topInputDataSigs(i);
        topInSigs(baseNwInIdx+1)=topInputValidSigs(i);
        topInSigs(baseNwInIdx+2)=streamedOutputs(i).ready.Signal;
        topOutSigs(baseNwOutIdx)=dataSig;
        topOutSigs(baseNwOutIdx+1)=streamedOutputs(i).valid.Signal;
    end

    hN=pirelab.createNewNetwork('Network',hTopN,...
    'Name','Output_FIFOs',...
    'InportNames',inputNames,...
    'InportTypes',inputTypes,...
    'InportRates',inputRates,...
    'OutportNames',outputNames,...
    'OutportTypes',outputTypes,...
    'OutportRates',outputRates);
    hTopN.copyOptimizationOptions(hN,false);
    hNIC=pirelab.instantiateNetwork(hTopN,hN,...
    topInSigs,topOutSigs,'Output_FIFOs');


    readyOutSig=hN.PirOutputSignals(1);
    hasSpaceSigs(numStreamedOut)=readyOutSig;

    for i=1:numStreamedOut
        baseNwInIdx=(i-1)*3+1;
        baseNwOutIdx=i*2;
        name=streamedOutputs(i).data.Signal.Name;

        dataIn=hN.PirInputSignals(baseNwInIdx);
        validIn=hN.PirInputSignals(baseNwInIdx+1);
        readyIn=hN.PirInputSignals(baseNwInIdx+2);

        dataOut=hN.PirOutputSignals(baseNwOutIdx);
        validOut=hN.PirOutputSignals(baseNwOutIdx+1);

        hasSpaceSigs(i)=instantiateOutputFIFO(hN,name,rate,fifoSize,...
        dataIn,validIn,readyIn,readyOutSig,...
        dataOut,validOut);
    end


    pirelab.getLogicComp(hN,hasSpaceSigs,readyOutSig,'and');
end


function topHasSpaceOut=instantiateOutputFIFO(hTopN,name,rate,fifoSize,...
    topDataIn,topValidIn,topReadyIn,topEnableSig,...
    topDataOut,topValidOut)

    hN=pirelab.createNewNetwork('Network',hTopN,...
    'Name','Output_FIFOs',...
    'InportNames',{[name,'_in'],'valid_in','ready_in','enable_sig'},...
    'InportTypes',[topDataIn.Type,pir_boolean_t,pir_boolean_t,pir_boolean_t],...
    'InportRates',repmat(rate,1,4),...
    'OutportNames',{[name,'_out'],'valid_out','has_space'},...
    'OutportTypes',[topDataOut.Type,pir_boolean_t,pir_boolean_t],...
    'OutportRates',repmat(rate,1,3));
    hTopN.copyOptimizationOptions(hN,false);

    topHasSpaceOut=addSignal(hTopN,pir_boolean_t,[name,'_buffer_has_space'],rate);
    pirelab.instantiateNetwork(hTopN,hN,...
    [topDataIn,topValidIn,topReadyIn,topEnableSig],...
    [topDataOut,topValidOut,topHasSpaceOut],...
    [name,'_FIFO']);

    [dataIn,validIn,readyIn,enableSig]=dealArr(hN.PirInputSignals);
    [dataOut,validOut,hasSpaceOut]=dealArr(hN.PirOutputSignals);




    realValidIn=addSignal(hN,pir_boolean_t,'valid',rate);
    pirelab.getLogicComp(hN,[validIn,enableSig],realValidIn,'and');



    emptySig=addSignal(hN,pir_boolean_t,'buffer_empty',rate);
    hasDataSig=addSignal(hN,pir_boolean_t,'buffer_has_data',rate);
    pirelab.getLogicComp(hN,emptySig,hasDataSig,'not');
    pirelab.getLogicComp(hN,[readyIn,hasDataSig],validOut,'and');

    fullSig=addSignal(hN,pir_boolean_t,'buffer_full',rate);
    pirelab.getLogicComp(hN,fullSig,hasSpaceOut,'not');

    createFIFOComps(hN,...
    [dataIn,realValidIn,validOut],[dataOut,emptySig,fullSig],...
    fifoSize);
end



function addEnablePort(hNIC,enbSig)

    rate=enbSig.SimulinkRate;

    smpNetwork=hNIC.ReferenceNetwork;
    enbSigNw=addSignal(smpNetwork,pir_boolean_t,'enable',rate);
    enbPortNw=smpNetwork.addInputPort('subsystem_enable','enable');
    enbSigNw.addDriver(enbPortNw);

    hNIC.reflectReferenceNetworkInterface;
    enbPort=hNIC.PirInputPorts(enbPortNw.PortIndex+1);
    enbSig.addReceiver(enbPort);
end






function createFIFOComps(hN,hInSigs,hOutSigs,fifoSize)
    needStatusOutSigs=numel(hOutSigs)>1;
    fifoComp=pirelab.getFIFOFWFTComp(hN,hInSigs,hOutSigs,fifoSize,'FIFO','',needStatusOutSigs);
    fifoSizeStr=num2str(fifoSize);

    for i=1:length(fifoComp)
        tag=fifoComp(i).getModelGenForNICTag;


        tag.setLibBlockInfo('hdlsllib/HDL RAMs/HDL FIFO',{...
        'mode','FWFT',...
        'fifo_size',fifoSizeStr,...
        'push_msg','Error',...
        'pop_msg','Error',...
        'show_empty',double(needStatusOutSigs&&i==1),...
        'show_full',double(needStatusOutSigs&&i==1),...
        'show_num',0});
    end
end



function signal=addSignal(nw,type,name,rate)
    signal=nw.addSignal;
    signal.Name=name;
    signal.Type=type;
    signal.SimulinkRate=rate;
end




function varargout=dealArr(arr)
    varargout=cell(1,numel(arr));
    for i=1:numel(arr)
        varargout{i}=arr(i);
    end
end


