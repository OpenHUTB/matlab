












classdef Registry<handle

    enumeration
Instance
    end

    events
ObjectCreated
    end


    methods(Access=private)
        function delete(obj)
        end
    end

    methods
        function value=get(obj,key)
            eventData=SimBiology.internal.Code.CreationEventData(key);
            obj.notify('ObjectCreated',eventData);
            value=eventData.existingObject;
        end

        function listener=add(obj,key,callback)
            listener=event.listener(obj,'ObjectCreated',callback);
        end
    end
end