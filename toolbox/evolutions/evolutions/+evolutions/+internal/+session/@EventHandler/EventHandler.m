classdef EventHandler<handle




    events(NotifyAccess=private)

EtmChanged
TreeChanged
EvolutionCreated
FileListChanged
EtiDataChanged
EiDataChanged
OnDiskFileChanged

RefreshClients
    end

    events(NotifyAccess=private)

Warning
    end

    events(NotifyAccess=private)

CriticalError
NonCriticalError
    end

    methods(Access=?evolutions.internal.session.SessionManager)
        function obj=EventHandler
        end
    end

    methods(Static=true)
        publish(eventName,varargin);
        listener=subscribe(eventName,functionHandle);
    end

    methods(Hidden,Access=public)

        publishEvent(obj,eventName,varargin);
        listener=subscribeEvent(obj,eventName,functionHandle);
        delete(obj);
    end
end
