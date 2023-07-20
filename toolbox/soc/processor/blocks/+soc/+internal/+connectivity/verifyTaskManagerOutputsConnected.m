function verifyTaskManagerOutputsConnected(taskMgr)





    import soc.internal.connectivity.*
    outPorts=getSystemOutputPorts(taskMgr);
    for i=1:numel(outPorts)
        portHdl=get_param(outPorts(i),'Handle');
        [~,dstBlkType]=getModelConnectedToTaskManagerPort(portHdl);
        if iscell(dstBlkType),continue;end
        if isempty(dstBlkType)
            error(message('soc:scheduler:TaskManagerUnconnectedTask'));
        end
    end
end
