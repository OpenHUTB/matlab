classdef(Hidden=true)Subscription<handle


    properties
messageService
subscriptionId
callback
params
    end

    methods
        function obj=Subscription(ms,id,callback,params)
mlock
            obj.subscriptionId=id;
            obj.callback=callback;
            obj.params=params;
            if~isempty(ms)
                obj.messageService=matlab.internal.WeakHandle(ms);
            end
        end

        function delete(obj)
            if~isempty(obj.messageService)&&~obj.messageService.isDestroyed()
                ms=obj.messageService.get();
                ms.unsubscribe(obj);
            else
                message.unsubscribe(obj);
            end
        end
    end
end
