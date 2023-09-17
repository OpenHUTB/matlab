classdef MultiplexedDataQueue<handle
    properties(GetAccess=private,SetAccess=immutable)
dataQueue
id
    end

    properties(GetAccess=private,SetAccess=immutable,Transient)
        map containers.Map
    end

    properties(Access=private,Transient)
callback
    end

    methods
        function self=MultiplexedDataQueue(multiplexedDQ)
            persistent counter;
            if isempty(counter)
                counter=1;
            else
                counter=counter+1;
            end
            self.id=counter;
            if nargin==0
                self.map=containers.Map('KeyType','double','ValueType','any');
                self.dataQueue=parallel.pool.DataQueue;
                afterEach(self.dataQueue,@self.processAfterEach);
            else
                self.map=multiplexedDQ.map;
                self.dataQueue=multiplexedDQ.dataQueue;
            end
            self.map(self.id)=matlab.internal.WeakHandle(self);
        end

        function send(self,msg)
            send(self.dataQueue,{self.id,msg});
        end

        function afterEach(self,callback)
            assert(isempty(self.callback));
            self.callback=callback;

        end

        function processAfterEach(self,idmsg)
            [pId,msg]=deal(idmsg{:});
            if isKey(self.map,pId)
                target=self.map(pId);
                target.get.callback(msg);
            end

        end

        function obj=fork(self)
            obj=experiments.internal.MultiplexedDataQueue(self);
        end

        function delete(self)
            if~isempty(self.map)
                self.map.remove(self.id);
            end
        end

        function count=getMapCount(self)
            if~isempty(self.map)
                count=length(self.map);
            end
        end

    end
end

