classdef PresetRenderingOptions




    enumeration

Default
LinearGrayscale

MRI

CT_Bone

CT_Lung

CT_SoftTissue

CT_Coronary

MRI_MIP

CT_MIP

CustomPreset

    end

    methods


        function renderingSettings=getRenderingSettings(self)

            renderingSettings=struct(...
            'RenderingStyle',[],...
            'Alphamap',[],...
            'Colormap',[],...
            'AlphaControlPoints',[],...
            'ColorControlPoints',[]);

            switch self

            case{medical.internal.app.labeler.model.PresetRenderingOptions.Default,...
                medical.internal.app.labeler.model.PresetRenderingOptions.LinearGrayscale}

                intensity=[0,1]';
                alpha=[0,1]';
                color=[0,0,0;1,1,1];

                renderingSettings.RenderingStyle=medical.internal.app.labeler.enums.RenderingTechniques.GradientOpacity;
                renderingSettings.AlphaControlPoints=[intensity,alpha];
                renderingSettings.ColorControlPoints=[intensity,color];

            case medical.internal.app.labeler.model.PresetRenderingOptions.MRI

                intensity=[0;20;40;120;220;1024];
                alpha=[0;0;0.15;0.3;0.38;0.5];
                color=[0,0,0;43,0,0;103,37,20;199,155,97;216,213,201;255,255,255];
                color=color./255;

                renderingSettings.RenderingStyle=medical.internal.app.labeler.enums.RenderingTechniques.VolumeRendering;
                renderingSettings.AlphaControlPoints=[intensity,alpha];
                renderingSettings.ColorControlPoints=[intensity,color];

            case medical.internal.app.labeler.model.PresetRenderingOptions.CT_Bone

                intensity=[-3024,-16.45,641.38,3071]';
                alpha=[0,0,0.72,0.72]';
                color=[0,0,0;186,65,77;231,208,141;255,255,255];
                color=color./255;

                renderingSettings.RenderingStyle=medical.internal.app.labeler.enums.RenderingTechniques.VolumeRendering;
                renderingSettings.AlphaControlPoints=[intensity,alpha];
                renderingSettings.ColorControlPoints=[intensity,color];

            case medical.internal.app.labeler.model.PresetRenderingOptions.CT_Lung

                intensity=[-2050,-910,-899,-510,-499,2952]';
                alpha=[0,0,0.05,0.05,0,0]';
                color=[0,0,0;0,0,0;0.7608,0.4118,0.3216;0.7608,0.4118,0.3216;0.888889,0.254949,0.0240258;1,1,1];

                renderingSettings.RenderingStyle=medical.internal.app.labeler.enums.RenderingTechniques.VolumeRendering;
                renderingSettings.AlphaControlPoints=[intensity,alpha];
                renderingSettings.ColorControlPoints=[intensity,color];

            case medical.internal.app.labeler.model.PresetRenderingOptions.CT_SoftTissue

                intensity=[-1024,-100,-50,350,400,3071]';
                alpha=[0,0,0.75,0.75,0,0]';
                color=[0,0,0;0,0,0;0.4,0.0,0.0;0.6,0,0;1,1,1;1,1,1];

                renderingSettings.RenderingStyle=medical.internal.app.labeler.enums.RenderingTechniques.VolumeRendering;
                renderingSettings.AlphaControlPoints=[intensity,alpha];
                renderingSettings.ColorControlPoints=[intensity,color];

            case medical.internal.app.labeler.model.PresetRenderingOptions.CT_Coronary

                intensity=[-2048,142.677,192.174,217.24,384.347,3661]';
                alpha=[0,0,0.5625,0.776786,0.830357,0.830357]';
                color=[0,0,0;0.615686,0,0.0156863;0.909804,0.454902,0;0.972549,0.807843,0.611765;0.909804,0.909804,1;1,1,1];

                renderingSettings.RenderingStyle=medical.internal.app.labeler.enums.RenderingTechniques.VolumeRendering;
                renderingSettings.AlphaControlPoints=[intensity,alpha];
                renderingSettings.ColorControlPoints=[intensity,color];

            case medical.internal.app.labeler.model.PresetRenderingOptions.MRI_MIP

                intensity=[0,98.37,416.64,2800]';
                alpha=[0,0,0.5,1]';
                color=ones(4,3);

                renderingSettings.RenderingStyle=medical.internal.app.labeler.enums.RenderingTechniques.MaximumIntensityProjection;
                renderingSettings.AlphaControlPoints=[intensity,alpha];
                renderingSettings.ColorControlPoints=[intensity,color];

            case medical.internal.app.labeler.model.PresetRenderingOptions.CT_MIP

                intensity=[-3024,-637.62,700,3071]';
                alpha=[0,0,1,1]';
                color=[0,0,0;255,255,255;255,255,255;255,255,255];
                color=color./255;

                renderingSettings.RenderingStyle=medical.internal.app.labeler.enums.RenderingTechniques.MaximumIntensityProjection;
                renderingSettings.AlphaControlPoints=[intensity,alpha];
                renderingSettings.ColorControlPoints=[intensity,color];

            case medical.internal.app.labeler.model.PresetRenderingOptions.CustomPreset


            end

        end

    end

end