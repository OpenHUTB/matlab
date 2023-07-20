classdef(Sealed=true,Hidden)ESBRegistry<handle




    properties(SetAccess='private')
        AllRefModels;
        EventSrcBlocks;
        EventSnkBlocks;
        Tasks;
        Clocks;
        TasksViewer=[];
    end
    properties(SetAccess='private')
        AllEventIDs={};
        AllTaskNames={};
        AllEventNames={};
    end
    methods(Access='private')
        function this=ESBRegistry
        end
    end
    methods(Static=true,Hidden)
        function h=manageInstance(action,model,~)

            mlock;
            persistent hStaticObj;
            if isnumeric(model),model=get_param(model,'Name');end
            switch action
            case('init')
                h=soc.internal.ESBRegistry;
                if Simulink.internal.useFindSystemVariantsMatchFilter()
                    refs=find_mdlrefs(model,'AllLevels',true,...
                    'KeepModelsLoaded',true,...
                    'MatchFilter',@Simulink.match.activeVariants);
                else
                    refs=find_mdlrefs(model,'AllLevels',true,...
                    'KeepModelsLoaded',true,...
                    'Variants','ActiveVariants');
                end
                h.AllRefModels=refs';
            case{'get'}
                if isempty(hStaticObj)
                    hStaticObj.regMap=containers.Map;
                    hStaticObj.regMap(model)=...
                    soc.internal.ESBRegistry.manageInstance('init',...
                    model);
                elseif~isKey(hStaticObj.regMap,model)
                    hStaticObj.regMap(model)=...
                    soc.internal.ESBRegistry.manageInstance('init',...
                    model);
                end
                h=hStaticObj.regMap(model);
            case{'getfullmodelreferencehierarchy'}
                h=soc.internal.ESBRegistry;
                refMdls=...
                soc.internal.ESBRegistry.getAllModelsInHierachy(...
                model,hStaticObj);
                for idxMdl=1:numel(refMdls)
                    r=soc.internal.ESBRegistry.manageInstance('get',...
                    refMdls{idxMdl});
                    propNames=properties(h);
                    for idxProps=1:numel(propNames)
                        prop=propNames{idxProps};
                        a=[h.(prop),r.(prop)];
                        if~isempty(a),h.(prop)=a;end
                    end
                end
            case 'destroy'

                if~isempty(hStaticObj)&&...
                    isKey(hStaticObj.regMap,model)
                    remove(hStaticObj.regMap,model);
                end
                h=[];
            otherwise
                assert(false,'Unknown action for ESB Registry');
                return;
            end
        end

        function res=isTaskBlockRegistered(model,hBlock)
            hReg=soc.internal.ESBRegistry.manageInstance('get',model);
            res=~isempty(hReg)&&~isempty(hReg.Tasks)&&...
            ismember(hBlock,[hReg.Tasks(:).BlockHandle]);
        end

        function res=isTaskNameRegistered(model,taskName)
            hReg=soc.internal.ESBRegistry.manageInstance('get',model);
            res=~isempty(hReg)&&...
            ismember(taskName,hReg.AllTaskNames);
        end

        function res=isEventIDAssociatedWithTask(model,eventID)
            hReg=soc.internal.ESBRegistry.manageInstance('get',model);
            res=~isempty(hReg)&&...
            ~isempty(hReg.Tasks)&&...
            ismember(eventID,{hReg.Tasks.EventID});
        end

        function res=isPeriodIDAssociatedWithTask(model,hBlk,period)
            import soc.internal.*
            tmBlk=ESBRegistry.getTaskManagerNameForTaskBlock(hBlk);
            hReg=ESBRegistry.manageInstance('get',model);
            res=false;
            if~isempty(hReg)&&~isempty(hReg.Tasks)
                idx=arrayfun(@(x)(isequal(x.Period,period)),hReg.Tasks);
                if any(idx)
                    samePeriodTasks=hReg.Tasks(idx);
                    tmBlks=arrayfun(@(x)(x.TaskkMgrBlockName),samePeriodTasks,'UniformOutput',false);
                    res=ismember(tmBlk,tmBlks);
                end
            end
        end

        function res=isEventSrcBlockRegistered(model,hBlk)
            res=false;
            reg=soc.internal.ESBRegistry.manageInstance('get',model);
            for idx=1:numel(reg.EventSrcBlocks)
                res=isequal(reg.EventSrcBlocks(idx).BlockHandle,hBlk);
                break
            end
        end

    end
    methods(Static=true)

        function allModels=getAllModelsInHierachy(model,staticObj)
            allRegs=staticObj.regMap;
            keys=allRegs.keys;
            if ischar(model)
                allModels={model};
            else
                allModels=model;
            end
            for idx=1:numel(keys)
                regObj=allRegs(keys{idx});
                if ismember(model,regObj.AllRefModels)
                    allModels=unique([allModels,regObj.AllRefModels]);
                end
            end
        end

        function addEvent(hBlock,eventNames)
            model=get_param(bdroot(hBlock),'Name');
            if~codertarget.utils.isESBEnabled(getActiveConfigSet(model))
                return
            end
            reg=soc.internal.ESBRegistry.manageInstance('get',model);
            reg.AllEventNames{end+1}=eventNames;
        end

        function addBlock(hBlock,inArg1,inArg2)
            if(ishandle(hBlock))
                model=get_param(bdroot(hBlock),'Name');
            else
                model=bdroot(gcb);
            end
            if~codertarget.utils.isESBEnabled(getActiveConfigSet(model))
                return
            end
            reg=soc.internal.ESBRegistry.manageInstance('get',model);
            if soc.internal.ESBRegistry.isEventSrcBlockRegistered(model,...
                hBlock)
                return;
            end
            if nargin==2&&isstruct(inArg1)
                events=inArg1;
            else
                events.EventID=inArg1;
                if nargin==2,inArg2='pull';end
                events.CommType=inArg2;
            end
            numSrcBlks=numel(reg.EventSrcBlocks)+1;
            numSnkBlks=numel(reg.EventSnkBlocks)+1;
            for eventIdx=1:numel(events)
                thisEvent=events(eventIdx);
                if~isfield(thisEvent,'TaskFcnPollCmd')
                    thisEvent.TaskFcnPollCmd='';
                end
                if~isfield(thisEvent,'TaskFcnPollCmdArg')
                    thisEvent.TaskFcnPollCmdArg='';
                end
                if~isfield(thisEvent,'IOBlockHandle')
                    thisEvent.IOBlockHandle=gcbh;
                end
                if isequal(thisEvent.CommType,'listen')
                    reg.EventSnkBlocks(numSnkBlks).BlockHandle=hBlock;
                    if isfield(reg.EventSnkBlocks(numSnkBlks),'Events')
                        idx1=numel(reg.EventSnkBlocks(numSnkBlks).Events)+1;
                    else
                        idx1=1;
                    end
                    reg.EventSnkBlocks(end).Events(idx1)=thisEvent;
                    reg.EventSnkBlocks(end).Model=model;
                else
                    if ismember(thisEvent.EventID,reg.AllEventIDs)
                        error(message('soc:scheduler:NonuniqueEventID',...
                        thisEvent.EventID));
                    end
                    reg.EventSrcBlocks(numSrcBlks).BlockHandle=hBlock;
                    if isfield(reg.EventSrcBlocks(numSrcBlks),'Events')
                        idx2=numel(reg.EventSrcBlocks(numSrcBlks).Events)+1;
                    else
                        idx2=1;
                    end
                    reg.EventSrcBlocks(end).Events(idx2)=thisEvent;
                    reg.EventSrcBlocks(end).Model=model;
                    reg.AllEventIDs{end+1}=thisEvent.EventID;
                end
            end
        end

        function addTask(hBlock,taskName,eventID,period,taskPriority,...
            coreNum,dropOverranTasks,playbackRecorded,...
            taskDurationSource,taskDuration,taskDurationDeviation,...
            logExecutionData,logDroppedTasks)
            model=get_param(bdroot(hBlock),'Name');
            if~codertarget.utils.isESBEnabled(model)
                return
            end
            hReg=soc.internal.ESBRegistry.manageInstance('get',model);
            if soc.internal.ESBRegistry.isTaskBlockRegistered(model,hBlock)
                return
            end
            if soc.internal.ESBRegistry.isTaskNameRegistered(model,taskName)
                error(message('soc:scheduler:NonuniqueTaskNamesReg',taskName));
            end
            if isequal(get_param(hBlock,'taskType'),'Event-driven')
                if soc.internal.ESBRegistry.isEventIDAssociatedWithTask(model,eventID)
                    error(message('soc:scheduler:MultipleTasksHandleSameEvent',eventID));
                end
            end
            if isequal(get_param(hBlock,'taskType'),'Timer-driven')



            else
                period=NaN;
            end

            hReg.Tasks(end+1).BlockHandle=hBlock;
            hReg.Tasks(end).TaskkMgrBlockName=...
            soc.internal.ESBRegistry.getTaskManagerNameForTaskBlock(hBlock);
            hReg.AllTaskNames{end+1}=taskName;
            hReg.Tasks(end).Name=taskName;
            hReg.Tasks(end).EventID=eventID;
            hReg.Tasks(end).Period=period;
            hReg.Tasks(end).Priority=taskPriority;
            hReg.Tasks(end).CoreNum=coreNum;
            hReg.Tasks(end).DropOverranTasks=dropOverranTasks;
            hReg.Tasks(end).PlaybackRecorded=playbackRecorded;
            hReg.Tasks(end).DurationSource=taskDurationSource;
            hReg.Tasks(end).MeanDuration=taskDuration;
            hReg.Tasks(end).DurationDeviation=taskDurationDeviation;
            hReg.Tasks(end).LogExecutionData=logExecutionData;
            hReg.Tasks(end).LogDroppedTasks=logDroppedTasks;
            if isequal(get_param(hBlock,'taskType'),'Timer-driven')

                hReg.Clocks(end+1).BlockHandle=hBlock;
                hReg.Clocks(end).TaskName=taskName;
                hReg.Clocks(end).EventID=[taskName,eventID];
                hReg.Clocks(end).Period=period;
                hReg.Clocks(end).NextEventTime=0.0;
            end
        end

        function tmName=getTaskManagerNameForTaskBlock(hBlock)
            hSubs=get_param(hBlock,'Parent');
            hHSBOn=get_param(hSubs,'Parent');
            hVarSubs=get_param(hHSBOn,'Parent');
            hTaskBlocks=get_param(hVarSubs,'Parent');
            tmName=get_param(hTaskBlocks,'Parent');
        end

        function out=getTaskViewer(model)
            if~codertarget.utils.isESBEnabled(model)
                return
            end
            hReg=soc.internal.ESBRegistry.manageInstance('get',model);
            if~isempty(hReg.TasksViewer)
                out=hReg.TasksViewer;
                return
            end
            hReg.TasksViewer=soc.internal.ESBTaskExecutionViewer(true);
            out=hReg.TasksViewer;
        end
        function destroyTaskViewer(model)
            hReg=soc.internal.ESBRegistry.manageInstance('get',model);
            if~isempty(hReg.TasksViewer)
                hReg.TasksViewer=[];
            end
        end

        function event=getNextEvent(eventID,model,time)
            event=[];
            reg=soc.internal.ESBRegistry.manageInstance('get',model);
            for blockIdx=1:numel(reg.EventSrcBlocks)
                for eventIdx=1:numel(reg.EventSrcBlocks(blockIdx).Events)
                    if isequal(eventID,...
                        reg.EventSrcBlocks(blockIdx).Events(eventIdx).EventID)
                        hBlock=reg.EventSrcBlocks(blockIdx).BlockHandle;
                        event=hBlock.getNextEvent(eventID,time);
                        return;
                    end
                end
            end
            for clockIdx=1:numel(reg.Clocks)
                if isequal(reg.Clocks(clockIdx).EventID,eventID)
                    eventTime=reg.Clocks(clockIdx).NextEventTime;
                    reg.Clocks(clockIdx).NextEventTime=eventTime+...
                    reg.Clocks(clockIdx).Period;
                    event.Time=eventTime;
                    event.ID=eventID;
                    return;
                end
            end
        end

        function events=eventCallback(eventID,model,time)
            reg=soc.internal.ESBRegistry.manageInstance(...
            'getfullmodelreferencehierarchy',model);
            events=[];
            for idx=1:numel(reg.EventSnkBlocks)
                if isequal(reg.EventSnkBlocks(idx).Events.EventID,eventID)
                    hBlock=reg.EventSnkBlocks(idx).BlockHandle;
                    event=hBlock.eventCallback(eventID,time);
                    events=[events(:),event];
                end
            end
        end
    end
end


