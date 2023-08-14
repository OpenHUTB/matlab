classdef(ConstructOnLoad)HitEventData<event.EventData





    properties

IntersectionPoint

    end

    methods

        function data=HitEventData(pos)

            data.IntersectionPoint=pos(1:2);

        end

    end

end