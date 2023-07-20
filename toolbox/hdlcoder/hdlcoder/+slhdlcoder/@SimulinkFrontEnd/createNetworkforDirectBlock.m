function hThisNetwork=createNetworkforDirectBlock(this,slName,configManager)


    hPir=this.hPir;
    slbh=get_param(slName,'Handle');
    phan=get_param(slName,'PortHandles');
    blockPath=getfullname(slbh);

    portlist=[phan.Inport,phan.Enable,phan.Trigger,phan.Reset];


    hThisNetwork=pirelab.createNewNetwork('PirInstance',hPir,...
    'Name',blockPath,...
    'NumofInports',numel(portlist),...
    'NumofOutports',numel(phan.Outport));
    hThisNetwork.FullPath=blockPath;
    hThisNetwork.SimulinkHandle=slbh;

    blockInfo=struct('Inports',[],'Outports',[],'EnablePort',[],...
    'ActionPort',[],'StateControl',[],'StateEnablePort',[],...
    'ResetPort',[],'TriggerPort',[],'SyntheticBlocks',[],'OtherBlocks',[]);
    blockInfo.OtherBlocks=slbh;


    this.blockInstantiation(slbh,blockInfo,configManager,hThisNetwork);
    hC=hThisNetwork.findComponent('sl_handle',slbh);



    for ii=1:numel(portlist)
        oportHandle=portlist(ii);
        hsig=pirGetSignal(this,hThisNetwork,slbh,oportHandle);
        hsig.SimulinkHandle=-1;
        hsig.addDriver(hThisNetwork,ii-1);
        hsig.addReceiver(hC,ii-1);
    end


    for ii=1:numel(phan.Outport)
        oportHandle=phan.Outport(ii);
        hsig=pirGetSignal(this,hThisNetwork,slbh,oportHandle);
        hsig.SimulinkHandle=-1;
        hsig.addReceiver(hThisNetwork,ii-1);
        hsig.addDriver(hC,ii-1);
    end

end

