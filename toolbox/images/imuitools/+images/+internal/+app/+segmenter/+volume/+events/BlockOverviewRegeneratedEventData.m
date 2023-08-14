classdef(ConstructOnLoad)BlockOverviewRegeneratedEventData<event.EventData





    properties

IncludeVolume
IncludeLabels
Parent

    end

    methods

        function data=BlockOverviewRegeneratedEventData(vol,labels,hfig)

            data.IncludeVolume=vol;
            data.IncludeLabels=labels;
            data.Parent=hfig;

        end

    end

end