
































































classdef(Abstract)TaskManager<handle
    events
Done
Terminate
    end

    properties(Abstract,Constant,Access=protected)


mRegisteredEvents
mRegisteredCriticalEvents
mRegisteredChannels
    end

    properties(Constant,Access=private)




        mTaskManagerEvents=[...
        Sldv.Tasking.TaskManagerEvents.TaskLaunch;...
        ]
    end

    properties(Access=private)


        mState Sldv.Tasking.TaskManagerState;



        mTimer=[];




        mTimerListener=[];




        mTaskList=[];




        mChannelMap containers.Map;


        mChannelWriteListeners event.listener;


        mChannelDoneListeners event.listener;



        mEventTaskMap containers.Map;


        mStartTime;


        mTimeOut;



        mIsLocked=false;


        mHasTimedOut=false;

        mFlushed=false;

        mTerminatePending=false;
    end

    properties(Access=protected)


mPendingEvents




mReadyQueue



mPendingTasks


mErrorLog
    end




    methods



        function obj=TaskManager(aPeriod,aTimeOut)


            assert(isnumeric(aPeriod)&(numel(aPeriod)==1),'Period should be a numeric scalar');

            assert(numel(unique(obj.mRegisteredChannels))==numel(obj.mRegisteredChannels),'channel list should be unique');

            assert(numel(unique(obj.mRegisteredEvents))==numel(obj.mRegisteredEvents),'event list should be unique');

            assert(numel(unique(obj.mRegisteredCriticalEvents))==numel(obj.mRegisteredCriticalEvents),'critical event list should be unique');

            assert(isempty(obj.mRegisteredChannels)||isenum(obj.mRegisteredChannels));
            assert(isempty(obj.mRegisteredEvents)||isenum(obj.mRegisteredEvents));
            assert(isempty(obj.mRegisteredCriticalEvents)||isenum(obj.mRegisteredCriticalEvents));

            tEnumValues=[uint32(obj.mRegisteredChannels),uint32(obj.mRegisteredCriticalEvents),uint32(obj.mRegisteredEvents)];
            if numel(tEnumValues)~=numel(unique(tEnumValues))
                error('All the Enums should have a different uint values greater than 1');
            end


            obj.mStartTime=clock;


            if nargin<2
                obj.mTimeOut=Inf;
            else
                obj.mTimeOut=aTimeOut;
            end


            obj.mState=Sldv.Tasking.TaskManagerState.Created;


            obj.mTimer=internal.IntervalTimer(aPeriod);
            obj.mTimerListener=event.listener(obj.mTimer,'Executing',@(src,evt)obj.TaskMgrTimerCB(src,evt));

            obj.mChannelMap=containers.Map('KeyType','uint32','ValueType','any');
            obj.mEventTaskMap=containers.Map('KeyType','uint32','ValueType','any');


            for ch=1:numel(obj.mRegisteredChannels)
                tChannelList.Channel=Sldv.Tasking.Channel(obj);
                tChannelList.ChannelType=obj.mRegisteredChannels(ch);
                tChannelList.TaskList=[];


                chKey=uint32(obj.mRegisteredChannels(ch));
                obj.mChannelMap(chKey)=tChannelList;




                obj.mChannelWriteListeners(ch)=addlistener(tChannelList.Channel,'DataAvailable',...
                @(src,evt)obj.notifyChannelEvent(src,evt,tChannelList.ChannelType));



                obj.mChannelDoneListeners(ch)=addlistener(tChannelList.Channel,'AllWritersDone',...
                @(src,evt)obj.notifyChannelEvent(src,evt,tChannelList.ChannelType));
            end


            for evt=1:numel(obj.mRegisteredEvents)

                evtKey=uint32(obj.mRegisteredEvents(evt));
                obj.mEventTaskMap(evtKey)=[];
            end
        end




        function delete(obj)


            if~isempty(obj.mTimerListener)
                clear('obj.mTimerListener');
                obj.mTimerListener=[];
            end


            if~isempty(obj.mTimer)
                if obj.mTimer.isRunning
                    stop(obj.mTimer);
                end
                clear('obj.mTimer');
                obj.mTimer=[];
            end


            for ind=1:numel(obj.mChannelWriteListeners)
                delete(obj.mChannelWriteListeners(ind));
            end
            for ind=1:numel(obj.mChannelDoneListeners)
                delete(obj.mChannelDoneListeners(ind));
            end

        end
    end


    methods(Access=public)










        function addNewTask(obj,aTask,isReady)

            assert(isa(aTask,'Sldv.Tasking.Task'),'Invalid Task Object');
            assert(islogical(isReady)|isReady==1|isReady==0,'InValid Argument');



            assert(obj.mState==Sldv.Tasking.TaskManagerState.Created);

            assert(aTask.getId()==-1);





            aTask.setId(numel(obj.mTaskList)+1);


            if isempty(obj.mTaskList)
                obj.mTaskList={aTask};
            else
                obj.mTaskList(end+1)={aTask};
            end


            if isReady
                obj.insertToTaskQueue(aTask.getId(),Sldv.Tasking.TaskManagerEvents.TaskLaunch);
            end



            assert(obj.mTaskList{aTask.getId()}.getId()==aTask.getId());
        end











        function broadcastEvent(obj,aEvent)







            logStr=sprintf('Adding event [%s] to pending list\n',aEvent);
            obj.debug(logStr);
            if isempty(obj.mPendingEvents)
                obj.mPendingEvents={aEvent};
            else
                obj.mPendingEvents(end+1)={aEvent};
            end
        end



















        function connect(obj,aTaskId,aChannelType,aChannelMode)

            assert(obj.isChannelRegistered(aChannelType),'Invalid Channel');
            assert((aChannelMode==Sldv.Tasking.ChannelConnectMode.Read)||...
            (aChannelMode==Sldv.Tasking.ChannelConnectMode.Write),'Invalid Channel Mode');



            assert(obj.mState==Sldv.Tasking.TaskManagerState.Created);



            ch=obj.getChannel(aChannelType);
            ch.connect(aTaskId,aChannelMode);



            if aChannelMode==Sldv.Tasking.ChannelConnectMode.Write
                return;
            end


            chKey=uint32(aChannelType);
            assert(obj.mChannelMap.isKey(chKey),'Channel not registered in Map');
            tChannelData=obj.mChannelMap(chKey);


            if isempty(tChannelData.TaskList)
                tChannelData.TaskList=aTaskId;
            else
                tChannelData.TaskList(end+1)=aTaskId;
            end
            obj.mChannelMap(chKey)=tChannelData;

        end














        function disConnect(obj,aTaskId,aChannelType)

            assert(obj.isChannelRegistered(aChannelType),'Invalid Channel');

            ch=obj.getChannel(aChannelType);

            if(false==ch.isConnected(aTaskId))


                return;
            end


            ch.disConnect(aTaskId);


            chKey=uint32(aChannelType);
            assert(obj.mChannelMap.isKey(chKey),'Channel not registered in Map');
            tChannelData=obj.mChannelMap(chKey);


            if~isempty(tChannelData.TaskList)
                taskToDelete=find(tChannelData.TaskList==aTaskId);

                if~isempty(taskToDelete)
                    tChannelData.TaskList(taskToDelete)=[];
                end
            end

            return;

        end







        function triggerOn(obj,aTaskId,aEvent)

            assert(obj.isValidTask(aTaskId),'Invalid Task');
            assert(obj.isEventRegistered(aEvent),'Invalid Event');



            assert(obj.mState==Sldv.Tasking.TaskManagerState.Created);



            evtKey=uint32(aEvent);
            assert(obj.mEventTaskMap.isKey(evtKey),'Event not listed in map');

            tTaskList=obj.mEventTaskMap(evtKey);


            tTaskList(end+1)=aTaskId;

            obj.mEventTaskMap(evtKey)=tTaskList;
        end



        function runAsync(obj)


            assert(obj.mState==Sldv.Tasking.TaskManagerState.Created,'Task Manager in Invalid State');

            obj.mState=Sldv.Tasking.TaskManagerState.Idle;
            start(obj.mTimer);
        end



        function tryTerminate(obj)




            assert(Sldv.Tasking.TaskManagerState.Created==obj.mState||...
            Sldv.Tasking.TaskManagerState.Idle==obj.mState||...
            Sldv.Tasking.TaskManagerState.Running==obj.mState,'Task Manager:Invalid State');

            if Sldv.Tasking.TaskManagerState.Running==obj.mState||...
                obj.mIsLocked
                obj.mTerminatePending=true;

                return;
            end

            obj.terminate('DV_CAUSE_INTERRUPTED');
        end

        function terminate(obj,cause)






            if~isempty(obj.mTimerListener)
                clear('obj.mTimerListener');
                obj.mTimerListener=[];
            end

            stop(obj.mTimer);

            for ind=1:numel(obj.mTaskList)
                tTask=obj.mTaskList{ind};
                if~tTask.isDone()
                    tTask.cancel(cause);
                end

            end

            obj.mState=Sldv.Tasking.TaskManagerState.Aborted;

            obj.mPendingEvents=[];
            obj.mReadyQueue=[];

            notify(obj,'Terminate');

            return;
        end



        function status=isRunning(obj)
            status=(Sldv.Tasking.TaskManagerState.Running==obj.mState);
        end



        function status=isDone(obj)
            status=(Sldv.Tasking.TaskManagerState.Done==obj.mState);
        end



        function status=isCreated(obj)
            status=(Sldv.Tasking.TaskManagerState.Created==obj.mState);
        end


        function status=isAborted(obj)
            status=(Sldv.Tasking.TaskManagerState.Aborted==obj.mState);
        end


        function status=isIdle(obj)
            status=(Sldv.Tasking.TaskManagerState.Idle==obj.mState);
        end


        function status=hasTimedOut(obj)
            status=obj.mHasTimedOut;
        end



        function flush(obj)
            if(Sldv.Tasking.TaskManagerState.Aborted==obj.mState||...
                Sldv.Tasking.TaskManagerState.Done==obj.mState)
                return;
            end

            obj.mFlushed=true;


            obj.mPendingEvents=[];
            obj.mPendingTasks=[];
            obj.mReadyQueue=[];

        end




        function aChannel=getChannel(obj,aChannelType)

            chKey=uint32(aChannelType);

            tChannel=obj.mChannelMap(chKey);
            aChannel=tChannel.Channel;
        end



        function aTime=elapsedTime(obj)
            tNow=clock;
            aTime=etime(tNow,obj.mStartTime);
        end
    end




    methods(Access=private)





        function status=isEventRegistered(obj,aEvent)
            status=~isempty(find(obj.mRegisteredEvents==aEvent));%#ok<EFIND>
            status=status||~isempty(find(obj.mRegisteredCriticalEvents==aEvent));%#ok<EFIND>
        end





        function status=isChannelRegistered(obj,aChannel)
            status=~isempty(find(obj.mRegisteredChannels==aChannel));%#ok<EFIND>
        end






        function status=isValidTask(obj,aTaskId)
            status=false;

            if~isnumeric(aTaskId)||numel(aTaskId)~=1
                return;
            end

            if~(aTaskId<=numel(obj.mTaskList)&&aTaskId>0)
                return;
            end

            status=true;
        end




        function notifyChannelEvent(obj,~,~,aChannelType)
            logStr=sprintf('Adding event [%s] to pending list\n',aChannelType);
            obj.debug(logStr);
            if isempty(obj.mPendingEvents)
                obj.mPendingEvents={aChannelType};
            else
                obj.mPendingEvents(end+1)={aChannelType};
            end
        end

    end




    methods(Access=private)



        function cleanupLock(obj)
            if isvalid(obj)
                obj.mIsLocked=false;
            end

            return;
        end












        function TaskMgrTimerCB(obj,~,~)

            if(true==obj.mIsLocked)
                warning('Entering timer callback of TaskManager again before earlier has finished');
                return;
            end



            obj.mIsLocked=true;
            lockCleanup=onCleanup(@()obj.cleanupLock());

            if obj.mTerminatePending
                obj.mTerminatePending=false;
                try
                    obj.terminate('DV_CAUSE_INTERRUPTED');
                catch

                end
                return;
            end


            if obj.mFlushed
                obj.mFlushed=false;


                for ind=1:numel(obj.mTaskList)
                    tTask=obj.mTaskList{ind};
                    if~tTask.isDone()
                        tTask.clear();
                    end
                end

                return;
            end



            if~isempty(obj.mReadyQueue)
                status=isequal([obj.mReadyQueue.TaskId],unique([obj.mReadyQueue.TaskId],'stable'));

            end






            if obj.isRunning()
                return;
            end


            status=obj.isCritical();
            if status



                try
                    obj.terminate('DV_CAUSE_INTERRUPTED');
                catch MEx
                    if~isvalid(obj)

                        return;
                    end
                end
                return;
            end









            status=obj.allTasksDone();
            if status




                try
                    obj.done();
                catch MEx
                    if~isvalid(obj)

                        return;
                    end
                end
                return;
            end


            if obj.elapsedTime>obj.mTimeOut
                obj.mHasTimedOut=true;



                try
                    obj.terminate('DV_CAUSE_TIMEOUT');
                catch MEx
                    if~isvalid(obj)

                        return;
                    end
                end
                return;
            end


            obj.removeDoneTasks();



            obj.addPendingTasks();



            while(1)
                evt=obj.getPendingEvent();
                if isempty(evt)
                    break;
                end
                logStr=sprintf('Adding tasks for pending event [%s] to ready/pending task list\n',evt);
                obj.debug(logStr);


                obj.addTasksByEvent(evt);
            end

            [tTaskId,tEvent]=obj.getReadyTask();
            if isempty(tTaskId)
                return;
            end

            try
                tTask=obj.mTaskList{tTaskId};
                logStr=sprintf('Running task [%s] for event [%s]\n',class(tTask),tEvent);
                obj.debug(logStr);

                obj.mState=Sldv.Tasking.TaskManagerState.Running;

                [isYield,yieldEvent]=tTask.run(tEvent);

                obj.mState=Sldv.Tasking.TaskManagerState.Idle;


                if isYield























                    obj.addPendingTasks();
                    obj.insertToTaskQueue(tTaskId,yieldEvent);
                end

            catch Mex






                if~isvalid(obj)
                    return;
                end

                obj.mErrorLog=Mex;
                if~obj.isAborted()
                    try
                        obj.terminate('DV_CAUSE_ERROR');
                    catch

                    end

                end
                return;
            end

            return;
        end




        function status=isCritical(obj)
            status=false;

            for ind1=1:numel(obj.mRegisteredCriticalEvents)
                tCriticalEvent=obj.mRegisteredCriticalEvents(ind1);

                for ind2=1:numel(obj.mPendingEvents)
                    if tCriticalEvent==obj.mPendingEvents{ind2}
                        status=true;
                        break;
                    end
                end
                if status
                    break;
                end
            end
        end




        function status=allTasksDone(obj)
            status=false;

            if~isempty(obj.mPendingEvents)
                return;
            end

            if~isempty(obj.mPendingTasks)
                return;
            end

            if~isempty(obj.mReadyQueue)
                return;
            end


            for ind=1:numel(obj.mTaskList)
                tTask=obj.mTaskList{ind};
                status=tTask.isDone();
                if~status
                    return;
                end
            end






            status=true;

            return;
        end






        function done(obj)


            assert(obj.mState==Sldv.Tasking.TaskManagerState.Created||...
            obj.mState==Sldv.Tasking.TaskManagerState.Idle,'Task Manager:Invalid State');

            assert(isempty(obj.mPendingEvents),'Still have some pending events');

            assert(isempty(obj.mReadyQueue),'Still have some tasks in ready queue');

            assert(isempty(obj.mPendingTasks),'Still have some tasks in pending queue');


            if~isempty(obj.mTimerListener)
                clear('obj.mTimerListener');
                obj.mTimerListener=[];
            end

            stop(obj.mTimer);


            obj.mState=Sldv.Tasking.TaskManagerState.Done;


            notify(obj,'Done');

            return;
        end



        function removeDoneTasks(obj)
            toDelete=[];

            sz=numel(obj.mReadyQueue);
            for ind=1:sz
                tTaskId=obj.mReadyQueue(ind).TaskId;
                tTask=obj.mTaskList{tTaskId};
                if tTask.isDone()
                    logStr=sprintf('Marking done task [%s] for deletion from ready queue\n',class(tTask));
                    obj.debug(logStr);
                    toDelete(end+1)=ind;%#ok<AGROW>
                end
            end
            if~isempty(toDelete)
                obj.mReadyQueue(toDelete)=[];
            end

            toDelete=[];

            sz=numel(obj.mPendingTasks);
            for ind=1:sz
                tTaskId=obj.mPendingTasks(ind).TaskId;
                tTask=obj.mTaskList{tTaskId};
                if tTask.isDone()
                    logStr=sprintf('Marking done task [%s] for deletion from pending task list\n',class(tTask));
                    obj.debug(logStr);
                    toDelete(end+1)=ind;%#ok<AGROW>
                end
            end
            if~isempty(toDelete)
                obj.mPendingTasks(toDelete)=[];
            end

        end



        function addPendingTasks(obj)
            toDelete=[];
            for ind=1:numel(obj.mPendingTasks)
                tTaskId=obj.mPendingTasks(ind).TaskId;
                tTask=obj.mTaskList{tTaskId};

                isAdded=obj.isTaskInReadyQueue(tTaskId);



                if~isAdded
                    tEvt=obj.mPendingTasks(ind).Event;
                    logStr=sprintf('Inserting task [%s] from pending list to ready queue for [%s] event and marking it for deletion from pending task list\n',class(tTask),tEvt);
                    obj.debug(logStr);
                    obj.insertToReadyQueue(tTaskId,tEvt);
                    toDelete(end+1)=ind;%#ok<AGROW>
                else
                    logStr=sprintf('Retaining task [%s] in pending list as it is already present in ready queue\n',class(tTask));
                    obj.debug(logStr);
                end
            end



            if~isempty(toDelete)
                obj.mPendingTasks(toDelete)=[];
            end
        end





        function status=isTaskInReadyQueue(obj,aTaskId)
            status=false;
            for ind=1:numel(obj.mReadyQueue)
                tId=obj.mReadyQueue(ind).TaskId;
                if tId==aTaskId
                    status=true;
                    break;
                end
            end
        end




        function evt=getPendingEvent(obj)
            evt=[];

            if isempty(obj.mPendingEvents)
                return;
            end

            evt=obj.mPendingEvents{1};
            obj.mPendingEvents(1)=[];
        end





        function addTasksByEvent(obj,evt)

            evtKey=uint32(evt);
            if obj.mEventTaskMap.isKey(evtKey)
                tTaskList=obj.mEventTaskMap(evtKey);

                for ind=1:numel(tTaskList)
                    tTaskId=tTaskList(ind);
                    logStr=sprintf('Inserting task [%s] for event [%s] in ready/pending task list\n',...
                    class(obj.mTaskList{tTaskId}),evt);
                    obj.debug(logStr);
                    obj.insertToTaskQueue(tTaskId,evt);
                end
            elseif obj.mChannelMap.isKey(evtKey)
                tTaskList=obj.mChannelMap(evtKey).TaskList;

                for ind=1:numel(tTaskList)
                    tTaskId=tTaskList(ind);
                    logStr=sprintf('Inserting task [%s] for channel event [%s] in ready/pending task list\n',...
                    class(obj.mTaskList{tTaskId}),evt);
                    obj.debug(logStr);
                    obj.insertToTaskQueue(tTaskId,evt);
                end
            end
        end




        function insertToTaskQueue(obj,aTaskId,aEvent)











            if obj.mTaskList{aTaskId}.isDone()
                return;
            end



            isAdded=obj.isTaskInReadyQueue(aTaskId);
            if~isAdded

                logStr=sprintf('Inserting task [%s] for event [%s] to ready queue\n',...
                class(obj.mTaskList{aTaskId}),aEvent);
                obj.debug(logStr);
                obj.insertToReadyQueue(aTaskId,aEvent);
            else

                logStr=sprintf('Adding task [%s] for event [%s] to pending task list\n',...
                class(obj.mTaskList{aTaskId}),aEvent);
                obj.debug(logStr);
                if isempty(obj.mPendingTasks)
                    obj.mPendingTasks=struct('TaskId',aTaskId,'Event',aEvent);
                else
                    obj.mPendingTasks(end+1).TaskId=aTaskId;
                    obj.mPendingTasks(end).Event=aEvent;
                end
            end
        end





        function insertToReadyQueue(obj,aTaskId,aEvent)

            logStr=sprintf('Inserted task [%s] for event [%s] in ready queue\n',...
            class(obj.mTaskList{aTaskId}),aEvent);
            obj.debug(logStr);
            if isempty(obj.mReadyQueue)
                obj.mReadyQueue=struct('TaskId',aTaskId,'Event',aEvent);
            else
                obj.mReadyQueue(end+1).TaskId=aTaskId;
                obj.mReadyQueue(end).Event=aEvent;
            end


            tTask=obj.mTaskList{aTaskId};
            tTask.notifyQueued();
        end



        function[aTaskId,aEvent]=getReadyTask(obj)
            aTaskId=[];
            aEvent=[];
            if isempty(obj.mReadyQueue)
                return;
            end

            aTaskId=obj.mReadyQueue(1).TaskId;
            aEvent=obj.mReadyQueue(1).Event;



            obj.mReadyQueue(1)=[];
        end



        function debug(~,logStr)
            loggerId='sldv::task_manager';

            sldvprivate('SLDV_LOG_DEBUG',loggerId,logStr);

            return;
        end

    end
end
