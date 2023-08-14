classdef StylerXButtonNotifier<handle




    properties(SetAccess=private,GetAccess=public)
BDHandle
        Listeners;
    end

    properties(Access=private,Constant)
        PLUGIN_PARAM_NAME='SLDiffStylerXButtonNotifier'
    end

    methods(Access=public)

        function obj=StylerXButtonNotifier(bdHandle)
            obj.BDHandle=bdHandle;
            obj.Listeners={};
            storePluginParam(bdHandle,obj.PLUGIN_PARAM_NAME,obj);
        end

        function delete(obj)
            try
                get_param(obj.BDHandle,'Name');
            catch
                return;
            end
            removePluginParam(obj.BDHandle,obj.PLUGIN_PARAM_NAME,obj)
        end

        function notifyClicked(obj)
            cellfun(...
            @(listener)listener(),...
            obj.Listeners...
            );
        end

        function subscription=addListener(obj,listener)
            obj.Listeners{end+1}=listener;

            subscription=onCleanup(@()obj.removeListener(listener));
        end

    end

    methods(Access=private)
        function removeListener(obj,toRemove)
            if isvalid(obj)
                obj.Listeners=obj.Listeners(...
                cellfun(@(listener)~isequal(listener,toRemove),obj.Listeners)...
                );
            end
        end
    end

end

function storePluginParam(bdHandle,param_name,obj)
    current=get_param(bdHandle,param_name);
    if isempty(current)
        set_param(bdHandle,param_name,obj);
    else
        current(end+1)=obj;
        set_param(bdHandle,param_name,current);
    end
end

function removePluginParam(bdHandle,param_name,obj)
    current=get_param(bdHandle,param_name);
    set_param(bdHandle,param_name,current(current~=obj));
end
