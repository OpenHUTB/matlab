




classdef(Abstract)Task<handle











    properties(Access=protected)
        mTaskManagerH=[];
    end

    properties(Access=private)
        mState=Sldv.Tasking.TaskState.None;
        mTaskId=-1;
        mYield=false;
        mYieldEvent;
        mDone=false;
        mErrorId=-1;
        mErrorMsg='';
    end




    methods(Hidden,Sealed=true)


        function setId(obj,tId)

            assert(Sldv.Tasking.TaskState.Created==obj.mState);

            obj.mTaskId=tId;

            return;
        end


        function tId=getId(obj)
            tId=obj.mTaskId;

            return;
        end



        function notifyQueued(obj)


            assert((Sldv.Tasking.TaskState.Running~=obj.mState)&&...
            (Sldv.Tasking.TaskState.Done~=obj.mState)&&...
            (Sldv.Tasking.TaskState.Cancelled~=obj.mState));



            obj.mState=Sldv.Tasking.TaskState.Ready;


            obj.mErrorId=[];
            obj.mErrorMsg='';


            obj.mYield=false;
        end



        function[yield,yieldEvent]=run(obj,event)

            assert(Sldv.Tasking.TaskState.Ready==obj.mState);


            obj.mState=Sldv.Tasking.TaskState.Running;

            try
                obj.mYieldEvent=event;
                status=obj.doTask(event);


                if(obj.mDone)
                    obj.doCleanup('DV_CAUSE_DONE');
                    obj.mState=Sldv.Tasking.TaskState.Done;


                elseif(true==status)
                    obj.mState=Sldv.Tasking.TaskState.Completed;
                else
                    obj.mState=Sldv.Tasking.TaskState.Failed;
                end
            catch MEx
                LoggerId='sldv::task_manager';
                logStr=sprintf('Task::run::Exception - %s',MEx.message);
                sldvprivate('SLDV_LOG_DEBUG',LoggerId,logStr);





                if~isvalid(obj)
                    rethrow(MEx);
                end
                obj.mState=Sldv.Tasking.TaskState.Failed;
                obj.mErrorId=MEx.identifier;
                obj.mErrorMsg=MEx.message;


            end

            yield=obj.mYield;
            yieldEvent=obj.mYieldEvent;
        end



        function errId=getErrorId(obj)
            errId=obj.mErrorId;

            return;
        end



        function errMsg=getErrorMsg(obj)
            errMsg=obj.mErrorMsg;

            return;
        end



        function cancel(obj,cause)
            try
                obj.doCleanup(cause);
            catch MEx
                LoggerId='sldv::task_manager';
                logStr=sprintf('Task::cancel::Exception - %s',MEx.message);
                sldvprivate('SLDV_LOG_DEBUG',LoggerId,logStr);
                obj.mErrorId=MEx.identifier;
                obj.mErrorMsg=MEx.message;


            end
            obj.mState=Sldv.Tasking.TaskState.Cancelled;
        end



        function clear(obj)
            obj.flush();
        end


        function status=isCreated(obj)
            status=(Sldv.Tasking.TaskState.Created==obj.mState);

            return;
        end


        function status=isReady(obj)
            status=(Sldv.Tasking.TaskState.Ready==obj.mState);

            return;
        end


        function status=isRunning(obj)
            status=(Sldv.Tasking.TaskState.Running==obj.mState);

            return;
        end



        function status=isComplete(obj)
            status=(Sldv.Tasking.TaskState.Completed==obj.mState);

            return;
        end



        function status=isFailed(obj)
            status=(Sldv.Tasking.TaskState.Failed==obj.mState);

            return;
        end




        function status=isDone(obj)
            status=(Sldv.Tasking.TaskState.Done==obj.mState);

            return;
        end




        function status=isCancelled(obj)
            status=(Sldv.Tasking.TaskState.Cancelled==obj.mState);

            return;
        end
    end


    methods(Access=public)




        function obj=Task(taskManagerH,ready)


            obj.mState=Sldv.Tasking.TaskState.Created;

            obj.mTaskManagerH=taskManagerH;
            obj.mTaskManagerH.addNewTask(obj,ready);
        end


        function delete(~)





        end
    end


    methods(Access=protected,Sealed=true)






        function connect(obj,channelId,mode)




            assert((Sldv.Tasking.TaskState.Created==obj.mState)||...
            (Sldv.Tasking.TaskState.Ready==obj.mState));

            obj.mTaskManagerH.connect(obj.mTaskId,channelId,mode);

            return;
        end






        function disConnect(obj,channelId)
            obj.mTaskManagerH.disConnect(obj.mTaskId,channelId);

            return;
        end



        function triggerOn(obj,eventId)





            assert((Sldv.Tasking.TaskState.Created==obj.mState)||...
            (Sldv.Tasking.TaskState.Ready==obj.mState));

            obj.mTaskManagerH.triggerOn(obj.mTaskId,eventId);

            return;
        end










        function[status,data,countRead]=read(obj,channelId,countRequested)


            assert(Sldv.Tasking.TaskState.Done~=obj.mState);

            chn=obj.mTaskManagerH.getChannel(channelId);
            assert(~isempty(chn));


            if(3==nargin)
                [status,data,countRead]=chn.read(obj.mTaskId,countRequested);

            else
                [status,data,countRead]=chn.read(obj.mTaskId);
            end

            return;
        end


        function done=isSourceDone(obj,channelId)


            assert(Sldv.Tasking.TaskState.Done~=obj.mState);

            chn=obj.mTaskManagerH.getChannel(channelId);
            assert(~isempty(chn));
            done=chn.isSourceDone();

            return;
        end


        function eof=isEof(obj,channelId)





            assert(Sldv.Tasking.TaskState.Done~=obj.mState);

            chn=obj.mTaskManagerH.getChannel(channelId);
            assert(~isempty(chn));
            eof=chn.isEof(obj.mTaskId);

            return;
        end



        function write(obj,channelId,data)


            assert(Sldv.Tasking.TaskState.Done~=obj.mState);

            chn=obj.mTaskManagerH.getChannel(channelId);
            assert(~isempty(chn));
            chn.write(obj.mTaskId,data);

            return;
        end



        function count=numDataAvailable(obj,channelId)


            assert(Sldv.Tasking.TaskState.Done~=obj.mState);

            chn=obj.mTaskManagerH.getChannel(channelId);
            assert(~isempty(chn));
            count=chn.numDataAvailable(obj.mTaskId);

            return;
        end











        function done(obj)
            obj.mDone=true;

            return;
        end



        function yield(obj,yieldEvent)


            assert(Sldv.Tasking.TaskState.Running==obj.mState);

            obj.mYield=true;

            if nargin==2
                obj.mYieldEvent=yieldEvent;
            end

            return;
        end
    end


    methods(Abstract,Access=protected)


        doTask(obj,event);




        doCleanup(obj,cause);
    end

    methods(Access=protected)



        function flush(~)


        end
    end

end
