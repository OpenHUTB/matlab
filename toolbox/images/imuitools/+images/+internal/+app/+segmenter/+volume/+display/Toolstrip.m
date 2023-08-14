classdef Toolstrip<handle




    events

ShowVolumeChanged

SpatialReferencingChanged

ColorChanged

RenderingChanged

AppCleared

VolumeLoadedFromWorkspace

VolumeLoadedFromFile

VolumeLoadedFromDICOM

VolumeLoadedFromBlockedImage

VolumeLoadedFromBlockedImageFolder

VolumeLoadedFromBlockedImageWorkspace

LabelsLoadedFromWorkspace

LabelsLoadedFromFile

LabelsSavedToWorkspace

LabelsSavedToFile

LabelsSavedAsToWorkspace

LabelsSavedAsToFile

LabelNamesImported

ColorOrderRestored

ThreeColumnLayoutRequested

TwoColumnLayoutRequested

ShowLabelsChanged

LabelOpacityChanged

SliceDimensionChanged

AutomationStarted

AutomationStopped

AutomationRangeUpdated

AutomateOnAllBlocks

BrushSelected

BrushSizeChanged

LabelToolSelected

InterpolateRequested

InterpolateManually

AddAlgorithm

ManageAlgorithms

ErrorThrown

RotateImage

ViewShortcuts

ViewDoc

ShowLabelsInVolume

OrientationAxesChanged

ContrastChanged

OpenSettings

CloseDialogs

ReadNextBlock

ReadPreviousBlock

ReadBlockByIndex

OverviewSettingsChanged

RegenerateOverview

PaintBySuperpixels

ShowVoxelInfo

ShowOverviewChanged

MarkBlockComplete

MoveCurrentBlock

RGBLimitsUpdated

FloodFillSensitivityChanged

MetricsUpdated

GroundTruthImportRequested

AddCustomMetric

LoadCustomMetric

UseGradientChanged

GradientColorChanged

    end

    properties(Dependent,SetAccess=protected)


ActiveLabelingTool

HideLabelsOnDraw

ContrastLimits

UseBlockedImage

ApplyOnAllBlocks

Tabs

    end

    properties(Dependent)

SaveToMATFile

SaveAsRequired

SaveAsLogical

EligibleToSaveAsLogical

SavedName

AutoSave

    end

    properties(Transient,SetAccess=protected,GetAccess={...
        ?images.uitest.factory.Tester,...
        ?uitest.factory.Tester,...
        ?medical.internal.app.home.labeler.display.toolstrip.Toolstrip})


TabGroup


        Home images.internal.app.segmenter.volume.display.HomeTab


        Label images.internal.app.segmenter.volume.display.LabelTab


        Automate images.internal.app.segmenter.volume.display.AutomateTab


        Volume images.internal.app.segmenter.volume.display.VolumeTab


        BlockedImage images.internal.app.segmenter.volume.display.BlockedImageTab

    end

    methods




        function self=Toolstrip(show3DDisplay,useWebVersion,showMetrics)

            self.TabGroup=matlab.ui.internal.toolstrip.TabGroup();
            self.TabGroup.Tag='VolumeLabelerTabs';

            wireUpHomeTab(self,show3DDisplay);

            wireUpLabelTab(self);

            wireUpAutomateTab(self,showMetrics);

            wireUpVolumeTab(self,show3DDisplay,useWebVersion);

            wireUpBlockedImage(self,useWebVersion);

            disable(self);

        end




        function enable(self)

            enable(self.Home);
            enable(self.Label);
            enable(self.Automate);
            enable(self.Volume,self.UseBlockedImage);
            enable(self.BlockedImage);
        end




        function disable(self)

            disable(self.Home);
            disable(self.Label);
            disable(self.Automate);
            disable(self.Volume);
            disable(self.BlockedImage);
        end




        function setEmptyState(self)

            clear(self.Home);
            enableLoadOnly(self.Home)
            disable(self.Label);
            disable(self.Automate);
            disable(self.Volume);
            disable(self.BlockedImage);
        end




        function setVolumeColor(self,color)

            setColor(self.Volume,color);

        end




        function setGradientColor(self,color)

            setGradientColor(self.Volume,color);

        end




        function setUseGradient(self,val)

            setUseGradient(self.Volume,val);

        end




        function setSpatialReferencing(self,x,y,z)

            setSpatialReferencing(self.Volume,x,y,z);

        end




        function markSaveAsDirty(self)

            markSaveAsDirty(self.Home);

        end




        function markSaveAsClean(self)

            markSaveAsClean(self.Home);

        end




        function save(self)

            save(self.Home);

        end




        function delete(self)
            delete(self.Automate);
            delete(self.BlockedImage);
        end




        function updateLayoutState(self,view3DDisplay,viewLabels,viewOverview)

            try %#ok<TRYNC>
                if view3DDisplay||viewOverview
                    add(self.TabGroup,self.Volume.Tab);
                else
                    tab=find(self.TabGroup,'VolumeTab');
                    if~isempty(tab)
                        remove(self.TabGroup,tab);
                    end
                end
            end

            showVolume(self.Home,view3DDisplay);
            showOverview(self.Home,viewOverview);

            showLabels(self.Home,viewLabels);

        end




        function updateSliceDimension(self,sliceDimension)
            updateSliceDimension(self.Home,sliceDimension)
        end




        function sliceDimension=getSliceDimension(self)

            sliceDimension=getSliceDimension(self.Home);

        end




        function setAutomationRange(self,startVal,endVal)
            setAutomationRange(self.Automate,startVal,endVal);
        end




        function displayAutomationRange(self,currentSlice,maxSlice)
            displayAutomationRange(self.Automate,currentSlice,maxSlice)
        end




        function enableInterpolation(self,TF)
            enableInterpolation(self.Label,TF);
        end




        function refreshAlgorithms(self)
            refresh(self.Automate);
        end




        function addAlgorithm(self,alg,isVolumeBased)
            addAlgorithm(self.Automate,alg,isVolumeBased);
        end




        function enableContrastControls(self,isRGB)
            enableContrastControls(self.Home,isRGB);
        end




        function showBlockedImageTab(self,TF)

            enableBlockedApply(self.Automate,TF);
            enableBlockedLabels(self.Home,TF);
            enableBlockedLabels(self.Volume,TF);

            try %#ok<TRYNC>
                if TF
                    add(self.TabGroup,self.BlockedImage.Tab);
                else
                    remove(self.TabGroup,self.BlockedImage.Tab);
                end
            end

        end




        function updateBlockIndex(self,idx,sz,blockCompleted)
            updateBlockIndex(self.BlockedImage,idx,sz);
            markBlockAsComplete(self.BlockedImage,blockCompleted);
        end




        function deselectPaintBySuperpixels(self)
            deselectPaintBySuperpixels(self.Label);
        end




        function deselectVoxelInfo(self)
            deselectVoxelInfo(self.Home);
        end




        function setWireframe(self,TF)
            setWireframe(self.Volume,TF);
        end




        function updateCompletionPercentage(self,pct)
            updateCompletionPercentage(self.BlockedImage,pct);
        end




        function updateRGBLimits(self,R,G,B)
            updateRGBLimits(self.Home,R,G,B);
        end




        function updateContrastLimits(self,contrastLimits)
            updateContrastLimits(self.Home,contrastLimits);
        end




        function updateBlockMetadata(self,evt)
            updateBlockMetadata(self.BlockedImage,evt);
        end




        function enableQualityMetrics(self,TF)
            enableQualityMetrics(self.Automate,TF);
        end




        function enableCustomMetrics(self,TF)
            enableCustomMetrics(self.Automate,TF);
        end




        function addCustomMetric(self,metric)
            addCustomMetric(self.Automate,metric);
        end

    end


    methods(Access=protected)


        function reactToVolumeVisibilityChange(self,evt)

            notify(self,'ShowVolumeChanged',evt);

        end


        function updateToolstripForClearedApp(self)

            notify(self,'AppCleared')

        end


        function reactToAutomationStart(self,evt)

            disable(self.Home);
            disable(self.Label);
            disable(self.Volume);
            disableDuringAutomation(self.Automate);



            drawnow;

            notify(self,'AutomationStarted',evt);

        end


        function reactToAutomationStop(self,evt)

            notify(self,'AutomationStopped',evt);

            enable(self);

        end


        function markAsComplete(self,evt)
            notify(self,'MarkBlockComplete',evt);
            overviewSettingsChanged(self.Volume);
        end


        function wireUpVolumeTab(self,show3DDisplay,useWebVersion)

            self.Volume=images.internal.app.segmenter.volume.display.VolumeTab(show3DDisplay,useWebVersion);

            if show3DDisplay
                add(self.TabGroup,self.Volume.Tab);

                addlistener(self.Volume,'SpatialReferencingChanged',@(src,evt)notify(self,'SpatialReferencingChanged',evt));
                addlistener(self.Volume,'ColorChanged',@(src,evt)notify(self,'ColorChanged',evt));
                addlistener(self.Volume,'GradientColorChanged',@(src,evt)notify(self,'GradientColorChanged',evt));
                addlistener(self.Volume,'UseGradientChanged',@(src,evt)notify(self,'UseGradientChanged',evt));
                addlistener(self.Volume,'RenderingChanged',@(src,evt)notify(self,'RenderingChanged',evt));
                addlistener(self.Volume,'ShowLabelsInVolume',@(src,evt)notify(self,'ShowLabelsInVolume',evt));
                addlistener(self.Volume,'OrientationAxesChanged',@(src,evt)notify(self,'OrientationAxesChanged',evt));
                addlistener(self.Volume,'OverviewSettingsChanged',@(src,evt)notify(self,'OverviewSettingsChanged',evt));
                addlistener(self.Volume,'RegenerateOverview',@(src,evt)notify(self,'RegenerateOverview',evt));
            end

        end


        function wireUpLabelTab(self)

            self.Label=images.internal.app.segmenter.volume.display.LabelTab;
            add(self.TabGroup,self.Label.Tab);

            addlistener(self.Label,'BrushSelected',@(src,evt)notify(self,'BrushSelected',evt));
            addlistener(self.Label,'BrushSizeChanged',@(src,evt)notify(self,'BrushSizeChanged',evt));
            addlistener(self.Label,'PaintBySuperpixels',@(src,evt)notify(self,'PaintBySuperpixels',evt));
            addlistener(self.Label,'LabelToolSelected',@(~,~)notify(self,'LabelToolSelected'));
            addlistener(self.Label,'InterpolateRequested',@(~,~)notify(self,'InterpolateRequested'));
            addlistener(self.Label,'InterpolateManually',@(~,~)notify(self,'InterpolateManually'));
            addlistener(self.Label,'FloodFillSensitivityChanged',@(src,evt)notify(self,'FloodFillSensitivityChanged',evt));

        end


        function wireUpAutomateTab(self,showMetrics)

            self.Automate=images.internal.app.segmenter.volume.display.AutomateTab(showMetrics);
            add(self.TabGroup,self.Automate.Tab);

            addlistener(self.Automate,'AutomationStarted',@(src,evt)reactToAutomationStart(self,evt));
            addlistener(self.Automate,'AutomationStopped',@(src,evt)reactToAutomationStop(self,evt));
            addlistener(self.Automate,'AutomationRangeUpdated',@(src,evt)notify(self,'AutomationRangeUpdated',evt));
            addlistener(self.Automate,'ManageAlgorithms',@(~,~)notify(self,'ManageAlgorithms'));
            addlistener(self.Automate,'AddAlgorithm',@(src,evt)notify(self,'AddAlgorithm',evt));
            addlistener(self.Automate,'ErrorThrown',@(src,evt)notify(self,'ErrorThrown',evt));
            addlistener(self.Automate,'OpenSettings',@(src,evt)notify(self,'OpenSettings',evt));
            addlistener(self.Automate,'CloseDialogs',@(~,~)notify(self,'CloseDialogs'));
            addlistener(self.Automate,'AutomateOnAllBlocks',@(src,evt)notify(self,'AutomateOnAllBlocks',evt));
            addlistener(self.Automate,'MetricsUpdated',@(src,evt)notify(self,'MetricsUpdated',evt));
            addlistener(self.Automate,'GroundTruthImportRequested',@(src,evt)notify(self,'GroundTruthImportRequested',evt));
            addlistener(self.Automate,'AddCustomMetric',@(src,evt)notify(self,'AddCustomMetric',evt));
            addlistener(self.Automate,'LoadCustomMetric',@(~,~)notify(self,'LoadCustomMetric'));

        end


        function wireUpHomeTab(self,show3DDisplay)

            self.Home=images.internal.app.segmenter.volume.display.HomeTab(show3DDisplay);
            add(self.TabGroup,self.Home.Tab);
            self.TabGroup.SelectedTab=self.Home.Tab;

            addlistener(self.Home,'AppCleared',@(~,~)updateToolstripForClearedApp(self));
            addlistener(self.Home,'VolumeLoadedFromWorkspace',@(~,~)notify(self,'VolumeLoadedFromWorkspace'));
            addlistener(self.Home,'VolumeLoadedFromDICOM',@(~,~)notify(self,'VolumeLoadedFromDICOM'));
            addlistener(self.Home,'VolumeLoadedFromFile',@(~,~)notify(self,'VolumeLoadedFromFile'));
            addlistener(self.Home,'VolumeLoadedFromBlockedImage',@(~,~)notify(self,'VolumeLoadedFromBlockedImage'));
            addlistener(self.Home,'VolumeLoadedFromBlockedImageFolder',@(~,~)notify(self,'VolumeLoadedFromBlockedImageFolder'));
            addlistener(self.Home,'VolumeLoadedFromBlockedImageWorkspace',@(~,~)notify(self,'VolumeLoadedFromBlockedImageWorkspace'));
            addlistener(self.Home,'LabelsLoadedFromWorkspace',@(~,~)notify(self,'LabelsLoadedFromWorkspace'));
            addlistener(self.Home,'LabelsLoadedFromFile',@(~,~)notify(self,'LabelsLoadedFromFile'));
            addlistener(self.Home,'LabelsSavedToWorkspace',@(src,evt)notify(self,'LabelsSavedToWorkspace',evt));
            addlistener(self.Home,'LabelsSavedToFile',@(src,evt)notify(self,'LabelsSavedToFile',evt));
            addlistener(self.Home,'LabelsSavedAsToWorkspace',@(~,~)notify(self,'LabelsSavedAsToWorkspace'));
            addlistener(self.Home,'LabelsSavedAsToFile',@(~,~)notify(self,'LabelsSavedAsToFile'));
            addlistener(self.Home,'ColorOrderRestored',@(src,evt)notify(self,'ColorOrderRestored',evt));
            addlistener(self.Home,'TwoColumnLayoutRequested',@(src,evt)notify(self,'TwoColumnLayoutRequested',evt));
            addlistener(self.Home,'ShowLabelsChanged',@(src,evt)notify(self,'ShowLabelsChanged',evt));
            addlistener(self.Home,'LabelOpacityChanged',@(src,evt)notify(self,'LabelOpacityChanged',evt));
            addlistener(self.Home,'SliceDimensionChanged',@(src,evt)notify(self,'SliceDimensionChanged',evt));
            addlistener(self.Home,'LabelNamesImported',@(~,~)notify(self,'LabelNamesImported'));
            addlistener(self.Home,'ViewShortcuts',@(~,~)notify(self,'ViewShortcuts'));
            addlistener(self.Home,'ViewDoc',@(~,~)notify(self,'ViewDoc'));
            addlistener(self.Home,'RotateImage',@(src,evt)notify(self,'RotateImage',evt));
            addlistener(self.Home,'ContrastChanged',@(~,~)notify(self,'ContrastChanged'));
            addlistener(self.Home,'ShowVoxelInfo',@(src,evt)notify(self,'ShowVoxelInfo',evt));
            addlistener(self.Home,'RGBLimitsUpdated',@(src,evt)notify(self,'RGBLimitsUpdated',evt));

            if show3DDisplay
                addlistener(self.Home,'ThreeColumnLayoutRequested',@(src,evt)notify(self,'ThreeColumnLayoutRequested',evt));
                addlistener(self.Home,'ShowVolumeChanged',@(src,evt)reactToVolumeVisibilityChange(self,evt));
                addlistener(self.Home,'ShowOverviewChanged',@(src,evt)notify(self,'ShowOverviewChanged',evt));
            end

        end

        function wireUpBlockedImage(self,useWebVersion)

            self.BlockedImage=images.internal.app.segmenter.volume.display.BlockedImageTab(useWebVersion);
            addlistener(self.BlockedImage,'ReadNextBlock',@(~,~)notify(self,'ReadNextBlock'));
            addlistener(self.BlockedImage,'ReadPreviousBlock',@(~,~)notify(self,'ReadPreviousBlock'));
            addlistener(self.BlockedImage,'ReadBlockByIndex',@(src,evt)notify(self,'ReadBlockByIndex',evt));
            addlistener(self.BlockedImage,'MarkBlockComplete',@(src,evt)markAsComplete(self,evt));
            addlistener(self.BlockedImage,'MoveCurrentBlock',@(src,evt)notify(self,'MoveCurrentBlock',evt));

        end

    end


    methods




        function tool=get.ActiveLabelingTool(self)
            tool=self.Label.ActiveTool;
        end




        function TF=get.HideLabelsOnDraw(self)
            TF=self.Label.HideLabelsOnDraw;
        end




        function val=get.ContrastLimits(self)
            val=self.Home.ContrastLimits;
        end




        function TF=get.UseBlockedImage(self)
            TF=self.Automate.AutomateOnBlocks;
        end




        function TF=get.ApplyOnAllBlocks(self)
            TF=self.Automate.ApplyOnAllBlocks;
        end




        function tool=get.Tabs(self)
            tool=self.TabGroup;
        end




        function set.SaveToMATFile(self,TF)
            self.Home.SaveToMATFile=TF;
        end

        function TF=get.SaveToMATFile(self)
            TF=self.Home.SaveToMATFile;
        end




        function set.SaveAsRequired(self,TF)
            self.Home.SaveAsRequired=TF;
        end

        function TF=get.SaveAsRequired(self)
            TF=self.Home.SaveAsRequired;
        end




        function set.SaveAsLogical(self,TF)
            self.Home.SaveAsLogical=TF;
        end

        function TF=get.SaveAsLogical(self)
            TF=self.Home.SaveAsLogical;
        end




        function set.EligibleToSaveAsLogical(self,TF)
            self.Home.EligibleToSaveAsLogical=TF;
        end

        function TF=get.EligibleToSaveAsLogical(self)
            TF=self.Home.EligibleToSaveAsLogical;
        end




        function set.SavedName(self,val)
            self.Home.SavedName=val;
        end

        function val=get.SavedName(self)
            val=self.Home.SavedName;
        end




        function TF=get.AutoSave(self)
            TF=self.Home.AutoSave;
        end




        function TF=isDataSaved(self)

            TF=isDataSaved(self.Home);

        end

    end

end