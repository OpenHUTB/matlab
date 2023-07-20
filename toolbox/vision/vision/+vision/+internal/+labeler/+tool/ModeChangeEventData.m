
classdef(ConstructOnLoad)ModeChangeEventData<event.EventData
    properties
        Mode;
    end

    methods
        function this=ModeChangeEventData(mode)
            this.Mode=mode;
        end
    end
end