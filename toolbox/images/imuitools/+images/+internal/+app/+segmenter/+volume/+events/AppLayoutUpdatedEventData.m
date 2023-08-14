classdef(ConstructOnLoad)AppLayoutUpdatedEventData<event.EventData





    properties

VolumeVisible
LabelVisible
OverviewVisible

    end

    methods

        function data=AppLayoutUpdatedEventData(vol,lab,ov)

            data.VolumeVisible=vol;
            data.LabelVisible=lab;
            data.OverviewVisible=ov;

        end

    end

end