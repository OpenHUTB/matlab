

classdef(Sealed)BuildStatusReceiver<handle



    properties
CallbackMap
    end

    properties(Hidden)
NextId
    end



    methods(Access=private)
        function obj=BuildStatusReceiver
            obj.CallbackMap=containers.Map('KeyType','uint32','ValueType','any');
            obj.NextId=uint32(1);
        end
    end

    methods(Static)
        function singleObj=getInstance
            persistent localObj
            if isempty(localObj)||isempty(localObj.CallbackMap)||~isvalid(localObj)
                localObj=coder.internal.buildstatus.BuildStatusReceiver;
            end
            singleObj=localObj;
        end

        function dq=createDataQueue(pool,fh)
            if~isa(pool,'coder.parallel.TestModePool')
                dq=parallel.internal.pool.DataQueue;
                dq.afterEach(fh);
            else

                dq=[];
            end
        end

        function registerDataQueueOnWorkers(pool,dq)
            if~isa(pool,'coder.parallel.TestModePool')
                pool.runOnAllWorkersSync(@coder.internal.buildstatus.registerDataQueue,dq);
            end
        end
    end

    methods
        function id=setupCallback(this,pool,fh)
            dq=this.createDataQueue(pool,fh);
            this.registerDataQueueOnWorkers(pool,dq);
            id=this.registerCallback(fh,dq);
        end

        function id=registerCallback(this,fh,dq)
            id=this.NextId;
            val=struct('CB',fh,'DataQueue',dq);
            this.CallbackMap(id)=val;


            this.NextId=this.NextId+1;
        end

        function deregisterCB(obj,id)
            if isKey(obj.CallbackMap,id)
                remove(obj.CallbackMap,id);
                if~isequal(obj.NextId-1,0)
                    obj.NextId=obj.NextId-1;
                end
            end
        end


        function receive(obj,msg)
            keysToCall=keys(obj.CallbackMap);
            for i=1:length(keysToCall)
                val=obj.CallbackMap(keysToCall{i});


                if~isempty(val.CB)&&isa(val.CB,'function_handle')
                    feval(val.CB,msg);
                elseif~isempty(val.DataQueue)&&isa(val.DataQueue,'parallel.internal.pool.DataQueue')
                    val.DataQueue.send(msg);
                end
            end
        end
    end
end
