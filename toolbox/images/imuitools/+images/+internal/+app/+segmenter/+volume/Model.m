classdef Model<handle&matlab.mixin.SetGet




    properties(Transient,SetAccess=protected,GetAccess={?uitest.factory.Tester,...
        ?medical.internal.app.home.labeler.Model})

        Automation images.internal.app.segmenter.volume.data.Automation

        History images.internal.app.segmenter.volume.data.History

        Interpolation images.internal.app.utilities.Interpolation

        IO images.internal.app.segmenter.volume.data.IO

        Label images.internal.app.segmenter.volume.data.Label

        Slice images.internal.app.segmenter.volume.data.Slice

        Summary images.internal.app.segmenter.volume.data.Summary

        Volume images.internal.app.segmenter.volume.data.Volume

    end

    properties(Access=protected)



        DisplaySliceSource(1,1)string="ScaledData";

    end




    events


SliceUpdated


ErrorThrown

    end

    methods




        function self=Model()

            wireUpVolume(self)
            wireUpLabels(self)
            wireUpIO(self)
            wireUpHistory(self);
            wireUpSlice(self);
            wireUpAutomation(self);
            wireUpSummary(self);
            wireUpInterpolation(self);

        end




        function clear(self)

            clear(self.Volume);
            clear(self.Label);
            clear(self.History);
            clear(self.Slice);
            clear(self.Summary);
            clear(self.IO);
            clear(self.Automation);

        end




        function delete(~)

        end




        function[volumeSlice,labelSlice,cmap,idx,maxIdx]=getSliceAtIndex(self,idx)






            if isempty(idx)
                idx=self.Slice.Current;
            end

            volumeSlice=getVolumeSliceInternal(self,idx,self.Slice.Dimension);
            labelSlice=getSlice(self.Label,idx,self.Slice.Dimension);
            cmap=self.Label.Colormap;
            maxIdx=self.Slice.Max;

        end




        function[name,idx,color]=getCurrentLabel(self)



            name=self.Label.CurrentName;
            idx=self.Label.CurrentIndex;
            color=self.Label.CurrentColor;

        end




        function names=getLabelNames(self)


            names=self.Label.Names;
        end




        function updateSlice(self,showLabels)





            if logical(showLabels)
                labels=getSlice(self.Label,self.Slice.Current,self.Slice.Dimension);
            else
                labels=uint8.empty;
            end

            dataSlice=getVolumeSliceInternal(self,self.Slice.Current,self.Slice.Dimension);
            notify(self,'SliceUpdated',images.internal.app.segmenter.volume.events.SliceUpdatedEventData(...
            dataSlice,labels,...
            self.Label.Colormap,self.Label.Alphamap,...
            self.Slice.Current,self.Slice.Max));

        end

    end

    methods(Access=protected)


        function clearButRetainLabelNames(self)

            clear(self.Volume);
            clearButRetainNames(self.Label);
            clear(self.History);
            clearNestingMasks(self.Label);
            clear(self.Slice);
            clear(self.Summary);
            clear(self.Automation);

        end


        function throwError(self,evt)
            notify(self,'ErrorThrown',evt);
        end

    end







    events



AutomationStopped



AutomationRangeUpdated



ReviewAutomationResults



GroundTruthLoaded

    end

    methods




        function startAutomation(self,alg,isVolume,settingsStruct,hfig)

            if~isVolume

                sliceAtIndex(self,self.Automation.Start);
            end

            start(self.Automation,alg,self.Label.CurrentName,isVolume,settingsStruct,hfig);

        end




        function stopAutomation(self)

            stop(self.Automation);

        end




        function setAutomationRange(self,startVal,endVal)

            setRange(self.Automation,startVal,endVal,self.Slice.Max);

        end




        function automateOnAllBlocks(self,useAllBlocks,borderSize,useParallel,skipCompleted,reviewResults)
            automateOnAllBlocks(self.Automation,useAllBlocks,borderSize,useParallel,skipCompleted,reviewResults);
        end




        function acceptBlockAutomationResults(self,acceptedBlocks,completedBlocks)
            acceptAutomationResults(self.Automation,acceptedBlocks);
            markBlockAsComplete(self.IO,completedBlocks);
        end




        function acceptAutomationResults(self,acceptResults,labels)
            if acceptResults
                add(self.History,self.Label.Data,labels,1,self.Slice.Dimension);
                self.Label.Data=labels;
                reactToLabelUpdate(self);
            end
        end




        function updateAutomationMetrics(self,evt)
            updateAutomationMetrics(self.Automation,evt);
        end




        function importGroundTruthData(self,vol)
            if isVolumeBlocked(self.IO)
                labels=getBlockedLabels(self.IO);
            else
                labels=self.Label.Data;
            end
            setGoldStandard(self.Automation,vol,labels);
        end




        function addCustomMetric(self,metric)
            setCustomMetric(self.Automation,metric);
        end

    end

    methods(Access=protected)


        function iterate(self,mode,useOriginalData)

            if self.Automation.AutomateOnAllBlocks&&isVolumeBlocked(self.IO)


                clear(self.History);

                apply(self.Automation,getBlockedImage(self.IO),getBlockedLabels(self.IO),self.Label.Names,mode,self.Slice.Dimension,...
                useOriginalData,self.Volume.RedLimit,self.Volume.GreenLimit,self.Volume.BlueLimit,self.IO.CompletedBlocks,self.IO.BlockMap,self.Label.Colormap);

            elseif strcmp(mode,'slice')


                if useOriginalData
                    run(self.Automation,getOriginalSlice(self.Volume,self.Slice.Current,self.Slice.Dimension),...
                    getCategoricalSlice(self.Label,self.Slice.Current,self.Slice.Dimension));
                else
                    run(self.Automation,getSlice(self.Volume,self.Slice.Current,self.Slice.Dimension),...
                    getCategoricalSlice(self.Label,self.Slice.Current,self.Slice.Dimension));
                end

                if self.Slice.Current==self.Automation.End||self.Automation.StopRequested

                    stop(self.Automation);

                else





                    if self.Automation.Start<=self.Automation.End
                        nextSlice(self.Slice);
                    else
                        previousSlice(self.Slice);
                    end

                    iterate(self.Automation);

                end

            else

                if useOriginalData
                    V=self.Volume.OriginalData;
                else
                    V=self.Volume.Data;
                end

                runOnVolume(self.Automation,V,self.Label.Data,useOriginalData,self.Volume.RedLimit,self.Volume.GreenLimit,self.Volume.BlueLimit,self.Label.Colormap,getCurrentIndex(self.IO));

                stop(self.Automation);

            end

        end


        function reactToAutomationUpdate(self,labels)

            if ismatrix(labels)

                addToTemporaryStack(self.History,getCategoricalSlice(self.Label,self.Slice.Current,self.Slice.Dimension),self.Slice.Current,self.Slice.Dimension);
                setSlice(self.Label,labels,self.Slice.Current,self.Slice.Dimension);

                regenerateSummarySlice(self);

            else
                add(self.History,self.Label.Data,labels,1,self.Slice.Dimension);
                self.Label.Data=labels;
                reactToLabelUpdate(self);
            end

        end

        function reactToAutomationStopping(self,evt)



            if self.Automation.AutomateOnAllBlocks&&isVolumeBlocked(self.IO)
                refreshLabelSource(self.IO);
                readCurrentBlock(self.IO);
                readCurrentLabelBlock(self);
            else
                regenerateSummary(self);
                changeSlice(self);
                applyTemporaryStack(self.History);
                update3DDisplayHeavyweight(self);
            end

            notify(self,'AutomationStopped',evt);

        end


        function wireUpAutomation(self)

            self.Automation=images.internal.app.segmenter.volume.data.Automation();

            iterateListener=addlistener(self.Automation,'Iterate',@(src,evt)iterate(self,evt.ExecutionMode,~evt.UseScaledVolume));
            iterateListener.Recursive=true;

            addlistener(self.Automation,'LabelsUpdated',@(src,evt)reactToAutomationUpdate(self,evt.Label));
            addlistener(self.Automation,'ErrorThrown',@(src,evt)throwError(self,evt));
            addlistener(self.Automation,'AutomationStopped',@(src,evt)reactToAutomationStopping(self,evt));
            addlistener(self.Automation,'RangeUpdated',@(src,evt)notify(self,'AutomationRangeUpdated',evt));
            addlistener(self.Automation,'ReviewResults',@(src,evt)notify(self,'ReviewAutomationResults',evt));
            addlistener(self.Automation,'ProgressUpdated',@(src,evt)markBlockAsSeen(self.IO,evt.CurrentBlock));
            addlistener(self.Automation,'GroundTruthLoaded',@(src,evt)notify(self,'GroundTruthLoaded',evt));

        end

    end




    events



HistoryUpdated

    end

    methods




        function undo(self)

            labels=undo(self.History,self.Label.Data);

            if~isempty(labels)
                self.Label.Data=labels;
                reactToLabelUpdate(self);
            end

            regenerateSummary(self);

        end




        function redo(self)

            labels=redo(self.History,self.Label.Data);

            if~isempty(labels)
                self.Label.Data=labels;
                reactToLabelUpdate(self);
            end

            regenerateSummary(self);

        end




        function setUndoStackLength(self,n)
            setLength(self.History,n);
        end

    end

    methods(Access=protected)


        function wireUpHistory(self)

            self.History=images.internal.app.segmenter.volume.data.History();

            addlistener(self.History,'HistoryUpdated',@(src,evt)notify(self,'HistoryUpdated',evt));

        end

    end




    events



AutoInterpolationFailed

    end

    methods




        function autoInterpolate(self,pos,val)

            [slice,idx]=findNeighboringSliceWithLabel(self.Label,val,self.Slice.Current,self.Slice.Dimension);

            if~isempty(slice)
                autoInterpolate(self.Interpolation,pos,val,slice,self.Slice.Current,idx,self.Slice.Dimension);
            end

        end




        function interpolate(self,pos1,pos2,val,idx1,idx2)

            interpolate(self.Interpolation,pos1,pos2,val,idx1,idx2,self.Slice.Dimension,size(getSlice(self.Volume,self.Slice.Current,self.Slice.Dimension)));

        end

    end

    methods(Access=protected)


        function wireUpInterpolation(self)

            self.Interpolation=images.internal.app.utilities.Interpolation();

            addlistener(self.Interpolation,'ErrorThrown',@(src,evt)throwError(self,evt));
            addlistener(self.Interpolation,'InterpolationCompleted',@(src,evt)setMaskSection(self,evt.Mask,evt.Label,evt.SliceNumber));
            addlistener(self.Interpolation,'AutoInterpolationFailed',@(~,~)notify(self,'AutoInterpolationFailed'));

        end

    end




    events





SpatialReferencingLoaded



BlockedImageOverviewUpdated



ShowBlockedImageDisplay



BlockIndexChanged



BlockedLabelsLoaded

BlockedImageLoadingStarted

BlockedImageLoadingFinished

CompletionPercentageUpdated

LabelsSaved

CompatibleAdapterRequired

BlockMetadataUpdated

    end

    methods




        function loadVolumeFromWorkspace(self,vol)
            loadVolumeFromWorkspace(self.IO,vol);
        end




        function loadVolumeFromFile(self,vol)
            loadVolumeFromFile(self.IO,vol);
        end




        function loadBlockedImageFromFile(self,vol)
            loadBlockedImageFromFile(self.IO,vol);
        end




        function loadBlockedLabelFromFile(self,labels)

            loadBlockedLabelFromFile(self.IO,labels);

            if isempty(getBlockedLabels(self.IO))
                return;
            end

            readCurrentLabelBlock(self);
            updateBlockedLabelName(self.IO);

        end




        function loadVolumeFromDICOMDirectory(self,vol)
            loadVolumeFromDICOMDirectory(self.IO,vol);
        end




        function loadLabelsFromWorkspace(self,labels)
            loadLabelsFromWorkspace(self.IO,labels);

            if isVolumeBlocked(self.IO)&&~isempty(getBlockedLabels(self.IO))
                readCurrentLabelBlock(self);
            end
        end




        function loadLabelsFromFile(self,labels)
            loadLabelsFromFile(self.IO,labels);
        end




        function saveLabelsToWorkspace(self,var,saveAsLogical,saveAsMATFile)
            saveLabelsToWorkspace(self.IO,var,self.Label.Data,saveAsLogical,saveAsMATFile);
            update3DDisplayHeavyweight(self);
        end




        function saveLabelsToFile(self,var,saveAsLogical,saveAsMATFile)
            saveLabelsToFile(self.IO,var,self.Label.Data,saveAsLogical,saveAsMATFile);
            update3DDisplayHeavyweight(self);
        end




        function readNextBlock(self)
            nextBlock(self.IO);
        end




        function readPreviousBlock(self)
            previousBlock(self.IO);
        end




        function readBlock(self,idx)
            readBlock(self.IO,idx);
        end




        function redrawBlockOverview(self)
            redrawBlockOverview(self.IO);
        end




        function regenerateBlockOverview(self,includeVolume,includeLabels,hfig)
            regenerateBlockOverview(self.IO,includeVolume,includeLabels,hfig,self.Volume.RedLimit,self.Volume.GreenLimit,self.Volume.BlueLimit);
        end




        function markBlockAsComplete(self,TF)
            markBlockAsComplete(self.IO,TF);
        end




        function shiftBlockIndex(self,idx)
            currentSlice=self.Slice.Current;
            shiftBlockIndex(self.IO,idx,self.Slice.Dimension);
            sliceAtIndex(self,currentSlice);
        end




        function convertAdapter(self,bim,loc)
            convertAdapter(self.IO,bim,loc);
        end

    end

    methods(Access=protected)


        function reactToVolumeLoading(self,vol)

            clearButRetainLabelNames(self);

            tform=self.IO.TransformFromFileMetadata;

            notify(self,'SpatialReferencingLoaded',images.internal.app.segmenter.volume.events.SpatialReferencingChangedEventData(...
            tform(1,1),tform(2,2),tform(3,3)));


            try
                self.Volume.Data=vol;
            catch ME

                if strcmp(ME.identifier,'MATLAB:nomem')

                    if~any(strcmp(class(vol),{'logical','uint8'}))
                        myMessage=getString(message('images:segmenter:outOfMemoryUsefulLoad'));
                    else
                        myMessage=getString(message('images:segmenter:outOfMemoryLoad'));
                    end

                else
                    myMessage=ME.message;
                end

                throwError(self,images.internal.app.segmenter.volume.events.ErrorEventData(myMessage));
                return;

            end


            reset(self.Slice,self.Volume.Size);

            if isVolumeBlocked(self.IO)
                readCurrentLabelBlock(self);
            else

                setEmptyData(self.Label,self.Volume.Size);
            end

            regenerateSummary(self);



            sz=self.Volume.Size;
            self.History.MemoryLimit=3.5*sz(1)*sz(2)*sz(3);

        end


        function readCurrentLabelBlock(self)
            labels=getCurrentLabelBlock(self.IO);
            if any(labels>0,'all')
                labels=images.internal.app.segmenter.volume.data.stitchedCategorical(labels,(1:1:self.Label.NumberOfLabels),self.Label.Names);
                reactToLabelLoading(self,labels);
            else
                setEmptyData(self.Label,self.Volume.Size);
            end

            if~isempty(labels)
                notify(self,'BlockedLabelsLoaded');
            end
        end


        function reactToLabelLoading(self,labels)

            if self.Volume.HasData&&isequal(size(labels,1:3),self.Volume.Size)

                self.Label.Data=labels;
                clear(self.History);
                clearNestingMasks(self.Label);
                reactToLabelUpdate(self);
                regenerateSummary(self);

                update3DDisplayHeavyweight(self);

            else
                throwError(self,images.internal.app.segmenter.volume.events.ErrorEventData(getString(message('images:segmenter:labelDimensionMismatch'))));
                reactToLabelUpdate(self);
            end

        end


        function wireUpIO(self)

            self.IO=images.internal.app.segmenter.volume.data.IO();

            addlistener(self.IO,'VolumeLoaded',@(src,evt)reactToVolumeLoading(self,evt.Data));
            addlistener(self.IO,'LabelsLoaded',@(src,evt)reactToLabelLoading(self,evt.Data));
            addlistener(self.IO,'ErrorThrown',@(src,evt)throwError(self,evt));
            addlistener(self.IO,'ShowBlockedImageDisplay',@(src,evt)notify(self,'ShowBlockedImageDisplay',evt));
            addlistener(self.IO,'BlockedImageOverviewUpdated',@(src,evt)notify(self,'BlockedImageOverviewUpdated',evt));
            addlistener(self.IO,'BlockIndexChanged',@(src,evt)notify(self,'BlockIndexChanged',evt));
            addlistener(self.IO,'BlockCategoriesDetected',@(src,evt)setCategories(self.Label,evt.Categories));
            addlistener(self.IO,'BlockedImageLoadingStarted',@(~,~)notify(self,'BlockedImageLoadingStarted'));
            addlistener(self.IO,'BlockedImageLoadingFinished',@(~,~)notify(self,'BlockedImageLoadingFinished'));
            addlistener(self.IO,'CompletionPercentageUpdated',@(src,evt)notify(self,'CompletionPercentageUpdated',evt));
            addlistener(self.IO,'LabelsSaved',@(src,evt)notify(self,'LabelsSaved',evt));
            addlistener(self.IO,'CompatibleAdapterRequired',@(src,evt)notify(self,'CompatibleAdapterRequired',evt));
            addlistener(self.IO,'BlockMetadataUpdated',@(src,evt)notify(self,'BlockMetadataUpdated',evt));

        end

    end




    events



NamesUpdated



CustomVisibilityRequested

    end

    methods




        function setMask(self,mask,val,prior,offset)

            if isempty(prior)

                add(self.History,self.Label.Data,mask,self.Slice.Current,self.Slice.Dimension);
            else


                add(self.History,self.Label.Data,mask|prior,self.Slice.Current,self.Slice.Dimension);
            end

            setMask(self.Label,mask,val,prior,self.History.Prior,self.Slice.Current,self.Slice.Dimension,offset);

            regenerateSummarySlice(self);

        end




        function setMaskSection(self,mask,val,sliceNumber)

            add(self.History,self.Label.Data,mask,sliceNumber,self.Slice.Dimension);
            setMaskSection(self.Label,mask,val,sliceNumber,self.Slice.Dimension);

            regenerateSummary(self);

        end




        function mergeWithExistingSlice(self,mask)



            slice=getSlice(self.Label,self.Slice.Current,self.Slice.Dimension);
            mask(mask==0)=slice(mask==0);

            add(self.History,self.Label.Data,mask,self.Slice.Current,self.Slice.Dimension);
            setSlice(self.Label,mask,self.Slice.Current,self.Slice.Dimension);

            regenerateSummarySlice(self);

        end




        function setSlice(self,slice)

            add(self.History,self.Label.Data,slice,self.Slice.Current,self.Slice.Dimension);
            setSlice(self.Label,slice,self.Slice.Current,self.Slice.Dimension);

            regenerateSummarySlice(self);

        end




        function setPriorMask(self,mask,holeMask,parentMask)
            updatePrior(self.History,getCategoricalSlice(self.Label,self.Slice.Current,self.Slice.Dimension),mask);
            updateNestingMasks(self.Label,holeMask,parentMask,self.Slice.Current,self.Slice.Dimension);
        end




        function fillRegion(self,mask,val)

            slice=getSlice(self.Label,self.Slice.Current,self.Slice.Dimension);

            BW=slice==slice(mask);
            BW=imfill(~BW,find(mask(:)))&BW;

            add(self.History,self.Label.Data,BW,self.Slice.Current,self.Slice.Dimension);
            setMask(self.Label,BW,val,logical.empty,uint8.empty,self.Slice.Current,self.Slice.Dimension,0);

            regenerateSummarySlice(self);

        end




        function floodFill(self,mask,val,L,tol)

            if isempty(L)
                L=getSlice(self.Volume,self.Slice.Current,self.Slice.Dimension);
            end

            [row,col]=find(mask,1);

            if size(L,3)==3
                L=sum((L-L(row,col,:)).^2,3);
            end

            L=mat2gray(L);
            BW=grayconnected(L,row,col,tol);

            add(self.History,self.Label.Data,BW,self.Slice.Current,self.Slice.Dimension);
            setMask(self.Label,BW,val,logical.empty,uint8.empty,self.Slice.Current,self.Slice.Dimension,0);

            regenerateSummarySlice(self);

        end




        function setCurrentLabel(self,label)

            setCurrent(self.Label,label);
            regenerateSummary(self);

        end




        function addLabel(self,label)

            addLabel(self.Label,label);
            regenerateSummary(self);

        end




        function newLabel(self)

            newLabel(self.Label);
            regenerateSummary(self);

        end




        function removeLabel(self,label)

            if isVolumeBlocked(self.IO)
                removeLabel(self.IO,self.Label.CurrentIndex);
            end

            removeLabel(self.Label,label);


            if self.Label.NumberOfLabels==0&&self.Volume.HasData
                newLabel(self);
            else
                regenerateSummary(self);
            end

            clear(self.History);



            redrawVolume(self);

        end




        function importLabels(self,label)
            importLabels(self.Label,label);
        end




        function setLabelAlphamap(self,amap)

            if isempty(amap)

                notify(self,'CustomVisibilityRequested',images.internal.app.segmenter.volume.events.NamesUpdatedEventData(...
                self.Label.Names,self.Label.Colormap,self.Label.Alphamap,self.Label.CurrentIndex));

            else
                setAlphamap(self.Label,amap);
                updateRGBA(self);
            end

        end




        function setLabelColormap(self,cmap)

            setColormap(self.Label,cmap);
            updateRGBA(self);

        end




        function setColor(self,label,color)

            setColor(self.Label,label,color);
            regenerateSummary(self);

        end




        function resetColors(self)

            resetColors(self.Label);
            regenerateSummary(self);

        end




        function setName(self,label,name)
            setName(self.Label,label,name);
        end




        function setOpacity(self,label,alpha)
            setOpacity(self.Label,label,alpha);
        end




        function setPreserveLabelColors(self,TF)
            setPreserveLabelColors(self.Label,TF)
        end

    end

    methods(Access=protected)


        function reactToLabelUpdate(self)



            update3DDisplayLightweight(self);

            if self.Volume.HasData
                updateSlice(self,true);
            end

        end


        function wireUpLabels(self)

            self.Label=images.internal.app.segmenter.volume.data.Label();

            addlistener(self.Label,'LabelsUpdated',@(~,~)reactToLabelUpdate(self));
            addlistener(self.Label,'NamesUpdated',@(src,evt)notify(self,'NamesUpdated',evt));
            addlistener(self.Label,'RGBAUpdated',@(~,~)updateRGBA(self));
            addlistener(self.Label,'ErrorThrown',@(src,evt)throwError(self,evt));

        end

    end




    events



SliceChanged

    end

    methods




        function nextSlice(self)
            nextSlice(self.Slice);
        end




        function previousSlice(self)
            previousSlice(self.Slice);
        end




        function sliceAtIndex(self,idx)
            sliceAtIndex(self.Slice,idx);
        end




        function setSliceDimension(self,slice)

            switch slice
            case 'xy'
                dim=3;
            case 'yz'
                dim=2;
            case 'xz'
                dim=1;
            otherwise
                return;
            end

            clear(self.History);
            clearNestingMasks(self.Label);
            setDimension(self.Slice,dim,self.Volume.Size);
            regenerateSummary(self);
            validateAutomationRange(self.Automation,self.Slice.Max);

        end




        function setDisplaySliceSource(self,source)

            validatestring(source,{'OriginalData','ScaledData'});
            self.DisplaySliceSource=string(source);

        end

    end

    methods(Access=protected)


        function changeSlice(self)

            dataSlice=getVolumeSliceInternal(self,self.Slice.Current,self.Slice.Dimension);
            notify(self,'SliceChanged',images.internal.app.segmenter.volume.events.SliceUpdatedEventData(...
            dataSlice,getSlice(self.Label,self.Slice.Current,self.Slice.Dimension),...
            self.Label.Colormap,self.Label.Alphamap,...
            self.Slice.Current,self.Slice.Max));

        end


        function wireUpSlice(self)

            self.Slice=images.internal.app.segmenter.volume.data.Slice();

            addlistener(self.Slice,'SliceUpdated',@(~,~)changeSlice(self));

        end

    end




    events



SummaryUpdated

    end

    methods




        function[summary,color]=createSummary(self,idx,color)

            summary=create(self.Summary,self.Label.NumericData,self.Slice.Dimension,idx);

        end

    end

    methods(Access=protected)


        function regenerateSummary(self)
            regenerate(self.Summary,self.Label.NumericData,self.Slice.Dimension,...
            self.Label.CurrentIndex);
        end


        function regenerateSummarySlice(self)
            regenerateSlice(self.Summary,getSlice(self.Label,self.Slice.Current,self.Slice.Dimension),...
            self.Slice.Current,self.Label.CurrentIndex);
        end


        function wireUpSummary(self)

            self.Summary=images.internal.app.segmenter.volume.data.Summary();

            addlistener(self.Summary,'SummaryUpdated',@(~,~)...
            notify(self,'SummaryUpdated',...
            images.internal.app.segmenter.volume.events.SummaryUpdatedEventData(...
            self.Summary.Data,self.Label.CurrentColor)));

        end

    end




    events


VolumeLoaded




VolumeUpdatedHeavyweight




VolumeUpdatedLightweight



RGBAUpdated

UpdateVoxelInfo

RGBLimitsUpdated

    end

    methods




        function updateVolumeRendering(self,thresh,alpha)

            updateRendering(self.Volume,thresh,alpha);
            updateRendering(self.IO,thresh,alpha);
            update3DDisplayLightweight(self);

        end




        function updateVolumeColormap(self,cmap)
            self.Volume.Colormap=cmap;
        end




        function updateVolumeAlphamap(self,amap)
            self.Volume.Alphamap=amap;
        end




        function redrawVolume(self)

            if self.Volume.HasData
                update3DDisplayHeavyweight(self);
            end

        end




        function getVoxelInfo(self,pos)

            [val,~]=getVoxel(self.Volume,pos,self.Slice.Current,self.Slice.Dimension);

            if isVolumeBlocked(self.IO)
                pos=getVoxelLocation(self.IO,pos,self.Slice.Current,self.Slice.Dimension);
            end

            if~isempty(val)
                notify(self,'UpdateVoxelInfo',images.internal.app.segmenter.volume.events.VoxelInfoEventData(pos,val));
            end

        end




        function updateRGBLimits(self,R,G,B)

            cachedR=self.Volume.RedLimit;
            cachedG=self.Volume.GreenLimit;
            cachedB=self.Volume.BlueLimit;

            updateRGBLimits(self.Volume,R,G,B);

            if isequal(cachedR,self.Volume.RedLimit)&&...
                isequal(cachedG,self.Volume.GreenLimit)&&...
                isequal(cachedB,self.Volume.BlueLimit)
                return;
            end

            if self.Volume.HasData
                updateSlice(self,true);
                redrawVolume(self);
            end

        end

    end

    methods(Access=protected)


        function reactToVolumeUpdate(self)


            notify(self,'VolumeLoaded',images.internal.app.segmenter.volume.events.VolumeLoadedEventData(...
            self.Volume.Data,self.Label.NumericData,...
            self.Volume.Alphamap,self.Volume.Colormap,...
            self.Label.Alphamap,self.Label.Colormap,...
            self.Slice.Current,self.Slice.Dimension,self.Volume.Datatype));

        end


        function update3DDisplayHeavyweight(self)

            notify(self,'VolumeUpdatedHeavyweight',images.internal.app.segmenter.volume.events.Display3DEventData(...
            self.Volume.Data,self.Label.NumericData,...
            self.Volume.Alphamap,self.Volume.Colormap,...
            self.Label.Alphamap,self.Label.Colormap,...
            self.Slice.Current,self.Slice.Dimension));

        end


        function update3DDisplayLightweight(self)

            notify(self,'VolumeUpdatedLightweight',images.internal.app.segmenter.volume.events.Display3DEventData(...
            self.Volume.Data,self.Label.NumericData,...
            self.Volume.Alphamap,self.Volume.Colormap,...
            self.Label.Alphamap,self.Label.Colormap,...
            self.Slice.Current,self.Slice.Dimension));

        end


        function updateRGBA(self)

            notify(self,'RGBAUpdated',images.internal.app.segmenter.volume.events.RGBAEventData(...
            self.Volume.Colormap,self.Volume.Alphamap,self.Label.Colormap,self.Label.Alphamap));

            if self.Volume.HasData
                updateSlice(self,true);
                regenerateSummary(self);
            end

        end


        function slice=getVolumeSliceInternal(self,idx,dim)




            switch self.DisplaySliceSource

            case "OriginalData"
                slice=getOriginalSlice(self.Volume,idx,dim);

            case "ScaledData"
                slice=getSlice(self.Volume,idx,dim);

            end

        end


        function wireUpVolume(self)

            self.Volume=images.internal.app.segmenter.volume.data.Volume();

            addlistener(self.Volume,'VolumeUpdated',@(~,~)reactToVolumeUpdate(self));
            addlistener(self.Volume,'RGBAUpdated',@(~,~)updateRGBA(self));
            addlistener(self.Volume,'RGBLimitsUpdated',@(src,evt)notify(self,'RGBLimitsUpdated',evt));

        end

    end

end