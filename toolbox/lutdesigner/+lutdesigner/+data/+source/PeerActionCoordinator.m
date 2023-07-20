classdef(Abstract)PeerActionCoordinator<handle

    properties(SetAccess=private,GetAccess={?matlab.unittest.TestCase})
HandlerMap
    end

    methods(Access=protected)
        function this=PeerActionCoordinator
            this.HandlerMap=containers.Map;
        end
    end

    methods
        function registerHandler(this,sourceKey,instanceID,handler)
            if~this.HandlerMap.isKey(sourceKey)
                this.HandlerMap(sourceKey)=containers.Map;
            end
            sourceHandlerMap=this.HandlerMap(sourceKey);
            sourceHandlerMap(instanceID)=handler;%#ok
        end

        function unregisterHandler(this,sourceKey,instanceID)
            if~this.HandlerMap.isKey(sourceKey)
                return;
            end
            sourceHandlerMap=this.HandlerMap(sourceKey);
            if~sourceHandlerMap.isKey(instanceID)
                return;
            end
            sourceHandlerMap.remove(instanceID);
            if sourceHandlerMap.length()==0
                this.HandlerMap.remove(sourceKey);
            end
        end
    end

    methods(Access={?lutdesigner.data.source.PeerActionCoordinator,?matlab.unittest.TestCase})
        function invokePeerHandlers(this,sourceKey,invokerID,handlerInputs)
            if~this.HandlerMap.isKey(sourceKey)
                return;
            end
            sourceHandlerMap=this.HandlerMap(sourceKey);
            instanceIDs=sourceHandlerMap.keys();
            for i=1:numel(instanceIDs)
                if~strcmp(instanceIDs{i},invokerID)
                    handler=sourceHandlerMap(instanceIDs{i});
                    handler(handlerInputs{:});
                end
            end
        end
    end
end
