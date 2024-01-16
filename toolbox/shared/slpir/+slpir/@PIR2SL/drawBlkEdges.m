function drawBlkEdges(this,mdlFile,hN)

    this.genmodeldisp(sprintf('Drawing block edges...'),3);
    slAutoRoute=strcmpi(this.AutoRoute,'yes')&&strcmpi(this.AutoPlace,'yes');
    pathName=mdlFile;
    vSignals=hN.Signals;
    numSignals=length(vSignals);

    for i=1:numSignals
        hS=vSignals(i);
        numDrivers=hS.NumberOfDrivers;
        vDrvPorts=hS.getDrivers;
        numRecvrs=hS.NumberOfReceivers;
        vRcvPorts=hS.getReceivers;

        for j=1:numDrivers
            hDrvP=vDrvPorts(j);
            if hDrvP.isSubsystemEnable||...
                (hDrvP.isSubsystemTrigger&&~this.isSFNetwork(hN.SimulinkHandle))||...
                hDrvP.isSubsystemSyncReset||...
                hDrvP.isSubsystemAction

                continue;
            end

            hDrvPOwner=hDrvP.Owner;

            if~this.shouldDrawComp(hDrvPOwner)
                continue;
            end

            if hDrvP.isNetworkPort

                drvPortName=hDrvP.Name;
                drvPortIdx=1;
            else
                drvPortName=hDrvPOwner.Name;
                drvPortIdx=hDrvP.PortIndex+1;

                if hDrvPOwner.getGMHandle>0
                    op=get_param(hDrvPOwner.getGMHandle,'Ports');
                    op=op(2);
                    if(hDrvPOwner.NumberOfPirOutputPorts~=op)&&hDrvP.didPIRPortNumChange
                        drvPortIdx=hDrvP.getOrigPIRPortNum+1;
                        pirPortIdx=hDrvP.PortIndex+1;


                        for portIdx=pirPortIdx:drvPortIdx-1
                            addTerminator(this,drvPortName,portIdx,pathName,slAutoRoute);
                        end


                        if pirPortIdx==hDrvPOwner.NumberOfPirOutputPorts&&hDrvPOwner.SimulinkHandle>0
                            numSLPorts=get_param(hDrvPOwner.SimulinkHandle,'Ports');
                            numSLPorts=numSLPorts(2);

                            for portIdx=drvPortIdx+1:numSLPorts
                                addTerminator(this,drvPortName,portIdx,pathName,slAutoRoute);
                            end
                        end
                    end
                end
            end

            signalWithConflictingNames=[];
            for k=1:numRecvrs
                hRcvP=vRcvPorts(k);
                if hRcvP.isClockBundle()
                    continue;
                end

                hRcvPOwner=hRcvP.Owner;

                if hRcvP.isSubsystemTrigger


                    if isSimulinkFunctionTrigger(hRcvPOwner)
                        continue;
                    end

                end

                if~this.shouldDrawComp(hRcvPOwner)
                    continue;
                end

                try
                    hasPropIOType=isprop(get_param(hDrvPOwner.SimulinkHandle,'Object'),'IOType');
                catch
                    hasPropIOType=false;
                end
                if~hasPropIOType||...
                    (hasPropIOType&&~strcmp(get_param(hDrvPOwner.SimulinkHandle,'IOType'),'siggen'))
                    conflictingName=addLine(this,pathName,hRcvPOwner,hRcvP,hDrvPOwner,drvPortName,...
                    drvPortIdx,slAutoRoute);
                    signalWithConflictingNames=[signalWithConflictingNames,conflictingName];%#ok<AGROW>
                end
            end
            if~isempty(signalWithConflictingNames)


                for l=1:numel(signalWithConflictingNames)
                    set_param(signalWithConflictingNames(l),'Name','');
                end
            end
        end
    end
end


function addTerminator(this,drvPortName,portIdx,pathName,slAutoRoute)

    prefix=[pathName,'/'];
    uniqueName=slpir.PIR2SL.getUniqueName([prefix,drvPortName,num2str(portIdx),'_term']);
    add_block('built-in/Terminator',uniqueName);

    termName=strrep(uniqueName,prefix,'');

    srcPort=sprintf('%s/%d',drvPortName,portIdx);
    dstPort=sprintf('%s/%d',termName,1);

    if slAutoRoute
        add_line(pathName,srcPort,dstPort,'autorouting','on');
    else
        add_line(pathName,srcPort,dstPort);
    end

end


function flag=isSimulinkFunctionTrigger(hC)

    flag=false;
    if~hC.isNetworkInstance
        return;
    end

    hN=hC.ReferenceNetwork;
    comps=hN.Components;
    numComps=length(comps);

    if hN.SimulinkHandle<0
        return;
    end

    for i=1:numComps
        curcmp=comps(i);
        sl=curcmp.SimulinkHandle;
        if~isa(curcmp,'hdlcoder.network')&&~curcmp.isAnnotation&&sl>0
            blktype=get_param(sl,'BlockType');
            if strcmp(blktype,'TriggerPort')&&strcmp(get_param(sl,'IsSimulinkFunction'),'on')
                flag=true;
                return;
            end
        end
    end
end



function receiverPortName=getRecvPortName(this,hRcvPOwner,hRcvP)
    if hRcvP.isNetworkPort

        rcvPortName=hRcvP.Name;
        rcvPortIdx='1';
    else
        rcvPortName=hRcvPOwner.Name;
        if hRcvP.isSubsystemEnable
            rcvPortIdx='Enable';
        elseif hRcvP.isSubsystemAction
            rcvPortIdx='Ifaction';
        elseif hRcvP.isSubsystemSyncReset
            rcvPortIdx='Reset';
        elseif hRcvP.isSubsystemTrigger
            if this.isSFNetwork(hRcvPOwner.SimulinkHandle)&&hRcvPOwner.isNetworkInstance
                rcvPortIdx=sprintf('%d',numel(hRcvPOwner.PirInputPorts));
            else
                rcvPortIdx='Trigger';
            end
        elseif hRcvP.isExternalEnable
            rcvPortIdx=sprintf('%d',getExternalEnablePortIdx(hRcvPOwner));
        elseif hRcvP.isExternalSyncReset
            rcvPortIdx=sprintf('%d',getExternalSyncResetPortIdx(hRcvPOwner));
        else
            assert(hRcvP.isData)

            rcvPortIdx=sprintf('%d',hRcvP.getRelativePortNum+1);
        end
    end
    receiverPortName=sprintf('%s/%s',rcvPortName,rcvPortIdx);
end


function signalWithConflictingNames=addLine(this,pathName,hRcvPOwner,hRcvP,...
    hDrvPOwner,drvPortName,drvPortIdx,slAutoRoute)
    srcPort=sprintf('%s/%d',drvPortName,drvPortIdx);
    dstPort=getRecvPortName(this,hRcvPOwner,hRcvP);

    signalWithConflictingNames=[];

    if slAutoRoute
        lineh=add_line(pathName,srcPort,dstPort,'autorouting','on');
    else
        lineh=add_line(pathName,srcPort,dstPort);
    end

    if isBusCreatorComp(hRcvPOwner)&&~isBusSelectorComp(hDrvPOwner)

        if isa(hRcvPOwner.PirOutputSignals.Type,'hdlcoder.tp_record')
            if isempty(hRcvPOwner.PirOutputSignals.Type.MemberNames)
                signalName=hRcvPOwner.PirInputSignals(hRcvP.portindex+1).Name;
            else
                signalName=hRcvPOwner.PirOutputSignals.Type.MemberNames{hRcvP.portindex+1};
            end
            if~isempty(get_param(lineh,'Name'))&&...
                ~strcmp(get_param(lineh,'Name'),signalName)
                signalWithConflictingNames=lineh;
            end
        end
        set_param(lineh,'Name',signalName);
    end
end


function busCreator=isBusCreatorComp(hC)
    busCreator=false;

    if isa(hC,'hdlcoder.buscreator_comp')
        busCreator=true;
    elseif isa(hC,'hdlcoder.black_box_comp')||isa(hC,'hdlcoder.block_comp')
        slbh=hC.SimulinkHandle;
        if isValidHandle(slbh)&&strcmp(get_param(slbh,'BlockType'),'BusCreator')
            busCreator=true;
        end
    end
end



function busSelector=isBusSelectorComp(hC)
    busSelector=false;

    if isa(hC,'hdlcoder.busselector_comp')
        busSelector=true;
    elseif isa(hC,'hdlcoder.black_box_comp')||isa(hC,'hdlcoder.block_comp')
        slbh=hC.SimulinkHandle;
        if isValidHandle(slbh)&&strcmp(get_param(slbh,'BlockType'),'BusSelector')
            busSelector=true;
        end
    end
end


function valid=isValidHandle(slbh)

    valid=false;

    if~isempty(slbh)&&slbh>0
        valid=true;
    end

end


function portIdx=getExternalEnablePortIdx(hC)
    assert(isa(hC,'hdlcoder.unitdelayenabledresettable_comp')||...
    isa(hC,'hdlcoder.integerdelayenabledresettable_comp')||...
    isa(hC,'hdlcoder.tappeddelayenabledresettable_comp'));

    hasExtEnable=hC.getHasExternalEnable;
    hasExtSyncReset=hC.getHasExternalSyncReset;

    if hasExtEnable&&hasExtSyncReset
        delayType=hdldelaytypeenum.DelayEnabledResettable;
    elseif hasExtEnable&&~hasExtSyncReset
        delayType=hdldelaytypeenum.DelayEnabled;
    elseif~hasExtEnable&&hasExtSyncReset
        delayType=hdldelaytypeenum.DelayResettable;
    else
        delayType=hdldelaytypeenum.Delay;
    end
    [~,portIdx,~]=delayType.getEnbSignals(hC.PirInputSignals);
end


function portIdx=getExternalSyncResetPortIdx(hC)
    assert(isa(hC,'hdlcoder.unitdelayenabledresettable_comp')||...
    isa(hC,'hdlcoder.integerdelayenabledresettable_comp')||...
    isa(hC,'hdlcoder.tappeddelayenabledresettable_comp'));

    hasExtEnable=hC.getHasExternalEnable;
    hasExtSyncReset=hC.getHasExternalSyncReset;

    if hasExtEnable&&hasExtSyncReset
        delayType=hdldelaytypeenum.DelayEnabledResettable;
    elseif hasExtEnable&&~hasExtSyncReset
        delayType=hdldelaytypeenum.DelayEnabled;
    elseif~hasExtEnable&&hasExtSyncReset
        delayType=hdldelaytypeenum.DelayResettable;
    else
        delayType=hdldelaytypeenum.Delay;
    end
    [~,portIdx]=delayType.getRstSignal(hC.PirInputSignals);
end




