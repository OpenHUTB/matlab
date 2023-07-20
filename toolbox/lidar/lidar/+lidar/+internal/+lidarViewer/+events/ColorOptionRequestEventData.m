classdef(ConstructOnLoad)ColorOptionRequestEventData<event.EventData





    properties


        ColorPresent=false;

    end

    methods

        function data=ColorOptionRequestEventData(colorPresent)
            data.ColorPresent=colorPresent;
        end
    end

end