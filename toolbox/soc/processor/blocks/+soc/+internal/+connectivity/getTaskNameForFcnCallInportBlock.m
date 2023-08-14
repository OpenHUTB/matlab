function name=getTaskNameForFcnCallInportBlock(topMdl,hFcnCallInport)







    name=getTaskNameInternal(topMdl,hFcnCallInport);
end


function name=getTaskNameInternal(topMdl,blk)
    name='';
    mySrcBlk=getMySrcBlock(topMdl,blk);
    while~isempty(mySrcBlk)&&~isMySrcBlockTaskManager(mySrcBlk)
        blk=mySrcBlk;
        mySrcBlk=getMySrcBlock(topMdl,blk);
    end
    if~isempty(mySrcBlk)
        idx=getTaskIndex(mySrcBlk,blk);
        name=getTaskName(mySrcBlk,idx);
    end
end


function mySrcBlk=getMySrcBlock(topMdl,blk)
    if isequal(get_param(blk,'BlockType'),'TriggerPort')
        mySrcBlk=getMySrcBlockForTriggerPort(blk);
    elseif isequal(get_param(blk,'BlockType'),'Inport')
        mySrcBlk=getMySrcBlockForInport(topMdl,blk);
    else
        mySrcBlk=[];
    end
end


function mySrcBlk=getMySrcBlockForInport(topMdl,blk)
    mySrcBlk=[];
    parent=get_param(blk,'Parent');
    port=get_param(blk,'Port');
    if isequal(get_param(parent,'Type'),'block_diagram')
        mdlRefBlk=find_system(topMdl,'FollowLinks','on',...
        'SearchDepth',1,'LookUnderMasks','on','BlockType',...
        'ModelReference','ModelName',parent);
        conn=get_param(mdlRefBlk{1},'PortConnectivity');
        for i=1:numel(conn)
            if~isempty(conn(i).SrcBlock)&&~isequal(conn(i).SrcBlock,-1)&&...
                (isequal(conn(i).Type,port))
                mySrcBlk=conn(i).SrcBlock;
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
    tskMgrConn=get_param(taskMgr,'PortConnectivity');
    for idxTaskMgrConn=1:numel(tskMgrConn)
        dest=tskMgrConn(idxTaskMgrConn).DstBlock;
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
                    idxFound=idxInport;
                    break
                end
            end
        end
        if idxFound,break;end
    end
end


function name=getTaskName(taskMgr,idx)
    tmOutPorts=find_system(taskMgr,'FollowLinks','on','SearchDepth',1,...
    'LookUnderMasks','on','BlockType','Outport');
    taskPort=tmOutPorts(idx);
    name=get_param(taskPort,'Name');
end
