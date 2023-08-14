




classdef Controller<handle

    properties
CameraController
ViewerModel
ViewerView
RenderingChangeViewListeners
    end

    methods
        function self=Controller(modelIn,viewIn)
            self.ViewerModel=modelIn;
            self.ViewerView=viewIn;



            self.CameraController=images.internal.app.volviewToolgroup.CameraController(self.ViewerView.Canvas,modelIn,viewIn);

            self.RenderingChangeViewListeners={};


            self.wireReplaceOrOverlayResponseViewListener();
            self.wireNewSessionViewListener();
            self.wire2DSliceViewListeners();
            self.wireSpatialReferencingListeners();
            self.wireViewVolumeOrSlicesToggleListeners();
            self.wireVolumeSettingsEditorListeners();
            self.wireLabelSettingsEditorListeners();
            self.wireVolumeImportListeners();
            self.wireRenderingSectionListeners();
            self.wireBackgroundColorChangeListeners();
            self.wireExportListener()


            self.wireCheckReplaceOrOverlayModelListener();
            self.wireModelClearedModelListener();
            self.wire2DSliceChangeModelListeners();
            self.wireVolumeDataChangeModelListeners();
            self.wireMergedVolumeUpdateChangeModelListeners();
            self.wire3DSliceSliceChangeModelListeners();
            self.wireVolumeDisplayChangeModelListeners();
            self.wireVolumeRenderingSettingsModelListeners();
            self.wireSpatialReferencingChangeModelListeners();
            self.wireSpatialReferencingMetadataListeners();
            self.wirePresetRenderingSettingsListeners();
            self.wireBackgroundColorChangeModelListeners();
            self.wireInputSourceChangeModelListener();
            self.wireExportEventModelListener();
            self.wireErrorListeners();
        end
    end


    methods

        function wireReplaceOrOverlayResponseViewListener(self)
            addlistener(self.ViewerView,'ReplaceOrOverlayResult',@(hObj,evt)self.updateReplaceOrOverlayResponse(evt));
        end

        function wireNewSessionViewListener(self)
            addlistener(self.ViewerView,'StartNewSession',@(hObj,evt)self.ViewerModel.clearModel());
        end

        function wire2DSliceViewListeners(self)
            addlistener(self.ViewerView.xySliceView.hSlider,'Value','PostSet',@(hObj,evt)set(self.ViewerModel,'ZSliceLocationSelected',evt.AffectedObject.Value));
            addlistener(self.ViewerView.xzSliceView.hSlider,'Value','PostSet',@(hObj,evt)set(self.ViewerModel,'YSliceLocationSelected',evt.AffectedObject.Value));
            addlistener(self.ViewerView.yzSliceView.hSlider,'Value','PostSet',@(hObj,evt)set(self.ViewerModel,'XSliceLocationSelected',evt.AffectedObject.Value));

            addlistener(self.ViewerView.xySliceFig,'WindowScrollWheel',@(hobj,evt)self.ViewerModel.modifyZSliceLocationSelectedByIncrement(-evt.VerticalScrollCount));
            addlistener(self.ViewerView.xzSliceFig,'WindowScrollWheel',@(hobj,evt)self.ViewerModel.modifyYSliceLocationSelectedByIncrement(-evt.VerticalScrollCount));
            addlistener(self.ViewerView.yzSliceFig,'WindowScrollWheel',@(hobj,evt)self.ViewerModel.modifyXSliceLocationSelectedByIncrement(-evt.VerticalScrollCount));
        end

        function wireSpatialReferencingListeners(self)
            addlistener(self.ViewerView.CustomReferencingButton,'ValueChanged',@(hObj,evt)self.reactToSpatialReferencingRadioButtonsChange(evt));
            addlistener(self.ViewerView.UniformInWorldButton,'ValueChanged',@(hObj,evt)self.reactToSpatialReferencingRadioButtonsChange(evt));
            addlistener(self.ViewerView.UseFileMetadataButton,'ValueChanged',@(hObj,evt)self.reactToSpatialReferencingRadioButtonsChange(evt));
            addlistener(self.ViewerView.XAxisUnitsEditField,'ValueChanged',@(hObj,evt)self.ViewerModel.changeSpatialReferencing(evt));
            addlistener(self.ViewerView.YAxisUnitsEditField,'ValueChanged',@(hObj,evt)self.ViewerModel.changeSpatialReferencing(evt));
            addlistener(self.ViewerView.ZAxisUnitsEditField,'ValueChanged',@(hObj,evt)self.ViewerModel.changeSpatialReferencing(evt));
            addlistener(self.ViewerModel,'CustomVoxelDimensionsChanged',@(hObj,evt)self.ViewerView.setCustomReferencingButtonActive());
        end

        function wireViewVolumeOrSlicesToggleListeners(self)
            addlistener(self.ViewerView.VolumeModeButton,'ValueChanged',@(hObj,evt)self.updateVolumeDisplayMode(evt));
            addlistener(self.ViewerView.LabelModeButton,'ValueChanged',@(hObj,evt)self.updateVolumeDisplayMode(evt));
            addlistener(self.ViewerView.ShowVolumeToggleButton,'ValueChanged',@(hObj,evt)set(self.ViewerModel,'Show3DVolume',evt.Source.Value));
        end

        function wireVolumeSettingsEditorListeners(self)
            self.RenderingChangeViewListeners{end+1}=addlistener(self.ViewerView.renderingEditorView.RenderingStylePopup,'Value','PostSet',@(hObj,evt)self.manageVolumeTechnique(evt.AffectedObject.String{evt.AffectedObject.Value}));
            self.RenderingChangeViewListeners{end+1}=addlistener(self.ViewerView.renderingEditorView.IsovalSlider,'Value','PostSet',@(hObj,evt)self.ViewerModel.setIsovalue(evt.AffectedObject.Value));
            self.RenderingChangeViewListeners{end+1}=addlistener(self.ViewerView.renderingEditorView,'IsosurfaceColorChange',@(hObj,evt)self.ViewerModel.setIsosurfaceColor(evt.Colormap));
            self.RenderingChangeViewListeners{end+1}=addlistener(self.ViewerView.renderingEditorView.ColorMapEditor,'ColormapChange',@(hObj,evt)self.ViewerModel.setColormapVol(evt.Colormap));
            self.RenderingChangeViewListeners{end+1}=addlistener(self.ViewerView.renderingEditorView.ColorMapEditor,'ColormapEdit',@(hObj,evt)self.ViewerModel.setColormapVol(evt.Colormap));
            self.RenderingChangeViewListeners{end+1}=addlistener(self.ViewerView.renderingEditorView.AlphaMapEditor,'AlphamapChange',@(hObj,evt)self.ViewerModel.setAlphamapVol(evt.Alphamap,evt.AlphaControlPoints));
            self.RenderingChangeViewListeners{end+1}=addlistener(self.ViewerView.renderingEditorView.AlphaMapEditor,'PositionChange',@(hObj,evt)self.ViewerModel.setAlphaMapFromControlPoints(hObj.Position));

            if iptgetpref('VolumeViewerUseHardware')
                self.RenderingChangeViewListeners{end+1}=addlistener(self.ViewerView.renderingEditorView.LightingToggle,'Value','PostSet',...
                @(hObj,evt)self.ViewerModel.setLighting(evt.AffectedObject.Value));
            end
        end

        function wireLabelSettingsEditorListeners(self)
            self.RenderingChangeViewListeners{end+1}=addlistener(self.ViewerView.renderingEditorView.EmbedLabelsCheckbox,'Value','PostSet',@(hObj,evt)self.updateModelVolumeMode(evt.AffectedObject.Value));
            self.RenderingChangeViewListeners{end+1}=addlistener(self.ViewerView.renderingEditorView,'LabelShowFlagChange',@(hObj,evt)self.ViewerModel.changeLabelVisibility(evt));
            self.RenderingChangeViewListeners{end+1}=addlistener(self.ViewerView.renderingEditorView,'LabelColorChange',@(hObj,evt)self.ViewerModel.changeLabelColor(evt));
            self.RenderingChangeViewListeners{end+1}=addlistener(self.ViewerView.renderingEditorView,'LabelOpacityChange',@(hObj,evt)self.ViewerModel.changeLabelOpacity(evt));
            self.RenderingChangeViewListeners{end+1}=addlistener(self.ViewerView.renderingEditorView.ThresholdSlider,'Value','PostSet',@(hObj,evt)self.ViewerModel.setOverlayConfigThreshold(evt.AffectedObject.Value));
            self.RenderingChangeViewListeners{end+1}=addlistener(self.ViewerView.renderingEditorView.VolumeOpacitySlider,'Value','PostSet',@(hObj,evt)self.ViewerModel.setOverlayConfigVolumeOpacity(evt.AffectedObject.Value));
        end

        function wireVolumeImportListeners(self)
            addlistener(self.ViewerView,'ImportFromFile',@(hObj,evt)self.ViewerModel.importVolumeFromFile(evt.Filename,evt.VolType));
            addlistener(self.ViewerView,'ImportFromDicomFolder',@(hObj,evt)self.ViewerModel.importVolumeFromDicomFolder(evt.DirectoryName,evt.VolType));
            addlistener(self.ViewerView,'ImportFromWorkspace',@(hObj,evt)self.ViewerModel.loadDataFromWorkspace(evt.VolumeData,evt.VolType,evt.VariableName));
        end

        function wireRenderingSectionListeners(self)
            addlistener(self.ViewerView.RestoreDefaultButton,'ButtonPushed',@(hObj,evt)self.reactToRestoreDefaultBtn());
        end

        function wireBackgroundColorChangeListeners(self)
            addlistener(self.ViewerView,'BackgroundColorChange',@(hobj,evt)set(self.ViewerModel,'BackgroundColor',evt.Color));
        end

        function wireExportListener(self)
            addlistener(self.ViewerView.ExportConfigSubitem,'ItemPushed',@(hObj,evt)self.ViewerModel.exportConfig());
        end
    end


    methods

        function wireCheckReplaceOrOverlayModelListener(self)
            addlistener(self.ViewerModel,'CheckReplaceOrOverlay',@(hObj,data)self.ViewerView.checkReplaceOrOverlay(data));
        end

        function wireModelClearedModelListener(self)
            addlistener(self.ViewerModel,'ModelCleared',@(hObj,data)self.ViewerView.disableViewControlsOnNewSession());
        end

        function wire2DSliceChangeModelListeners(self)
            addlistener(self.ViewerModel,'XYSliceChange',@(hObj,data)self.ViewerView.xySliceView.updateImageSlice(data.Slice,data.SliceIndex));
            addlistener(self.ViewerModel,'YZSliceChange',@(hObj,data)self.ViewerView.yzSliceView.updateImageSlice(data.Slice,data.SliceIndex));
            addlistener(self.ViewerModel,'XZSliceChange',@(hObj,data)self.ViewerView.xzSliceView.updateImageSlice(data.Slice,data.SliceIndex));
        end

        function wire3DSliceSliceChangeModelListeners(self)
            addlistener(self.ViewerModel,'XYSliceChange',@(hObj,data)self.ViewerView.slicePlane3DViewer.updateXYPlane(data.Slice,data.NumSlicesInDim,data.SliceIndex));
            addlistener(self.ViewerModel,'XZSliceChange',@(hObj,data)self.ViewerView.slicePlane3DViewer.updateXZPlane(data.Slice,data.NumSlicesInDim,data.SliceIndex));
            addlistener(self.ViewerModel,'YZSliceChange',@(hObj,data)self.ViewerView.slicePlane3DViewer.updateYZPlane(data.Slice,data.NumSlicesInDim,data.SliceIndex));
        end

        function wireVolumeDataChangeModelListeners(self)







            addlistener(self.ViewerModel,'VolumeDataChange',@(hObj,data)self.updateSliceViews(data));
            addlistener(self.ViewerModel,'VolumeDataChange',@(hObj,data)self.updateVolumeViewData(data.Volume));
            addlistener(self.ViewerModel,'VolumeDataChange',@(hObj,data)self.updateVolumeViewDataLimits(data));
            addlistener(self.ViewerModel,'VolumeDataChange',@(hObj,data)self.update3DSliceView(data));
            addlistener(self.ViewerModel,'VolumeDataChange',@(hObj,data)self.ViewerView.enableViewControlsOnDataLoad(data));
        end

        function wireMergedVolumeUpdateChangeModelListeners(self)
            addlistener(self.ViewerModel,'VolumeDataUpdate',@(hObj,data)self.updateSliceViews(data));
            addlistener(self.ViewerModel,'VolumeDataUpdate',@(hObj,data)self.updateVolumeViewData(data.Volume));
            addlistener(self.ViewerModel,'VolumeDataUpdate',@(hObj,data)self.update3DSliceView(data));
            addlistener(self.ViewerModel,'VolumeDataUpdate',@(hObj,data)self.ViewerView.enableViewControlsOnDataLoad(data));

        end

        function wireVolumeDisplayChangeModelListeners(self)
            addlistener(self.ViewerModel,'VolumeDisplayChange',@(hObj,data)self.updateVolumeDisplay(data));
        end

        function wireVolumeRenderingSettingsModelListeners(self)
            addlistener(self.ViewerModel,'VolumeRenderingSettingsChange',@(hObj,data)self.manageVolumeRenderingSettings(data));
        end

        function wireSpatialReferencingChangeModelListeners(self)
            addlistener(self.ViewerModel,'SpatialReferencingChange',@(hObj,data)self.updateViewTransform(data));
            addlistener(self.ViewerModel,'SpatialReferencingChange',@(hObj,data)self.updateSliceViews(data));
            addlistener(self.ViewerModel,'SpatialReferencingEditFieldsSet',@(hObj,data)self.ViewerView.setSpatialReferencingEditFields(data.XSize,data.YSize,data.ZSize));
        end

        function wireSpatialReferencingMetadataListeners(self)
            addlistener(self.ViewerModel,'SpatialReferencingMetadataAvailableChange',@(hObj,data)self.updateSpatialReferencingToolstripControls(data));
        end

        function wirePresetRenderingSettingsListeners(self)
            addlistener(self.ViewerModel,'PresetRenderingSettingsChange',@(hObj,data)self.updateRenderingEditor(data));
        end

        function wireBackgroundColorChangeModelListeners(self)
            addlistener(self.ViewerModel,'BackgroundColorChange',@(hObj,data)self.ViewerView.setBackgroundColor(data.Color));
        end

        function wireErrorListeners(self)
            addlistener(self.ViewerModel,'UnableToLoadFile',@(hObj,data)self.ViewerView.displayFileLoadFailedDlg(data.ErrorMessage));
            addlistener(self.ViewerModel,'UnableToLoadFolder',@(hObj,data)self.ViewerView.displayFolderLoadFailedDlg(data.ErrorMessage));
            addlistener(self.ViewerModel,'UnableToSetCustomVoxelDimensions',@(hObj,data)self.ViewerView.displayInvalidSpatialReferencingDlg(data.ErrorMessage));
            addlistener(self.ViewerModel,'VolumeSizesNotEqual',@(hObj,data)self.ViewerView.displayVolSizesNotEqualDlg(data.ErrorMessage));
            addlistener(self.ViewerModel,'NumLabelsExceededMax',@(hObj,data)self.ViewerView.displayNumLabelsExceededDlg(data.ErrorMessage));
        end

        function wireInputSourceChangeModelListener(self)
            addlistener(self.ViewerModel,'InputSourceChange',@(hObj,data)self.updateInputSourceOnTitlebar(data));
        end

        function wireExportEventModelListener(self)
            addlistener(self.ViewerModel,'ExportDataAvailable',@(hObj,data)self.ViewerView.launchExportDialog(data.Config));
        end
    end


    methods(Access=private)

        function reactToRestoreDefaultBtn(self)
            self.ViewerModel.restoreDefaultRendering();
        end

        function updateModelVolumeMode(self,val)
            if val
                self.ViewerModel.updateVolumeMode('mixed');
            else
                self.ViewerModel.updateVolumeMode('labels');
            end
        end

        function reactToSpatialReferencingRadioButtonsChange(self,evt)





            if(~evt.EventData.NewValue)
                return
            end

            if(evt.Source==self.ViewerView.CustomReferencingButton)
                self.ViewerModel.Transform=self.ViewerModel.CustomTransform;
            elseif(evt.Source==self.ViewerView.UniformInWorldButton)
                self.ViewerModel.Transform=self.ViewerModel.UpsampleToCubeTransform;
            else
                self.ViewerModel.Transform=self.ViewerModel.TransformFromFileMetadata;
            end
        end

        function manageVolumeTechnique(self,volumeTechniqueStr)

            renderingPopupUIStrings={getString(message('images:volumeViewerToolgroup:volRenderingCategoryName')),...
            getString(message('images:volumeViewerToolgroup:mipCategoryName')),...
            getString(message('images:volumeViewerToolgroup:isosurfaceCategoryName'))};

            styleMap=containers.Map(renderingPopupUIStrings,...
            {'VolumeRendering','MaximumIntensityProjection','Isosurface'});

            self.ViewerModel.Renderer=styleMap(volumeTechniqueStr);

        end

        function updateVolumeDisplayMode(self,evt)




            if(~evt.EventData.NewValue)
                return
            end

            if(evt.Source==self.ViewerView.VolumeModeButton)
                self.ViewerModel.updateVolumeMode('volume');

            elseif(evt.Source==self.ViewerView.LabelModeButton)
                if~self.ViewerView.renderingEditorView.EmbedLabelsCheckbox.Value
                    self.ViewerModel.updateVolumeMode('labels');
                else
                    self.ViewerModel.updateVolumeMode('mixed');
                end
            end
        end

        function updateReplaceOrOverlayResponse(self,evt)
            switch evt.RefreshValue

            case 'Volume'
                self.ViewerModel.HasVolumeData=false;
            case 'LabeledVolume'
                self.ViewerModel.HasLabeledVolumeData=false;
            case 'App'
                self.ViewerModel.HasVolumeData=false;
                self.ViewerModel.HasLabeledVolumeData=false;
            case 'Cancel'
                self.ViewerModel.CancelImportFlag=true;
            end
        end

    end


    methods(Access=private)

        function updateInputSourceOnTitlebar(self,eventData)

            title=strcat(getString(message('images:volumeViewerToolgroup:appName'))," - ");

            if strcmp(eventData.VolType,'volume')
                self.ViewerView.VolumeSource=eventData.InputSource;
            else
                self.ViewerView.LabeledVolumeSource=eventData.InputSource;
            end

            if~self.ViewerModel.HasVolumeData
                self.ViewerView.VolumeSource="";
            else
                title=strcat(title,getString(message('images:volumeViewerToolgroup:volumeData')),...
                ": ",self.ViewerView.VolumeSource,"");
            end

            if~self.ViewerModel.HasLabeledVolumeData
                self.ViewerView.LabeledVolumeSource="";
            else
                if self.ViewerModel.HasVolumeData
                    title=strcat(title," & ");
                end

                title=strcat(title,getString(message('images:volumeViewerToolgroup:labelData')),...
                ": ",self.ViewerView.LabeledVolumeSource);
            end

            self.ViewerView.ToolGroup.Title=title;
        end

        function updateSliceViews(self,eventData)

            self.ViewerView.xySliceView.updateOverallImageDisplay(eventData.XYSlice,eventData.NumSlicesInZ,eventData.ZSliceLocationSelected);
            self.ViewerView.xzSliceView.updateOverallImageDisplay(eventData.XZSlice,eventData.NumSlicesInY,eventData.YSliceLocationSelected);
            self.ViewerView.yzSliceView.updateOverallImageDisplay(eventData.YZSlice,eventData.NumSlicesInX,eventData.XSliceLocationSelected);
        end

        function updateVolumeViewData(self,volume)
            self.ViewerView.volumeRenderingView.updateVolumeWithNewData(volume);
        end

        function updateVolumeViewDataLimits(self,eventData)
            self.ViewerView.volumeRenderingView.updateVolumeWithNewDataLimits(eventData.NumSlicesInX,...
            eventData.NumSlicesInY,eventData.NumSlicesInZ)
        end

        function update3DSliceView(self,eventData)
            self.ViewerView.slicePlane3DViewer.updateScaling(eventData.NumSlicesInX,eventData.NumSlicesInY,eventData.NumSlicesInZ);
            self.ViewerView.slicePlane3DViewer.updateXYPlane(eventData.XYSlice,eventData.NumSlicesInZ,eventData.ZSliceLocationSelected);
            self.ViewerView.slicePlane3DViewer.updateXZPlane(eventData.XZSlice,eventData.NumSlicesInY,eventData.YSliceLocationSelected);
            self.ViewerView.slicePlane3DViewer.updateYZPlane(eventData.YZSlice,eventData.NumSlicesInX,eventData.XSliceLocationSelected);
        end

        function updateVolumeDisplay(self,eventData)

            boolToOnOffMap=containers.Map({true,false},{'on','off'});

            self.ViewerView.slicePlane3DViewer.Visible=boolToOnOffMap(eventData.Display3DSlices);
            self.ViewerView.volumeRenderingView.Visible=boolToOnOffMap(eventData.DisplayVolume);
            self.ViewerView.renderingEditorView.Enable=eventData.DisplayVolume;
            if strcmp(self.ViewerModel.VolumeMode,'labels')
                children=get(self.ViewerView.renderingEditorView.OpacitySliderSubpanel,'Children');
                set(children,'Enable',boolToOnOffMap(eventData.DisplayVolume));
            end

        end

        function setEnableStateOnVolumeRenderingSettingsViewListeners(self,state)

            for i=1:length(self.RenderingChangeViewListeners)
                self.RenderingChangeViewListeners{i}.Enabled=state;
            end

        end

        function updateRenderingEditor(self,data)









            config=data.Config;
            self.setEnableStateOnVolumeRenderingSettingsViewListeners(false);

            switch config.RenderingStyle
            case{'VolumeRendering','MaximumIntensityProjection'}
                self.ViewerView.renderingEditorView.AlphaMapEditor.Position=config.AlphaControlPoints;
                self.ViewerView.renderingEditorView.AlphaMapEditor.setDefaults();
                self.ViewerView.renderingEditorView.ColorMapEditor.Position=config.ColorControlPoints;
                self.ViewerView.renderingEditorView.ColorMapEditor.setDefaults();
            case 'Isosurface'
                self.ViewerView.renderingEditorView.IsovalSlider.Value=config.Isovalue;
            case 'LabelVolumeRendering'



                if~isempty(self.ViewerView.renderingEditorView.LabelsBrowser.LabelConfiguration)
                    self.ViewerView.renderingEditorView.LabelsBrowser.setSelection(1);
                    if data.Config.ShowFlags(1)
                        self.ViewerView.renderingEditorView.ShowLabelCheckbox.Value=1;
                    else
                        self.ViewerView.renderingEditorView.ShowLabelCheckbox.Value=0;
                    end
                end
            case 'LabelOverlayRendering'



                if~isempty(self.ViewerView.renderingEditorView.LabelsBrowser.LabelConfiguration)
                    self.ViewerView.renderingEditorView.LabelsBrowser.setSelection(1);
                    if data.Config.ShowFlags(1)
                        self.ViewerView.renderingEditorView.ShowLabelCheckbox.Value=1;
                    else
                        self.ViewerView.renderingEditorView.ShowLabelCheckbox.Value=0;
                    end
                end

                self.ViewerView.renderingEditorView.ThresholdSlider.Value=config.Threshold;
                self.ViewerView.renderingEditorView.VolumeOpacitySlider.Value=config.OpacityValue;
            end

            manageVolumeRenderingSettings(self,data);

            self.setEnableStateOnVolumeRenderingSettingsViewListeners(true);

        end

        function manageVolumeRenderingSettings(self,data)



            config=data.Config;
            switch config.RenderingStyle
            case 'VolumeRendering'

                self.ViewerView.VolumeMode='volume';
                self.ViewerView.renderingEditorView.LightingToggle.Value=config.Lighting;
                self.ViewerView.renderingEditorView.RenderingStylePopup.Value=renStylePopupValueMap(config.RenderingStyle);


                self.ViewerView.volumeRenderingView.Alphamap=config.Alphamap;
                self.ViewerView.volumeRenderingView.Colormap=config.Colormap;
                self.ViewerView.volumeRenderingView.Lighting=config.Lighting;

            case 'MaximumIntensityProjection'

                self.ViewerView.VolumeMode='mip';
                self.ViewerView.renderingEditorView.RenderingStylePopup.Value=renStylePopupValueMap(config.RenderingStyle);


                self.ViewerView.volumeRenderingView.Alphamap=config.Alphamap;
                self.ViewerView.volumeRenderingView.Colormap=config.Colormap;

            case 'Isosurface'

                self.ViewerView.VolumeMode='iso';
                self.ViewerView.renderingEditorView.IsosurfaceColor=config.IsosurfaceColor;
                self.ViewerView.renderingEditorView.RenderingStylePopup.Value=renStylePopupValueMap(config.RenderingStyle);


                self.ViewerView.volumeRenderingView.IsoValue=config.Isovalue;
                self.ViewerView.volumeRenderingView.Colormap=repmat(config.IsosurfaceColor,[256,1]);

            case 'LabelVolumeRendering'

                self.ViewerView.VolumeMode='labels';


                self.ViewerView.volumeRenderingView.Alphamap=config.Alphamap;
                self.ViewerView.volumeRenderingView.Colormap=config.Colormap;
                self.ViewerView.volumeRenderingView.Lighting=config.Lighting;



                if~isequal(config,self.ViewerView.renderingEditorView.LabelsBrowser.LabelConfiguration)
                    self.ViewerView.renderingEditorView.LabelsBrowser.LabelConfiguration=copy(config);
                end

            case 'LabelOverlayRendering'

                self.ViewerView.VolumeMode='mixed';


                self.ViewerView.volumeRenderingView.Alphamap=config.Alphamap;
                self.ViewerView.volumeRenderingView.Colormap=config.Colormap;
                self.ViewerView.volumeRenderingView.Lighting=config.Lighting;



                if~isequal(config,self.ViewerView.renderingEditorView.LabelsBrowser.LabelConfiguration)
                    self.ViewerView.renderingEditorView.LabelsBrowser.LabelConfiguration=config;
                end
            end

            if~self.ViewerModel.Show3DVolume
                self.ViewerView.renderingEditorView.Enable=false;
            end


            self.ViewerView.volumeRenderingView.RenderingStyle=config.RenderingStyle;

        end

        function updateViewTransform(self,data)
            self.ViewerView.VolumeTransform.Matrix=data.Transform;
            self.ViewerView.setSpatialReferencingEditFields(data.Transform(1,1),data.Transform(2,2),data.Transform(3,3));
        end

        function updateSpatialReferencingToolstripControls(self,data)




            if(data.MetadataAvailable)
                self.ViewerView.UseFileMetadataButton.Value=true;
                self.ViewerView.UseFileMetadataButton.Enabled=true;
            else
                self.ViewerView.CustomReferencingButton.Value=true;
                self.ViewerView.UseFileMetadataButton.Enabled=false;
            end

        end

    end

end


function out=renStylePopupValueMap(renStyleStr)

    strmap=containers.Map({'VolumeRendering','MaximumIntensityProjection','Isosurface'},...
    {1,2,3});

    out=strmap(renStyleStr);

end
