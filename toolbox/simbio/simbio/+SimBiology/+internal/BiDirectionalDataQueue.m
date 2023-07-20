















classdef BiDirectionalDataQueue<handle
    properties(Access=public)

WorkerToClient


ClientToWorkerMap


ClientToWorker
        EndNow=false
    end

    properties(Constant,Access=private)
        ClientID=0
    end

    properties(Transient)
WorkerID
    end

    methods(Static)
        function obj=loadobj(obj)
            initialize(obj);
        end
    end

    methods
        function[obj]=BiDirectionalDataQueue()
            initialize(obj);




            verifyIsClient(obj)


            obj.WorkerToClient=parallel.internal.pool.DataQueue;


            obj.ClientToWorkerMap=containers.Map('KeyType','double','ValueType','any');
        end



        function[data,dataReceived]=poll(obj,varargin)


            verifyIsClient(obj);


            done=false;
            while~done
                [dataCell,dataReceived]=poll(obj.WorkerToClient,varargin{:});
                if~dataReceived

                    data=[];
                    return
                end


                [workerIndex,isUserData,data]=dataCell{:};

                if isUserData

                    dataReceived=isUserData;
                    return

                else



                    obj.ClientToWorkerMap(workerIndex)=data;


                    if obj.EndNow
                        data.send(obj.EndNow)
                    end
                end
            end
        end

        function[]=stop(obj)

            verifyIsClient(obj);

            endNow=true;
            obj.EndNow=endNow;
            workerQueues=values(obj.ClientToWorkerMap);
            for i=1:length(workerQueues)
                workerQueues{i}.send(endNow);
            end
        end



        function[]=send(obj,data)
            verifyIsWorker(obj);

            isUserData=true;
            obj.WorkerToClient.send({obj.WorkerID,isUserData,data});

            [endNow,dataReceived]=poll(obj.ClientToWorker);
            if dataReceived
                assert(isequal(endNow,true),...
                'Unexpected data received from workers. Only stop signal is expected.')
                obj.EndNow=endNow;
            end
        end

        function[value]=shouldStop(obj)

            verifyIsWorker(obj);
            value=obj.EndNow;
        end

    end

    methods(Access=private)
        function value=isClient(obj)
            value=(obj.WorkerID==SimBiology.internal.BiDirectionalDataQueue.ClientID);
        end

        function value=isWorker(obj)
            value=(obj.WorkerID~=SimBiology.internal.BiDirectionalDataQueue.ClientID);
        end

        function[]=verifyIsClient(obj)
            assert(isClient(obj),'Method can only be called on client.');
        end

        function[]=verifyIsWorker(obj)
            assert(isWorker(obj),'Method can only be called on worker.');
        end

        function[]=initialize(obj)



            task=getCurrentTask();
            if isempty(task)
                obj.WorkerID=SimBiology.internal.BiDirectionalDataQueue.ClientID;
            else
                obj.WorkerID=task.ID;


                obj.ClientToWorker=parallel.internal.pool.DataQueue;
                obj.WorkerToClient.send({obj.WorkerID,false,obj.ClientToWorker});
            end
        end
    end
end