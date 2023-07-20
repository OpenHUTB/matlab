function h=TaskManagerAppMap(blockHandles,varargin)



    isTskMgrBlk=contains(get_param(blockHandles(1),'MaskType'),'Task Manager');
    if isTskMgrBlk
        h=TaskManagerAppDlg.TaskManagerAppMap();
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
    else
        h=TaskManagerAppDlg.TaskManagerAppMap();
        h.TskMgrBlockHandles=blockHandles;
        h.TskMgrBlocks=arrayfun(@(x)(get_param(x,'Object')),blockHandles);

        parent=h.TskMgrBlocks(1).getParent;
        while~isa(parent,'Simulink.BlockDiagram')
            parent=parent.getParent;
        end
        h.Root=parent;
        if nargin>1
            mdlName=varargin{1};
        end

        totTskIdx=0;
        allTaskNames=codertarget.internal.taskmapper.findHWITaskNames(mdlName);
        h.eventList=codertarget.internal.taskmapper.findDynamicEventSources(mdlName);
        hCS=getActiveConfigSet(mdlName);
        data=get_param(hCS,'CoderTargetData');
        if~isfield(data,'TaskMap')
            data.TaskMap.EventSources='unspecified';
        end
        for i=1:numel(allTaskNames)
            totTskIdx=totTskIdx+1;
            thisTaskName=allTaskNames{i};
            h.taskMappingData{totTskIdx,1}=thisTaskName;

            thisTaskName=strrep(thisTaskName,' ','');
            if isfield(data.TaskMap,'Tasks')
                storedTaskNames=fieldnames(data.TaskMap.Tasks);
                [found,~]=ismember(thisTaskName,storedTaskNames);
            else
                found=0;

                thisMgr=h.TskMgrBlocks(i);
                blkH=thisMgr.getFullName;
                taskInfo=codertarget.internal.taskmapper.findHWITaskInfo(blkH);
                data.TaskMap.Tasks.(thisTaskName)=struct('TaskPriority','','DisablePremption','','MappedSource','unspecified');
                data.TaskMap.Tasks.(thisTaskName).TaskPriority=taskInfo.TaskPriorites;
                data.TaskMap.Tasks.(thisTaskName).DisablePremption=taskInfo.DisablePreemption;
            end
            if found
                [foundEvt,evtId]=ismember(data.TaskMap.Tasks.(thisTaskName).MappedSource,h.eventList);
            end
            if~found||~foundEvt
                evtId=1;
            end
            h.taskMappingData{totTskIdx,2}=evtId-1;
            h.taskMappingData{totTskIdx,3}='Manually assigned';
            h.taskMappingData{totTskIdx,4}='unspecified';
        end
        set_param(hCS,'CoderTargetData',data);
    end
end
