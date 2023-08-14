

classdef(Abstract)ViewSourceBase<handle
    properties
        isAttachedToModel=false
        ModelHandle=[]
    end
    events
HandleBeingDestroyed
    end
    methods
        out=getClientAssociationHandle(obj)
        onBrowserClose(obj,size)
        out=CoderDataSourceName(obj)
        function onSourceBeingDestroyed(obj,~,~,~)

            obj.notify('HandleBeingDestroyed');
        end
        function createListener(~,~)

        end
    end
end
