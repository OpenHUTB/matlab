classdef(ConstructOnLoad)SummaryUpdatedEventData<event.EventData





    properties

Label
Color

SliceDirection

    end

    methods

        function data=SummaryUpdatedEventData(label,color)

            data.Label=label;
            data.Color=color;

        end

    end

end