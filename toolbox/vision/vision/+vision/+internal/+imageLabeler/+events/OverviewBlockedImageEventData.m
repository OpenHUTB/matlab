



classdef(ConstructOnLoad)OverviewBlockedImageEventData<event.EventData

    properties


BlockedImage


ImageNum
    end

    methods

        function data=OverviewBlockedImageEventData(resizedBim,idx)

            data.BlockedImage=resizedBim;
            data.ImageNum=idx;

        end
    end

end