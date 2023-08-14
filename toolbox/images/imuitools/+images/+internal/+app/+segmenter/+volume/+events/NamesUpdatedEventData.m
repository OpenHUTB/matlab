classdef(ConstructOnLoad)NamesUpdatedEventData<event.EventData





    properties

Names
Colormap
Alphamap
SelectedIndex

    end

    methods

        function data=NamesUpdatedEventData(names,cmap,amap,idx)

            data.Names=names;
            data.Colormap=cmap;
            data.Alphamap=amap;
            data.SelectedIndex=idx;

        end

    end

end