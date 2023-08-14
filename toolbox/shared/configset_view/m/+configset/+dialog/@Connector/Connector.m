

classdef Connector<handle


    properties(Access=private)
mID
    end

    properties(Constant)
        channel='/csview';
    end

    events
Event
    end

    methods(Access=private)
        function obj=Connector()
            obj.mID=message.subscribe(obj.channel,@obj.callback);
        end

        callback(obj,msg);
    end

    methods
        function unsubscribe(obj)
            message.unsubscribe(obj.mID);
        end
    end

    methods(Static)
        obj=getInstance();
    end
end

