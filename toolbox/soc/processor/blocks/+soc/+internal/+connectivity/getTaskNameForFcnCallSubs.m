function[taskName,eventName]=getTaskNameForFcnCallSubs(blk,varargin)









    if(nargin>1)
        topModel=varargin{1};
    else
        topModel='';
    end
    if ischar(blk)
        blk=get_param(blk,'Handle');
    end
    if~ishandle(blk)
        blk=gcbh;
    end
    isSearchOver=0;
    hParentSys=get_param(blk,'Parent');
    while~isSearchOver&&~isempty(hParentSys)
        hSubSys=hParentSys;
        if isequal(get_param(hSubSys,'ScheduleAs'),'Aperiodic partition')
            isSearchOver=true;
        else
            conn=get_param(hSubSys,'PortConnectivity');
            portTypes={conn.Type};
            idxTrigPort=contains(portTypes,'trigger');
            isSearchOver=any(idxTrigPort);
        end
        hParentSys=get_param(hSubSys,'Parent');
    end
    [taskName,eventName]=locGetTaskNameInternal(hSubSys,topModel);
end


function[taskName,eventName]=locGetTaskNameInternal(hSubSys,topModel)
    taskName='';
    eventName='';
    triggPorts=find_system(hSubSys,'FollowLinks','on','SearchDepth',1,...
    'LookUnderMasks','on','BlockType','TriggerPort');
    if~isempty(triggPorts)
        blk=get_param(triggPorts{1},'Handle');
        mySrcBlk=locGetMySrcBlock(blk);
        idx=[];
        while~isempty(mySrcBlk)&&~locIsMySrcBlockTaskManager(mySrcBlk)
            blk=mySrcBlk;
            [mySrcBlk,idx]=locGetMySrcBlock(blk,topModel);
        end
        if~isempty(mySrcBlk)
            if isempty(idx)
                idx=getTaskIndex(mySrcBlk,blk);
            end
            [taskName,eventName]=locGetTaskNameFromTaskManager(mySrcBlk,idx);
        end
    else
        taskMgr=soc.internal.connectivity.getTaskManagerBlock(topModel);
        if~iscell(taskMgr),taskMgr={taskMgr};end
        for i=1:numel(taskMgr)
            thisTaskMgr=taskMgr{i};
            taskName=get_param(hSubSys,'PartitionName');
            allTaskData=get_param(thisTaskMgr,'AllTaskData');
            dm=soc.internal.TaskManagerData(allTaskData);
            if ismember(taskName,dm.getTaskNames)
                thisTaskData=dm.getTask(taskName);
                eventName=thisTaskData.taskEvent;
                break;
            end
        end
        assert(~isempty(eventName),['Can''t find a task matching the partition '...
        ,taskName,'']);
    end
end


function[mySrcBlk,idx]=locGetMySrcBlock(blk,topModel)
    idx=[];
    if isequal(get_param(blk,'BlockType'),'TriggerPort')
        mySrcBlk=locGetMySrcBlockForTriggerPort(blk);
    elseif isequal(get_param(blk,'BlockType'),'Inport')
        [mySrcBlk,idx]=locGetMySrcBlockForInport(blk,topModel);
    elseif isequal(get_param(blk,'BlockType'),'AsynchronousTaskSpecification')


        portHandles=get_param(blk,'PortHandles');
        blockPort=get_param(get_param(portHandles.Inport,'Line'),'SrcBlockHandle');
        [mySrcBlk,idx]=locGetMySrcBlockForInport(blockPort,topModel);
    else
        mySrcBlk=[];
    end
end


function[mySrcBlk,idx]=locGetMySrcBlockForInport(blk,topMdl)
    mySrcBlk=[];
    idx=[];
    parent=get_param(blk,'Parent');
    port=get_param(blk,'Port');
    if isequal(get_param(parent,'Type'),'block_diagram')
        assert(~isempty(topMdl),...
        'Top-level model name is required to get the source block for given inport.')
        if~bdIsLoaded(topMdl)
            load_system(topMdl);
        end


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
                [~,idx]=ismember(get_param(connectedLine,'SrcPortHandle'),...
                allTaskMgrPorts.Outport);
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


function mySrcBlk=locGetMySrcBlockForTriggerPort(blk)
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


function res=locIsMySrcBlockTaskManager(blk)
    res=isequal(get_param(blk,'MaskType'),'Task Manager');
end


function idx=getTaskIndex(taskMgr,blk)



    tskMgrConn=get_param(taskMgr,'PortHandles');
    allTaskMgrOutports=tskMgrConn.Outport;
    allTaskMgrLines=get_param(allTaskMgrOutports,'Line');
    if~iscell(allTaskMgrLines)


        allTaskMgrLines={allTaskMgrLines};
    end

    allParentLineH=get_param(get_param(blk,'Parent'),'LineHandles');







    if strcmpi(get_param(blk,'BlockType'),'TriggerPort')
        connectedLine=allParentLineH.Trigger;
    elseif strcmpi(get_param(blk,'BlockType'),'Inport')
        thisPortIndex=get_param(blk,'Port');
        connectedLine=allParentLineH.Inport(str2double(thisPortIndex));
    else
        error(message('soc:scheduler:TaskMgrMisplaced'));
    end


    idx=find(cellfun(@(x)isequal(x,connectedLine),allTaskMgrLines));
end


function[name,eventName]=locGetTaskNameFromTaskManager(taskMgr,idx)
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
