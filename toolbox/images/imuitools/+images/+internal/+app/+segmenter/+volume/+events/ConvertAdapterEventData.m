classdef(ConstructOnLoad)ConvertAdapterEventData<event.EventData





    properties

BlockedImage
Location

    end

    methods

        function data=ConvertAdapterEventData(bim,loc)

            data.BlockedImage=bim;
            data.Location=loc;

        end

    end

end