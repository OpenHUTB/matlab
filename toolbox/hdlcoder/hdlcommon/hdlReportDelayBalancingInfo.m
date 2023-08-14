function lat=hdlReportDelayBalancingInfo(p,needsMessage)




    lat=0;
    currentDriver=hdlcurrentdriver;
    hN=p.getTopNetwork;
    outs=hN.NumberOfPirOutputPorts;

    maxLatency=0;
    maxEnabledLatency=0;
    latencies=zeros(1,outs);
    enbdLatencies=zeros(1,outs);

    streamInfo=streamingmatrix.getStreamedPorts(hN);

    for ii=0:outs-1
        lat=p.getDutExtraLatency(ii);
        enbdLat=p.getDutExtraEnabledLatency(ii);

        if isStreamedPort(hN.PirOutputPorts(ii+1),streamInfo)


            lat=lat+6;
        end

        latencies(ii+1)=lat;
        enbdLatencies(ii+1)=enbdLat;

        if lat>maxLatency
            maxLatency=lat;
        end

        if enbdLat>maxEnabledLatency
            maxEnabledLatency=enbdLat;
        end
    end

    if maxLatency>0||maxEnabledLatency>0
        if needsMessage
            hdldisp(message('hdlcoder:hdldisp:DelayBalanceInfo1'));
            hdldisp(message('hdlcoder:hdldisp:DelayBalanceInfo2'));
        end
        hdldisp(message('hdlcoder:hdldisp:DelayBalanceMoreLatency'));

        gp=pir();
        if gp.hasTestpointUnmatchedDelays


            hdldisp(message('hdlcoder:hdldisp:DelayBalanceDiffLatency'));
        end
        for ii=1:outs
            portStr=sprintf('%d',ii);
            latencyStr=sprintf('%d',latencies(ii));

            hdldisp(message('hdlcoder:hdldisp:DelayBalanceLatency',portStr,latencyStr));

            if enbdLatencies(ii)>0
                enbdLatencyStr=sprintf('%d',enbdLatencies(ii));
                hdldisp(message('hdlcoder:hdldisp:DelayBalanceEnabledLatency',portStr,enbdLatencyStr));
            end
        end
    end


    if targetcodegen.targetCodeGenerationUtils.isNFPMode()
        gp=pir();
        gp.setDutMaxLatency(maxLatency);
        if(maxLatency>1e06)
            error(message('hdlcoder:hdldisp:HighDBLatencyError',sprintf('%d',maxLatency)));
        end
    end

    phaseCycles=zeros(1,outs);

    if p.hasPhaseOffsetCRPports
        hdldisp(message('hdlcoder:hdldisp:ClockRatePipeliningPhase'));
        for i=0:outs-1
            ph=p.getOutputPortPhase(i);
            phaseCycles(i+1)=ph;
            if ph>0
                hdldisp(message('hdlcoder:hdldisp:CRPPhase',sprintf('%d',i+1),sprintf('%d',ph)));
            end
        end
    else


        if~isempty(latencies)
            latencies=latencies(1);
            enbdLatencies=enbdLatencies(1);
        end
    end

    currentDriver.cgInfo.latency=latencies;
    currentDriver.cgInfo.phaseCycles=phaseCycles;
    currentDriver.cgInfo.enabledLatency=enbdLatencies;
end

function isit=isStreamedPort(hP,streamInfo)
    if hP.hasStreamingMatrixTag
        isit=true;
    else
        isit=false;
        portIdx=hP.PortIndex;

        for i=1:numel(streamInfo.streamedOutPorts)
            outInfo=streamInfo.streamedOutPorts(i);
            if portIdx==outInfo.valid.PortIndex
                isit=true;
                return;
            end
        end

        for i=1:numel(streamInfo.streamedInPorts)
            inInfo=streamInfo.streamedInPorts(i);
            if isa(inInfo.ready,'hdlcoder.port')&&portIdx==inInfo.ready.PortIndex
                isit=true;
                return;
            end
        end
    end
end


