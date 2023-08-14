function verifyTaskManagerConnections(taskMgr)




    errorIfTaskConnectedToTerminator(taskMgr);
    errorIfTasksConnectionsNotLegal(taskMgr);
    errorIfConcurrencySettingInvalid(taskMgr);
end


function errorIfTaskConnectedToTerminator(taskMgr)
    import soc.internal.connectivity.*
    ports=getTaskManagerFcnCallPorts(taskMgr);
    for i=1:numel(ports)
        dstBlock=ports(i).DstBlock;
        if~isempty(dstBlock)
            if isequal(get_param(dstBlock,'BlockType'),'Terminator')
                error(message('soc:scheduler:TaskMgrTerminated'));
            end
        end
    end
end


function errorIfTasksConnectionsNotLegal(taskMgr)
    import soc.internal.connectivity.*
    outPorts=getSystemOutputPorts(taskMgr);
    mdlHdl=[];
    for i=1:numel(outPorts)
        portHdl=get_param(outPorts(i),'Handle');
        [blkh,dstBlkType]=getModelConnectedToTaskManagerPort(portHdl);
        if iscell(dstBlkType)
            error(message('soc:scheduler:TaskManagerUnexpectedTwoBlocks'));
        end
        switch dstBlkType
        case ''

        case 'Terminator'

        case 'SubSystem'

        case 'FunctionCallSplit'
            error(message('soc:scheduler:TaskMgrFcnCallSplit'));
        case 'ModelReference'
            mdlHdl=[mdlHdl,blkh];%#ok<AGROW>
            uniqHdls=unique(mdlHdl);
            if numel(uniqHdls)>1
                error(message('soc:scheduler:TaskMgrDrivesMultipleModels'));
            end
        otherwise
            error(message('soc:scheduler:TaskManagerUnexpectedBlock',...
            dstBlkType));
        end
    end
end


function errorIfConcurrencySettingInvalid(taskMgr)
    modelName=bdroot(taskMgr);
    if strcmpi(get_param(taskMgr,"EnableTaskSimulation"),'off'),return;end
    if isnumeric(modelName),modelName=get_param(modelName,'Name');end
    if~isequal(get_param(modelName,'ConcurrentTasks'),'on')
        dm=soc.internal.TaskManagerData(get_param(taskMgr,'AllTaskData'),...
        'evaluate',modelName);
        allTaskNames=dm.getTaskNames;
        taskCoreNums=zeros(1,numel(allTaskNames));
        for i=1:numel(allTaskNames)
            taskData=dm.getTask(allTaskNames{i});
            taskCoreNums(i)=taskData.coreNum;
        end
        if~isscalar(unique(taskCoreNums))
            taskMgrPath=soc.blkcb.cbutils('GetBlkPath',taskMgr);
            error(message('soc:scheduler:ConcurrentTaskMustBeOn',taskMgrPath,modelName));
        end
    end
end