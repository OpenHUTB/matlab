function pirAddNetworkPorts(this,hThisNetwork,blockInfo,configManager)






    inportblocks=blockInfo.Inports;
    outportblocks=blockInfo.Outports;
    enablePort=blockInfo.EnablePort;
    stateEnable=blockInfo.StateEnablePort;
    resetPort=blockInfo.ResetPort;
    triggerPort=blockInfo.TriggerPort;
    actionPort=blockInfo.ActionPort;

    if numel([enablePort,triggerPort])>1
        msg=message('hdlcoder:validate:TriggerAndEnableUnsupported',...
        hThisNetwork.Name);
        this.updateChecks(hThisNetwork.Name,'block',msg,'error');
    end


    numPorts=length(inportblocks);
    sortedblks=cell(1,numPorts);
    for ii=1:numPorts
        portnum=str2double(get_param(inportblocks(ii),'Port'));
        sortedblks{portnum}=inportblocks(ii);
    end


    for ii=1:length(sortedblks)
        iph=sortedblks{ii};
        name=getInPortName(iph);
        ip=hThisNetwork.addInputPort(this.validateAndGetName(name));
        setPortImplParams(this,ip,iph,configManager,hThisNetwork);
        addPortComment(ip,iph)

        this.addDutRate(iph);
    end


    numPorts=length(outportblocks);
    sortedblks=cell(1,numPorts);
    for ii=1:numPorts
        portnum=str2double(get_param(outportblocks(ii),'Port'));
        sortedblks{portnum}=outportblocks(ii);
    end


    for ii=1:length(sortedblks)
        oph=sortedblks{ii};
        name=getOutPortName(oph);
        op=hThisNetwork.addOutputPort(this.validateAndGetName(name));
        setPortImplParams(this,op,oph,configManager,hThisNetwork);
        addPortComment(op,oph)

        this.addDutRate(oph);
    end

    if~isempty(enablePort)
        addEnablePort(this,hThisNetwork,enablePort,@(pHandle)pHandle.Enable);
    end

    if~isempty(actionPort)
        hThisNetwork.setHasActionInstances;
        addEnablePort(this,hThisNetwork,actionPort,@(pHandle)pHandle.Ifaction);
    end

    if~isempty(stateEnable)
        addStateEnablePort(this,hThisNetwork,stateEnable);
    end

    if~isempty(resetPort)
        if 2==slfeature('ResettableSubsystem')
            addResetPort(this,hThisNetwork,resetPort);
        else
            msg=message('hdlcoder:validate:ResetPortNotSupported');
            blk=[hThisNetwork.Name,'/',get_param(resetPort,'Name')];
            this.updateChecks(blk,'block',msg,'error');
        end
    end

    if~isempty(triggerPort)
        addTriggerPortPriv(this,hThisNetwork,triggerPort);
    end
end

function setPortImplParams(this,hPort,slPortHandle,configManager,hThisNetwork)
    impl=this.pirGetImplementation(slPortHandle,configManager);
    if isa(impl,'hdldefaults.AbstractPort')
        isTopNetworkPort=strcmp(hThisNetwork.Name,this.SimulinkConnection.System);
        impl.setPortImplParams(hPort,isTopNetworkPort);

        balanceDelaysOff=strcmpi(impl.getImplParams('BalanceDelays'),'off');
        if isTopNetworkPort

            gp=pir;
            if(hPort.isDriver)
                gp.setConstDUTInPort(hPort.PortIndex,balanceDelaysOff);
            else
                gp.setTestpointDUTOutPort(hPort.PortIndex,balanceDelaysOff);
            end
        elseif balanceDelaysOff


            if(hPort.isDriver)
                msg=message('hdlcoder:validate:BalanceDelaysSetOnInternalInPort');
            else
                msg=message('hdlcoder:validate:BalanceDelaysSetOnInternalOutPort');
            end
            blk=[hThisNetwork.Name,'/',hPort.Name];
            this.updateChecks(blk,'block',msg,'warning');
        end
    end
end

function addEnablePort(this,hThisNetwork,enablePort,getHandle)
    checkCtrlPortOnTopDut(this,hThisNetwork);
    name=get_param(enablePort,'Name');
    port=hThisNetwork.addInputPort('subsystem_enable',name);


    this.addDutRate(enablePort);

    parent=get_param(enablePort,'Parent');
    pHandle=get_param(parent,'PortHandles');
    pHandle=getHandle(pHandle);
    pNum=get_param(pHandle,'PortNumber');
    pConnectivity=get_param(parent,'PortConnectivity');

    if pConnectivity(pNum).SrcBlock==-1
        error(message('hdlcoder:validate:EnablePortNotConnected',hThisNetwork.FullPath));
    end
    hsig=this.pirGetSignal(hThisNetwork,enablePort,pHandle);
    hsig.addDriver(port);
end

function addStateEnablePort(this,hThisNetwork,stateEnable)
    checkCtrlPortOnTopDut(this,hThisNetwork);
    name=get_param(stateEnable,'Name');
    port=hThisNetwork.addInputPort('subsystem_state_enable',name);


    this.addDutRate(stateEnable);

    parent=get_param(stateEnable,'Parent');
    pHandle=get_param(parent,'PortHandles');
    pHandle=pHandle.StateEnable;

    hsig=this.pirGetSignal(hThisNetwork,stateEnable,pHandle);
    hsig.addDriver(port);
end

function addResetPort(this,hThisNetwork,resetPort)
    checkCtrlPortOnTopDut(this,hThisNetwork);
    name=get_param(resetPort,'Name');
    port=hThisNetwork.addInputPort('subsystem_sync_reset',name);


    this.addDutRate(resetPort);

    parent=get_param(resetPort,'Parent');
    pHandle=get_param(parent,'PortHandles');
    pHandle=pHandle.Reset;

    hsig=this.pirGetSignal(hThisNetwork,resetPort,pHandle);
    hsig.addDriver(port);
end

function addTriggerPortPriv(this,hThisNetwork,triggerPort)
    checkCtrlPortOnTopDut(this,hThisNetwork);
    port=this.addTriggerPort(hThisNetwork,triggerPort);

    if~isempty(port)

        parent=get_param(triggerPort,'Parent');
        pHandle=get_param(parent,'PortHandles');
        pHandle=pHandle.Trigger;

        hsig=this.pirGetSignal(hThisNetwork,triggerPort,pHandle);
        hsig.addDriver(port);
    end
end

function checkCtrlPortOnTopDut(this,hThisNetwork)
    if this.HDLCoder.AllowBlockAsDUT
        return;
    end
    if strcmp(hThisNetwork.FullPath,this.SimulinkConnection.System)
        if this.HDLCoder.mdlIdx==numel(this.HDLCoder.AllModels)

            this.updateChecks(hThisNetwork.FullPath,'model',...
            message('hdlcoder:validate:topDUT'),'Error');
            error(message('hdlcoder:validate:topDUT'));
        else

            this.updateChecks(hThisNetwork.FullPath,'model',...
            message('hdlcoder:validate:refModelControlPort'),'Error');
            error(message('hdlcoder:validate:refModelControlPort'));
        end
    end
end

function addPortComment(pirPortH,slPortH)
    desc=get_param(slPortH,'Description');
    if~isempty(desc)
        pirPortH.addComment(desc);
    end
end

function name=getInPortName(iph)

    name=get_param(iph,'PortName');

end

function name=getOutPortName(oph)

    name=get_param(oph,'PortName');

end


