classdef(ConstructOnLoad)WarningThrownEventData<event.EventData




    properties

Identifier

Message

Details

    end

    methods

        function evt=WarningThrownEventData(id,msg,details)

            evt.Identifier=id;

            evt.Message=msg;

            evt.Details=details;

        end

    end

end