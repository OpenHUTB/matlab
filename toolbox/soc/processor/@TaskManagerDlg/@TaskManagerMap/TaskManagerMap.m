function h=TaskManagerMap(blockHandles)




    h=TaskManagerDlg.TaskManagerMap();
    h.TskMgrBlockHandles=blockHandles;
    h.TskMgrBlocks=arrayfun(@(x)(get_param(x,'Object')),blockHandles);



    parent=h.TskMgrBlocks(1).getParent;
    while~isa(parent,'Simulink.BlockDiagram')
        parent=parent.getParent;
    end
    h.Root=parent;

    totTskIdx=0;
    for blkIdx=1:numel(h.TskMgrBlocks)
        thisBlkData=h.TskMgrBlocks(blkIdx).AllTaskData;
        dm=soc.internal.TaskManagerData(thisBlkData);
        allTaskNames=dm.getTaskNames;
        h.eventList=soc.internal.getTaskEventSources(parent);
        for i=1:numel(allTaskNames)
            totTskIdx=totTskIdx+1;
            thisTaskName=allTaskNames{i};
            thisTaskData=dm.getTask(thisTaskName);
            h.taskMappingData{totTskIdx,1}=thisTaskName;
            [found,idx]=ismember(thisTaskData.taskEventSource,h.eventList);
            if~found
                h.eventList{end+1}=thisTaskData.taskEventSource;
                idx=numel(h.eventList);
            end
            h.taskMappingData{totTskIdx,2}=idx-1;
            h.taskMappingData{totTskIdx,3}=thisTaskData.taskEventSourceAssignmentType;
            h.taskMappingData{totTskIdx,4}=thisTaskData.taskEventSourceType;
        end
    end
end
