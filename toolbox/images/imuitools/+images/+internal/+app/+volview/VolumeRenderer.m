




classdef VolumeRenderer<handle

    events
CameraMoved
WarningThrown
    end

    properties
Colormap
Alphamap
    end

    properties(Dependent)
RenderingStyle
Transform
VolumeVisible

OrientationAxes
Isovalue
Lighting
BackgroundColor
GradientColor
UseGradient
DisplaySlicePlanes
OverlayColormap
OverlayAlphamap

VolumeData
OverlayData
Alpha
    end

    properties
Viewer
VolumeObject
    end

    properties(Access=private)
RenderingStyleInternal
        SlicePlanesInternal=false;
    end

    methods(Access=private)

        function setDefaultTransferFunction(self)

            self.Colormap=gray(256);
            self.Alphamap=linspace(0,1,256);

        end

        function resetTransferFunction(self)

            self.VolumeObject.Colormap=self.Colormap;
            self.VolumeObject.Alphamap=self.Alphamap;

        end

        function resetOverlayTransferFunction(self)

            self.VolumeObject.OverlayColormap=self.OverlayColormap;
            self.VolumeObject.OverlayAlphamap=self.OverlayAlphamap;

        end

    end


    methods

        function self=VolumeRenderer(hParent)

            setDefaultTransferFunction(self);
            self.Viewer=images.ui.graphics3d.Viewer3D(hParent,'Tag','Viewer3D',...
            'Interactions',["rotate","zoom","axes"],'ShowWarnings',false);
            self.VolumeObject=images.ui.graphics3d.Volume(self.Viewer,...
            'RescaleOverlayData',false,'Tag','VolumeObject');

            addlistener(self.Viewer,'CameraMoved',@(src,evt)notify(self,'CameraMoved',evt));
            addlistener(self.Viewer,'WarningThrown',@(src,evt)notify(self,'WarningThrown',evt));

        end

        function updateVolumeWithNewData(self,vol,overlayVol)



            self.VolumeObject.Data=permute(vol,[2,1,3]);
            self.VolumeObject.OverlayData=permute(overlayVol,[2,1,3]);
        end

        function updateXYPlane(self,zLoc,szInWorld,szInLocal)

            zLoc=((zLoc-1)*((szInLocal-1)/(szInWorld-1)))+1;
            self.VolumeObject.SlicePlaneValues(3,4)=zLoc;
            drawnow('limitrate');
        end

        function updateXZPlane(self,yLoc,szInWorld,szInLocal)

            yLoc=((yLoc-1)*((szInLocal-1)/(szInWorld-1)))+1;
            self.VolumeObject.SlicePlaneValues(2,4)=yLoc;
            drawnow('limitrate');
        end

        function updateYZPlane(self,xLoc,szInWorld,szInLocal)

            xLoc=((xLoc-1)*((szInLocal-1)/(szInWorld-1)))+1;
            self.VolumeObject.SlicePlaneValues(1,4)=xLoc;
            drawnow('limitrate');
        end

    end


    methods

        function set.DisplaySlicePlanes(self,TF)
            self.SlicePlanesInternal=TF;
            if TF
                self.VolumeObject.RenderingStyle='SlicePlanes';
            else
                self.RenderingStyle=self.RenderingStyleInternal;
            end
        end

        function TF=get.DisplaySlicePlanes(self)
            TF=strcmp(self.VolumeObject.RenderingStyle,'SlicePlanes');
        end

        function set.Isovalue(self,val)
            self.VolumeObject.IsosurfaceValue=val;
        end

        function val=get.Isovalue(self)
            val=self.VolumeObject.IsosurfaceValue;
        end

        function set.BackgroundColor(self,color)
            self.Viewer.BackgroundColor=color;
        end

        function color=get.BackgroundColor(self)
            color=self.Viewer.BackgroundColor;
        end

        function set.GradientColor(self,color)
            self.Viewer.GradientColor=color;
        end

        function color=get.GradientColor(self)
            color=self.Viewer.GradientColor;
        end

        function set.UseGradient(self,color)
            self.Viewer.BackgroundGradient=color;
        end

        function color=get.UseGradient(self)
            color=self.Viewer.BackgroundGradient;
        end

        function set.Transform(self,tform)
            self.VolumeObject.Transformation=tform';
        end

        function tform=get.Transform(self)
            tform=self.VolumeObject.Transformation;
        end

        function set.Lighting(self,onOff)
            self.Viewer.Lighting=onOff;
        end

        function onOff=get.Lighting(self)
            onOff=self.Viewer.Lighting;
        end

        function set.VolumeVisible(self,onOff)
            self.VolumeObject.Visible=onOff;
        end

        function onOff=get.VolumeVisible(self)
            onOff=self.VolumeObject.Visible;
        end

        function set.OrientationAxes(self,onOff)
            self.Viewer.OrientationAxes=onOff;
        end

        function onOff=get.OrientationAxes(self)
            onOff=self.Viewer.OrientationAxes;
        end

        function set.Colormap(self,cmap)

            assert(isa(cmap,'double'));



            if size(cmap,1)~=256
                error('Require 256 length colormap.');
            end
            self.Colormap=cmap;

            self.resetTransferFunction();

        end

        function set.Alphamap(self,amap)

            assert(isa(amap,'double'),'Assume incoming alphamap will be [0 1] normalized double data.');

            if length(amap)~=256
                error('Require 256 length alphamap.');
            end

            self.Alphamap=amap;

            self.resetTransferFunction();

        end

        function set.OverlayColormap(self,cmap)

            assert(isa(cmap,'double'));



            if size(cmap,1)~=256
                error('Require 256 length colormap.');
            end
            self.VolumeObject.OverlayColormap=cmap;

        end

        function set.OverlayAlphamap(self,amap)

            assert(isa(amap,'double'),'Assume incoming alphamap will be [0 1] normalized double data.');

            if length(amap)~=256
                error('Require 256 length alphamap.');
            end
            self.VolumeObject.OverlayAlphamap=amap;
        end

        function set.RenderingStyle(self,technique)

            technique=validatestring(technique,{'VolumeRendering','Isosurface',...
            'MaximumIntensityProjection','LabelVolumeRendering'...
            ,'LabelOverlayRendering'});

            switch(technique)
            case{'VolumeRendering','MaximumIntensityProjection'}
                self.VolumeObject.RenderingStyle=technique;
                self.VolumeObject.OverlayAlphamap=0;

            case 'Isosurface'
                self.VolumeObject.RenderingStyle='Isosurface';

            case 'LabelVolumeRendering'
                self.VolumeObject.RenderingStyle='VolumeRendering';
                self.VolumeObject.Alphamap=0;

            case 'LabelOverlayRendering'
                self.VolumeObject.RenderingStyle='VolumeRendering';
            end

            self.RenderingStyleInternal=technique;


            if self.SlicePlanesInternal
                self.VolumeObject.RenderingStyle='SlicePlanes';
            end

        end

        function style=get.RenderingStyle(self)
            style=self.RenderingStyleInternal;
        end

        function data=get.VolumeData(self)
            data=self.VolumeObject.Data;
        end

        function data=get.OverlayData(self)
            data=self.VolumeObject.OverlayData;
        end

        function amap=get.Alpha(self)
            amap=self.VolumeObject.Alphamap;
        end

    end

end

