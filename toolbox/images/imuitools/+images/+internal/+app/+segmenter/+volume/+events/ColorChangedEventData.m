classdef(ConstructOnLoad)ColorChangedEventData<event.EventData





    properties

Label
Color

    end

    methods

        function data=ColorChangedEventData(name,cmap)

            data.Label=name;
            data.Color=cmap;

        end

    end

end