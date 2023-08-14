classdef(ConstructOnLoad)VolumeLoadedEventData<event.EventData





    properties

Volume
Label
VolumeTransform

VolumeBounds

OrientationAxesLabels

    end

    methods

        function data=VolumeLoadedEventData(vol,labels,volTransform,volumeBounds,axesLabels)

            data.Volume=vol;
            data.Label=labels;
            data.VolumeTransform=volTransform;

            data.VolumeBounds=volumeBounds;

            data.OrientationAxesLabels=axesLabels;

        end

    end

end
