classdef VerificationChangeEvent<event.EventData

    properties
type
eventObj
    end

    methods
        function this=VerificationChangeEvent(type,eventObj)
            this.type=type;
            this.eventObj=eventObj;
        end
    end

end

