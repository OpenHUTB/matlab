function hC=pirAddComponent(this,slbh,hThisNetwork)







    blkName=get_param(slbh,'Name');
    blkPath=getfullname(slbh);

    phan=get(slbh,'PortHandles');
    nin=length(phan.Inport);
    nout=length(phan.Outport);

    if~isempty(phan.State)
        nout=nout+length(phan.State);
    end

    blkTag=hdlgetblocklibpath(slbh);
    if isempty(blkTag)
        msgobj=message('hdlcoder:engine:MissingBlkTag',strrep(blkName,newline,' '));
        this.updateChecks(blkPath,'block',msgobj,'Warning');
    end

    hC=hThisNetwork.addComponent('block_comp',nin,nout,blkTag);
    hC.Name=this.validateAndGetName(blkName);
    hC.SimulinkHandle=slbh;


    this.addDutRate(slbh);


    if~isempty(phan.Trigger)
        triggerPort=find_system(slbh,'SearchDepth',1,'LookUnderMasks','all',...
        'BlockType','TriggerPort');
        this.addTriggerPort(hC,triggerPort);
    end
end
