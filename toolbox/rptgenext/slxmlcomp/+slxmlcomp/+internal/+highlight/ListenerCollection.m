classdef ListenerCollection<handle




    properties(Access=private)
Listeners
    end

    methods(Access=public)
        function obj=ListenerCollection()
            obj.Listeners=struct();
        end

        function fireListeners(obj,listenerId,varargin)
            if~isfield(obj.Listeners,listenerId)
                return
            end
            cellfun(...
            @(listener)listener(varargin{:}),...
            obj.Listeners.(listenerId)...
            );
        end

        function listenerCleanup=addListener(obj,listenerId,listener)
            if~isfield(obj.Listeners,listenerId)
                obj.Listeners.(listenerId)={};
            end
            obj.Listeners.(listenerId)=[obj.Listeners.(listenerId),{listener}];
            listenerCleanup=@()obj.removeListener(listenerId,listener);
        end

        function removeListener(obj,listenerId,toRemove)
            if~isfield(obj.Listeners,listenerId)
                return
            end
            listenersWithId=obj.Listeners.(listenerId);
            obj.Listeners.(listenerId)=listenersWithId(...
            cellfun(@(listener)~isequal(listener,toRemove),listenersWithId)...
            );
        end
    end

end
