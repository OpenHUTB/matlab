function mdl=getModelConnectedToTaskManager(tskMgrBlk)




    import soc.internal.connectivity.*

    dstBlk=[];
    outPorts=getSystemOutputPorts(tskMgrBlk);
    for i=1:numel(outPorts)
        portHdl=get_param(outPorts(i),'Handle');
        [dstBlk,dstBlkType]=getModelConnectedToTaskManagerPort(portHdl{1});
        if isequal(dstBlkType,'ModelReference'),break;end
    end
    mdl=dstBlk;
end