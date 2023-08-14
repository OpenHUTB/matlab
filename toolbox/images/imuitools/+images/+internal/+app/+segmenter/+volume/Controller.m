classdef Controller<handle




    properties(Access=protected,Hidden,Transient)

Model
View

    end


    properties(Access=protected,Hidden,Transient)

IOListeners
LabelListeners
SliceListeners
HistoryListeners
VolumeListeners
AutomationListeners
ErrorListeners
DialogListeners
BlockedImageListeners

    end


    methods




        function self=Controller(modelObject,viewObject)

            self.Model=modelObject;
            self.View=viewObject;

            addlistener(self.View,'AppClosed',@(~,~)delete(self));

            wireUpIOListeners(self);
            wireUpLabelListeners(self);
            wireUpSliceListeners(self);
            wireUpHistoryListeners(self);
            wireUpVolumeListeners(self);
            wireUpAutomationListeners(self);
            wireUpErrorListeners(self);
            wireUpDialogListeners(self);
            wireUpBlockedImageListeners(self);

        end




        function delete(self)

            delete(self.IOListeners)
            delete(self.LabelListeners)
            delete(self.SliceListeners)
            delete(self.HistoryListeners)
            delete(self.VolumeListeners)
            delete(self.AutomationListeners)
            delete(self.ErrorListeners)
            delete(self.DialogListeners);

        end

    end


    methods(Access=protected)


        function wireUpIOListeners(self)


            a=event.listener(self.Model,'SpatialReferencingLoaded',@(src,evt)updateSpatialReferencing(self.View,evt.X,evt.Y,evt.Z));


            b=event.listener(self.View,'AppCleared',@(src,evt)clear(self.Model));
            c=event.listener(self.View,'VolumeFromWorkspaceRequested',@(src,evt)loadVolumeFromWorkspace(self.Model,evt.Data));
            d=event.listener(self.View,'VolumeFromFileRequested',@(src,evt)loadVolumeFromFile(self.Model,evt.Data));
            e=event.listener(self.View,'VolumeFromDICOMRequested',@(src,evt)loadVolumeFromDICOMDirectory(self.Model,evt.Data));
            f=event.listener(self.View,'LabelsFromFileRequested',@(src,evt)loadLabelsFromFile(self.Model,evt.Data));
            g=event.listener(self.View,'LabelsFromWorkspaceRequested',@(src,evt)loadLabelsFromWorkspace(self.Model,evt.Data));
            h=event.listener(self.View,'SaveToWorkspaceRequested',@(src,evt)saveLabelsToWorkspace(self.Model,evt.Name,evt.SaveAsLogical,evt.SaveAsMATFile));
            i=event.listener(self.View,'SaveToFileRequested',@(src,evt)saveLabelsToFile(self.Model,evt.Name,evt.SaveAsLogical,evt.SaveAsMATFile));
            j=event.listener(self.View,'LabelNamesImported',@(src,evt)importLabels(self.Model,evt.Label));
            k=event.listener(self.View,'BlockedImageFromFileRequested',@(src,evt)loadBlockedImageFromFile(self.Model,evt.Data));
            l=event.listener(self.View,'BlockedLabelsFromFileRequested',@(src,evt)loadBlockedLabelFromFile(self.Model,evt.Data));
            m=event.listener(self.View,'ConvertAdapter',@(src,evt)convertAdapter(self.Model,evt.BlockedImage,evt.Location));

            n=event.listener(self.Model,'BlockedImageLoadingStarted',@(~,~)startWaitBar(self.View,getString(message('images:segmenter:waitForNextBlock'))));
            o=event.listener(self.Model,'BlockedImageLoadingFinished',@(~,~)clearWaitBar(self.View));
            p=event.listener(self.Model,'CompletionPercentageUpdated',@(src,evt)updateCompletionPercentage(self.View,evt.Completed));
            q=event.listener(self.Model,'LabelsSaved',@(src,evt)setSaveLocation(self.View,evt.Name,evt.SaveAsMATFile));
            r=event.listener(self.Model,'CompatibleAdapterRequired',@(src,evt)requestToConvertLabels(self.View,evt.Label));
            s=event.listener(self.Model,'BlockMetadataUpdated',@(src,evt)updateBlockMetadata(self.View,evt));

            self.IOListeners=[a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s];

        end


        function wireUpLabelListeners(self)


            a=event.listener(self.Model,'NamesUpdated',@(src,evt)labelNamesUpdated(self.View,...
            evt.Names,...
            evt.Colormap,...
            evt.Alphamap,...
            evt.SelectedIndex));

            b=event.listener(self.Model,'SummaryUpdated',@(src,evt)updateSummary(self.View,evt.Label,evt.Color));
            c=event.listener(self.Model,'CustomVisibilityRequested',@(src,evt)customizeLabelVisibility(self.View,evt.Names,evt.Alphamap));
            d=event.listener(self.Model,'AutoInterpolationFailed',@(~,~)manuallyInterpolate(self.View));


            e=event.listener(self.View,'LabelCreated',@(~,~)newLabel(self.Model));
            f=event.listener(self.View,'LabelNameEdited',@(src,evt)setName(self.Model,evt.OldLabel,evt.NewLabel));
            g=event.listener(self.View,'LabelDeleted',@(src,evt)removeLabel(self.Model,evt.Label));
            h=event.listener(self.View,'LabelColorChanged',@(src,evt)setColor(self.Model,evt.Label,evt.Color));
            i=event.listener(self.View,'RegionDrawn',@(src,evt)setMask(self.Model,...
            evt.Mask,...
            evt.Label,...
            evt.PreviousMask,...
            evt.Offset));
            j=event.listener(self.View,'FillRegion',@(src,evt)fillRegion(self.Model,...
            evt.Mask,...
            evt.Label));
            k=event.listener(self.View,'LabelRequested',@(~,~)getCurrentLabel(self));
            l=event.listener(self.View,'LabelSelected',@(src,evt)setCurrentLabel(self.Model,evt.Label));
            m=event.listener(self.View,'RegionPasted',@(src,evt)mergeWithExistingSlice(self.Model,evt.Mask));
            n=event.listener(self.View,'LabelColorsReset',@(~,~)resetColors(self.Model));
            o=event.listener(self.View,'LabelNamesRequested',@(~,~)getLabelNames(self));
            p=event.listener(self.View,'InterpolateRequested',@(src,evt)autoInterpolate(self.Model,evt.PositionOne,evt.Value));
            q=event.listener(self.View,'InterpolateManually',@(src,evt)interpolate(self.Model,evt.PositionOne,evt.PositionTwo,evt.Value,evt.SliceOne,evt.SliceTwo));
            r=event.listener(self.View,'FloodFillRegion',@(src,evt)floodFill(self.Model,evt.Mask,evt.Label,evt.Superpixels,evt.Sensitivity));

            self.LabelListeners=[a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r];

        end


        function wireUpSliceListeners(self)


            a=event.listener(self.Model,'SliceUpdated',@(src,evt)redrawSlice(self.View,...
            evt.VolumeSlice,...
            evt.LabelSlice,...
            evt.Colormap));

            b=event.listener(self.Model,'SliceChanged',@(src,evt)updateSlice(self.View,...
            evt.VolumeSlice,...
            evt.LabelSlice,...
            evt.Colormap,...
            evt.CurrentSlice,...
            evt.MaxSlice));

            c=event.listener(self.Model,'UpdateVoxelInfo',@(src,evt)updateVoxelInfo(self.View,evt.Location,evt.Value));


            d=event.listener(self.View,'NextSliceRequested',@(~,~)nextSlice(self.Model));
            e=event.listener(self.View,'PreviousSliceRequested',@(~,~)previousSlice(self.Model));
            f=event.listener(self.View,'SliceAtLocationRequested',@(src,evt)sliceAtIndex(self.Model,evt.Index));
            g=event.listener(self.View,'LocationSelected',@(~,~)getSliceAtIndex(self,[]));
            h=event.listener(self.View,'SliceRequested',@(~,~)getSliceAtIndexForROIs(self,[]));
            i=event.listener(self.View,'RedrawSlice',@(~,~)updateSlice(self.Model,true));
            j=event.listener(self.View,'RedrawSliceWithoutLabels',@(~,~)updateSlice(self.Model,false));
            k=event.listener(self.View,'SliceDimensionChanged',@(src,evt)setSliceDimension(self.Model,evt.Dimension));
            l=event.listener(self.View,'SliceAtLocationRequestedForThumbnail',@(src,evt)getSliceAtIndexForThumbnail(self,evt.Index));
            m=event.listener(self.View,'VoxelInfoRequested',@(src,evt)getVoxelInfo(self.Model,evt.IntersectionPoint));
            n=event.listener(self.View,'BlockIndexShifted',@(src,evt)shiftBlockIndex(self.Model,evt.IndexShift));

            self.SliceListeners=[a,b,c,d,e,f,g,h,i,j,k,l,m,n];

        end


        function wireUpHistoryListeners(self)


            a=event.listener(self.Model,'HistoryUpdated',@(src,evt)enableUndoRedo(self.View,evt.CanUndo,evt.CanRedo));


            b=event.listener(self.View,'UndoRequested',@(~,~)undo(self.Model));
            c=event.listener(self.View,'RedoRequested',@(~,~)redo(self.Model));
            d=event.listener(self.View,'SetPriorMask',@(src,evt)setPriorMask(self.Model,evt.Mask,evt.HoleMask,evt.ParentMask));

            self.HistoryListeners=[a,b,c,d];

        end


        function wireUpVolumeListeners(self)


            a=event.listener(self.Model,'VolumeLoaded',@(src,evt)updateVolume(self.View,...
            evt.Volume,...
            evt.Label,...
            evt.VolumeAlphamap,...
            evt.VolumeColormap,...
            evt.LabelAlphamap,...
            evt.LabelColormap,...
            evt.SliceIndex,...
            evt.Dimension));

            b=event.listener(self.Model,'VolumeUpdatedHeavyweight',@(src,evt)updateVolumeHeavyweight(self.View,...
            evt.Volume,...
            evt.Label,...
            evt.VolumeAlphamap,...
            evt.VolumeColormap,...
            evt.LabelAlphamap,...
            evt.LabelColormap));

            c=event.listener(self.Model,'VolumeUpdatedLightweight',@(~,~)updateVolumeLightweight(self.View));

            d=event.listener(self.Model,'RGBAUpdated',@(src,evt)updateRGBA(self.View,...
            evt.DataColormap,...
            evt.DataAlphamap,...
            evt.LabelColormap,...
            evt.LabelAlphamap));

            e=event.listener(self.Model,'RGBLimitsUpdated',@(src,evt)updateRGBLimits(self.View,...
            evt.Red,...
            evt.Green,...
            evt.Blue));


            f=event.listener(self.View,'RGBLimitsUpdated',@(src,evt)updateRGBLimits(self.Model,...
            evt.Red,...
            evt.Green,...
            evt.Blue));

            g=event.listener(self.View,'VolumeRenderingChanged',@(src,evt)updateVolumeRendering(self.Model,...
            evt.Threshold,...
            evt.Opacity));

            h=event.listener(self.View,'RedrawVolume',@(~,~)redrawVolume(self.Model));
            i=event.listener(self.View,'ShowLabelsInVolume',@(src,evt)setLabelAlphamap(self.Model,evt.Show));
            i.Recursive=true;

            self.VolumeListeners=[a,b,c,d,e,f,g,h,i];

        end


        function wireUpAutomationListeners(self)


            a=event.listener(self.Model,'AutomationStopped',@(src,evt)cleanUpAfterAutomation(self.View));
            b=event.listener(self.Model,'AutomationRangeUpdated',@(src,evt)setAutomationRange(self.View,evt.Start,evt.End));
            c=event.listener(self.Model,'ReviewAutomationResults',@(src,evt)reviewBlockedImageResults(self.View,...
            evt.BlockedVolume,evt.BlockedLabels,evt.Categories,evt.Metrics,evt.BlockFileNames,evt.UseOriginalData,...
            evt.BlockMap,evt.RedLimits,evt.GreenLimits,evt.BlueLimits,evt.Colormap));


            d=event.listener(self.View,'AutomationStarted',@(src,evt)startAutomation(self.Model,evt.Algorithm,evt.VolumeBased,evt.Settings,evt.Parent));
            e=event.listener(self.View,'AutomationStopped',@(~,~)stopAutomation(self.Model));
            f=event.listener(self.View,'AutomationRangeUpdated',@(src,evt)setAutomationRange(self.Model,evt.Start,evt.End));
            g=event.listener(self.View,'AcceptAutomationResults',@(src,evt)acceptAutomationResults(self.Model,evt.AcceptedBlocks,evt.CompletedBlocks));
            h=event.listener(self.View,'AcceptBlockAutomationResults',@(src,evt)acceptBlockAutomationResults(self.Model,evt.AcceptedBlocks,evt.CompletedBlocks));
            i=event.listener(self.View,'MetricsUpdated',@(src,evt)updateAutomationMetrics(self.Model,evt));
            j=event.listener(self.View,'GroundTruthDataLoaded',@(src,evt)importGroundTruthData(self.Model,evt.Data));
            k=event.listener(self.View,'AddCustomMetric',@(src,evt)addCustomMetric(self.Model,evt.Data));

            m=event.listener(self.Model,'GroundTruthLoaded',@(src,evt)groundTruthLoaded(self.View,evt.Data));

            self.AutomationListeners=[a,b,c,d,e,f,g,h,i,j,k,m];

        end


        function wireUpErrorListeners(self)


            a=event.listener(self.Model,'ErrorThrown',@(src,evt)error(self.View,evt.Message));

            self.ErrorListeners=a;

        end


        function wireUpDialogListeners(self)


            a=event.listener(self.View,'SliceAtLocationRequestedForDialog',@(src,evt)getSliceAtIndexForDialog(self,evt.Index));
            b=event.listener(self.View,'SummaryRequestedForDialog',@(src,evt)createSummary(self,evt.Label,evt.Color));

            self.DialogListeners=[a,b];

        end


        function wireUpBlockedImageListeners(self)


            a=event.listener(self.Model,'BlockedImageOverviewUpdated',@(src,evt)setBlockedImageOverview(self.View,evt.Data,evt.Completed,evt.History,evt.CurrentIndex,evt.BlockSize,evt.Colormap,evt.Alphamap,evt.SizeInBlocks));
            b=event.listener(self.Model,'ShowBlockedImageDisplay',@(src,evt)showBlockedImageTab(self.View,evt.Show));
            c=event.listener(self.Model,'BlockIndexChanged',@(src,evt)updateBlockIndex(self.View,evt.CurrentIndex,evt.SizeInBlocks,evt.Completed));
            d=event.listener(self.Model,'BlockedLabelsLoaded',@(src,evt)blockedLabelsLoaded(self.View));


            e=event.listener(self.View,'ReadNextBlock',@(~,~)readNextBlock(self.Model));
            f=event.listener(self.View,'ReadPreviousBlock',@(~,~)readPreviousBlock(self.Model));
            g=event.listener(self.View,'ReadBlockByIndex',@(src,evt)readBlock(self.Model,evt.CurrentIndex));
            h=event.listener(self.View,'AutomateOnAllBlocks',@(src,evt)automateOnAllBlocks(self.Model,evt.AutomateOnBlocks,evt.BorderSize,evt.UseParallel,evt.SkipCompleted,evt.Review));
            i=event.listener(self.View,'RedrawBlockOverview',@(src,evt)redrawBlockOverview(self.Model));
            j=event.listener(self.View,'RegenerateBlockOverview',@(src,evt)regenerateBlockOverview(self.Model,evt.IncludeVolume,evt.IncludeLabels,evt.Parent));
            k=event.listener(self.View,'MarkBlockComplete',@(src,evt)markBlockAsComplete(self.Model,evt.EventData.NewValue));

            self.BlockedImageListeners=[a,b,c,d,e,f,g,h,i,j,k];

        end

    end


    methods(Access=protected)


        function createSummary(self,label,color)

            [label,color]=createSummary(self.Model,label,color);
            updateDialogSummary(self.View,label,color)

        end


        function getSliceAtIndexForDialog(self,idx)

            [volumeSlice,labelSlice,cmap,currentIdx,maxIdx]=getSliceAtIndex(self.Model,idx);

            if~isempty(volumeSlice)
                sliceAtIndexProvidedForDialog(self.View,volumeSlice,labelSlice,cmap,currentIdx,maxIdx);
            end

        end


        function getSliceAtIndexForThumbnail(self,idx)

            [volumeSlice,labelSlice,cmap,~,~]=getSliceAtIndex(self.Model,idx);

            if~isempty(volumeSlice)
                sliceAtIndexProvidedForThumbnail(self.View,volumeSlice,labelSlice,cmap);
            end

        end


        function getSliceAtIndex(self,idx)

            [volumeSlice,labelSlice,cmap,currentIdx,~]=getSliceAtIndex(self.Model,idx);
            sliceSelected(self.View,volumeSlice,labelSlice,cmap,currentIdx);

        end


        function getSliceAtIndexForROIs(self,idx)

            [volumeSlice,labelSlice,~,~,~]=getSliceAtIndex(self.Model,idx);
            updateROISlice(self.View,volumeSlice,labelSlice);

        end


        function getCurrentLabel(self)

            [name,idx,color]=getCurrentLabel(self.Model);

            if~isempty(name)
                drawLabel(self.View,idx,color);
            end

        end


        function getLabelNames(self)

            names=getLabelNames(self.Model);

            if~isempty(names)
                reassignLabels(self.View,names);
            end

        end

    end

end