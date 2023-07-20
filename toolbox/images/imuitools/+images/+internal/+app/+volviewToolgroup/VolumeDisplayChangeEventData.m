classdef(ConstructOnLoad)VolumeDisplayChangeEventData<event.EventData
    properties
Display3DSlices
DisplayVolume
    end

    methods
        function data=VolumeDisplayChangeEventData(displayVolume)
            data.Display3DSlices=~displayVolume;
            data.DisplayVolume=displayVolume;
        end
    end
end