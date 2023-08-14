classdef(ConstructOnLoad)FloodFillSettingsEventData<event.EventData





    properties

Size
Sensitivity

    end

    methods

        function data=FloodFillSettingsEventData(tol,sz)

            data.Size=sz;
            data.Sensitivity=tol;

        end

    end

end