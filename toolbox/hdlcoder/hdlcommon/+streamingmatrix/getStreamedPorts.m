



















function portInfo=getStreamedPorts(hN)

    inAreNonStreamed=true(1,numel(hN.PirInputPorts));
    outAreNonStreamed=true(1,numel(hN.PirOutputPorts));

    [streamedInPorts,externalDelayInPorts,inAreNonStreamed,outAreNonStreamed]=...
    partitionPorts(hN.PirInputPorts,inAreNonStreamed,outAreNonStreamed,true);

    [streamedOutPorts,externalDelayOutPorts,outAreNonStreamed,inAreNonStreamed]=...
    partitionPorts(hN.PirOutputPorts,outAreNonStreamed,inAreNonStreamed,false);



    nonStreamedInPorts=hN.PirInputPorts(inAreNonStreamed);
    nonStreamedOutPorts=hN.PirOutputPorts(outAreNonStreamed);

    portInfo=streamingmatrix.AllPortInfo;
    portInfo.streamedInPorts=streamedInPorts;
    portInfo.streamedOutPorts=streamedOutPorts;
    portInfo.nonStreamedInPorts=nonStreamedInPorts;
    portInfo.nonStreamedOutPorts=nonStreamedOutPorts;
    portInfo.externalDelayPorts=...
    reconcileExternalDelayPorts(externalDelayInPorts,externalDelayOutPorts);
end


function[streamedPorts,externalDelayPorts,primaryAreNonStreamed,otherAreNonStreamed]=...
    partitionPorts(primaryPorts,primaryAreNonStreamed,otherAreNonStreamed,primaryAreInput)


    streamedPorts=repmat(streamingmatrix.StreamedPortInfo,1,numel(primaryPorts));
    streamedPortIdx=1;

    externalDelayPorts=repmat(streamingmatrix.StreamedPortInfo,1,numel(primaryPorts));
    externalDelayPortIdx=1;

    for i=1:numel(primaryPorts)
        pt=primaryPorts(i);

        if pt.hasStreamingMatrixTag
            tag=pt.getStreamingMatrixTag;
            streamedPorts(streamedPortIdx).data=pt;
            primaryAreNonStreamed(i)=false;



            if tag.hasValidPort
                validPt=tag.getValidPort;
                streamedPorts(streamedPortIdx).valid=validPt;
                primaryAreNonStreamed(validPt.PortIndex+1)=false;
            end



            if tag.hasReadyPort
                readyPt=tag.getReadyPort;
                streamedPorts(streamedPortIdx).ready=readyPt;
                otherAreNonStreamed(readyPt.PortIndex+1)=false;
            end

            streamedPortIdx=streamedPortIdx+1;

        elseif pt.hasExternalDelayTag

            externalDelayPorts(externalDelayPortIdx).data=pt;
            primaryAreNonStreamed(i)=false;


            if~primaryAreInput
                externalDelayPorts(externalDelayPortIdx).valid=primaryPorts(i+1);
                primaryAreNonStreamed(i+1)=false;
            end

            externalDelayPortIdx=externalDelayPortIdx+1;
        end
    end


    streamedPorts(streamedPortIdx:end)=[];
    externalDelayPorts(externalDelayPortIdx:end)=[];
end

function externalDelayInfo=reconcileExternalDelayPorts(inDelays,outDelays)
    assert(numel(inDelays)==numel(outDelays));

    externalDelayInfo=repmat(streamingmatrix.ExternalDelayPortInfo,1,numel(inDelays));

    for i=1:numel(inDelays)
        inPort=inDelays(i).data;
        outPort=outDelays(i).data;
        assert(inPort.hasExternalDelayTag&&outPort.hasExternalDelayTag);

        inDelayTag=inPort.getExternalDelayTag;
        outDelayTag=outPort.getExternalDelayTag;
        assert(inDelayTag.getDelay==outDelayTag.getDelay);

        externalDelayInfo(i).inPort=inDelays(i);
        externalDelayInfo(i).outPort=outDelays(i);
        externalDelayInfo(i).delayLength=inDelayTag.getDelay;
    end
end
