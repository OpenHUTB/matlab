classdef(ConstructOnLoad)NamesUpdatedEventData<event.EventData





    properties

Names
Colormap

    end

    methods

        function data=NamesUpdatedEventData(names,cmap)

            data.Names=names;
            data.Colormap=cmap;

        end

    end

end