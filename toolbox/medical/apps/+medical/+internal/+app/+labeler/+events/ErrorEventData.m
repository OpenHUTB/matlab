classdef(ConstructOnLoad)ErrorEventData<event.EventData




    properties

Message

    end

    methods

        function data=ErrorEventData(message)
            data.Message=message;
        end

    end
end