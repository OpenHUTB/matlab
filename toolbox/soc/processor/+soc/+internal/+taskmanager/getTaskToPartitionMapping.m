function mapStruct=getTaskToPartitionMapping(tskMgrBlk)




    taskNames=soc.internal.connectivity.getTaskNames(tskMgrBlk);
    refMdlBlk=soc.internal.connectivity.getModelConnectedToTaskManager(tskMgrBlk);
    refMdlNam=get_param(refMdlBlk,'ModelName');
    schedule=get_param(refMdlNam,'Schedule');
    tmPortNum=i_getTaskMgrPortNumForRatePorts(refMdlBlk);
    portNames=i_getPartRatePortNames(schedule);
    mapStruct=struct('PartName',portNames,'TaskName','','ParIndex',[]);
    for i=1:numel(portNames)
        mapStruct(i).TaskName=taskNames{tmPortNum(i)+1};
        mapStruct(i).ParIndex=schedule.Order.Index(mapStruct(i).PartName);
    end
end



function res=i_getPartRatePortNames(schedule)
    parTypes=schedule.Order.Type;
    parNames=schedule.Order.Partition;
    res=[...
    sort(parNames(arrayfun(@(x)isequal(x,'Aperiodic'),parTypes)));...
    sort(parNames(arrayfun(@(x)isequal(x,'Periodic'),parTypes)))...
    ];
end



function res=i_getTaskMgrPortNumForRatePorts(refMdlBlk)
    res={};
    pc=get_param(refMdlBlk,'PortConnectivity');
    for i=1:numel(pc)
        portNum=i_getSrcPortNum(pc(i));
        if isempty(portNum),continue;end
        res{end+1}=portNum;%#ok<AGROW> 
    end
    res=cell2mat(res);
end


function res=i_getSrcPortNum(pc)
    res=[];
    srcBlk=pc.SrcBlock;
    if isempty(srcBlk),return;end
    btype=get_param(srcBlk,'BlockType');

    switch btype
    case 'SubSystem'
        mtype=get_param(srcBlk,'MaskType');
        assert(isequal(mtype,'Task Manager'),'TODO: Task Manager found in a subsystem');
        res=pc.SrcPort;
    end
end
