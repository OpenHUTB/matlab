function this=enableLoggingOnPort(this,...
    bpath,...
    bEnable,...
    sigType,...
    bRecurse,...
    linksOpt,...
    maskOpt)












    len=bpath.getLength();
    if len<1
        return;
    end
    subsys=bpath.getBlock(len);


    if strcmp(sigType,'bounds')

        blks=Simulink.SimulationData.ModelLoggingInfo.utFindBlocksInModel(...
        subsys,...
        'AllVariants',...
        'on',...
        linksOpt,...
        maskOpt,...
        bRecurse,...
        'Inport');


        outports=Simulink.SimulationData.ModelLoggingInfo.utFindBlocksInModel(...
        subsys,...
        'AllVariants',...
        'on',...
        linksOpt,...
        maskOpt,...
        bRecurse,...
        'Outport');
        for idx=1:length(outports)
            ph=get_param(outports{idx},'PortHandles');
            line=get_param(ph.Inport,'Line');
            if ishandle(line)
                srcBlk=get_param(line,'SrcBlockHandle');
                if ishandle(srcBlk)
                    srcBlk=get_param(srcBlk,'Object');
                    blks=[blks;srcBlk.getFullName];%#ok<AGROW>
                end
            end
        end
    else
        blks=Simulink.SimulationData.ModelLoggingInfo.utFindBlocksInModel(...
        subsys,...
        'AllVariants',...
        'on',...
        linksOpt,...
        maskOpt,...
        bRecurse);
    end



    bNamedOnly=strcmp(sigType,'named');
    bUnnamedOnly=strcmp(sigType,'unnamed');
    if bEnable
        logStr='on';
    else
        logStr='off';
    end


    for idx=1:length(blks)


        ph=get_param(blks{idx},'PortHandles');
        for pIdx=1:length(ph.Outport)


            if strcmpi(...
                get_param(ph.Outport(pIdx),'DataLogging'),...
                logStr)
                continue;
            end


            if bNamedOnly||bUnnamedOnly
                bIsNamed=...
                ~isempty(get_param(ph.Outport(pIdx),'Name'));
                if bIsNamed~=bNamedOnly
                    continue;
                end
            end


            set_param(ph.Outport(pIdx),'DataLogging',logStr);


            if~bEnable
                pos=this.findSignal(blks{idx},pIdx);
                if~isempty(pos)
                    this.signals_(pos)=[];
                    if isempty(this.signals_)
                        this.signals_=...
                        Simulink.SimulationData.SignalLoggingInfo.empty;
                    end
                end
            end

        end
    end

end
