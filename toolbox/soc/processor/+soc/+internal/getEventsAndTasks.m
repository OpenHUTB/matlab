function[sortedTasks,eventSources,eventListForEventSources,eventCommType]...
    =getEventsAndTasks(h,taskMgr)




    custInfo=soc.internal.taskmanager.getCustomizationInfo(taskMgr);

    reg=soc.internal.ESBRegistry.manageInstance(...
    'getfullmodelreferencehierarchy',h.ModelName);

    eventSources=containers.Map;

    eventSources=locAddIOPeripheralEventSources(reg,taskMgr,h.ModelName,eventSources);
    eventSources=locAddTimerEventSources(reg,taskMgr,h.ModelName,eventSources,h.StartTime);
    eventSources=locAddDiagnosticsEventSources(reg,taskMgr,h.ModelName,eventSources,h.StartTime);

    myTasks=locGetTasks(reg,taskMgr);
    sortedTasks=locSortElements(myTasks,'Name','ascend');

    allTaskData=get_param(taskMgr,'AllTaskData');
    dm=soc.internal.TaskManagerData(allTaskData,'evaluate',h.ModelName);
    for i=1:numel(sortedTasks)
        taskData=dm.getTask(sortedTasks(i).Name);
        h.TaskDurationData{i}=taskData.taskDurationData;
    end

    sortedTasks=locSetPeriodicTaskPriority(h.ModelName,sortedTasks);

    myTaskNames=arrayfun(@(x)(x.Name),myTasks,'UniformOutput',false);

    eventListForEventSources={};
    eventCommType={};

    myEventSrcs=locGetMyEventSources(reg,myTaskNames);
    if~isempty(myEventSrcs)
        for blkIdx=1:numel(myEventSrcs)
            for eventIdx=1:numel(myEventSrcs(blkIdx).Events)
                thisEvent=myEventSrcs(blkIdx).Events(eventIdx);
                eventID=thisEvent.EventID;
                eventListForEventSources{end+1}=eventID;%#ok<*AGROW>
                eventCommType{end+1}=thisEvent.CommType;
            end
        end
    end


    posPriorityOrder=isequal(...
    get_param(h.ModelName,'PositivePriorityOrder'),'on');
    if~posPriorityOrder
        maxPriority=max([sortedTasks(:).Priority]);
        for taskIdx=1:numel(sortedTasks)
            sortedTasks(taskIdx).Priority=...
            maxPriority-sortedTasks(taskIdx).Priority+1;
        end
    end


    taskRTBMap=soc.internal.connectivity.getRTBToAsyncTaskMap(h.ModelName,taskMgr);

    clockEvents=[];
    for taskIdx=1:numel(sortedTasks)
        task=sortedTasks(taskIdx);
        if isequal(task.PlaybackRecorded,'on')&&~isequal(task.EventID,'clock')
            eventID=[task.Name,task.EventID];
            eventListForEventSources{end+1}=eventID;
            eventCommType{end+1}='pull';
        elseif~isequal(task.EventID,'clock')
            eventID=task.EventID;
            if~isequal(eventID,'<empty>')&&~ismember(eventID,...
                eventListForEventSources)
                DAStudio.error('soc:scheduler:TaskEventNotFound',eventID,...
                task.Name);
            end
        else

            eventID=[task.Name,task.EventID];
            clockEvents(end+1).TaskPriority=task.Priority;
            clockEvents(end).EventID=eventID;
        end

        mean=-1;
        dev=-1;
        taskData=dm.getTask(task.Name);
        durFromDiag=isequal(task.PlaybackRecorded,'on')||...
        isequal(taskData.taskDurationSource,'Recorded task execution statistics');

        eventName=soc.internal.constructEventName(eventID);
        setTasks(h,taskIdx,task.Name,eventName,...
        locGetTaskPeriod(task,taskRTBMap),...
        task.Priority,task.CoreNum,...
        custInfo.taskpreemptionsupported);
        setRunnables(h,taskIdx,task.Name,mean,dev,durFromDiag);
    end
    sortedClockEvents=locSortElements(clockEvents,'TaskPriority','descend');
    sortedClockEvents=locApplyScheduleEditorToPeriodicTasks(h.TopTaskManagerBlock,sortedClockEvents);
    for clockIdx=1:numel(sortedClockEvents)
        eventCommType{end+1}='pull';
        eventListForEventSources{end+1}=sortedClockEvents(clockIdx).EventID;
    end
    locApplyScheduleEditorPriorities(h,h.TopTaskManagerBlock,sortedTasks)
end


function mySrcs=locGetMyEventSources(reg,myTaskNames)
    mySrcs=[];
    for blkIdx=1:numel(reg.EventSrcBlocks)
        srcBlk=reg.EventSrcBlocks(blkIdx);
        for eventIdx=1:numel(srcBlk.Events)
            eventID=srcBlk.Events(eventIdx).EventID;
            taskNameFromEventID=eventID(1:end-5);
            if ismember(taskNameFromEventID,myTaskNames)
                if isempty(mySrcs)
                    mySrcs=srcBlk;
                else
                    mySrcs(end+1)=srcBlk;
                end
            end
        end
    end
end


function myTasks=locGetTasks(reg,tskMgrBlk)
    allTaskData=get_param(tskMgrBlk,'AllTaskData');
    dm=soc.internal.TaskManagerData(allTaskData);
    taskNames=dm.getTaskNames;
    allTasks=reg.Tasks;
    idx=0;
    for i=1:numel(allTasks)
        thisTask=allTasks(i);
        if ismember(thisTask.Name,taskNames)
            idx=idx+1;
            myTasks(idx)=thisTask;
        end
    end
    if(0==idx),myTasks=[];end
end



function period=locGetTaskPeriod(task,theMap)
    period=task.Period;

    if isnan(period)&&theMap.isKey(task.Name)&&...
        exist('./soc_RTBRateInfo.txt','file')

        theHandle=theMap(task.Name);
        A=importdata('soc_RTBRateInfo.txt');
        [nRows,~]=size(A);
        for i=1:nRows
            if isequal(theHandle,A(i,1))
                period=A(i,2);
                return;
            end
        end
    end
end



function setTasks(h,idx,tskName,eventName,period,priority,coreNum,preemptible)
    h.Tasks{idx,1}=tskName;
    h.Tasks{idx,2}=eventName;
    h.Tasks{idx,3}=period;
    h.Tasks{idx,4}=priority;
    h.Tasks{idx,5}=coreNum;
    h.Tasks{idx,6}=preemptible;
end



function setRunnables(h,idx,name,mean,dev,durFromDiag)
    h.Runnables{idx,1}=name;
    h.Runnables{idx,2}=idx;
    h.Runnables{idx,3}=mean;
    h.Runnables{idx,4}=dev;
    h.Runnables{idx,5}=1;
    h.Runnables{idx,6}=idx;
    h.Runnables{idx,7}=durFromDiag;
end



function evtSrcs=locAddIOPeripheralEventSources(reg,tskMgr,mdl,evtSrcs)
    myTaskNames=soc.internal.taskmanager.getTaskNames(tskMgr);
    for blkIdx=1:numel(reg.EventSrcBlocks)
        eventSrcBlk=reg.EventSrcBlocks(blkIdx);
        for eventIdx=1:numel(eventSrcBlk.Events)
            thisEvent=eventSrcBlk.Events(eventIdx);
            eventID=thisEvent.EventID;

            task=locGetTaskBlockForIOPeripheralEventSource(reg,eventID);
            if~ismember(task.Name,myTaskNames),continue;end
            if isempty(task)
                hSource=soc.internal.IOPeripheralEventSource(eventID,...
                mdl,'',false,false);
            else
                if isequal(task.PlaybackRecorded,'on'),continue;end
                hSource=soc.internal.IOPeripheralEventSource(eventID,...
                mdl,task.Name,task.DropOverranTasks,...
                task.LogDroppedTasks);
            end
            hSource.setBlockHandle(eventSrcBlk.BlockHandle);
            hSource.setModelName(eventSrcBlk.Model);
            hSource.setCommType(thisEvent.CommType);
            hSource.setTaskFcnPollCmd(thisEvent.TaskFcnPollCmd);

            evtSrcs(eventID)=hSource;
        end
    end
end



function taskBlk=locGetTaskBlockForIOPeripheralEventSource(reg,eventID)
    taskBlk=[];
    for idx=1:numel(reg.Tasks)
        thisTask=reg.Tasks(idx);
        if isequal(eventID,thisTask.EventID)
            taskBlk=thisTask;
            break;
        end
    end
end



function evtSrcs=locAddTimerEventSources(reg,tskMgr,mdl,evtSrcs,startTime)
    allTasks=reg.Tasks;
    myTaskNames=soc.internal.taskmanager.getTaskNames(tskMgr);
    allTaskData=get_param(tskMgr,'AllTaskData');
    dm=soc.internal.TaskManagerData(allTaskData,'evaluate',mdl);
    for idx=1:numel(allTasks)
        hTask=allTasks(idx);
        if~ismember(hTask.Name,myTaskNames),continue;end
        if isequal(hTask.EventID,'clock')&&...
            ~isequal(hTask.PlaybackRecorded,'on')
            taskData=dm.getTask(hTask.Name);
            durationFromDiag=isequal(taskData.taskDurationSource,...
            'Recorded task execution statistics');
            diagFileName=taskData.diagnosticsFile;
            eventID=[hTask.Name,hTask.EventID];

            hSource=soc.internal.TimerEventSource(eventID,...
            durationFromDiag,diagFileName,hTask.Period,...
            mdl,hTask.Name,hTask.DropOverranTasks,hTask.LogDroppedTasks,...
            startTime);

            evtSrcs(eventID)=hSource;
        end
    end
end



function evtSrcs=locAddDiagnosticsEventSources(reg,tskMgr,mdl,evtSrcs,startTime)
    allTasks=reg.Tasks;
    myTaskNames=soc.internal.taskmanager.getTaskNames(tskMgr);
    for idx=1:numel(allTasks)
        hTask=allTasks(idx);
        if~ismember(hTask.Name,myTaskNames),continue;end
        if isequal(hTask.PlaybackRecorded,'on')
            hBlk=hTask.BlockHandle;
            diagFileName=get_param(hBlk,'diagnosticsFile');
            if~exist(diagFileName,'file')
                throwAsCaller(MException(message(...
                'soc:scheduler:DiagFileNotFound',diagFileName,hTask.Name)));
            end
            [~,NAME,~]=fileparts(diagFileName);
            if isequal(NAME,'metadata')
                throwAsCaller(MException(message(...
                'soc:scheduler:DiagFileNameWrong',mdl)));
            end
            eventID=[hTask.Name,hTask.EventID];

            hSource=soc.internal.DiagnosticsEventSource(eventID,diagFileName,...
            mdl,hTask.Name,hTask.DropOverranTasks,hTask.LogDroppedTasks,...
            startTime);

            evtSrcs(eventID)=hSource;
        end
    end
end



function sortedElems=locSortElements(elements,keyField,order)
    keepSorting=true;
    sortedElems=elements;
    while(keepSorting)
        keepSorting=false;
        for idx=1:numel(elements)-1
            isSwapped=swapElemsIfOutOfOrder(idx);
            keepSorting=keepSorting||isSwapped;
        end
    end
    function isSwapped=swapElemsIfOutOfOrder(idx)
        isSwapped=false;
        elem1=sortedElems(idx).(keyField);
        elem2=sortedElems(idx+1).(keyField);
        if isequal(elem1,elem2)
            return
        end
        switch(order)
        case 'ascend'
            if~isAscending(elem1,elem2)
                tmp=sortedElems(idx);
                sortedElems(idx)=sortedElems(idx+1);
                sortedElems(idx+1)=tmp;
                isSwapped=true;
            end
        case 'descend'
            if isAscending(elem1,elem2)
                tmp=sortedElems(idx);
                sortedElems(idx)=sortedElems(idx+1);
                sortedElems(idx+1)=tmp;
                isSwapped=true;
            end
        end
    end
    function isInRightOrder=isAscending(elem1,elem2)
        if isnumeric(elem1)
            isInRightOrder=elem1<elem2;
        else
            isInRightOrder=isequal({elem1,elem2},...
            sort({elem1,elem2}));
        end
    end
end



function tasks=locSetPeriodicTaskPriority(modelName,tasks)
    baseRatePriority=40;
    sampleTimes=get_param(modelName,'SampleTimes');
    rates={};
    for stIdx=1:numel(sampleTimes)
        periodAndOffset=sampleTimes(stIdx).Value;
        if isempty(periodAndOffset)||~isequal(numel(periodAndOffset),2),continue;end
        if periodAndOffset(1)>0&&~isinf(periodAndOffset(1))
            rates{end+1}.TID=sampleTimes(stIdx).TID;
            rates{end}.Period=periodAndOffset(1);
        end
    end
    for tskIdx=1:numel(tasks)
        if isequal(tasks(tskIdx).EventID,'clock')
            for rateIdx=1:numel(rates)
                if isequal(tasks(tskIdx).Period,rates{rateIdx}.Period)
                    tasks(tskIdx).Priority=double(baseRatePriority-rates{rateIdx}.TID);
                end
            end
        end
    end
end



function events=locApplyScheduleEditorToPeriodicTasks(tskMgr,events)
    useSchedEditor=isequal(get_param(tskMgr,'UseScheduleEditor'),'on');
    if~useSchedEditor,return;end
    soc.internal.taskmanager.verifyPartitionsHaveTasks(tskMgr);
    refMdl=soc.internal.connectivity.getModelConnectedToTaskManager(tskMgr);
    if~isequal(get_param(refMdl,'BlockType'),'ModelReference'),return;end
    refMdlName=get_param(refMdl,'ModelName');
    schedule=get_param(refMdlName,'Schedule');
    myTbl=schedule.Order;
    part=myTbl.Partition;
    tbl=table2struct(myTbl);
    for i=length(part):-1:1
        tbl(i).Partition=part{i};
        if~isequal(tbl(i).Type,'Periodic'),tbl(i)=[];end
    end
    keepSorting=true;
    while(keepSorting)
        keepSorting=false;
        for i=2:length(tbl)
            names={tbl(i-1).Partition,tbl(i).Partition};
            if isequal(tbl(i).Trigger,tbl(i-1).Trigger)&&...
                ~isequal(names,sort(names))
                tmp=tbl(i-1);
                tbl(i-1)=tbl(i);
                tbl(i)=tmp;
                tmp=events(i-1);
                events(i-1)=events(i);
                events(i)=tmp;
                keepSorting=true;
            end
        end
    end
end


function locApplyScheduleEditorPriorities(h,tskMgr,tasks)
    useSchedEditor=isequal(get_param(tskMgr,'UseScheduleEditor'),'on');
    if~useSchedEditor,return;end
    soc.internal.taskmanager.verifyPartitionsHaveTasks(tskMgr);
    map=soc.internal.taskmanager.getTaskToPartitionMapping(tskMgr);
    for idx=1:numel(tasks)
        fnd=arrayfun(@(x)isequal(x.TaskName,h.Tasks{idx,1}),map);
        thisTask=map(fnd);
        h.Tasks{idx,4}=1+numel(tasks)-thisTask.ParIndex;
    end
end
