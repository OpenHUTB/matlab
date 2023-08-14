classdef ApplicationEventData<event.EventData





    properties
        OldID='';
    end

    methods
        function this=ApplicationEventData(oldID)
            this.OldID=oldID;
        end
    end

end

