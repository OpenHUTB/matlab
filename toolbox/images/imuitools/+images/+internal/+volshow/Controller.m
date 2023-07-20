classdef Controller<handle



    properties(Transient,Hidden)

CameraController
ViewerModel
ViewerView

    end

    properties(Transient,Hidden,Access=private)

VolumeDataChangeListener
MergedVolumeDataUpdateListener
VolumeDisplayChangeListener
SpatialReferencingChangeListener
BackgroundColorChangeListener
VolumeRenderingSettingsChangeListener

UnableToSetCustomVoxelDimensionsListener
NumLabelsExceededMaxListener

    end

    methods

        function self=Controller(modelIn,viewIn)
            self.ViewerModel=modelIn;
            self.ViewerView=viewIn;



            self.CameraController=images.internal.app.volview.CameraController(self.ViewerView.Canvas,modelIn,viewIn);


            self.wireVolumeDataChangeModelListeners();
            self.wireMergedVolumeDataUpdateModelListeners();
            self.wireVolumeDisplayChangeModelListeners();
            self.wireSpatialReferencingChangeModelListeners();
            self.wireVolumeRenderingSettingsModelListeners();
            self.wireBackgroundColorChangeModelListeners();

            self.wireVoxelDimensionsFailedToSetListeners();
            self.wireNumLabelsExceededMaxListeners();
        end

        function delete(self)

            delete(self.CameraController);
            self.CameraController=[];

            delete(self.VolumeDataChangeListener);
            delete(self.MergedVolumeDataUpdateListener);
            delete(self.VolumeDisplayChangeListener);
            delete(self.SpatialReferencingChangeListener);
            delete(self.BackgroundColorChangeListener);
            delete(self.VolumeRenderingSettingsChangeListener);

            delete(self.UnableToSetCustomVoxelDimensionsListener);
            delete(self.NumLabelsExceededMaxListener);


            self.ViewerModel=[];
            self.ViewerView=[];

            delete(self);
        end

    end


    methods

        function wireVolumeDataChangeModelListeners(self)
            self.VolumeDataChangeListener=event.listener(self.ViewerModel,'VolumeDataChange',@(hObj,data)self.updateVolumeView(data));
        end

        function wireMergedVolumeDataUpdateModelListeners(self)
            self.MergedVolumeDataUpdateListener=event.listener(self.ViewerModel,'VolumeDataUpdate',@(hObj,data)self.updateVolumeViewData(data));
        end

        function wireVolumeDisplayChangeModelListeners(self)
            self.VolumeDisplayChangeListener=event.listener(self.ViewerModel,'VolumeDisplayChange',@(hObj,data)self.updateVolumeDisplay(data));
        end

        function wireSpatialReferencingChangeModelListeners(self)
            self.SpatialReferencingChangeListener=event.listener(self.ViewerModel,'SpatialReferencingChange',@(hObj,data)self.updateViewTransform(data));
        end

        function wireBackgroundColorChangeModelListeners(self)
            self.BackgroundColorChangeListener=event.listener(self.ViewerModel,'BackgroundColorChange',@(hObj,data)self.ViewerView.setBackgroundColor(data.Color));
        end

        function wireVolumeRenderingSettingsModelListeners(self)
            self.VolumeRenderingSettingsChangeListener=event.listener(self.ViewerModel,'VolumeRenderingSettingsChange',@(hObj,data)self.manageVolumeRenderingSettings(data));
        end

        function wireVoxelDimensionsFailedToSetListeners(self)
            self.UnableToSetCustomVoxelDimensionsListener=event.listener(self.ViewerModel,'UnableToSetCustomVoxelDimensions',@(hObj,data)self.ViewerView.displayInvalidSpatialReferencingError(data.ErrorMessage));
        end

        function wireNumLabelsExceededMaxListeners(self)
            self.NumLabelsExceededMaxListener=event.listener(self.ViewerModel,'NumLabelsExceededMax',@(hObj,data)self.ViewerView.displayNumLabelsExceededError(data.ErrorMessage));
        end

    end



    methods(Access=private)

        function updateVolumeView(self,eventData)

            self.updateVolumeViewData(eventData);
            self.updateVolumeViewDataLimits(eventData);
        end

        function updateVolumeViewData(self,eventData)
            self.ViewerView.volumeRenderingView.updateVolumeWithNewData(eventData.Volume);
        end

        function updateVolumeViewDataLimits(self,eventData)
            [NumSlicesInX,NumSlicesInY,NumSlicesInZ]=size(eventData.Volume);
            self.ViewerView.volumeRenderingView.updateVolumeWithNewDataLimits(NumSlicesInX,...
            NumSlicesInY,NumSlicesInZ)
        end

        function updateVolumeDisplay(self,eventData)

            boolToOnOffMap=containers.Map({true,false},{'on','off'});
            self.ViewerView.volumeRenderingView.Visible=boolToOnOffMap(eventData.DisplayVolume);

        end

        function manageVolumeRenderingSettings(self,eventData)
            config=eventData.Config;
            switch config.RenderingStyle
            case{'VolumeRendering','MaximumIntensityProjection'...
                ,'LabelVolumeRendering','LabelOverlayRendering'}
                self.ViewerView.volumeRenderingView.Alphamap=config.Alphamap;
                self.ViewerView.volumeRenderingView.Colormap=config.Colormap;
                self.ViewerView.volumeRenderingView.Lighting=config.Lighting;

            case 'Isosurface'
                self.ViewerView.volumeRenderingView.IsoValue=config.Isovalue;
                self.ViewerView.volumeRenderingView.Colormap=repmat(config.IsosurfaceColor,[256,1]);
            end


            self.ViewerView.volumeRenderingView.RenderingStyle=config.RenderingStyle;

        end

        function updateViewTransform(self,data)
            self.ViewerView.VolumeTransform.Matrix=data.Transform;
        end

    end

end