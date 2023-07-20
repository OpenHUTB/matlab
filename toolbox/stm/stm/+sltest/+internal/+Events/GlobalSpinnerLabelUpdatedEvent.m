



classdef GlobalSpinnerLabelUpdatedEvent<event.EventData
    properties
        Text(1,1)string;
    end

    methods
        function this=GlobalSpinnerLabelUpdatedEvent(text)
            this.Text=text;
        end
    end
end
