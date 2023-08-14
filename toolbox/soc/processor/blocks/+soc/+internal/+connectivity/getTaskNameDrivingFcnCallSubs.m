function[name,eventName]=getTaskNameDrivingFcnCallSubs(topMdl,theSysHandle)




    triggPorts=find_system(theSysHandle,'FollowLinks','on',...
    'SearchDepth',1,'LookUnderMasks','on','BlockType','TriggerPort');
    [name,eventName]=getTaskNameInternal(topMdl,triggPorts);
end


function[name,eventName]=getTaskNameInternal(topMdl,blk)
    name='';
    eventName='';
    mySrcBlk=getMySrcBlock(topMdl,blk);
    idx=[];

    while~isempty(mySrcBlk)&&~isMySrcBlockTaskManager(mySrcBlk)
        blk=mySrcBlk;
        [mySrcBlk,idx]=getMySrcBlock(topMdl,blk);
    end

    if~isempty(mySrcBlk)
        if isempty(idx)
            idx=getTaskIndex(mySrcBlk,blk);
        end
        [name,eventName]=getTaskName(mySrcBlk,idx);
    end
end


function[mySrcBlk,idx]=getMySrcBlock(topMdl,blk)
    idx=[];
    if isequal(get_param(blk,'BlockType'),'TriggerPort')
        mySrcBlk=getMySrcBlockForTriggerPort(blk);
    elseif isequal(get_param(blk,'BlockType'),'Inport')
        [mySrcBlk,idx]=getMySrcBlockForInport(topMdl,blk);
    elseif isequal(get_param(blk,'BlockType'),'AsynchronousTaskSpecification')


        portHandles=get_param(blk,'PortHandles');
        blockPort=get_param(get_param(portHandles.Inport,'Line'),'SrcBlockHandle');
        [mySrcBlk,idx]=getMySrcBlockForInport(topMdl,blockPort);
    else
        mySrcBlk=[];
    end
end


function[mySrcBlk,idx]=getMySrcBlockForInport(topMdl,blk)
    mySrcBlk=[];
    idx=[];
    parent=get_param(blk,'Parent');
    port=get_param(blk,'Port');
    if isequal(get_param(parent,'Type'),'block_diagram')


        mdlRefBlk=find_system(topMdl,'FollowLinks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','on','BlockType',...
        'ModelReference','ModelName',parent);
        conn=get_param(mdlRefBlk{1},'PortConnectivity');
        portHandles=get_param(mdlRefBlk{1},'PortHandles');
        for i=1:numel(conn)
            if~isempty(conn(i).SrcBlock)&&~isequal(conn(i).SrcBlock,-1)&&...
                (isequal(conn(i).Type,port))
                mySrcBlk=conn(i).SrcBlock;
                allTaskMgrPorts=get_param(mySrcBlk,'PortHandles');
                mdlRefPortHandle=portHandles.Inport(i);
                connectedLine=get_param(mdlRefPortHandle,'Line');
                [~,idx]=ismember(get_param(connectedLine,'SrcPortHandle'),allTaskMgrPorts.Outport);
                break
            end
        end
    else
        conn=get_param(parent,'PortConnectivity');
        for i=1:numel(conn)
            if~isempty(conn(i).SrcBlock)&&~isequal(conn(i).SrcBlock,-1)&&...
                (isequal(conn(i).Type,port))
                mySrcBlk=conn(i).SrcBlock;
                break
            end
        end
    end
end


function mySrcBlk=getMySrcBlockForTriggerPort(blk)
    mySrcBlk=[];
    par=get_param(blk,'Parent');
    conn=get_param(par,'PortConnectivity');
    for i=1:numel(conn)
        if~isempty(conn(i).SrcBlock)&&~isequal(conn(i).SrcBlock,-1)&&...
            (isequal(conn(i).Type,'trigger'))
            mySrcBlk=conn(i).SrcBlock;
            break
        end
    end
end


function res=isMySrcBlockTaskManager(blk)
    res=isequal(get_param(blk,'MaskType'),'Task Manager');
end


function idxFound=getTaskIndex(taskMgr,blk)
    blkType=get_param(blk,'BlockType');
    idxFound=0;

    tskMgrConn=get_param(taskMgr,'PortHandles');
    allTaskMgrOutports=tskMgrConn.Outport;
    for iter=1:numel(allTaskMgrOutports)
        thisOutportLine=get_param(allTaskMgrOutports(iter),'Line');
        dest=get_param(thisOutportLine,'DstBlockHandle');
        if~isempty(dest)
            if isequal(get_param(dest,'BlockType'),'ModelReference')
                dest=get_param(dest,'ModelName');
            end
            inportsInDest=find_system(dest,'FollowLinks','on',...
            'SearchDepth',1,'LookUnderMasks','on','BlockType',blkType);
            for idxInport=1:numel(inportsInDest)
                ip=inportsInDest(idxInport);
                if~isnumeric(ip),ip=get_param(ip{1},'Handle');end
                if isequal(ip,blk)
                    idxFound=iter;
                    break
                end
            end
        end
        if idxFound
            break;
        end
    end
end


function[name,eventName]=getTaskName(taskMgr,idx)
    tmOutPorts=find_system(taskMgr,'FollowLinks','on','SearchDepth',1,...
    'LookUnderMasks','on','BlockType','Outport');
    taskPort=tmOutPorts(idx);
    allTaskData=get_param(taskMgr,'AllTaskData');
    dm=soc.internal.TaskManagerData(allTaskData);
    name=get_param(taskPort,'Name');
    thisTaskData=dm.getTask(name);
    if isequal(thisTaskData.taskType,'Timer-driven')
        eventName='';
    else
        eventName=thisTaskData.taskEvent;
    end

end
