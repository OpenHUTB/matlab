classdef LiveAppContainer<handle

    properties(SetAccess='private',GetAccess='public')
appInstance
appStateChangeEventAggregator
autoRunEventListener
        code='';
    end

    methods
        function obj=LiveAppContainer(appInstance)
            obj.appInstance=appInstance;
        end


        function registerChangedListener(obj,callback,fig)
            try
                addlistener(obj.appInstance,'Changed',callback);
            catch ME
            end

            try
                addlistener(obj.appInstance,'StateChanged',callback);
            catch ME
            end

            aggregator=matlab.ui.internal.AppStateChangeEventAggregator();
            aggregator.attach(fig);
            addlistener(aggregator,'AppStateChanged',callback);
            obj.appStateChangeEventAggregator=aggregator;
        end


        function registerAutoRunListener(obj,callback)
            try
                obj.autoRunEventListener=addlistener(obj.appInstance,'AutoRun','PostSet',callback);
            catch ME
            end
        end

        function removeAutorunListener(obj)
            if~isempty(obj.autoRunEventListener)
                obj.autoRunEventListener.delete();
            end
        end

        function updateCode(obj,code)

            obj.code=code;
        end

        function delete(obj)
            obj.appInstance.delete();

            if~isempty(obj.appStateChangeEventAggregator)
                obj.appStateChangeEventAggregator.delete();
            end
        end
    end
end