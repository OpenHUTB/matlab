




classdef VolumeRenderer<handle

    properties(Access=private)
ContainingPanel
Canvas
    end


    properties
VolumePrimitive
Colormap
Alphamap
RVol
Transform
Light
IsoValue
RenderingStyleInternal
Camera
    end

    properties(Dependent)
RenderingStyle
VolumeData
Visible
XLimits
YLimits
ZLimits
Lighting
    end

    properties(Constant)
        DefaultAlphaFunc=0.02;
        DefaultSampleDensity=0.005;
    end

    methods(Access=private)


        function setDefaultTransferFunction(self)

            self.Colormap=gray(256);
            self.Alphamap=linspace(0,1,256);

        end

        function resetTransferFunction(self)

            self.VolumePrimitive.TransferFunction=[self.Colormap';self.Alphamap];

        end

    end


    methods

        function self=VolumeRenderer(hCamera,hTransform,hCanvas,Vol)

            self.Canvas=hCanvas;
            self.VolumePrimitive=matlab.graphics.primitive.world.osg.Volume();
            self.VolumePrimitive.Data=Vol;
            self.setDefaultTransferFunction();
            self.VolumePrimitive.Parent=hTransform;
            self.Camera=hCamera;

            self.setVolumePrimitiveRenderingTechnique();

            self.VolumePrimitive.SampleDensity=self.DefaultSampleDensity;
            self.VolumePrimitive.SampleDensityWhenMoving=self.DefaultSampleDensity*2;
            self.VolumePrimitive.AlphaFunc=self.DefaultAlphaFunc;

            self.Light=matlab.graphics.primitive.world.LightSource('Parent',hCamera,'Visible','off');
            self.IsoValue=self.DefaultAlphaFunc;

        end

        function updateVolumeWithNewData(self,Volume)
            self.VolumeData=Volume;
        end

        function updateVolumeWithNewDataLimits(self,numSlicesInX,numSlicesInY,numSlicesInZ)





            self.Camera.Viewport.Units='normalized';
            drawnow;
            self.XLimits=[0.5,numSlicesInX+0.5];
            self.YLimits=[0.5,numSlicesInY+0.5];
            self.ZLimits=[0.5,numSlicesInZ+0.5];



            self.Camera.Viewport.Units='pixels';

        end

        function updateVolumeAtFullResolution(self)









            self.Canvas.Color=self.Canvas.Color;

        end

        function setVolumePrimitiveRenderingTechnique(self)



            if iptgetpref('VolumeViewerUseHardware')
                self.VolumePrimitive.VolumeTechnique='RayTraced';
            else
                self.VolumePrimitive.VolumeTechnique='FixedFunction';
            end
        end

    end


    methods
        function set.Lighting(self,onOff)
            self.Light.Visible=onOff;
        end

        function onOff=get.Lighting(self)
            onOff=self.Light.Visible;
        end

        function set.Visible(self,onOff)
            self.VolumePrimitive.Visible=onOff;
        end

        function onOff=get.Visible(self)
            onOff=self.VolumePrimitive.Visible;
        end

        function set.Colormap(self,cmap)

            assert(isa(cmap,'double'));



            if size(cmap,1)~=256
                error('Require 256 length colormap.');
            end



            self.Colormap=im2uint8(cmap);

            self.resetTransferFunction();

        end

        function set.Alphamap(self,amap)

            assert(isa(amap,'double'),'Assume incoming alphamap will be [0 1] normalized double data.');

            if length(amap)~=256
                error('Require 256 length alphamap.');
            end

            self.Alphamap=im2uint8(amap);

            self.resetTransferFunction();

        end

        function set.RenderingStyle(self,technique)

            technique=validatestring(technique,{'VolumeRendering','Isosurface',...
            'MaximumIntensityProjection','LabelVolumeRendering'...
            ,'LabelOverlayRendering'});

            self.VolumePrimitive.AlphaFunc=self.DefaultAlphaFunc;
            switch(technique)
            case 'VolumeRendering'
                self.setVolumePrimitiveRenderingTechnique();
                self.VolumePrimitive.Interpolation='Linear';
                self.VolumePrimitive.Isosurface=0;
                self.VolumePrimitive.MaximumIntensityProjection=0;

            case 'Isosurface'
                self.setVolumePrimitiveRenderingTechnique();
                self.VolumePrimitive.Isosurface=1;
                self.VolumePrimitive.Interpolation='Linear';
                self.VolumePrimitive.MaximumIntensityProjection=0;
                self.VolumePrimitive.AlphaFunc=self.IsoValue;

            case 'MaximumIntensityProjection'
                self.setVolumePrimitiveRenderingTechnique();
                self.VolumePrimitive.Interpolation='Linear';
                self.VolumePrimitive.Isosurface=0;
                self.VolumePrimitive.MaximumIntensityProjection=1;

            case{'LabelVolumeRendering','LabelOverlayRendering'}
                self.setVolumePrimitiveRenderingTechnique();
                self.VolumePrimitive.Interpolation='Nearest';
                self.VolumePrimitive.Isosurface=0;
                self.VolumePrimitive.MaximumIntensityProjection=0;
            end

            self.RenderingStyleInternal=technique;

        end

        function style=get.RenderingStyle(self)
            style=self.RenderingStyleInternal;
        end

        function set.VolumeData(self,volData)
            self.VolumePrimitive.Data=volData;
        end

        function vol=get.VolumeData(self)
            vol=self.VolumePrimitive.Data;
        end

        function set.XLimits(self,xlim)
            self.VolumePrimitive.XLim=xlim;
        end

        function lim=get.XLimits(self)
            lim=self.VolumePrimitive.XLim;
        end

        function set.YLimits(self,ylim)
            self.VolumePrimitive.YLim=ylim;
        end

        function lim=get.YLimits(self)
            lim=self.VolumePrimitive.YLim;
        end

        function set.ZLimits(self,zlim)
            self.VolumePrimitive.ZLim=zlim;
        end

        function lim=get.ZLimits(self)
            lim=self.VolumePrimitive.ZLim;
        end
    end

end

