classdef(ConstructOnLoad)RenderingChangedEventData<event.EventData





    properties

Threshold
Opacity

    end

    methods

        function data=RenderingChangedEventData(val,alpha)

            data.Threshold=val;
            data.Opacity=alpha;

        end

    end

end