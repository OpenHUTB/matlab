function connectCopiedSignal(blkHandle,portIndex,isStatePort)



    if~Simulink.scopes.LAScope.isLogicAnalyzerAvailable()
        return;
    end


    instSig=getInstSigWithBlockPath(blkHandle);
    if validInstSigRebound(instSig)&&instSig.isGivenPortObserved(blkHandle,portIndex)
        sigSpec=instSig.get(1);
    else
        blkName=get_param(blkHandle,'Name');
        blkParent=get_param(blkHandle,'Parent');
        blkPath=[blkParent,'/',blkName];
        ports=get_param(blkHandle,'PortHandles');
        if isStatePort
            statePort=ports.State;

            portHandle=statePort(1);
        else
            outPorts=ports.Outport;
            portHandle=outPorts(portIndex);
        end
        sigName=get(portHandle,'Name');
        sigSpec=Simulink.sdi.internal.SignalObserverMenu.locGetSigSpec(blkHandle,...
        portIndex,blkPath,sigName,portHandle);
    end

    sigSpec=sigSpec.updatePortHandle();
    model=get_param(bdroot(blkHandle),'Name');
    lacosi=Simulink.scopes.LAScope.getLogicAnalyzer(model);
    lacosi.updateBoundSignals(sigSpec,[]);

end

function instSig=getInstSigWithBlockPath(blkHandle)
    instSig=Simulink.HMI.InstrumentedSignals(get_param(bdroot(blkHandle),'Name'));
    instSignals=get_param(bdroot(blkHandle),'InstrumentedSignals');
    if~isempty(instSignals)

        blkName=get_param(blkHandle,'Name');
        blkParent=get_param(blkHandle,'Parent');
        blkPath=[blkParent,'/',blkName];

        blkPath=strrep(blkPath,newline,' ');

        lenInstSignals=instSignals.Count;
        for idx=1:lenInstSignals
            sig=get(instSignals,idx,true);
            if strcmp(sig.BlockPath_,blkPath)
                sigSpec=Simulink.HMI.SignalSpecification(sig);
                instSig.add(sigSpec);
                return;
            end
        end
    end
end

function validInstSig=validInstSigRebound(instSig)
    validInstSig=~isempty(instSig)&&instSig.Count>0;
    if validInstSig
        instSig.applyRebindingRules;
    end
end
