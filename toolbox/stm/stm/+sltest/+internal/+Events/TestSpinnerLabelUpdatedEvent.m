



classdef TestSpinnerLabelUpdatedEvent<event.EventData
    properties
        ID(1,1)int32;
        Text(1,1)string;
    end

    methods
        function this=TestSpinnerLabelUpdatedEvent(id,text)
            this.ID=id;
            this.Text=text;
        end
    end
end
