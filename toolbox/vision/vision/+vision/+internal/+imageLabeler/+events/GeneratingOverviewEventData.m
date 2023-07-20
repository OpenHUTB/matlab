



classdef(ConstructOnLoad)GeneratingOverviewEventData<event.EventData

    properties

ImageName


ImageSize
    end

    methods

        function data=GeneratingOverviewEventData(imageName,imageSize)

            data.ImageName=imageName;
            data.ImageSize=imageSize;

        end
    end

end