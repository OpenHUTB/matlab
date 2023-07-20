



classdef Channel<handle






    properties(Access=private)
        mBuffer=[];
        mTaskData=containers.Map;










        mTaskManagerH=[];
        mMinDataSizeForDeletion=1;
        mAllWritersDone=true;

    end

    events(NotifyAccess=private)

DataAvailable

AllWritersDone
    end

    methods(Access=public)







        function connect(obj,taskId,mode)


            assert(~obj.mTaskData.isKey(taskId));


            obj.createTaskData(taskId);


            obj.setConnectMode(taskId,mode);


            if(Sldv.Tasking.ChannelConnectMode.Read==mode)
                obj.setReadPos(taskId,1);

            elseif(Sldv.Tasking.ChannelConnectMode.Write==mode)
                obj.mAllWritersDone=false;
            end

            assert(obj.mTaskData.isKey(taskId));
            return
        end


        function disConnect(obj,taskId)


            assert(obj.mTaskData.isKey(taskId));


            obj.mTaskData.remove(taskId);




            anyWriterStillConnected=false;
            taskIds=keys(obj.mTaskData);
            for i=1:length(taskIds)
                tId=taskIds{i};
                if(Sldv.Tasking.ChannelConnectMode.Write==obj.getConnectMode(tId))
                    anyWriterStillConnected=true;
                    break;
                end
            end
            if(false==anyWriterStillConnected)
                obj.mAllWritersDone=true;
                notify(obj,'AllWritersDone');
            end

            assert(~obj.mTaskData.isKey(taskId));
            return;
        end


        function status=isConnected(obj,taskId)

            status=obj.mTaskData.isKey(taskId);

            return;
        end







        function status=isReader(obj,taskId)

            status=obj.mTaskData.isKey(taskId)&&...
            (Sldv.Tasking.ChannelConnectMode.Read==obj.getConnectMode(taskId));

            return;
        end







        function status=isWriter(obj,taskId)

            status=obj.mTaskData.isKey(taskId)&&...
            (Sldv.Tasking.ChannelConnectMode.Write==obj.getConnectMode(taskId));

            return;
        end




        function numData=numDataAvailable(obj,taskId)

            numData=0;

            if obj.mTaskData.isKey(taskId)&&...
                (Sldv.Tasking.ChannelConnectMode.Read==obj.getConnectMode(taskId))&&...
                (obj.getReadPos(taskId)<=length(obj.mBuffer))



                numData=(length(obj.mBuffer)-obj.getReadPos(taskId))+1;
            end

            return;
        end






        function[status,data,countRead]=read(obj,taskId,countRequested)

            status=true;
            data=[];
            countRead=0;



            if nargin<3
                countRequested=obj.numDataAvailable(taskId);
            end


            if(Sldv.Tasking.ChannelConnectMode.Write==obj.getConnectMode(taskId))
                status=false;
                return;
            end





            if(countRequested>obj.numDataAvailable(taskId))
                countRequested=obj.numDataAvailable(taskId);
            end


            if(countRequested==0)
                return;
            end


            bufReadStartPos=obj.getReadPos(taskId);








            if(bufReadStartPos<=length(obj.mBuffer))
                bufReadEndPos=bufReadStartPos+(countRequested-1);
                data=obj.mBuffer(bufReadStartPos:bufReadEndPos);
                countRead=countRequested;





                obj.setReadPos(taskId,(bufReadEndPos+1));


                obj.tryShrinkBuffer();
            end




            return;
        end



        function done=isSourceDone(obj)
            done=obj.mAllWritersDone;

            return;
        end



        function eof=isEof(obj,taskId)
            eof=false;

            if((0==obj.numDataAvailable(taskId))&&(true==obj.mAllWritersDone))
                eof=true;
            end

            return;
        end




        function status=write(obj,taskId,data)

            status=true;


            if isempty(data)
                return;
            end


            if(Sldv.Tasking.ChannelConnectMode.Read==obj.getConnectMode(taskId))
                status=false;
                return;
            end











            obj.mBuffer=horzcat(obj.mBuffer,data);








            notify(obj,'DataAvailable');

            return;
        end


        function status=flush(obj,taskId)


            status=obj.read(taskId);

            return;
        end

    end


    methods(Access=public)

        function obj=Channel(taskManagerH)

            obj.mTaskManagerH=taskManagerH;


            obj.mTaskData=containers.Map('KeyType','int32','ValueType','any');
        end


        function delete(obj)










        end

    end

    methods(Access=private)

        function createTaskData(obj,taskId)


            assert(~obj.mTaskData.isKey(taskId));

            taskData=struct('Mode',Sldv.Tasking.ChannelConnectMode.None,...
            'ReadPos',0);
            obj.mTaskData(taskId)=taskData;

            return;
        end


        function tryShrinkBuffer(obj)

            taskIds=keys(obj.mTaskData);



            allTasksReadPos=length(obj.mBuffer)+1;
            for i=1:length(taskIds)
                taskId=taskIds{i};

                if(Sldv.Tasking.ChannelConnectMode.Read==obj.getConnectMode(taskId))
                    currTaskReadPos=obj.getReadPos(taskId);
                    if currTaskReadPos<allTasksReadPos
                        allTasksReadPos=currTaskReadPos;
                    end
                end
            end



            if(allTasksReadPos>obj.mMinDataSizeForDeletion)

                obj.mBuffer(1:allTasksReadPos-1)=[];


                for i=1:length(taskIds)
                    taskId=taskIds{i};

                    if(Sldv.Tasking.ChannelConnectMode.Read==obj.getConnectMode(taskId))
                        currTaskReadPos=obj.getReadPos(taskId);
                        obj.setReadPos(taskId,(currTaskReadPos-allTasksReadPos)+1);
                    end
                end
            end

            return;
        end

    end




    methods(Access=private)

        function mode=getConnectMode(obj,taskId)

            assert(obj.mTaskData.isKey(taskId));

            taskData=obj.mTaskData(taskId);
            mode=taskData.Mode;

            return;
        end


        function setConnectMode(obj,taskId,mode)

            assert(obj.mTaskData.isKey(taskId));

            taskData=obj.mTaskData(taskId);
            taskData.Mode=mode;
            obj.mTaskData(taskId)=taskData;

            return;
        end


        function pos=getReadPos(obj,taskId)



            taskData=obj.mTaskData(taskId);
            pos=taskData.ReadPos;

            return;
        end


        function setReadPos(obj,taskId,pos)



            taskData=obj.mTaskData(taskId);
            taskData.ReadPos=pos;
            obj.mTaskData(taskId)=taskData;

            return;
        end

    end


    methods(Access=private)




        function status=validateTaskReadPositions(obj)
            status=true;
            taskIds=keys(obj.mTaskData);

            for i=1:length(taskIds)
                taskId=taskIds{i};



                if(Sldv.Tasking.ChannelConnectMode.Read==obj.getConnectMode(taskId))
                    currTaskReadPos=obj.getReadPos(taskId);

                    if((1<=currTaskReadPos)&&(currTaskReadPos<=length(obj.mBuffer)))
                        fprintf('Read position of task {%d} is valid and there is some data available for reading\n',taskId);
                    elseif(currTaskReadPos==(length(obj.mBuffer)+1))
                        fprintf('Read position of task {%d} is valid, but there is no data available for reading\n',taskId);
                    else
                        status=false;
                        warning('Read position of task {%d} is invalid',taskId);
                    end
                end
            end

            return;
        end

    end

end
