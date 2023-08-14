function v=validateBlock(this,hC)%#ok<INUSL>


    v=hdlvalidatestruct;



    try
        entity_name='';
        blkFullPath=getfullname(hC.SimulinkHandle);
        entity_name=hdlget_param(blkFullPath,'EntityName');
    catch mEx

    end
    if isempty(entity_name)
        entity_name='';
    end

    hPir=pir;
    if(strcmp(entity_name,'*')||(hPir.isReservedWord(entity_name)))
        errorStatus=1;
        msgObj=message('hdlcoder:validate:BBoxEntityNameError',blkFullPath,entity_name);
        v=hdlvalidatestruct(errorStatus,...
        msgObj);
        return
    end


    if(hC.SimulinkHandle==-1)
        return
    end

    if strcmp(get_param(blkFullPath,'BlockType'),'ModelReference')
        blkFullPath=get_param(blkFullPath,'ModelName');
        load_system(blkFullPath);
    end

    v=checkForCtlPortOnBBoxSS(this,blkFullPath,v);

    inports=find_system(blkFullPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','BlockType','Inport');
    for ii=1:numel(inports)
        inport=inports(ii);
        if iscell(inport)
            inport=inport{1};
        end
        blkType=get_param(inport,'BlockType');
        inportObj=get_param(inport,'Object');
        isBusElem=inportObj.IsBusElementPort();
        if strcmp(blkType,'Inport')&&strcmp(isBusElem,'on')
            v=[v,reportErrorForBlackBoxWithBusElementPorts];
        end
    end

    outports=find_system(blkFullPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','BlockType','Outport');
    for ii=1:numel(outports)
        outport=outports(ii);
        if iscell(outport)
            outport=outport{1};
        end
        blkType=get_param(outport,'BlockType');
        outportObj=get_param(outport,'Object');
        isBusElem=outportObj.IsBusElementPort();
        if strcmp(blkType,'Outport')&&strcmp(isBusElem,'on')
            v=[v,reportErrorForBlackBoxWithBusElementPorts];
        end
    end



    if~hdlgetparameter('balancedelays')&&~isempty(this.getImplParams('ImplementationLatency'))&&...
        (this.getImplParams('ImplementationLatency')>0)
        if~isempty(this.getImplParams('AllowDistributedPipelining'))&&...
            strcmp(this.getImplParams('AllowDistributedPipelining'),'on')
            msgObj=message('hdlcoder:validate:BlackBoxAllowDistribPipeline');
            errorStatus=1;
            v=hdlvalidatestruct(errorStatus,msgObj);
        end
    end
end

function v=reportErrorForBlackBoxWithBusElementPorts()
    msgObj=message('hdlcoder:validate:BlackBoxHavingBusElementPorts');
    errorStatus=1;
    v=hdlvalidatestruct(errorStatus,msgObj);
end

function v=checkForCtlPortOnBBoxSS(~,blockPath,v)
    enbblk=find_system(blockPath,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','BlockType','EnablePort');
    trgblk=find_system(blockPath,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','BlockType','TriggerPort');
    rstblk=find_system(blockPath,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','BlockType','ResetPort');

    if~isempty([enbblk;trgblk;rstblk])
        msgObj=message('hdlcoder:validate:BBoxCtlPort');
        errorStatus=1;
        v=[v,hdlvalidatestruct(errorStatus,msgObj)];
    end
end
