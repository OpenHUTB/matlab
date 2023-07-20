classdef(ConstructOnLoad)VolumeRenderingSettingsChangedEventData<event.EventData





    properties

RenderingPreset
RenderingStyle
VolumeAlphaCP
VolumeColorCP

    end

    methods

        function data=VolumeRenderingSettingsChangedEventData(renderingPreset,renderingStyle,alphaControlPts,colorControlPts)

            data.RenderingPreset=renderingPreset;
            data.RenderingStyle=renderingStyle;
            data.VolumeAlphaCP=alphaControlPts;
            data.VolumeColorCP=colorControlPts;

        end

    end

end
