




classdef Controller<handle

    properties(Access=private)
ViewerModel
ViewerView
    end

    properties(Access=private)
RenderingChangeViewListeners
    end

    methods
        function self=Controller(modelIn,viewIn)
            self.ViewerModel=modelIn;
            self.ViewerView=viewIn;

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
            self.wireExportListener();
            self.wireCameraListener();


            self.wireDataLoadingListeners();
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


    methods(Access=private)

        function wireCameraListener(self)
            addlistener(self.ViewerView.volumeRenderingView,'CameraMoved',@(src,evt)updateCamera(self.ViewerModel,evt.CameraPosition,evt.CameraTarget,evt.CameraUpVector,evt.CameraZoom));
        end

        function wireReplaceOrOverlayResponseViewListener(self)
            addlistener(self.ViewerView,'ReplaceOrOverlayResult',@(hObj,evt)self.updateReplaceOrOverlayResponse(evt));
        end

        function wireNewSessionViewListener(self)
            addlistener(self.ViewerView,'StartNewSession',@(hObj,evt)self.ViewerModel.clearModel());
        end

        function wire2DSliceViewListeners(self)

            addlistener(self.ViewerView.xySliceView,'SliderValueChanged',@(~,evt)set(self.ViewerModel,'ZSliceLocationSelected',evt.Value));
            addlistener(self.ViewerView.xzSliceView,'SliderValueChanged',@(~,evt)set(self.ViewerModel,'YSliceLocationSelected',evt.Value));
            addlistener(self.ViewerView.yzSliceView,'SliderValueChanged',@(~,evt)set(self.ViewerModel,'XSliceLocationSelected',evt.Value));

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
            addlistener(self.ViewerView,'VolumeDisplayChangeRequested',@(hObj,evt)set(self.ViewerModel,'Show3DVolume',evt.DisplayVolume));
        end

        function wireVolumeSettingsEditorListeners(self)
            self.RenderingChangeViewListeners{end+1}=addlistener(self.ViewerView.renderingEditorView,'RenderingTechniqueChanged',@(hObj,evt)self.manageVolumeTechniqueWeb(evt.Value));
            self.RenderingChangeViewListeners{end+1}=addlistener(self.ViewerView.renderingEditorView,'IsovalueChanged',@(hObj,evt)self.ViewerModel.setIsovalue(evt.Value));

            if iptgetpref('VolumeViewerUseHardware')
                self.RenderingChangeViewListeners{end+1}=addlistener(self.ViewerView.renderingEditorView,'LightingToggled',@(hObj,evt)self.ViewerModel.setLighting(evt.Value));
            end

            self.RenderingChangeViewListeners{end+1}=addlistener(self.ViewerView.renderingEditorView,'IsosurfaceColorChange',@(hObj,evt)self.ViewerModel.setIsosurfaceColor(evt.Colormap));
            self.RenderingChangeViewListeners{end+1}=addlistener(self.ViewerView.renderingEditorView,'BringAppInFocus',@(hObj,evt)self.ViewerView.bringAppInFocus());
            self.RenderingChangeViewListeners{end+1}=addlistener(self.ViewerView.renderingEditorView.ColorMapEditor,'ColormapChange',@(hObj,evt)self.updateColormap(evt.Colormap));
            self.RenderingChangeViewListeners{end+1}=addlistener(self.ViewerView.renderingEditorView.ColorMapEditor,'ColormapEdit',@(hObj,evt)self.updateColormap(evt.Colormap));
            self.RenderingChangeViewListeners{end+1}=addlistener(self.ViewerView.renderingEditorView.AlphaMapEditor,'AlphamapChange',@(hObj,evt)self.updateAlphamap(evt.Alphamap,evt.AlphaControlPoints));
            self.RenderingChangeViewListeners{end+1}=addlistener(self.ViewerView.renderingEditorView.AlphaMapEditor,'PositionChange',@(hObj,evt)self.updateAlphamapFromControlPoints(hObj.Position));

            self.RenderingChangeViewListeners{end+1}=addlistener(self.ViewerView.renderingEditorView.ColorMapEditor,'BringAppInFocus',@(hObj,evt)self.ViewerView.bringAppInFocus());


        end

        function wireLabelSettingsEditorListeners(self)
            self.RenderingChangeViewListeners{end+1}=addlistener(self.ViewerView.renderingEditorView,'LabelOverlayViewToggled',@(hObj,evt)self.updateModelVolumeMode(evt.Value));
            self.RenderingChangeViewListeners{end+1}=addlistener(self.ViewerView.renderingEditorView,'OverlayOpacityThresholdChanged',@(hObj,evt)self.ViewerModel.setOverlayConfigThreshold(evt.Value));
            self.RenderingChangeViewListeners{end+1}=addlistener(self.ViewerView.renderingEditorView,'OverlayVolumeOpacityChanged',@(hObj,evt)self.ViewerModel.setOverlayConfigVolumeOpacity(evt.Value));

            self.RenderingChangeViewListeners{end+1}=addlistener(self.ViewerView.renderingEditorView,'LabelShowFlagChange',@(hObj,evt)self.ViewerModel.changeLabelVisibility(evt));
            self.RenderingChangeViewListeners{end+1}=addlistener(self.ViewerView.renderingEditorView,'LabelColorChange',@(hObj,evt)self.ViewerModel.changeLabelColor(evt));
            self.RenderingChangeViewListeners{end+1}=addlistener(self.ViewerView.renderingEditorView,'LabelOpacityChange',@(hObj,evt)self.ViewerModel.changeLabelOpacity(evt));

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
            addlistener(self.ViewerView,'BackgroundColorChange',@(hobj,evt)setBackgroundColor(self.ViewerModel,evt.Color,evt.GradientColor,evt.UseGradient));
        end

        function wireExportListener(self)
            addlistener(self.ViewerView.ExportConfigSubitem,'ItemPushed',@(hObj,evt)self.ViewerModel.exportConfig());
        end
    end


    methods(Access=private)

        function wireDataLoadingListeners(self)
            addlistener(self.ViewerModel,'DataLoadingStarted',@(~,~)self.ViewerView.dataLoadingStarted());
            addlistener(self.ViewerModel,'DataLoadingFinished',@(~,~)self.ViewerView.dataLoadingFinished());
        end

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
            addlistener(self.ViewerModel,'XYSliceChange',@(hObj,data)self.ViewerView.volumeRenderingView.updateXYPlane(data.SliceIndex,data.NumSlicesInDim,data.VolumeSize));
            addlistener(self.ViewerModel,'XZSliceChange',@(hObj,data)self.ViewerView.volumeRenderingView.updateXZPlane(data.SliceIndex,data.NumSlicesInDim,data.VolumeSize));
            addlistener(self.ViewerModel,'YZSliceChange',@(hObj,data)self.ViewerView.volumeRenderingView.updateYZPlane(data.SliceIndex,data.NumSlicesInDim,data.VolumeSize));
        end

        function wireVolumeDataChangeModelListeners(self)







            addlistener(self.ViewerModel,'VolumeDataChange',@(hObj,data)self.updateSliceViews(data));
            addlistener(self.ViewerModel,'VolumeDataChange',@(hObj,data)self.updateVolumeViewData(data,data.Volume,data.OverlayVolume));
            addlistener(self.ViewerModel,'VolumeDataChange',@(hObj,data)self.ViewerView.enableViewControlsOnDataLoad(data));
        end

        function wireMergedVolumeUpdateChangeModelListeners(self)
            addlistener(self.ViewerModel,'VolumeDataUpdate',@(hObj,data)self.updateSliceViews(data));
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
            addlistener(self.ViewerModel,'BackgroundColorChange',@(hObj,data)self.ViewerView.setBackgroundColor(data.Color,data.GradientColor,data.UseGradient));
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
            addlistener(self.ViewerModel,'ExportDataAvailable',@(hObj,data)self.ViewerView.launchExportDialog(data.Config,data.ViewerConfig));
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

            renderingPopupUIStrings={getString(message('images:volumeViewer:volRenderingCategoryName')),...
            getString(message('images:volumeViewer:mipCategoryName')),...
            getString(message('images:volumeViewer:isosurfaceCategoryName'))};


            styleMap=containers.Map(renderingPopupUIStrings,...
            {'VolumeRendering','MaximumIntensityProjection','Isosurface'});

            self.ViewerModel.Renderer=styleMap(volumeTechniqueStr);

        end

        function manageVolumeTechniqueWeb(self,itemValue)

            styleMap=containers.Map(1:3,...
            {'VolumeRendering','MaximumIntensityProjection','Isosurface'});

            self.ViewerModel.Renderer=styleMap(itemValue);

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

        function updateColormap(self,colormap)
            self.ViewerModel.setColormapVol(colormap)
        end

        function updateAlphamap(self,alphamap,controlPoints)
            self.ViewerModel.setAlphamapVol(alphamap,controlPoints)
        end

        function updateAlphamapFromControlPoints(self,points)
            self.ViewerModel.setAlphaMapFromControlPoints(points)
        end

    end


    methods(Access=private)

        function updateInputSourceOnTitlebar(self,eventData)

            title=getString(message('images:volumeViewer:appName'));

            if strcmp(eventData.VolType,'volume')
                self.ViewerView.VolumeSource=eventData.InputSource;
            else
                self.ViewerView.LabeledVolumeSource=eventData.InputSource;
            end

            if self.ViewerView.VolumeSource==""&&self.ViewerView.LabeledVolumeSource==""
                self.ViewerView.App.Title=title;
                return
            end

            title=strcat(title," - ");

            if~self.ViewerModel.HasVolumeData
                self.ViewerView.VolumeSource="";
            else
                title=strcat(title,getString(message('images:volumeViewer:volumeData')),...
                ": ",self.ViewerView.VolumeSource,"");
            end

            if~self.ViewerModel.HasLabeledVolumeData
                self.ViewerView.LabeledVolumeSource="";
            else
                if self.ViewerModel.HasVolumeData
                    title=strcat(title," & ");
                end

                title=strcat(title,getString(message('images:volumeViewer:labelData')),...
                ": ",self.ViewerView.LabeledVolumeSource);
            end

            self.ViewerView.App.Title=title;
        end

        function updateSliceViews(self,eventData)

            self.ViewerView.xySliceView.updateOverallImageDisplay(eventData.XYSlice,eventData.NumSlicesInZ,eventData.ZSliceLocationSelected);
            self.ViewerView.xzSliceView.updateOverallImageDisplay(eventData.XZSlice,eventData.NumSlicesInY,eventData.YSliceLocationSelected);
            self.ViewerView.yzSliceView.updateOverallImageDisplay(eventData.YZSlice,eventData.NumSlicesInX,eventData.XSliceLocationSelected);
        end

        function updateVolumeViewData(self,eventData,volume,overlayVolume)
            self.ViewerView.volumeRenderingView.updateVolumeWithNewData(volume,overlayVolume);
            update3DSliceView(self,eventData);
        end

        function update3DSliceView(self,eventData)
            self.ViewerView.volumeRenderingView.updateXYPlane(eventData.ZSliceLocationSelected,eventData.TransformedVolumeSize(3),eventData.VolumeSize(3));
            self.ViewerView.volumeRenderingView.updateXZPlane(eventData.YSliceLocationSelected,eventData.TransformedVolumeSize(2),eventData.VolumeSize(2));
            self.ViewerView.volumeRenderingView.updateYZPlane(eventData.XSliceLocationSelected,eventData.TransformedVolumeSize(1),eventData.VolumeSize(1));
        end

        function updateVolumeDisplay(self,eventData)

            boolToOnOffMap=containers.Map({true,false},{'on','off'});

            self.ViewerView.volumeRenderingView.DisplaySlicePlanes=eventData.Display3DSlices;
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
                self.ViewerView.renderingEditorView.setIsosurfaceColor(config.IsosurfaceColor);
                self.ViewerView.renderingEditorView.RenderingStylePopup.Value=renStylePopupValueMap(config.RenderingStyle);


                self.ViewerView.volumeRenderingView.Isovalue=config.Isovalue;
                self.ViewerView.volumeRenderingView.Colormap=repmat(config.IsosurfaceColor,[256,1]);

            case 'LabelVolumeRendering'

                self.ViewerView.VolumeMode='labels';


                self.ViewerView.volumeRenderingView.OverlayAlphamap=config.Alphamap;
                self.ViewerView.volumeRenderingView.OverlayColormap=config.Colormap;
                self.ViewerView.volumeRenderingView.Lighting=config.Lighting;



                if~isequal(config,self.ViewerView.renderingEditorView.LabelsBrowser.LabelConfiguration)
                    self.ViewerView.renderingEditorView.setLabelConfiguration(config);
                end

            case 'LabelOverlayRendering'

                self.ViewerView.VolumeMode='mixed';


                self.ViewerView.volumeRenderingView.Alphamap=config.Alphamap;
                self.ViewerView.volumeRenderingView.Colormap=config.Colormap;
                self.ViewerView.volumeRenderingView.OverlayAlphamap=config.OverlayAlphamap;
                self.ViewerView.volumeRenderingView.OverlayColormap=config.OverlayColormap;
                self.ViewerView.volumeRenderingView.Lighting=config.Lighting;



                if~isequal(config,self.ViewerView.renderingEditorView.LabelsBrowser.LabelConfiguration)
                    self.ViewerView.renderingEditorView.setLabelConfiguration(config);
                end
            end

            if~self.ViewerModel.Show3DVolume
                self.ViewerView.renderingEditorView.Enable=false;
            end


            self.ViewerView.volumeRenderingView.RenderingStyle=config.RenderingStyle;

        end

        function updateViewTransform(self,data)
            self.ViewerView.volumeRenderingView.Transform=data.Transform;
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
