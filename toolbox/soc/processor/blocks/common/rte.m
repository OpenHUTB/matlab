classdef(StrictDefaults)rte<matlab.DiscreteEventSystem







































    properties
        TaskManagerBlock;
        TopTaskManagerBlock;

        EventSources;
        TaskBlocks;

        CustomEventIDs={''};
        CustomEvents={''};
        CustomEventCommType={'pull';'push';'listen'};

        TaskRunning=[];
        TaskBlocked=[];
        TaskDependencies=[];
        NumTaskTriggersPending=[];

        ModelName='';
        StartTime=0;
        ClockPeriod=1;
        NumberOfRTForTask=[];
        ShowInSDI;


        Tasks={'start','initialize',1,1000,0,0;...
        'term','terminate',1,1000,0,0;...
        'base','clock',1,30,0,1;...
        'medium','clock',2,20,0,1;...
        'slow','clock',5,10,0,1;...
        'int1','interrupt1',1,50,0,0;
        'int2','interrupt2',1,50,0,0};

        Runnables={'Func2',1,0.1,0.03,0,2;...
        'F1',2,0.2,0.03,1,1;...
        'Func1',3,0.2,0.03,0,1;...
        'F2',3,0.1,0.03,1,2;...
        'Func3',4,0.1,0.03,0,3;...
        'F3',5,0.1,0.03,1,3};

        TaskColors=hsv(7);
        Environment=struct(...
        'NumCores',1,...
        'MaxNumTasks',99,...
        'MaxNumTimers',99,...
        'TaskPriorities',int16(1:99),...
        'TaskPriorityDescending',1,...
        'KernelLatency',0,...
        'TaskContextSaveTime',0,...
        'TaskContextRestoreTime',0,...
        'ModeChangeTime',0...
        );
        TaskDurationData;
    end
    properties(DiscreteState)
CurrEventType
CurrClockTick
CurrTaskGen
CurrAperiodicEvent
CurrTaskServersTaskPris
CurrTaskServersPreEmptible
    end

    properties(Access=private)
        StEventQueue=1;
        StEventServer=2;
        StClockTicker=3;
        StTaskWait=4;
        StTaskReady=5;
        StSubtaskGen=6;
        StTaskServer=7;

        EvPowerUp=uint32(1);
        EvPowerDown=uint32(2);
        EvClockStart=uint32(3);
        EvClockTick=uint32(4);
        EvCustom=uint32(5);
        EvDead=uint32(6);

        STTaskStart=uint32(1);
        STTaskEnd=uint32(2);
        STTaskSuspend=uint32(3);
        STTaskResume=uint32(4);
        STTaskOverrun=uint32(5);
        STWRunnableComplete=uint32(6);
        STWLRunnableComplete=uint32(7);
        STRTRun=uint32(8);

        TaskExViewerObj=[];
    end
    methods(Static,Access=protected)
        function header=getHeaderImpl
            header=matlab.system.display.Header(...
            'rte',...
            'Title','Run-time Environment Block');
        end
        function groups=getPropertyGroupsImpl
            firstGroup=matlab.system.display.SectionGroup(...
            'Title','General',...
            'PropertyList',{'ClockPeriod','CustomEvents',...
            'Tasks','Runnables','TaskColors'});
            groups=firstGroup;
        end
    end

    methods(Access='private')
        function eventID=getEventIDForIdx(h,idx)
            tag=h.CustomEvents{idx};
            txt=DAStudio.message('soc:scheduler:CustomEventNamePrefix');
            eventID=strrep(tag,txt,'');
        end
    end



    methods(Access=protected)
        function num=getNumInputsImpl(~)
            num=1;
        end
        function num=getNumOutputsImpl(~)
            num=1;
        end
        function name=getInputNamesImpl(~)
            name='event';
        end
        function name=getOutputNamesImpl(~)
            name='subtask';
        end
        function icon=getIconImpl(~)
            icon='ESB Scheduler';
        end
        function out=getOutputDataTypeImpl(~)
            out='rteSubTask';
        end
        function sz_1=getOutputSizeImpl(~)
            sz_1=[1,1];
        end
        function c1=isOutputComplexImpl(~)
            c1=false;
        end

        function[sz,dt,cp]=getDiscreteStateSpecificationImpl(h,s)
            if strcmp(s,'CurrEventType')
                sz=[1,1];
                dt='uint32';
                cp=false;
            elseif strcmp(s,'CurrClockTick')
                sz=[1,1];
                dt='uint32';
                cp=false;
            elseif strcmp(s,'CurrTaskGen')
                sz=[1,1];
                dt='uint32';
                cp=false;
            elseif strcmp(s,'CurrAperiodicEvent')
                sz=[1,1];
                dt='uint32';
                cp=false;
            elseif strcmp(s,'CurrTaskServersTaskPris')
                sz=[1,h.Environment.NumCores];
                dt='double';
                cp=false;
            elseif strcmp(s,'CurrTaskServersPreEmptible')
                sz=[1,h.Environment.NumCores];
                dt='logical';
                cp=false;
            else
                assert(true);
            end
        end
    end



    methods(Access=protected)
        function s=saveObjectImpl(h)%#ok<STOUT>
            error(message('soc:msgs:OpPointSaveRestoreNotSupported',...
            'The Task Manager block'));
            s=saveObjectImpl@matlab.System(h);%#ok<UNRCH>
        end

        function loadObjectImpl(h,s,wasLocked)
            loadObjectImpl@matlab.System(h,s,wasLocked);
        end

        function blk=getTopTaskManagerBlock(h)
            blk=h.TaskManagerBlock;
            while 1
                if isequal(get_param(get_param(blk,'Parent'),'Name'),'Core Task Manager')
                    blk=get_param(blk,'Parent');
                    break;
                end
                blk=get_param(blk,'Parent');
            end
            blk=get_param(blk,'Parent');
        end

        function entityTypes=getEntityTypesImpl(h)
            import soc.internal.connectivity.*

            h.TaskManagerBlock=gcb;
            h.ModelName=bdroot(h.TaskManagerBlock);
            h.StartTime=str2double(get_param(h.ModelName,'StartTime'));
            hCS=getActiveConfigSet(h.ModelName);
            h.TopTaskManagerBlock=h.getTopTaskManagerBlock();
            verifyTaskManagerOutputsConnected(get_param(h.TopTaskManagerBlock,'Handle'));
            if~isequal(get_param(bdroot(h.ModelName),'BlockDiagramType'),'library')
                if~codertarget.utils.isMdlConfiguredForSoC(hCS)
                    error(message('soc:scheduler:NotConfiguredForSOC',h.ModelName));
                end
                if~isequal(get_param(h.ModelName,'SimulationMode'),'accelerator')&&...
                    isequal(get_param(h.ModelName,'HardwareBoard'),'None')
                    error(message('soc:scheduler:HWBoardNone',h.ModelName));
                end
                if~isequal(get_param(h.ModelName,'SimulationMode'),'accelerator')
                    h.checkAllModelsConsistent(get_param(h.ModelName,'HardwareBoard'));
                end
                if isequal(get_param(h.ModelName,'ProdHWDeviceType'),'ASIC/FPGA')
                    error(message('soc:utils:HWBoardASICFPGA',h.ModelName));
                end
                if isequal(get_param(h.ModelName,'PositivePriorityOrder'),'off')
                    error(message('soc:utils:NegPriorityOrderNotSupported'));
                end
                reg=soc.internal.ESBRegistry.manageInstance(...
                'getfullmodelreferencehierarchy',h.ModelName);

                assert(~isempty(reg.Tasks),'No registered tasks');
                h.Environment=codertarget.targethardware.getEnvironment(h.ModelName);
            end


            if~builtin('license','checkout','SoC_Blockset')
                error(message('soc:utils:NoLicense'));
            end

            entityTypes(1)=h.entityType('esbEvent','rteEvent',1,0);
            entityTypes(2)=h.entityType('clock','double',1,0);
            entityTypes(3)=h.entityType('task','rteTask',1,0);
            entityTypes(4)=h.entityType('subtask','rteSubTask',1,0);
        end

        function[storageInfo,iMap]=getEntityStorageImpl(h)
            storageInfo(1)=h.queueFIFO('esbEvent',1024);
            storageInfo(2)=h.queueFIFO('esbEvent',1);
            storageInfo(3)=h.queueFIFO('clock',1);
            storageInfo(4)=h.queuePriority(...
            'task',1024,'taskPriority','descending');
            storageInfo(5)=h.queuePriority(...
            'task',1024,'taskPriority','descending');
            storageInfo(6)=h.queueFIFO('subtask',64);
            for k=1:h.Environment.NumCores
                storageInfo(6+k)=h.queueFIFO('task',1);
            end
            iMap=1;
        end

        function[inputTypes,outputTypes]=getEntityPortsImpl(~)
            inputTypes={'esbEvent'};
            outputTypes={'subtask'};
        end
    end



    methods(Access=protected)
        function setupImpl(h,~,~)
            h.CurrAperiodicEvent=uint32(0);
            h.CurrTaskServersTaskPris=zeros(1,h.Environment.NumCores);
            h.CurrTaskServersPreEmptible=true(1,h.Environment.NumCores);
            reg=soc.internal.ESBRegistry.manageInstance(...
            'getfullmodelreferencehierarchy',h.ModelName);
            h.TaskExViewerObj=reg.getTaskViewer(h.ModelName);
        end
        function resetImpl(h)

            h.CurrEventType=uint32(0);
            h.CurrClockTick=uint32(0);
            h.CurrTaskGen=uint32(0);
        end
        function releaseImpl(h)
            reg=soc.internal.ESBRegistry.manageInstance(...
            'getfullmodelreferencehierarchy',h.ModelName);
            reg.destroyTaskViewer(h.ModelName);
            h.TaskExViewerObj.clear;
        end
    end



    methods(Access=protected)
        function events=setupEventsImpl(h)
            h.verifyEnvironment;
            if~codertarget.utils.isESBEnabled(getActiveConfigSet(h.ModelName))
                events=[];
                return;
            end
            h.registerEventsAndTasks;
            h.setStartTimeForEventSources;
            for i=1:size(h.Tasks,1)
                h.TaskRunning(i)=0;
                h.TaskBlocked(i)=0;
                h.NumTaskTriggersPending(i)=0;
                h.updateSDITaskLog(i,h.StartTime,soc.profiler.TaskState.Waiting);
            end

            usedCores=[];
            for i=1:size(h.Tasks,1)
                usedCores=[usedCores,h.Tasks{i,5}];%#ok<AGROW>
            end
            for k=0:h.Environment.NumCores-1
                if~ismember(k,usedCores),continue;end
                h.updateSDICoreLog(uint32(k),h.StartTime,uint32(0));
            end

            if size(h.Tasks,1)>0
                events=h.eventGenerate(h.StTaskWait,'taskGen',0,1);
            else
                events=[];
            end
            events=[events,h.eventGenerate(h.StClockTicker,'clockGen',0,1)];

            esbEvents=h.getEventsFromAllEventSources;
            for idx=1:numel(esbEvents)



                if esbEvents(idx).IsDurationFromDiagnostics
                    i=h.getTaskIndexForEvent(esbEvents(idx).eventID);
                    h.Runnables{i,3}=esbEvents(idx).TaskDuration;
                    h.Runnables{i,4}=0;
                end
                deltaT=esbEvents(idx).deltaT;

                if~isequal(h.getTaskIndexForEvent(esbEvents(idx).eventID),-1)
                    deltaT=deltaT+h.Environment.KernelLatency;
                end
                tag=soc.internal.constructEventName(esbEvents(idx).eventID);
                newEvent=h.eventGenerate(h.StEventQueue,tag,deltaT,2);
                events=[events,newEvent];%#ok<AGROW> %
            end

        end
    end





    methods(Access=protected)
        function[entity,events]=esbEventGenerateImpl(h,stLoc,entity,tag)




            events=[];
            if stLoc==h.StEventQueue
                if(strcmp(tag,'clockTick'))

                    entity.data.type=h.EvClockTick;
                    events=h.eventForward('storage',h.StEventServer,0);
                else
                    prefix=DAStudio.message('soc:scheduler:CustomEventNamePrefix');
                    assert(isequal(strfind(tag,prefix),1));

                    entity.data.type=uint32(5);
                    [~,eventIdx]=ismember(tag,h.CustomEvents);
                    if(eventIdx==0)
                        return;
                    end
                    entity.data.index=uint32(eventIdx);
                    entity.sys.priority=double(entity.data.index);
                    events=h.eventForward('storage',h.StEventServer,0);





                    if~ismember(tag,h.Tasks(:,2))
                        events=h.addNextCustomEvent(events,eventIdx);
                    end
                end
            end
        end

        function[entity,events]=esbEventEntryImpl(h,stLoc,entity,src)%#ok<INUSD>



            events=[];
            if isequal(entity.data.type,5)&&isequal(entity.data.index,0)
                entity=h.assignIndexToGenericCustomEntity(entity);
            end
            if stLoc==h.StEventQueue

                entity.priority=1;
                events=h.eventForward('storage',h.StEventServer,0);
            elseif stLoc==h.StEventServer

                switch entity.data.type
                case h.EvPowerUp

                    events=[events,h.eventIterate(h.StTaskWait,'checkReady'),...
                    h.eventIterate(h.StEventServer,'destroyCurrentEvent')];
                    h.CurrEventType=h.EvPowerUp;
                case h.EvClockStart
                    h.CurrClockTick=uint32(0);
                    events=[events,h.eventIterate(h.StClockTicker,...
                    'enableClock')];

                    events=[events,h.eventIterate(h.StTaskWait,'checkReady'),...
                    h.eventIterate(h.StEventServer,'destroyCurrentEvent')];
                    h.CurrEventType=h.EvClockTick;
                case h.EvClockTick
                    h.CurrClockTick=h.CurrClockTick+1;
                    for k=1:h.Environment.NumCores
                        events=[events,h.eventIterate(h.StTaskServer+k-1,...
                        'checkOverrun')];%#ok
                    end

                    events=[events,h.eventIterate(h.StTaskWait,'checkReady'),...
                    h.eventIterate(h.StEventServer,'destroyCurrentEvent')];
                    h.CurrEventType=h.EvClockTick;
                case h.EvCustom
                    eventIdx=entity.data.index;
                    h.CurrAperiodicEvent=eventIdx;
                    entity.sys.priority=double(eventIdx);
                    for k=1:h.Environment.NumCores
                        events=[events,h.eventIterate(h.StTaskServer+k-1,...
                        'checkOverrun')];%#ok
                    end

                    events=[events,h.eventIterate(h.StTaskWait,'checkReady'),...
                    h.eventIterate(h.StEventServer,'destroyCurrentEvent')];
                    h.CurrEventType=h.EvCustom;
                    eventID=h.getEventIDForIdx(eventIdx);
                    taskIdx=h.getTaskIndexForEvent(eventID);
                    if~isequal(taskIdx,-1)&&...
                        h.TaskRunning(taskIdx)&&~h.isTimerEvent(eventID)
                        h.NumTaskTriggersPending(eventIdx)=...
                        h.NumTaskTriggersPending(eventIdx)+1;
                    end
                otherwise
                    assert(true);
                end
            end
        end

        function events=esbEventDestroyImpl(h,stLoc,entity)%#ok<INUSD>
            events=[];
        end

        function[entity,events,next]=esbEventIterateImpl(h,stLoc,entity,tag,status)%#ok<INUSD>

            if strcmp(tag,'removeTaskEvents')
                assert(stLoc==h.StEventQueue||stLoc==h.StEventServer);
                events=h.eventDestroy();
            elseif strcmp(tag,'destroyCurrentEvent')
                events=h.eventDestroy();
            else
                assert(1);
            end
            next=true;
        end
    end




    methods(Access=protected)
        function[entity,events]=taskGenerateImpl(h,stLoc,entity,tag)


            assert(stLoc==h.StTaskWait);
            assert(strcmp(tag,'taskGen'));
            events=[];
            h.CurrTaskGen=h.CurrTaskGen+uint32(1);
            currName=h.Tasks{h.CurrTaskGen,1};
            entity.data.idx=h.CurrTaskGen;
            entity.data.taskPriority=h.Tasks{h.CurrTaskGen,4};
            entity.data.core=uint32(h.Tasks{h.CurrTaskGen,5});
            entity.data.preemptible=logical(h.Tasks{h.CurrTaskGen,6});
            entity.data.name(1:length(currName))=uint8(currName);
            entity.data.color=h.TaskColors(h.CurrTaskGen,:);
            currEventType=h.Tasks{h.CurrTaskGen,2};
            switch currEventType
            case 'initialize'
                entity.data.type=h.EvPowerUp;
            case 'terminate'
                entity.data.type=h.EvPowerDown;
            case 'clock'
                entity.data.type=h.EvClockTick;
                entity.data.clockMultiple=uint32(...
                h.Tasks{h.CurrTaskGen,3});
            case 'unassigned'
                entity.data.type=h.EvDead;
                entity.data.taskPriority=0;
            otherwise
                entity.data.type=h.EvCustom;
                entity.data.customEventID=...
                uint32(find(strcmp(h.CustomEvents,currEventType),1));


                if isequal(currEventType,'CustomEventID_<empty>')
                    entity.data.customEventID=uint32(numel(h.CustomEvents)+1);
                end
            end

            nUsed=0;
            for k=1:size(h.Runnables,1)
                if h.Runnables{k,2}==h.CurrTaskGen
                    nUsed=nUsed+1;
                    entity.data.runnableWireless(nUsed)=...
                    logical(h.Runnables{k,5});
                    entity.data.runnableIDs(nUsed)=...
                    uint32(h.Runnables{k,6});
                    entity.data.runnableDurationsMean(nUsed)=...
                    h.Runnables{k,3};
                    entity.data.runnableDurationsVar(nUsed)=...
                    h.Runnables{k,4};
                end
            end
            if nUsed==0

                entity.data.type=h.EvDead;
                entity.data.taskPriority=0;
            end
            if h.CurrTaskGen<size(h.Tasks,1)

                events=h.eventGenerate(h.StTaskWait,'taskGen',0,1);
            end
        end

        function[entity,events]=taskTimerImpl(h,stLoc,entity,tTag)
            events=[];
            if stLoc>=h.StTaskServer
                assert(strcmp(tTag,'runnableDue'));


                if entity.data.runnableWireless(entity.data.currentRunnableID)
                    preStr='WLRcomp';
                else
                    preStr='WRcomp';
                end
                events=[events,...
                h.eventGenerate(h.StSubtaskGen,...
                [preStr,'_',int2str(entity.data.runnableIDs(...
                entity.data.currentRunnableID))],0,1)];

                entity.data.currentRunnableID=...
                entity.data.currentRunnableID+1;
                entity.data.currentRunnableStartTime=h.getCurrentTime;
                entity.data.currentRunnableRemTime=0;
                if entity.data.runnableIDs(entity.data.currentRunnableID)~=0

                    events=[events,h.eventTimer(...
                    'runnableDue',...
                    entity.data.runnableDurations(...
                    entity.data.currentRunnableID))];
                else
                    entity.data.currAssignedCore=uint32(0);
                    entity.data.currentRunnableID=uint32(0);
                    entity.data.currentRunnableStartTime=0;

                    [events,addedEvent]=h.addNextCustomEvent(events,...
                    entity.data.customEventID);
                    h.dropOverranEvents();

                    events=[events,h.eventGenerate(h.StSubtaskGen,...
                    ['Tend_',int2str(entity.data.idx)],0,1)];
                    h.TaskRunning(entity.data.idx)=0;
                    if h.NumTaskTriggersPending(entity.data.idx)>0
                        if h.isDropOverranTaskOn(entity.data.idx)
                            while(h.NumTaskTriggersPending(entity.data.idx)>0)
                                h.NumTaskTriggersPending(entity.data.idx)=...
                                h.NumTaskTriggersPending(entity.data.idx)-1;
                                h.logDroppedTask(entity.data.idx);
                            end

                            events=[events,h.eventForward('storage',...
                            h.StTaskWait,0)];
                        else
                            h.NumTaskTriggersPending(entity.data.idx)=...
                            h.NumTaskTriggersPending(entity.data.idx)-1;

                            events=[events,h.eventForward('storage',...
                            h.StTaskReady,0)];
                        end
                    elseif~isempty(addedEvent)&&isequal(addedEvent.delay,0)

                        events=[events,h.eventForward('storage',...
                        h.StTaskReady,0)];
                    else

                        events=[events,h.eventForward('storage',...
                        h.StTaskWait,0)];
                    end
                end
            end
        end

        function updateTaskStateFile(h)
            fid=fopen('taskStates.txt','w');
            for i=1:numel(h.TaskRunning)
                if h.TaskRunning(i)
                    fprintf(fid,'%12.6f\n',h.Tasks{i,3});
                end
            end
            fclose(fid);
        end

        function[entity,events]=taskEntryImpl(h,stLoc,entity,src)%#ok<INUSD>
            events=[];
            if stLoc==h.StTaskReady


                events=[events,h.eventIterate(h.StTaskReady,'pullNextReady')];
            elseif stLoc>=h.StTaskServer


                if entity.data.currentRunnableID==0
                    for k=1:length(entity.data.runnableDurationsMean)
                        runnableIdx=entity.data.runnableIDs(k);
                        if runnableIdx>0
                            entity.data.runnableDurations(k)=...
                            h.getDurationValue(runnableIdx);
                        else
                            break;
                        end
                    end
                end

                if entity.data.currentRunnableID==0

                    h.updateTaskStateFile();
                    entity.data.currentRunnableID=uint32(1);
                    entity.data.currentRunnableStartTime=h.getCurrentTime;
                    entity.data.wasPreempted=false;
                    h.updateSDITaskLog(entity.data.idx,h.getCurrentTime,...
                    soc.profiler.TaskState.Running);
                    h.updateSDICoreLog(entity.data.core,h.getCurrentTime,...
                    entity.data.idx);

                    for idxRT=1:h.NumberOfRTForTask(entity.data.idx)
                        events=[events,h.eventGenerate(h.StSubtaskGen,...
                        ['RTrun_',int2str(entity.data.idx+idxRT-1)],0,1)];%#ok<AGROW>
                    end
                    events=[events,h.eventGenerate(h.StSubtaskGen,...
                    ['Tstart_',int2str(entity.data.idx)],0,1)];

                    if(isequal(h.TaskBlocks(entity.data.idx).PlaybackRecorded,'on'))
                        taskDuration=h.Runnables{entity.data.idx,3};
                    elseif isequal(h.TaskBlocks(entity.data.idx).DurationSource,...
                        'Input port')
                        taskDuration=h.getDurationViaInputPort(...
                        h.TaskBlocks(entity.data.idx).BlockHandle);
                        if(taskDuration<0)






                            taskName=deblank(char(entity.data.name)');
                            error(message('soc:scheduler:InvalidTaskDurationInpPort',...
                            num2str(taskDuration),taskName));
                        end
                        entity.data.runnableDurations(entity.data.currentRunnableID)=taskDuration;
                    else
                        taskDuration=entity.data.runnableDurations(entity.data.currentRunnableID);
                    end
                    events=[events,h.eventTimer('runnableDue',taskDuration)];
                else

                    cTime=h.getCurrentTime;
                    taskDuration=...
                    entity.data.runnableDurations(entity.data.currentRunnableID);
                    entity.data.currentRunnableRemTime=...
                    entity.data.currentRunnableRemTime+...
                    h.Environment.TaskContextRestoreTime;
                    entity.data.currentRunnableStartTime=cTime-...
                    taskDuration+...
                    entity.data.currentRunnableRemTime;
                    h.updateSDITaskLog(entity.data.idx,h.getCurrentTime,...
                    soc.profiler.TaskState.Running);
                    h.updateSDICoreLog(entity.data.core,h.getCurrentTime,...
                    entity.data.idx);

                    events=[events,h.eventGenerate(h.StSubtaskGen,...
                    ['Tresume_',int2str(entity.data.idx)],0,1)];

                    events=[events,h.eventTimer('runnableDue',...
                    entity.data.currentRunnableRemTime)];
                end
            end
        end

        function[entity,events,next]=taskIterateImpl(h,stLoc,entity,tag,status)%#ok<INUSD>
            events=[];
            switch tag
            case 'debug'
keyboard
                events=[];
                next=true;
            case 'checkReady'
                assert(stLoc==h.StTaskWait);
                [entity,events,next]=taskIterateFindReady(h,entity);
            case 'pullNextReady'
                assert(stLoc==h.StTaskReady);
                [entity,events,next]=taskIteratePullNextReady(h,entity);
            case 'moveBackToWait'
                assert(stLoc==h.StTaskReady||stLoc>=h.StTaskServer);
                [entity,events,next]=taskIterateMoveBackToWait(h,entity);
            case 'preEmpt'
                assert(stLoc>=h.StTaskServer);
                cTime=h.getCurrentTime;

                crTime=entity.data.runnableDurations(entity.data.currentRunnableID);
                entity.data.currentRunnableRemTime=...
                crTime-(cTime-entity.data.currentRunnableStartTime);
                entity.data.currAssignedCore=uint32(0);
                events=[h.eventGenerate(h.StSubtaskGen,...
                ['Tsuspend_',int2str(entity.data.idx)],0,1),...
                h.cancelTimer('runnableDue'),...
                h.eventForward('storage',h.StTaskReady,0)];
                events(3).delay=...
                h.Environment.TaskContextSaveTime;
                next=false;
            case 'checkOverrun'
                assert(stLoc>=h.StTaskServer);
                hasOverrun=false;
                if entity.data.type==h.CurrEventType
                    if entity.data.type==h.EvClockTick
                        if(entity.data.clockMultiple==1||...
                            rem(h.CurrClockTick,entity.data.clockMultiple-1)==0)
                            hasOverrun=true;
                        end
                    elseif entity.data.type==h.EvCustom
                        if h.CurrAperiodicEvent==entity.data.customEventID
                            hasOverrun=true;
                        end
                    end
                end
                if hasOverrun
                    events=[events...
                    ,h.eventGenerate(...
                    h.StSubtaskGen,...
                    ['Toverrun_',int2str(entity.data.idx)],0,1)];
                end
                next=true;
            otherwise
                events=[];
                next=false;
                assert(true);
            end
        end

        function[entity,events,next]=taskIterateFindReady(h,entity)
            events=[];
            if entity.data.type==h.CurrEventType
                switch h.CurrEventType
                case{h.EvPowerUp,h.EvPowerDown}
                    events=[events,h.eventForward('storage',h.StTaskReady,0)];
                case h.EvCustom
                    if h.CurrAperiodicEvent==entity.data.customEventID
                        events=[events,h.eventForward('storage',...
                        h.StTaskReady,0)];
                    end
                case h.EvClockTick
                    if(entity.data.clockMultiple==1||...
                        rem(h.CurrClockTick,entity.data.clockMultiple)==0)
                        events=[events,h.eventForward('storage',...
                        h.StTaskReady,0)];
                    end
                end
            end
            next=true;
        end

        function res=isUpstreamTaskRunningOrBlocked(h,taskIdx)
            res=0;
            if~isempty(h.TaskDependencies{taskIdx})
                for i=1:numel(h.TaskDependencies{taskIdx})
                    upsTaskIdx=h.TaskDependencies{taskIdx}(i);
                    res=res||...
                    h.TaskRunning(upsTaskIdx)||...
                    h.TaskBlocked(upsTaskIdx);
                end
            end
        end

        function[entity,events,next]=taskIteratePullNextReady(h,entity)
            events=[];
            if entity.data.currAssignedCore==uint32(0)
                taskIdx=entity.data.idx;
                coreIdx=entity.data.core+1;
                upstreamTaskRunning=h.isUpstreamTaskRunningOrBlocked(taskIdx);
                h.TaskBlocked(taskIdx)=upstreamTaskRunning;
                if~upstreamTaskRunning&&...
                    h.CurrTaskServersPreEmptible(coreIdx)&&...
                    (h.CurrTaskServersTaskPris(coreIdx)<entity.data.taskPriority)
                    h.TaskRunning(taskIdx)=1;
                    h.TaskBlocked(taskIdx)=0;
                    cNum=double(coreIdx);
                    if h.CurrTaskServersTaskPris(coreIdx)>0

                        events=[events,h.eventIterate(h.StTaskServer+cNum-1,'preEmpt')];
                    end
                    events=[events,h.eventForward(...
                    'storage',h.StTaskServer+cNum-1,0)];
                    h.CurrTaskServersTaskPris(coreIdx)=entity.data.taskPriority;
                    h.CurrTaskServersPreEmptible(coreIdx)=entity.data.preemptible;
                    entity.data.currAssignedCore=coreIdx;
                end
            end
            next=true;
        end

        function[entity,events,next]=taskIterateMoveBackToWait(h,entity)
            events=h.eventForward('storage',h.StTaskWait,0);
            next=true;
        end

        function events=taskExitImpl(h,stLoc,entity,dst)%#ok<INUSD>
            events=[];
            if stLoc>=h.StTaskServer
                if entity.data.currentRunnableID==0

                    h.CurrTaskServersTaskPris(stLoc-h.StTaskServer+1)=0;
                    h.CurrTaskServersPreEmptible(stLoc-h.StTaskServer+1)=true;
                    events=h.eventIterate(h.StTaskReady,'pullNextReady');
                    entity.data.wasPreempted=false;
                    h.updateSDITaskLog(entity.data.idx,h.getCurrentTime,...
                    soc.profiler.TaskState.Waiting);
                    h.updateSDICoreLog(entity.data.core,h.getCurrentTime,...
                    uint32(0));
                else

                    entity.data.wasPreempted=true;
                    h.updateSDITaskLog(entity.data.idx,h.getCurrentTime,...
                    soc.profiler.TaskState.Ready);
                    h.updateSDICoreLog(entity.data.core,h.getCurrentTime,...
                    uint32(0));
                end
            end
        end
    end



    methods(Access=protected)
        function[entity,events]=subtaskGenerateImpl(h,stLoc,entity,tag)
            assert(stLoc==h.StSubtaskGen);
            if strncmp(tag,'Tstart',6)
                entity.data.type=uint32(h.STTaskStart);
            elseif strncmp(tag,'Tend',4)
                entity.data.type=uint32(h.STTaskEnd);
            elseif strncmp(tag,'Tsuspend',8)
                entity.data.type=uint32(h.STTaskSuspend);
            elseif strncmp(tag,'Tresume',7)
                entity.data.type=uint32(h.STTaskResume);
            elseif strncmp(tag,'Toverrun',8)
                entity.data.type=uint32(h.STTaskOverrun);
            elseif strncmp(tag,'WRcomp',6)
                entity.data.type=uint32(h.STWRunnableComplete);
            elseif strncmp(tag,'WLRcomp',7)
                entity.data.type=uint32(h.STWLRunnableComplete);
            elseif strncmp(tag,'RTrun',5)
                entity.data.type=uint32(h.STRTRun);
            else
                assert(true);
            end
            [~,idxStr]=strtok(tag,'_');
            idxVal=uint32(str2double(idxStr(2:end)));
            entity.data.idx=idxVal;
            events=h.eventForward('output',1,0);
        end
    end



    methods(Access=protected)


        function taskMgr=getTaskManagerBlockName(h)
            thisBlk=h.TaskManagerBlock;
            taskMgr=[];
            while(~isempty(thisBlk))
                if isequal(get_param(thisBlk,'MaskType'),'Task Manager')
                    taskMgr=thisBlk;
                    break;
                end
                thisBlk=get_param(thisBlk,'Parent');
            end
            assert(~isempty(taskMgr),'Task Manager block not found.');
        end
        function checkAllModelsConsistent(h,topMdlBoard)
            import soc.internal.connectivity.*
            taskMgr=h.getTaskManagerBlockName;
            refMdlHdl=getModelConnectedToTaskManager(taskMgr);
            if isequal(get_param(refMdlHdl,'BlockType'),'ModelReference')
                refMdlName=get_param(refMdlHdl,'ModelName');
                refMdlBoard=get_param(refMdlName,'HardwareBoard');
                if~isequal(refMdlBoard,topMdlBoard)
                    error(message('soc:msgs:BoardNameMismatch'));
                end
            end
        end

        function registerEventsAndTasks(h)
            import soc.internal.connectivity.*

            h.Tasks={};
            h.Runnables={};
            h.CustomEvents={};
            tskMgr=h.getTaskManagerBlockName;
            [sortedTasks,eventSrcs,eventIDList,eventCommTypeList]...
            =soc.internal.getEventsAndTasks(h,tskMgr);
            if isempty(sortedTasks),return;end
            h.EventSources=eventSrcs;
            h.TaskBlocks=sortedTasks;
            h.CustomEventIDs=eventIDList;
            h.CustomEventCommType=eventCommTypeList;
            for eventIdx=1:numel(eventIDList)
                ID=soc.internal.constructEventName(eventIDList{eventIdx});
                h.CustomEvents{end+1}=ID;
            end

            if contains([sortedTasks(:).PlaybackRecorded],'on')
                soc.internal.crosscheckModelAndRecordedData(h.ModelName);
            end

            cs=getActiveConfigSet(h.ModelName);
            valStore=DAStudio.message('codertarget:ui:SimDiagShowInSDIStorage');
            h.ShowInSDI=isequal(...
            codertarget.data.getParameterValue(cs,valStore),1);
            if h.ShowInSDI
                [showInSDI,saveToFile,overwriteFile]=...
                soc.internal.profile.getSimDiagnosticsOptions(h.ModelName);
                runDir='';
                if saveToFile
                    subName=DAStudio.message('soc:scheduler:SimDiagFolderPostfix');
                    runDir=soc.internal.profile.getSharedDiagnosticDirName(...
                    h.ModelName,subName,overwriteFile);
                    soc.internal.profile.saveTaskInfo(h.ModelName,subName);
                end
                h.TaskExViewerObj.initializeRun(showInSDI,h.ModelName);
                h.TaskExViewerObj.initializeSignals(saveToFile,runDir);
                h.TaskExViewerObj.initializeCores(sortedTasks);
                h.TaskExViewerObj.start;
            end
            rtBlkMap=soc.internal.getESBTaskRTInfo(h.ModelName);
            for idx=1:numel(sortedTasks)
                numRT=0;
                if rtBlkMap.isKey(sortedTasks(idx).Name)
                    numRT=numel(rtBlkMap(sortedTasks(idx).Name));
                end
                h.NumberOfRTForTask(idx)=numRT;
            end
            for idx=1:numel(sortedTasks)
                h.TaskDependencies{idx}=[];
            end
            if isMulticoreImplementation(h.ModelName,tskMgr)&&...
                isTaskManagerDrivingRateAdapterModel(tskMgr)
                h.TaskDependencies=getTaskOnFasterTaskDependencyMap(...
                h.ModelName,h.TopTaskManagerBlock);
            end
        end

        function setStartTimeForEventSources(h)
            srcKeys=h.EventSources.keys;
            for i=1:numel(srcKeys)
                hSrc=h.EventSources(srcKeys{i});
                hSrc.setStartTime(h.StartTime);
            end
        end

        function entity=assignIndexToGenericCustomEntity(h,entity)
            name=(char(entity.data.name'));
            name=deblank(name);
            eventID=soc.internal.constructEventName(name);
            [~,idx]=ismember(eventID,h.CustomEvents);
            entity.data.index=uint32(idx);
        end

        function val=getDurationValue(h,idxRunnable)
            if h.Runnables{idxRunnable,7}


                val=h.Runnables{idxRunnable,3};
            else
                durData=h.TaskDurationData{idxRunnable};
                if length(durData)==1
                    val=h.getNormal(durData);
                else
                    val=h.genCompositeRnd(idxRunnable);
                end
            end
        end

        function val=genCompositeRnd(h,idxRunnable)
            durData=h.TaskDurationData{idxRunnable};
            y=[durData(:).percent];
            [yprime,idx]=sort(y,'ascend');
            limits=0;
            for i=1:numel(yprime)
                val=limits(end)+yprime(i);
                limits=[limits,val];%#ok<AGROW>
            end
            limits=limits(2:end)/100;
            coinFlip=rand(1);
            for j=1:numel(yprime)
                if coinFlip<limits(j)
                    val=h.getNormal(durData(idx(j)));
                    break
                end
            end
        end

        function val=getNormal(~,elem)
            val=elem.mean+elem.dev*randn(1,1);
            if(val<elem.min)
                val=elem.min;
            elseif(val>elem.max)
                val=elem.max;
            end
        end

        function verifyEnvironment(h)
            reg=soc.internal.ESBRegistry.manageInstance(...
            'getfullmodelreferencehierarchy',h.ModelName);
            if numel(reg.Tasks)>h.Environment.MaxNumTasks
                error(message('soc:scheduler:MaxNumTasksExceeded',...
                numel(reg.Tasks),h.Environment.MaxNumTasks));
            end
            numTimerTasks=0;
            for i=1:numel(reg.Tasks)
                numTimerTasks=numTimerTasks+...
                isequal(reg.Tasks(i).EventID,'clock');
            end
            if numTimerTasks>h.Environment.MaxNumTimers
                error(message('soc:scheduler:MaxNumTimersExceeded',...
                numel(numTimerTasks),h.Environment.MaxNumTimers));
            end
        end

        function esbEvents=getEventsFromAllEventSources(h)
            if isempty(h.EventSources)
                esbEvents=[];
            else
                counter=0;
                keys=h.EventSources.keys;
                for idx=1:numel(keys)
                    thisSource=h.EventSources(keys{idx});
                    if isequal(thisSource.getCommType,'push')
                        continue;
                    end
                    eventID=thisSource.getEventID;
                    time=h.getCurrentTime;
                    event=thisSource.getNextEvent(eventID,time);
                    if~isempty(event)
                        deltaT=event.Time-time;
                        if(deltaT<0),continue;end
                        thisEvent.eventID=eventID;
                        thisEvent.deltaT=deltaT;
                        thisEvent.TaskDuration=event.TaskDuration;
                        thisEvent.IsDurationFromDiagnostics=...
                        event.IsDurationFromDiagnostics;
                        counter=counter+1;
                        esbEvents(counter)=thisEvent;%#ok<AGROW>
                    end
                end
                if(isequal(counter,0))
                    esbEvents=[];
                end
            end
        end

        function ret=isTimerEvent(h,eventID)
            ret=isa(h.EventSources(eventID),...
            'soc.internal.TimerEventSource');
        end

        function taskIdx=getTaskIndexForEvent(h,eventID)
            taskIdx=-1;
            taskBlocks=h.Tasks;
            for idx=1:size(taskBlocks,1)
                if isequal(['CustomEventID_',eventID],taskBlocks{idx,2})
                    taskIdx=idx;
                    break
                end
            end
        end

        function ret=isDropOverranTaskOn(h,idx)
            eventID=h.getEventIDForIdx(idx);
            ret=h.EventSources(eventID).getDropOverranTasks();
        end

        function logDroppedTask(h,idx)



            time=h.getCurrentTime;
            eventID=h.getEventIDForIdx(idx);
            srcObj=h.EventSources(eventID);
            srcObj.logDroppedTaskEvent(time);
        end

        function dropOverranEvents(h)
            time=h.getCurrentTime;
            keys=h.EventSources.keys;
            for i=1:numel(keys)
                thisSource=h.EventSources(keys{i});
                eventID=thisSource.getEventID;
                thisSource.dropPastEvents(eventID,time);
            end
        end

        function[events,addedEvent]=addNextCustomEvent(h,events,idx)



            if(~isequal(idx,0))
                if isequal(h.CustomEventCommType{idx},'push')
                    addedEvent=[];
                    return;
                end
                time=h.getCurrentTime;
                tag=h.CustomEvents{idx};
                eventID=h.getEventIDForIdx(idx);
                event=h.EventSources(eventID).getNextEvent(eventID,time);
                if~isempty(event)



                    if event.IsDurationFromDiagnostics
                        tskIdx=h.getTaskIndexForEvent(eventID);
                        h.Runnables{tskIdx,3}=event.TaskDuration;
                        h.Runnables{tskIdx,4}=0;
                    end
                    deltaT=event.Time-time;
                    tol=1e-9;





                    if(deltaT<0)||(deltaT<tol)
                        deltaT=0;
                    end

                    if~isequal(h.getTaskIndexForEvent(eventID),-1)
                        deltaT=deltaT+h.Environment.KernelLatency;
                    end
                    addedEvent=h.eventGenerate(h.StEventQueue,tag,deltaT,1);
                else
                    addedEvent=[];
                end
                events=[events,addedEvent];
            end
        end

        function updateSDITaskLog(h,taskIdx,stateTime,state)
            if~h.ShowInSDI,return;end
            if~h.TaskBlocks(taskIdx).LogExecutionData
                return;
            else
                name=h.TaskBlocks(taskIdx).Name;
                h.TaskExViewerObj.updateTaskLog(name,stateTime,state);
            end
        end

        function updateSDICoreLog(h,core,stateTime,state)
            if~h.ShowInSDI,return;end
            h.TaskExViewerObj.updateCoreLog(h.TopTaskManagerBlock,...
            core,stateTime,state);
        end

        function duration=getDurationViaInputPort(~,blkHandle)
            tskBlkName=get_param(blkHandle,'Name');
            actTaskSFcn=[get_param(blkHandle,'Parent'),'/',tskBlkName,'/','S-Function1'];
            rto=get_param(...
            actTaskSFcn,...
            'RuntimeObject');
            duration=rto.InputPort(1).Data;
        end
    end
end




