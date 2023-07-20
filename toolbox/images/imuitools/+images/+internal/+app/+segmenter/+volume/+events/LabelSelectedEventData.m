classdef(ConstructOnLoad)LabelSelectedEventData<event.EventData





    properties

Label
Color

    end

    methods

        function data=LabelSelectedEventData(label,color)

            data.Label=label;
            data.Color=color;

        end

    end

end