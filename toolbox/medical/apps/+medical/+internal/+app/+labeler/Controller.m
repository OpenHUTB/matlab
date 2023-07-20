classdef Controller<handle




    properties(Access=private)

        View medical.internal.app.labeler.View

        Model medical.internal.app.labeler.Model

    end

    methods

        function self=Controller(model,view)

            self.Model=model;
            self.View=view;

            self.wireupViewListeners();
            self.wireupModelListeners();

        end

        function delete(self)

            self.Model.addSessionToRecentFiles();

            self.Model.delete();
            self.delete();

        end

    end

    methods(Access=protected)


        function wireupViewListeners(self)

            addlistener(self.View,'AppClosed',@(src,evt)delete(self));


            addlistener(self.View,'RefreshRecentSessions',@(src,evt)refreshRecentSessions(self.Model));
            addlistener(self.View,'ClearCurrentSession',@(src,evt)clear(self.Model));
            addlistener(self.View,'OpenSessionRequested',@(src,evt)openSession(self.Model,evt.Value));
            addlistener(self.View,'SaveSessionRequested',@(src,evt)saveSession(self.Model));
            addlistener(self.View,'DataFormatUpdated',@(src,evt)setDataFormat(self.Model,evt.Value));
            addlistener(self.View,'LabelDataLocationSet',@(src,evt)setLabelDataLocation(self.Model,evt.Value));


            addlistener(self.View,'DataFromFileRequested',@(src,evt)addDataFromFile(self.Model,evt.Value));
            addlistener(self.View,'VolumeFromFolderRequested',@(src,evt)addDataFromDICOMFolder(self.Model,evt.Value));
            addlistener(self.View,'GroundTruthFromFileRequested',@(src,evt)addGroundTruthFromFile(self.Model,evt.Value));
            addlistener(self.View,'GroundTruthFromWkspRequested',@(src,evt)addGroundTruth(self.Model,evt.Value));
            addlistener(self.View,'ExportGroundTruthToFile',@(src,evt)exportGroundTruthToFile(self.Model,evt.Value));
            addlistener(self.View,'ExportLabelDefsToFile',@(src,evt)exportLabelDefsToFile(self.Model,evt.Value));
            addlistener(self.View,'LabelDefsFromFileRequested',@(src,evt)self.Model.addLabelDefsFromFile(evt.Value));

            addlistener(self.View,'ResetWindowLevel',@(src,evt)updateDefaultContrastLimits(self.Model));


            addlistener(self.View,'ReadDataRequested',@(src,evt)self.Model.readData(evt.Value));
            addlistener(self.View,'RemoveLabelsRequested',@(src,evt)self.Model.removeLabels(evt.Value));
            addlistener(self.View,'CopyDataLocationRequested',@(src,evt)self.Model.copyDataLocation(evt.Value));
            addlistener(self.View,'CopyLabelLocationRequested',@(src,evt)self.Model.copyLabelLocation(evt.Value));


            addlistener(self.View,'SliceAtIndexRequestedForDialog',@(src,evt)getSliceForDialog(self,evt.Value,evt.SliceDirection));
            addlistener(self.View,'SummaryRequestedForDialog',@(src,evt)createSummary(self,evt.Label,evt.Color,evt.SliceDirection));


            addlistener(self.View,'SliceAtIndexRequested',@(src,evt)getSlice(self,evt.Value,evt.SliceDirection));
            addlistener(self.View,'SliceAtIndexRequestedForThumbnail',@(src,evt)getSliceForThumbnail(self,evt.Value,evt.SliceDirection));
            addlistener(self.View,'RefreshSlice',@(src,evt)refreshSlice(self,true,evt.Value,evt.SliceDirection));
            addlistener(self.View,'RefreshSliceWithoutLabels',@(src,evt)refreshSlice(self,false,evt.Value,evt.SliceDirection));
            addlistener(self.View,'LabelRequested',@(src,evt)getCurrentLabel(self,evt.Value));
            addlistener(self.View,'VoxelInfoRequested',@(src,evt)getVoxelInfo(self.Model,evt.Position,evt.Index,evt.SliceDirection));
            addlistener(self.View,'SaveSnapshot',@(src,evt)saveSnapshot(self.Model,evt.Filename,evt.Snapshot3D,evt.SliceIdx,evt.SliceDirection));
            addlistener(self.View,'LabelOpacityChanged',@(src,evt)setLabelOpacity(self.Model,evt.Value));
            addlistener(self.View,'ContrastLimitsChanged',@(src,evt)setContrastLimits(self.Model,evt.Value));


            addlistener(self.View,'NewLabelDefinitionRequested',@(src,evt)addNewLabelDefinition(self.Model));
            addlistener(self.View,'LabelSelected',@(src,evt)setCurrentLabel(self.Model,evt.Label));
            addlistener(self.View,'LabelNameChanged',@(src,evt)labelNameChanged(self.Model,evt.OldLabel,evt.NewLabel));
            addlistener(self.View,'LabelColorChanged',@(src,evt)labelColorChanged(self.Model,evt.Label,evt.Color));
            addlistener(self.View,'LabelVisibilityChanged',@(src,evt)labelVisibilityChanged(self.Model,evt.Label,evt.Value));
            addlistener(self.View,'LabelDeleted',@(src,evt)labelDeleted(self.Model,evt.Value));


            addlistener(self.View,'LevelTraceSelected',@(src,evt)reactToLevelTraceSelection(self,evt.Value));
            addlistener(self.View,'SliceRequestedForROI',@(src,evt)getSliceForROIs(self,evt.Value,evt.SliceDirection));
            addlistener(self.View,'LocationSelected',@(src,evt)selectSlice(self,evt.Value,evt.SliceDirection));
            addlistener(self.View,'SetPriorMask',@(src,evt)setPriorMask(self.Model,evt.Mask,evt.HoleMask,evt.ParentMask,evt.SliceIdx,evt.SliceDirection));
            addlistener(self.View,'RegionDrawn',@(src,evt)setMask(self.Model,evt.Mask,evt.Label,evt.PreviousMask,evt.Offset,evt.SliceIdx,evt.SliceDirection));
            addlistener(self.View,'RegionPasted',@(src,evt)mergeWithExistingSlice(self.Model,evt.Mask,evt.SliceIdx,evt.SliceDirection));
            addlistener(self.View,'FillRegion',@(src,evt)fillRegion(self.Model,evt.Mask,evt.Label,evt.SliceIdx,evt.SliceDirection));
            addlistener(self.View,'FloodFillRegion',@(src,evt)floodFill(self.Model,evt.Mask,evt.Label,evt.Superpixels,evt.Sensitivity,evt.SliceIdx,evt.SliceDirection));
            addlistener(self.View,'LabelNamesForROIRequested',@(src,evt)getLabelDefinitionNamesForROI(self,evt.Value,evt.SliceDirection));
            addlistener(self.View,'InterpolateRequested',@(src,evt)autoInterpolate(self.Model,evt.PositionOne,evt.Value,evt.SliceOne,evt.SliceDirection));
            addlistener(self.View,'InterpolateManually',@(src,evt)interpolate(self.Model,evt.PositionOne,evt.PositionTwo,evt.Value,evt.SliceOne,evt.SliceTwo,evt.SliceDirection));
            addlistener(self.View,'UpdateLevelTraceLabel',@(src,evt)updateLevelTraceLabel(self));

            addlistener(self.View,'UndoRequested',@(src,evt)undo(self.Model));
            addlistener(self.View,'RedoRequested',@(src,evt)redo(self.Model));


            addlistener(self.View,'RefreshLabels3D',@(src,evt)refreshLabels3D(self.Model));
            addlistener(self.View,'RedrawVolume',@(src,evt)redrawVolume(self.Model));
            addlistener(self.View,'RefreshLabelVolumeAlpha',@(src,evt)updateLabelVolumeAlpha(self.Model));
            addlistener(self.View,'RefreshUserDefinedVolumeRenderings',@(src,evt)refreshUserDefinedVolumeRenderings(self.Model));
            addlistener(self.View,'PresetRenderingRequested',@(src,evt)updateFromPresetVolumeRendering(self.Model,evt.Value));
            addlistener(self.View,'UserDefinedRenderingRequested',@(src,evt)updateFromUserDefinedVolumeRendering(self.Model,evt.Value));
            addlistener(self.View,'SaveUserDefinedRendering',@(src,evt)saveUserDefinedVolumeRendering(self.Model,evt.Value));
            addlistener(self.View,'RemoveUserDefinedRendering',@(src,evt)removeUserDefinedVolumeRendering(self.Model,evt.Value));
            addlistener(self.View,'ApplyRenderingToAllVolumes',@(src,evt)applyCurrentRenderingToAllVolumes(self.Model));
            addlistener(self.View,'VolumeRenderingStyleChanged',@(src,evt)setRenderingStyle(self.Model,evt.Value));
            addlistener(self.View,'ColorControlPtsUpdated',@(src,evt)setColorControlPoints(self.Model,evt.Value));
            addlistener(self.View,'AlphaControlPtsUpdated',@(src,evt)setAlphaControlPoints(self.Model,evt.Value));


            addlistener(self.View,'AutomationDirectionUpdated',@(src,evt)setAutomationSliceDirection(self.Model,evt.Value));
            addlistener(self.View,'AutomationRangeUpdated',@(src,evt)setAutomationRange(self.Model,evt.Start,evt.End));
            addlistener(self.View,'AutomationStarted',@(src,evt)startAutomation(self.Model,evt.Algorithm,evt.VolumeBased,evt.Settings,evt.Parent));
            addlistener(self.View,'AutomationStopped',@(~,~)stopAutomation(self.Model));


            addlistener(self.View,'PublishRequested',@(src,evt)publishRequested(self.Model,evt.PublishFormat,evt.Filepath,evt.SliceRangeStart,evt.SliceRangeEnd,evt.Screenshot3D,evt.SliceDirection));

        end


        function wireupModelListeners(self)

            addlistener(self.Model,'ErrorThrown',@(~,evt)error(self.View,evt.Message));
            addlistener(self.Model,'WarningThrown',@(~,evt)warning(self.View,evt.Message));


            addlistener(self.Model,'RequestedRecentSessions',@(src,evt)self.View.refreshRecentSessions(evt.DataSource,evt.DataFormat));
            addlistener(self.Model,'NewDataFormatUpdated',@(~,evt)setDataFormat(self.View,evt.Value));
            addlistener(self.Model,'DisableSaveCustomRenderings',@(src,evt)disableSaveCustomRenderings(self.View));
            addlistener(self.Model,'SessionLocationSet',@(~,evt)setSessionLocation(self.View,evt.Value));
            addlistener(self.Model,'SessionIsUnsaved',@(~,evt)markSessionAsUnsaved(self.View));
            addlistener(self.Model,'SessionIsSaved',@(~,evt)markSessionAsSaved(self.View));
            addlistener(self.Model,'SetLabelOpacity',@(~,evt)setLabelOpacity(self.View,evt.Value));


            addlistener(self.Model,'RequestedSlice',@(~,evt)self.View.updateSlice(evt.Slice,evt.LabelSlice,...
            evt.LabelColormap,evt.LabelVisible,evt.CurrentIdx,evt.MaxIdx,evt.SliceDirection));
            addlistener(self.Model,'RequestedVoxelInfo',@(~,evt)self.View.updateVoxelInfo(evt.Position,evt.Intensity,evt.Index,evt.SliceDirection));


            addlistener(self.Model,'FirstDataAdded',@(src,evt)reactToFirstDataAdded(self.View));
            addlistener(self.Model,'DataAdded',@(src,evt)addToDataBrowser(self.View,evt.DataName,evt.HasLabels));
            addlistener(self.Model,'IsCurrentDataOblique',@(src,evt)set(self.View,'IsCurrentDataOblique',evt.Value));
            addlistener(self.Model,'InitializeSliceViews',@(src,evt)initializeSlices(self.View,...
            evt.DataLimits,evt.NumSlicesASC,evt.PixelSpacingASC,evt.IsRGB));

            addlistener(self.Model,'VolumeLoaded',@(src,evt)updateVolume(self.View,...
            evt.Volume,evt.Label,evt.VolumeTransform,evt.VolumeBounds,evt.OrientationAxesLabels));

            addlistener(self.Model,'UpdateLabelStatus',@(src,evt)updateLabelStatus(self.View,evt.DataName,evt.HasLabels));
            addlistener(self.Model,'ChangeSlice',@(src,evt)getSlice(self,evt.Value,evt.SliceDirection));
            addlistener(self.Model,'LabelsUpdated',@(src,evt)labelsUpdated(self.View));
            addlistener(self.Model,'HistoryUpdated',@(src,evt)enableUndoRedo(self.View,evt.CanUndo,evt.CanRedo));
            addlistener(self.Model,'SummaryUpdated',@(src,evt)updateSummary(self.View,evt.Label,evt.Color,evt.SliceDirection));
            addlistener(self.Model,'UpdateContrastLimits',@(src,evt)self.View.updateContrastLimits(evt.Value));
            addlistener(self.Model,'CurrentlyLoadingData',@(src,evt)self.View.updateDataLoadingProgessDialog(evt.Value));


            addlistener(self.Model,'VolumeRenderingSettingsUpdated',@(src,evt)setVolumeRendering(self.View,...
            evt.RenderingPreset,...
            evt.RenderingStyle,...
            evt.VolumeAlphaCP,...
            evt.VolumeColorCP));
            addlistener(self.Model,'UpdateToCustomRenderingPreset',@(src,evt)setCustomRenderingPreset(self.View));
            addlistener(self.Model,'RequestedUserDefinedVolumeRenderingSettings',@(src,evt)refreshUserDefinedRenderings(self.View,evt.Value));
            addlistener(self.Model,'LabelVolumeAlphaUpdated',@(src,evt)updateLabelVolumeAlpha(self.View,evt.Value));
            addlistener(self.Model,'LabelVolumeColorUpdated',@(src,evt)updateLabelVolumeColor(self.View,evt.Value));
            addlistener(self.Model,'UpdateLabels3D',@(src,evt)updateLabels(self.View,evt.Value));
            addlistener(self.Model,'CustomizeLabelVisibilityRequested',@(src,evt)customizeLabelVisibility(self.View,evt.LabelName,evt.LabelVisible));



            addlistener(self.Model,'LabelDefinitionsUpdated',@(src,evt)updateLabelDefinitions(self.View,evt.LabelName,evt.LabelColor,evt.LabelVisible,evt.SelectedIdx));
            addlistener(self.Model,'LabelColorUpdated',@(src,evt)updateLabelColor(self.View,evt.Value));
            addlistener(self.Model,'LabelAlphaUpdated',@(src,evt)updateLabelAlpha(self.View,evt.Value));


            addlistener(self.Model,'AutomationDirectionUpdated',@(src,evt)setAutomationDirection(self.View,evt.MaxSliceIdx,evt.SliceDirection));
            addlistener(self.Model,'AutomationRangeUpdated',@(src,evt)setAutomationRange(self.View,evt.Start,evt.End));
            addlistener(self.Model,'AutomationStopped',@(src,evt)cleanUpAfterAutomation(self.View));
        end

    end


    methods(Access=protected)


        function getCurrentLabel(self,sliceDir)

            [name,idx,color]=getCurrentLabel(self.Model);

            if~isempty(name)
                drawLabel(self.View,idx,color,sliceDir);
            end

        end


        function getLabelDefinitionNamesForROI(self,idx,sliceDir)

            names=getLabelDefinitionNames(self.Model);

            if~isempty(names)
                reassignLabels(self.View,names,idx,sliceDir);
            end

        end


        function getSlice(self,idx,sliceDir)

            [slice,labelSlice,maxIdx,labelColormap,labelVisible]=self.Model.getSlice(idx,sliceDir);
            self.View.updateSlice(slice,labelSlice,labelColormap,labelVisible,idx,maxIdx,sliceDir);

        end


        function refreshSlice(self,showLabels,idx,sliceDir)

            [slice,labelSlice,maxIdx,labelColormap,labelVisible]=self.Model.getSlice(idx,sliceDir);
            if showLabels
                self.View.refreshSlice(slice,labelSlice,labelColormap,labelVisible,idx,maxIdx,sliceDir);
            else
                self.View.refreshSlice(slice,[],[],[],idx,maxIdx,sliceDir);
            end

        end


        function getSliceForROIs(self,idx,sliceDir)

            [slice,labelSlice]=getSlice(self.Model,idx,sliceDir);
            updateROISlice(self.View,slice,labelSlice,sliceDir);

        end


        function getSliceForDialog(self,idx,sliceDir)

            [slice,labelSlice,maxIdx,labelColormap,~]=self.Model.getSlice(idx,sliceDir);

            if~isempty(slice)
                self.View.sliceAtIndexProvidedForDialog(slice,labelSlice,labelColormap,idx,maxIdx);
            end

        end


        function getSliceForThumbnail(self,idx,sliceDir)

            [slice,labelSlice,maxIdx,labelColormap,~]=self.Model.getSlice(idx,sliceDir);

            if~isempty(slice)
                self.View.sliceAtIndexProvidedForThumbnail(slice,labelSlice,labelColormap,idx,maxIdx,sliceDir);
            end

        end


        function selectSlice(self,idx,sliceDir)

            [~,labelSlice,~,cmap]=getSlice(self.Model,idx,sliceDir);
            sliceSelected(self.View,labelSlice,cmap,sliceDir);

        end


        function createSummary(self,label,color,sliceDir)

            [label,color]=createSummary(self.Model,label,color,sliceDir);
            self.View.updateDialogSummary(label,color)

        end


        function reactToLevelTraceSelection(self,TF)

            [name,val,color]=getCurrentLabel(self.Model);
            if~isempty(name)
                reactToLevelTraceSelection(self.View,TF,val,color);
            end

        end


        function updateLevelTraceLabel(self)
            [name,val,color]=getCurrentLabel(self.Model);
            if~isempty(name)
                updateLevelTraceLabel(self.View,val,color);
            end
        end

    end

end
