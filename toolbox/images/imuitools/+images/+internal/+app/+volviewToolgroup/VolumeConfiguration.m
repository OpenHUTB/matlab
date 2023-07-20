classdef VolumeConfiguration<handle


    properties
        Alphamap=linspace(0,1,256);
        Colormap=gray(256);
        Lighting=false;
RenderingStyle
        Isovalue=0.5
        IsosurfaceColor=[1,0,0];
AlphaControlPoints
ColorControlPoints
    end

    methods

        function obj=VolumeConfiguration(settingName)

            switch settingName

            case{'default','gray',getString(message('images:volumeViewerToolgroup:linear'))}

                intensity=[0,1];
                alpha=intensity;
                color=[0,0,0;1,1,1];
                [obj.Alphamap,obj.Colormap,obj.AlphaControlPoints,obj.ColorControlPoints]=...
                computeMaps(intensity,alpha,color);
                obj.Lighting=true;
                obj.RenderingStyle='VolumeRendering';

            case getString(message('images:volumeViewerToolgroup:ctbone'))
                intensity=[-3024,-16.45,641.38,3071];
                alpha=[0,0,0.72,0.72];
                color=[0,0,0;186,65,77;231,208,141;255,255,255];

                color=color./255;
                [obj.Alphamap,obj.Colormap,obj.AlphaControlPoints,obj.ColorControlPoints]=...
                computeMaps(intensity,alpha,color);
                obj.Lighting=true;
                obj.RenderingStyle='VolumeRendering';

            case getString(message('images:volumeViewerToolgroup:ctsoft_tissue'))
                intensity=[-1024,-100,-50,350,400,3071];
                alpha=[0,0,0.75,0.75,0,0];
                color=[0,0,0;0,0,0;0.4,0.0,0.0;0.6,0,0;1,1,1;1,1,1];

                [obj.Alphamap,obj.Colormap,obj.AlphaControlPoints,obj.ColorControlPoints]=...
                computeMaps(intensity,alpha,color);
                obj.Lighting=true;
                obj.RenderingStyle='VolumeRendering';

            case getString(message('images:volumeViewerToolgroup:ctlung'))
                intensity=[-2050,-910,-899,-510,-499,2952];
                alpha=[0,0,0.05,0.05,0,0];
                color=[0,0,0;0,0,0;0.7608,0.4118,0.3216;0.7608,0.4118,0.3216;0.888889,0.254949,0.0240258;1,1,1];

                [obj.Alphamap,obj.Colormap,obj.AlphaControlPoints,obj.ColorControlPoints]=...
                computeMaps(intensity,alpha,color);
                obj.Lighting=true;
                obj.RenderingStyle='VolumeRendering';

            case getString(message('images:volumeViewerToolgroup:ctcoronary'))
                intensity=[-2048,142.677,192.174,217.24,384.347,3661];
                alpha=[0,0,0.5625,0.776786,0.830357,0.830357];
                color=[0,0,0;0.615686,0,0.0156863;0.909804,0.454902,0;0.972549,0.807843,0.611765;0.909804,0.909804,1;1,1,1];

                [obj.Alphamap,obj.Colormap,obj.AlphaControlPoints,obj.ColorControlPoints]=...
                computeMaps(intensity,alpha,color);
                obj.Lighting=true;
                obj.RenderingStyle='VolumeRendering';

            case getString(message('images:volumeViewerToolgroup:mri'))
                intensity=[0,20,40,120,220,1024];
                alpha=[0,0,0.15,0.3,0.38,0.5];
                color=[0,0,0;43,0,0;103,37,20;199,155,97;216,213,201;255,255,255];
                color=color./255;
                [obj.Alphamap,obj.Colormap,obj.AlphaControlPoints,obj.ColorControlPoints]=...
                computeMaps(intensity,alpha,color);
                obj.Lighting=true;
                obj.RenderingStyle='VolumeRendering';

            case getString(message('images:volumeViewerToolgroup:ctmip'))
                intensity=[-3024,-637.62,700,3071];
                alpha=[0,0,1,1];
                color=[0,0,0;255,255,255;255,255,255;255,255,255];
                color=color./255;
                [obj.Alphamap,obj.Colormap,obj.AlphaControlPoints,obj.ColorControlPoints]=...
                computeMaps(intensity,alpha,color);
                obj.Lighting=true;
                obj.RenderingStyle='MaximumIntensityProjection';

            case getString(message('images:volumeViewerToolgroup:mrimip'))
                intensity=[0,98.37,416.64,2800];
                alpha=[0,0,0.5,1];
                color=ones(4,3);
                [obj.Alphamap,obj.Colormap,obj.AlphaControlPoints,obj.ColorControlPoints]=...
                computeMaps(intensity,alpha,color);
                obj.Lighting=true;
                obj.RenderingStyle='MaximumIntensityProjection';

            case 'isosurface-binary'
                obj.IsosurfaceColor=[1,0,0];
                obj.Isovalue=0.49;
                obj.RenderingStyle='Isosurface';
                return

            otherwise
                assert(false,'Unexpected rendering setting requested');

            end
        end
    end
end

function[amap,cmap,alphaCP,colorCP]=computeMaps(intensity,alpha,color)

    minIntensity=min(intensity);
    maxIntensity=max(intensity);
    scaledIntensity=(intensity-minIntensity)./(maxIntensity-minIntensity);

    queryPoints=linspace(minIntensity,maxIntensity,256);

    amap=interp1(intensity,alpha,queryPoints);
    cmap=interp1(intensity,color,queryPoints);

    alphaCP=[scaledIntensity;alpha]';
    colorCP=[scaledIntensity',color];
end
