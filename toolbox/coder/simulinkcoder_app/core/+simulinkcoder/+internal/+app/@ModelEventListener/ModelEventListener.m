

classdef ModelEventListener
    properties(Constant,Hidden)
        ModelListeners=containers.Map('KeyType','char','ValueType','any');
    end

    methods(Static,Hidden)
        function addEventListeners(modelName)
            handlers={};

            mh=get_param(modelName,'Handle');
            handlers=[handlers;{Simulink.listener(mh,'CloseEvent',@simulinkcoder.internal.app.ModelEventListener.onModelClose)}];

            mo=get_param(mh,'Object');
            handlers=[...
            handlers;...
            {Simulink.listener(mo,'ObjectChildAdded',@simulinkcoder.internal.app.ModelEventListener.onObjectChildAdded)};...
            {Simulink.listener(mo,'ObjectChildRemoved',@simulinkcoder.internal.app.ModelEventListener.onObjectChildRemoved)};...
            ];

            mapMgr=get_param(modelName,'MappingManager');
            coderDictMapping=mapMgr.getActiveMappingFor('CoderDictionary');
            if~isempty(coderDictMapping)
                handlers=[...
                handlers;...
                {event.listener(coderDictMapping,...
                'InportMappingEntityAdded',...
                @simulinkcoder.internal.app.ModelEventListener.onInportAdded)};...
                {event.listener(coderDictMapping,...
                'InportMappingEntityDeleted',...
                @simulinkcoder.internal.app.ModelEventListener.onInportDeleted)};...
                ];
            end

            localListenersMap=simulinkcoder.internal.app.ModelEventListener.ModelListeners;
            localListenersMap(modelName)=handlers;%#ok
        end

        function removeEventListeners(modelName)
            localListenersMap=simulinkcoder.internal.app.ModelEventListener.ModelListeners;
            listeners=localListenersMap(modelName);
            for i=1:numel(listeners)
                delete(listeners{i});
            end
            remove(localListenersMap,modelName);
        end

        function onInportAdded(~,~)
        end

        function onInportDeleted(~,~)
        end

        function onModelClose(~,eventData)
            simulinkcoder.internal.app.ModelEventListener.removeEventListeners(eventData.Source.Name);
        end

        function onObjectChildAdded(~,eventData)
            if isa(eventData.Child,'Simulink.Inport')||isa(eventData.Child,'Simulink.Outport')
                simulinkcoder.internal.app.objectAddedHandler(eventData.Child);
            end
        end

        function onObjectChildRemoved(~,~)
        end
    end
end
