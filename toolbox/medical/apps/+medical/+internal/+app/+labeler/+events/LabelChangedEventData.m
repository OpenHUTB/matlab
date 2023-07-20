classdef(ConstructOnLoad)LabelChangedEventData<event.EventData




    properties

Label
Value

    end

    methods

        function data=LabelChangedEventData(name,value)

            data.Label=name;
            data.Value=value;

        end

    end

end