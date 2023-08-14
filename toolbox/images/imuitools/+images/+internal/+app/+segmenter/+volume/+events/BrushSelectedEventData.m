classdef(ConstructOnLoad)BrushSelectedEventData<event.EventData





    properties

Selected

    end

    methods

        function data=BrushSelectedEventData(TF)

            data.Selected=TF;

        end

    end

end