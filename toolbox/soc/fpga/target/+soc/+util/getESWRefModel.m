function[taskMgrBlks,varargout]=getESWRefModel(sys)
    if nargout>2
        nargoutchk(1,2);
    end

    taskMgrBlks=soc.internal.connectivity.getTaskManagerBlock(sys,'overrideAssert');
    if isempty(taskMgrBlks)
        refModels='';
    else
        if~iscell(taskMgrBlks)
            refModels=getReferenceModels(taskMgrBlks);
        else
            refModels=cellfun(@(x)getReferenceModels(x),taskMgrBlks,'UniformOutput',false);
        end
    end

    if nargout>1
        varargout{1}=refModels;
    end
end

function ret=getReferenceModels(taskMgrBlk)
    connectedBlkHandle=soc.internal.connectivity.getModelConnectedToTaskManager(taskMgrBlk);
    msle=MSLException([],message('soc:utils:TaskMgrConnToSubsys',getfullname(taskMgrBlk),getfullname(connectedBlkHandle)));
    portH=get_param(taskMgrBlk,'LineHandles');
    allLineHandles=portH.Outport;
    allModelRefs=arrayfun(@(x)get_param(get_param(x,'NonVirtualDstPorts'),'Parent'),allLineHandles,'UniformOutput',false);

    areAllModelRefs=cellfun(@(x)isequal(get_param(x,'BlockType'),'ModelReference'),allModelRefs);
    assert(all(areAllModelRefs),'soc:utils:TaskMgrConnToSubsys',msle.message);
    allBlkNames=cellfun(@(x)get_param(x,'ModelName'),allModelRefs,'UniformOutput',false);
    ret=allBlkNames{1};
end