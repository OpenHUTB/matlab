classdef(Enumeration)PauseState


    enumeration
paused
pausing
running
    end

    methods


        function tf=isPaused(obj)
            tf=matlab.graphics.chart.primitive.tall.internal.PauseState.running~=obj;
        end
    end
end