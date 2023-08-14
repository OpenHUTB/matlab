classdef Toolstrip<handle




    properties(SetAccess=private,GetAccess={?uitest.factory.Tester,...
        ?medical.internal.app.labeler.View})

        TabGroup matlab.ui.internal.toolstrip.TabGroup

    end

    properties(SetAccess=private,GetAccess=?uitest.factory.Tester)


        Home medical.internal.app.labeler.view.toolstrip.HomeTab


        Label medical.internal.app.labeler.view.toolstrip.LabelTab


        Automate medical.internal.app.labeler.view.toolstrip.AutomateTab


        VolumeRendering medical.internal.app.labeler.view.toolstrip.VolumeRenderingTab

    end

    properties(Dependent)

AutoSave
WindowLevelEnabled
ShowOrientationMarkers
IsSuperPixelsActive
LevelTraceThreshold
InterpolationAllowed

    end

    events
ErrorThrown
    end

    methods

        function self=Toolstrip()



            self.TabGroup=matlab.ui.internal.toolstrip.TabGroup();
            self.TabGroup.Tag=string(medical.internal.app.labeler.enums.Tag.MainTabGroup);


            self.wireupHomeTab();
            self.wireupLabelTab();
            self.wireupAutomateTab();
            self.wireupVolumeRenderingTab();

        end


        function delete(self)
            delete(self.Automate);
        end


        function setup(self,dataFormat)

            switch dataFormat

            case medical.internal.app.labeler.enums.DataFormat.Volume
                self.Home.setup(dataFormat);
                self.Automate.setup(dataFormat);

                if self.Home.IsVolumeDisplaySupported
                    self.showTab(self.VolumeRendering.Tab);
                    self.VolumeRendering.setRenderingEditor(false);
                end


            case medical.internal.app.labeler.enums.DataFormat.Image
                self.Home.setup(dataFormat);
                self.Automate.setup(dataFormat);
                self.hideTab(self.VolumeRendering.Tab);

            otherwise
                error('Invalid mode, should never reach here')

            end

        end


        function tool=getTabGroup(self)
            tool=self.TabGroup;
        end


        function enableLoadOnly(self)


            self.Home.enableLoadOnly();
            self.Label.disable();
            self.Automate.disable();
            self.VolumeRendering.disable();

        end


        function enable(self)

            enable(self.Home);
            enable(self.Label);
            enable(self.Automate);
            enable(self.VolumeRendering);
        end


        function disable(self)

            disable(self.Home);
            disable(self.Label);
            disable(self.Automate);
            disable(self.VolumeRendering);
        end


        function enableDataControls(self)
            self.Home.enable();
            self.VolumeRendering.enable();
            self.VolumeRendering.disableShowLabels();
        end


        function enableLabelControls(self)

            self.Home.enableLabelOpacity();
            self.Home.enableExport();
            self.Automate.enable();
            self.VolumeRendering.enableShowLabels();

        end


        function disableLabelControls(self)

            self.Home.disableLabelOpacity();
            self.Home.disableExport();
            self.Automate.disable();
            self.VolumeRendering.disableShowLabels();

        end


        function enableDrawing(self)
            self.Label.enable();
        end


        function disableDrawing(self)
            self.Label.disable();
        end


        function setIsCurrentDataOblique(self,TF)
            self.Home.setIsCurrentDataOblique(TF);
            self.Automate.setIsCurrentDataOblique(TF);
        end


        function disableVolumeRendering(self)

            self.Home.IsVolumeDisplaySupported=false;

            self.showVolumeRenderingTab(false);

        end

    end

    methods(Access=protected)


        function showTab(self,tab)

            if isempty(self.TabGroup.contains(tab.Tag))
                self.TabGroup.add(tab);
            end

        end


        function hideTab(self,tab)

            if~isempty(self.TabGroup.contains(tab.Tag))
                self.TabGroup.remove(tab);
            end

        end

    end




    events

NewSessionRequested
NewVolumeSessionRequested
NewImageSessionRequested
OpenSessionRequested
OpenRecentSessionRequested
SaveSessionRequested
ImportDataFromFile
ImportVolumeFromFolder
ImportDataFromDICOMDatabase
ImportGroundTruthFromFile
ImportGroundTruthFromWksp
ImportLabelDefsFromFile
ShowVolume
ContrastChanged
EnableWindowLevel
ResetWindowLevel
LabelOpacityChanged
ShowScaleBars
Show2DOrientationMarkers
Show3DOrientationAxes
ShowVoxelInfo
DisplayConventionChanged
ViewShortcuts
LayoutChangeRequested
SnapshotRequested
AnimationRequested
ShowPublishPanel
ExportGroundTruthToFile
ExportLabelDefsToFile

    end

    methods


        function TF=getShowVolume(self)
            TF=self.Home.getShowVolume();
        end


        function setLabelOpacity(self,opacity)
            self.Home.setLabelOpacity(opacity);
        end


        function opacity=getLabelOpacity(self)
            opacity=self.Home.getLabelOpacity();
        end


        function enableContrastControls(self,TF)
            self.Home.enableContrastControls(TF);
        end


        function enableExport(self)
            self.Home.enableExport();
        end


        function disableExport(self)
            self.Home.disableExport();
        end


        function enableSaveSession(self,TF)
            self.Home.enableSaveSession(TF);
        end


        function TF=isDataSaved(self)
            TF=isDataSaved(self.Home);
        end


        function enableExportLabelDefs(self)
            self.Home.enableExportLabelDefs();
        end


        function disableExportLabelDefs(self)
            self.Home.disableExportLabelDefs()

        end


        function TF=get.AutoSave(self)
            TF=self.Home.AutoSave;
        end


        function TF=get.WindowLevelEnabled(self)
            TF=self.Home.WindowLevelEnabled;
        end

        function set.WindowLevelEnabled(self,TF)
            self.Home.WindowLevelEnabled=TF;
        end


        function markSaveAsDirty(self)
            markSaveAsDirty(self.Home);
        end


        function markSaveAsClean(self)
            markSaveAsClean(self.Home);
        end


        function setWindowBounds(self,bounds)
            self.Home.setWindowBounds(bounds);
        end


        function refreshRecentSessions(self,recentSessions,dataFormat)
            self.Home.refreshRecentSessions(recentSessions,dataFormat);
        end


        function TF=get.ShowOrientationMarkers(self)
            TF=self.Home.ShowOrientationMarkers;
        end

    end

    methods(Access=protected)


        function wireupHomeTab(self)

            self.Home=medical.internal.app.labeler.view.toolstrip.HomeTab();
            add(self.TabGroup,self.Home.Tab);
            self.TabGroup.SelectedTab=self.Home.Tab;

            addlistener(self.Home,'NewVolumeSessionRequested',@(src,evt)self.notify('NewVolumeSessionRequested'));
            addlistener(self.Home,'NewImageSessionRequested',@(src,evt)self.notify('NewImageSessionRequested'));
            addlistener(self.Home,'OpenSessionRequested',@(src,evt)self.notify('OpenSessionRequested'));
            addlistener(self.Home,'OpenRecentSessionRequested',@(src,evt)self.notify('OpenRecentSessionRequested',evt));
            addlistener(self.Home,'SaveSessionRequested',@(src,evt)self.notify('SaveSessionRequested'));

            addlistener(self.Home,'ImportDataFromFile',@(src,evt)self.notify('ImportDataFromFile'));
            addlistener(self.Home,'ImportVolumeFromFolder',@(src,evt)self.notify('ImportVolumeFromFolder'));
            addlistener(self.Home,'ImportGroundTruthFromFile',@(src,evt)self.notify('ImportGroundTruthFromFile'));
            addlistener(self.Home,'ImportGroundTruthFromWksp',@(src,evt)self.notify('ImportGroundTruthFromWksp'));
            addlistener(self.Home,'ImportLabelDefsFromFile',@(src,evt)self.notify('ImportLabelDefsFromFile'));

            addlistener(self.Home,'ShowVolume',@(src,evt)reactToVolumeVisibilityToggled(self,evt));
            addlistener(self.Home,'ContrastChanged',@(src,evt)notify(self,'ContrastChanged'));
            addlistener(self.Home,'EnableWindowLevel',@(src,evt)notify(self,'EnableWindowLevel',evt));
            addlistener(self.Home,'ResetWindowLevel',@(src,evt)notify(self,'ResetWindowLevel'));
            addlistener(self.Home,'LabelOpacityChanged',@(src,evt)notify(self,'LabelOpacityChanged',evt));
            addlistener(self.Home,'ShowVoxelInfo',@(src,evt)notify(self,'ShowVoxelInfo',evt));
            addlistener(self.Home,'ShowScaleBars',@(src,evt)notify(self,'ShowScaleBars',evt));
            addlistener(self.Home,'Show2DOrientationMarkers',@(src,evt)notify(self,'Show2DOrientationMarkers',evt));
            addlistener(self.Home,'Show3DOrientationAxes',@(src,evt)notify(self,'Show3DOrientationAxes',evt));
            addlistener(self.Home,'DisplayConventionChanged',@(src,evt)notify(self,'DisplayConventionChanged',evt));
            addlistener(self.Home,'ViewShortcuts',@(src,evt)notify(self,'ViewShortcuts'));
            addlistener(self.Home,'ShowPublishPanel',@(src,evt)notify(self,'ShowPublishPanel',evt));
            addlistener(self.Home,'SnapshotRequested',@(src,evt)notify(self,'SnapshotRequested'));
            addlistener(self.Home,'LayoutChangeRequested',@(src,evt)notify(self,'LayoutChangeRequested',evt));
            addlistener(self.Home,'AnimationRequested',@(src,evt)notify(self,'AnimationRequested'));
            addlistener(self.Home,'ExportGroundTruthToFile',@(src,evt)notify(self,'ExportGroundTruthToFile'));
            addlistener(self.Home,'ExportLabelDefsToFile',@(src,evt)notify(self,'ExportLabelDefsToFile'));

        end


        function reactToVolumeVisibilityToggled(self,evt)

            self.showVolumeRenderingTab(evt.Value);
            notify(self,'ShowVolume',evt);

        end

    end




    events

BrushSelected
BrushSizeChanged
LevelTraceSelected
LevelTraceThresholdChanged
PaintBySuperpixels
LabelToolSelected
InterpolateRequested
InterpolateManually
FloodFillSensitivityChanged

    end

    methods


        function tool=getActiveLabelingTool(self)

            if self.Home.WindowLevelEnabled
                tool='WindowLevel';
            else
                tool=self.Label.ActiveTool;
            end

        end


        function TF=getHideLabelsOnDraw(self)
            TF=self.Label.HideLabelsOnDraw;
        end


        function enableInterpolation(self,TF)
            self.Label.enableInterpolation(TF);
        end


        function set.InterpolationAllowed(self,TF)
            self.Label.InterpolationAllowed=TF;
        end


        function selectDefaultDrawingTool(self)
            self.Label.selectDefaultDrawingTool();
        end


        function deselectAllDrawingTools(self)
            self.Label.deselectAll();
        end


        function deselectPaintBySuperpixels(self)
            deselectPaintBySuperpixels(self.Label);
        end


        function TF=get.IsSuperPixelsActive(self)
            TF=self.Label.IsSuperPixelsActive;
        end


        function sz=getPaintBrushSize(self)
            sz=self.Label.getPaintBrushSize();
        end


        function val=get.LevelTraceThreshold(self)
            val=self.Label.LevelTraceThreshold;
        end

    end

    methods(Access=protected)


        function wireupLabelTab(self)

            self.Label=medical.internal.app.labeler.view.toolstrip.LabelTab();
            add(self.TabGroup,self.Label.Tab);

            addlistener(self.Label,'BrushSelected',@(src,evt)notify(self,'BrushSelected',evt));
            addlistener(self.Label,'BrushSizeChanged',@(src,evt)notify(self,'BrushSizeChanged',evt));
            addlistener(self.Label,'LevelTraceSelected',@(src,evt)notify(self,'LevelTraceSelected',evt));
            addlistener(self.Label,'LevelTraceThresholdChanged',@(src,evt)notify(self,'LevelTraceThresholdChanged',evt));
            addlistener(self.Label,'PaintBySuperpixels',@(src,evt)notify(self,'PaintBySuperpixels',evt));
            addlistener(self.Label,'LabelToolSelected',@(src,evt)notify(self,'LabelToolSelected'));
            addlistener(self.Label,'InterpolateRequested',@(src,evt)notify(self,'InterpolateRequested'));
            addlistener(self.Label,'InterpolateManually',@(src,evt)notify(self,'InterpolateManually'));
            addlistener(self.Label,'FloodFillSensitivityChanged',@(src,evt)notify(self,'FloodFillSensitivityChanged',evt));

        end

    end




    events

AutomationStarted
AutomationStopped
AutomationDirectionUpdated
AutomationRangeUpdated
AddAlgorithm
ManageAlgorithms
OpenSettings
CloseDialogs
ViewAutomationHelp







    end

    methods


        function refreshAlgorithms(self)
            refresh(self.Automate);
        end


        function addAlgorithm(self,alg,isVolumeBased)
            addAlgorithm(self.Automate,alg,isVolumeBased);
        end


        function setAutomationRangeBounds(self,currVal,maxVal)
            setAutomationRangeBounds(self.Automate,currVal,maxVal);
        end


        function setAutomationRange(self,startVal,endVal)
            setAutomationRange(self.Automate,startVal,endVal);
        end


        function displayAutomationRange(self,currentSlice,maxSlice,sliceDir)
            displayAutomationRangeMedicalApp(self.Automate,currentSlice,maxSlice,sliceDir)
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


        function wireupAutomateTab(self)

            self.Automate=medical.internal.app.labeler.view.toolstrip.AutomateTab();
            add(self.TabGroup,self.Automate.Tab);

            addlistener(self.Automate,'AutomationStarted',@(src,evt)reactToAutomationStart(self,evt));
            addlistener(self.Automate,'AutomationStopped',@(src,evt)reactToAutomationStop(self,evt));
            addlistener(self.Automate,'AutomationRangeUpdated',@(src,evt)notify(self,'AutomationRangeUpdated',evt));
            addlistener(self.Automate,'AutomationDirectionUpdated',@(src,evt)notify(self,'AutomationDirectionUpdated',evt));
            addlistener(self.Automate,'ManageAlgorithms',@(src,evt)notify(self,'ManageAlgorithms'));
            addlistener(self.Automate,'AddAlgorithm',@(src,evt)notify(self,'AddAlgorithm',evt));
            addlistener(self.Automate,'ErrorThrown',@(src,evt)notify(self,'ErrorThrown',evt));
            addlistener(self.Automate,'OpenSettings',@(src,evt)notify(self,'OpenSettings',evt));
            addlistener(self.Automate,'CloseDialogs',@(src,evt)notify(self,'CloseDialogs'));
            addlistener(self.Automate,'ViewAutomationHelp',@(src,evt)notify(self,'ViewAutomationHelp'));







        end


        function reactToAutomationStart(self,evt)

            disable(self.Home);
            disable(self.Label);
            disable(self.VolumeRendering);
            disableDuringAutomation(self.Automate);



            drawnow;

            notify(self,'AutomationStarted',evt);

        end


        function reactToAutomationStop(self,evt)

            notify(self,'AutomationStopped',evt);

            enable(self);

        end
    end




    events

RenderingEditorToggled

PresetRenderingRequested
UserDefinedRenderingRequested

SaveRenderingRequested
ManageRenderingRequested
RemoveRenderingRequested

ApplyRenderingToAllVolumes

BackgroundGradientToggled
BackgroundColorChangeRequested
GradientColorChangeRequested
RestoreBackgroundRequested

    end

    methods


        function setBackgroundColor(self,color)
            self.VolumeRendering.setBackgroundColor(color);
        end


        function setGradientColor(self,color)
            self.VolumeRendering.setGradientColor(color);
        end


        function setVolumeBackgroundSettings(self,useGradient,backgroundColor,gradientColor)
            self.VolumeRendering.setVolumeBackgroundSettings(useGradient,backgroundColor,gradientColor);
        end


        function disableSaveUserDefinedRenderings(self)
            self.VolumeRendering.disableSaveCustomRenderings();
        end


        function TF=getShowRenderingEditor(self)
            TF=self.VolumeRendering.getShowRenderingEditor();
        end


        function setRenderingPreset(self,renderingPrest)
            self.VolumeRendering.setRenderingPreset(renderingPrest);
        end


        function addUserDefinedRendering(self,tag,renderingName)
            self.VolumeRendering.addUserDefinedRendering(tag,renderingName)
        end


        function refreshUserDefinedRenderings(self,tag,renderingName)
            self.VolumeRendering.refreshUserDefinedRenderings(tag,renderingName)
        end


        function removeUserDefinedRendering(self,tag)
            self.VolumeRendering.removeUserDefinedRendering(tag);
        end

    end

    methods(Access=protected)


        function wireupVolumeRenderingTab(self)

            self.VolumeRendering=medical.internal.app.labeler.view.toolstrip.VolumeRenderingTab();
            add(self.TabGroup,self.VolumeRendering.Tab);

            addlistener(self.VolumeRendering,'RenderingEditorToggled',@(src,evt)self.notify('RenderingEditorToggled',evt));

            addlistener(self.VolumeRendering,'PresetRenderingRequested',@(src,evt)self.notify('PresetRenderingRequested',evt));
            addlistener(self.VolumeRendering,'UserDefinedRenderingRequested',@(src,evt)self.notify('UserDefinedRenderingRequested',evt));

            addlistener(self.VolumeRendering,'SaveRenderingRequested',@(src,evt)self.notify('SaveRenderingRequested'));
            addlistener(self.VolumeRendering,'ManageRenderingRequested',@(src,evt)self.notify('ManageRenderingRequested',evt));
            addlistener(self.VolumeRendering,'ApplyRenderingToAllVolumes',@(src,evt)self.notify('ApplyRenderingToAllVolumes'));

            addlistener(self.VolumeRendering,'BackgroundGradientToggled',@(src,evt)self.notify('BackgroundGradientToggled',evt));
            addlistener(self.VolumeRendering,'BackgroundColorChangeRequested',@(src,evt)self.notify('BackgroundColorChangeRequested'));
            addlistener(self.VolumeRendering,'GradientColorChangeRequested',@(src,evt)self.notify('GradientColorChangeRequested'));
            addlistener(self.VolumeRendering,'RestoreBackgroundRequested',@(src,evt)self.notify('RestoreBackgroundRequested'));



        end


        function showVolumeRenderingTab(self,TF)

            if TF
                self.showTab(self.VolumeRendering.Tab)
            else
                self.hideTab(self.VolumeRendering.Tab)
            end

        end

    end

end
