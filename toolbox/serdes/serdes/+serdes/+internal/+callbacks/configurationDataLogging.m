function configurationDataLogging(model,state)
    mws=get_param(model,'ModelWorkspace');
    requiredMWSElements=["TxTree","RxTree","SerdesIBIS"];
    if isempty(mws)||~all(arrayfun(@(x)mws.hasVariable(x),requiredMWSElements))
        return
    end

    rxBlock=[model,'/Rx'];
    rxPorts=get_param(rxBlock,'PortHandles');
    if~isempty(rxPorts)
        if strcmp(state,'off')
            disableLogging(rxPorts.Outport(1),'rxOut');
        else
            enableLogging(rxPorts.Outport(1),'rxOut');
        end
    end
    clockBlockSFun=find_system(rxBlock,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'SearchDepth',4,'LookUnderMasks','all','FollowLinks','on','FunctionName','clock_times_writer');
    triggeredSubsystems=get_param(clockBlockSFun,'Parent');
    clockTimeBlocks=get_param(triggeredSubsystems,'Parent');
    isIBISAMIBlock=strcmp(cellfun(@serdes.internal.callbacks.getLibraryBlockType,clockTimeBlocks,'UniformOutput',false),'IBIS_clock');

    for clkBlockIdx=1:size(clockTimeBlocks)
        if clkBlockIdx==1
            if isIBISAMIBlock(clkBlockIdx)

                if strcmp(state,'on')
                    modIBISAMIClockTimes(clockTimeBlocks{clkBlockIdx},'off');
                end
                modIBISAMIClockTimes(triggeredSubsystems{clkBlockIdx},state);
            else
                modClockbus2Clocktime(clockTimeBlocks{clkBlockIdx},state);
            end
        else
            if isIBISAMIBlock(clkBlockIdx)
                modIBISAMIClockTimes(triggeredSubsystems{clkBlockIdx},'off');
            else
                modClockbus2Clocktime(clockTimeBlocks{clkBlockIdx},'off');
            end
        end
    end
end


function setLogging(port,state,mode,name)
    set_param(port,'DataLogging',state);
    set_param(port,'DataLoggingNameMode',mode);
    set_param(port,'DataLoggingName',name);
end


function[state,mode,name]=getLogging(port)
    state=get_param(port,'DataLogging');
    mode=get_param(port,'DataLoggingNameMode');
    name=get_param(port,'DataLoggingName');
end


function disableLogging(port,name)
    [loggingState,loggingMode,loggingName]=getLogging(port);

    if strcmp(loggingState,'on')&&strcmp(loggingMode,'Custom')&&strcmp(loggingName,name)

        setLogging(port,'off','SignalName','');
    end
end


function enableLogging(port,name,varargin)
    if nargin>2
        suppressWarning=varargin{1};
    else
        suppressWarning=false;
    end
    [loggingState,loggingMode,loggingName]=getLogging(port);

    if strcmp(loggingState,'on')&&...
        (~strcmp(loggingMode,'Custom')||...
        (strcmp(loggingMode,'Custom')&&~strcmp(loggingName,name)))
        if strcmp(name,'rxOut')
            location='Rx WaveOut';
        else
            location=name;
        end
        if~suppressWarning
            warning(message('serdes:callbacks:OverridingUserLogging',location));
        end
    end
    setLogging(port,'on','Custom',name);
end


function modClockbus2Clocktime(block,state)
    busSelector=find_system(block,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'SearchDepth',2,'LookUnderMasks','all','FollowLinks','on','BlockType','BusSelector');
    lockedLibrary=strcmp(get_param(block,'LinkStatus'),'resolved');
    if size(busSelector,1)==1
        busSelectorPorts=get_param(busSelector{1},'PortHandles');
        if~isempty(busSelectorPorts)
            if strcmp(state,'off')
                disableLogging(busSelectorPorts.Outport(1),'clockValidOnRising');
                disableLogging(busSelectorPorts.Outport(2),'clockTime');
            else
                enableLogging(busSelectorPorts.Outport(1),'clockValidOnRising',lockedLibrary);
                enableLogging(busSelectorPorts.Outport(2),'clockTime',lockedLibrary);
            end
        end
    end
end


function modIBISAMIClockTimes(block,state)
    inportConnectivity=get_param(block,'PortConnectivity');

    triggerPort=0;
    hasTrigger=false;
    for inportIdx=1:size(inportConnectivity,1)
        if strcmp(inportConnectivity(inportIdx).Type,'trigger')
            triggerPort=inportIdx;
            hasTrigger=true;
            break
        end
    end

    if~isempty(inportConnectivity)
        clockSignalNames={'clockValidOnRising','clockTime'};
        for inportIdx=1:2
            clockConnectedBlock=inportConnectivity(inportIdx).SrcBlock;
            clockConnectedSrcPort=inportConnectivity(inportIdx).SrcPort+1;

            if~hasTrigger
                clockSignalName=clockSignalNames{inportIdx};
            else

                if inportIdx==triggerPort
                    clockSignalName=clockSignalNames{1};
                else
                    clockSignalName=clockSignalNames{2};
                end
            end
            if~isempty(clockConnectedBlock)&&~isempty(clockConnectedSrcPort)
                clockConnectedBlockPortHandles=get_param(clockConnectedBlock,'PortHandles');
                if~isempty(clockConnectedBlockPortHandles)
                    clockConnectedBlockOutport=clockConnectedBlockPortHandles.Outport(clockConnectedSrcPort);
                    if strcmp(state,'off')
                        disableLogging(clockConnectedBlockOutport,clockSignalName);
                    else
                        enableLogging(clockConnectedBlockOutport,clockSignalName,hasTrigger);
                    end
                end
            end
        end
    end
end
