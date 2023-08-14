classdef(ConstructOnLoad)StandardViewChangedEventData<event.EventData






    properties
        View;
    end

    methods

        function data=StandardViewChangedEventData(view)
            data.View=view;
        end
    end
end