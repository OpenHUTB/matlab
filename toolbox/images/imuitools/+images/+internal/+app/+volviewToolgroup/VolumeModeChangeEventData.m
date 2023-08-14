

classdef(ConstructOnLoad)VolumeModeChangeEventData<event.EventData
    properties
VolumeMode
    end

    methods
        function data=VolumeModeChangeEventData(mode)
            data.VolumeMode=mode;
        end
    end
end