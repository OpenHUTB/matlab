


classdef ConnectorAPI<handle


    methods(Static)
        ret=getAPI()
        ret=getSetHaveControllersBeenRemoved(varargin)
        enableEventCallback(evtName)
        disableEventCallback(evtName)
    end


    methods

        function delete(this)
            stop(this);
        end

    end

    methods(Access=protected)
        initControllers(this)
        removeControllers(this)
        setEventCallbackState(this,evtName,enableState)
    end


    properties(Access=protected)
        Port='';
        ControllersInitialized=false;
        EventListeners;
    end
end
