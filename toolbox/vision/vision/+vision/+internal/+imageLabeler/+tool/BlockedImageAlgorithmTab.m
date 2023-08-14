




classdef BlockedImageAlgorithmTab<vision.internal.labeler.tool.AlgorithmTab

    properties(Access=protected)

AutomationRegionSection
BlockedParametersSection

CurrentAutomationRegionMode
        NumCustomPolygons=0
PolygonPositions
PreviousLabelSelectionIndex
    end

    events
DetailViewImageClicked
    end

    methods(Access=public)

        function this=BlockedImageAlgorithmTab(tool)
            this@vision.internal.labeler.tool.AlgorithmTab(tool);
        end

        function disableControls(this)
            this.ViewSection.Section.disableAll();
            this.SettingsSection.Section.disableAll();
            this.AlgorithmSection.Section.disableAll();
            this.CloseSection.Section.disableAll();
        end

        function populateBlockedParameterResLevelList(this,numLevels)
            levelVec=1:numLevels;
            levelVec=num2cell(levelVec');
            newLevelList=cellfun(@(x){num2str(x)},levelVec);
            this.BlockedParametersSection.ResLevelDropDown.replaceAllItems(newLevelList);
            this.BlockedParametersSection.ResLevelDropDown.SelectedIndex=1;
        end

        function updateNumCustomPolygons(this,value)
            this.NumCustomPolygons=value;
        end

        function updatePolygonPositions(this,roiPos)
            this.PolygonPositions=roiPos;
        end

        function disableAutomationRegionCustom(this)
            this.AutomationRegionSection.CustomRegionToggleButton.Enabled=false;
        end

        function disableStopButton(this)



            this.AlgorithmSection.StopButton.Enabled=false;
        end
        function disableUseParallelButton(this)
            this.BlockedParametersSection.UseParallelToggleButton.Enabled=false;
        end

        function mode=getCurrentAutomationRegionMode(this)
            mode=this.CurrentAutomationRegionMode;
        end

        function setRunButtonMode(this,flag)
            this.AlgorithmSection.RunButton.Enabled=flag;
        end

        function resetAutomationRegionMode(this)

            setBlockedAutomationRegionMode(this,'CurrentRegion')
        end

        function resetBlockSizeRowColumnValue(this,val)

            this.BlockedParametersSection.BlockSizeRowsField.Value=val;
            this.BlockedParametersSection.BlockSizeColumnsField.Value=val;
        end

        function setAlgorithmMode(this,mode)
            tool=getParent(this);
            numImages=getNumImagesAutomation(tool);
            switch mode
            case 'run'
                this.AlgorithmSection.RunButton.Enabled=false;
                if numImages==1
                    this.disableStopButton();
                else
                    this.AlgorithmSection.StopButton.Enabled=true;
                end
                this.AlgorithmSection.UndoRunButton.Enabled=false;
                this.SettingsSection.SettingsButton.Enabled=false;
                this.AutomationRegionSection.Section.disableAll();
                this.BlockedParametersSection.Section.disableAll();
                this.CloseSection.Section.disableAll();

            case 'stop'

                this.AlgorithmSection.RunButton.Enabled=false;
                this.AlgorithmSection.StopButton.Enabled=false;
                this.AlgorithmSection.UndoRunButton.Enabled=true;
                this.SettingsSection.SettingsButton.Enabled=false;
                this.CloseSection.Section.enableAll();

            case 'undorun'

                if~strcmp(this.CurrentAutomationRegionMode,'CustomRegion')||(this.NumCustomPolygons>0)
                    this.setRunButtonMode(true);
                end
                this.AlgorithmSection.StopButton.Enabled=false;
                this.AlgorithmSection.UndoRunButton.Enabled=false;
                this.SettingsSection.SettingsButton.Enabled=this.IsSettingsNeeded&&true;
                this.CloseSection.AcceptButton.Enabled=false;
                this.CloseSection.CancelButton.Enabled=true;
                this.AutomationRegionSection.Section.enableAll();
                if numImages>1
                    this.disableAutomationRegionCustom();
                end
                this.BlockedParametersSection.Section.enableAll();
            otherwise

                assert(false,'Unrecognized switch expression')

            end

            this.CurrentMode=mode;
        end

        function setBlockedAutomationRegionForRun(this,bim)
            tool=getParent(this);
            algorithm=tool.AlgorithmSetupHelper.AlgorithmInstance;
            mode=this.CurrentAutomationRegionMode;
            switch mode
            case 'CurrentRegion'

                tool=getParent(this);
                lims=tool.getImageAxesLimits;
                roiPos={[lims.CurrentXLim(1),lims.CurrentYLim(1);...
                lims.CurrentXLim(2),lims.CurrentYLim(1);...
                lims.CurrentXLim(2),lims.CurrentYLim(2);...
                lims.CurrentXLim(1),lims.CurrentYLim(2)]};
                updateBlockLocationSet(algorithm,bim,mode,roiPos);

            case 'WholeImage'
                roiPos=[];
                updateBlockLocationSet(algorithm,bim,mode,roiPos);

            case 'CustomRegion'
                roiPos=this.PolygonPositions;
                updateBlockLocationSet(algorithm,bim,mode,roiPos);

            otherwise

            end
        end

    end




    methods(Access=protected)

        function createWidgets(this)
            this.createViewSection();
            this.createAutomationRegionSection();
            this.createBlockedParametersSection();
            this.createSettingsSection();
            this.createRunAlgorithmSection();
            this.createCloseSection();
        end

        function createAutomationRegionSection(this)
            this.AutomationRegionSection=vision.internal.imageLabeler.tool.sections.AutomationRegionSection;
            this.addSectionToTab(this.AutomationRegionSection);


            setBlockedAutomationRegionMode(this,'CurrentRegion')
        end

        function createBlockedParametersSection(this)
            this.BlockedParametersSection=vision.internal.imageLabeler.tool.sections.BlockedParametersSection;
            this.addSectionToTab(this.BlockedParametersSection);

        end

        function createCloseSection(this)
            this.CloseSection=vision.internal.imageLabeler.tool.sections.CloseSection;
            this.addSectionToTab(this.CloseSection);
        end
    end




    methods(Access=protected)

        function installListeners(this)
            this.installListenersViewSection();
            this.installListenersAutomationRegionSection();
            this.installListenersBlockedParametersSection();
            this.installListenersSettingsSection();
            this.installListenersRunAlgorithmSection();
            this.installListenersCloseSection();
        end

        function installListenersAutomationRegionSection(this)
            this.AutomationRegionSection.CurrentRegionToggleButton.ValueChangedFcn=@(es,ed)setBlockedAutomationRegionMode(this,'CurrentRegion');
            this.AutomationRegionSection.WholeImageToggleButton.ValueChangedFcn=@(es,ed)setBlockedAutomationRegionMode(this,'WholeImage');
            this.AutomationRegionSection.CustomRegionToggleButton.ValueChangedFcn=@(es,ed)setBlockedAutomationRegionMode(this,'CustomRegion');


        end

        function installListenersBlockedParametersSection(this)
            this.BlockedParametersSection.ResLevelDropDown.ValueChangedFcn=@(es,ed)setBlockedParameterResLevel(this,es);
            this.BlockedParametersSection.BlockSizeRowsField.ValueChangedFcn=@(es,ed)setBlockedParameterBlockSizeRows(this,es);
            this.BlockedParametersSection.BlockSizeColumnsField.ValueChangedFcn=@(es,ed)setBlockedParameterBlockSizeColumns(this,es);
            this.BlockedParametersSection.UseParallelToggleButton.ValueChangedFcn=@(es,ed)setBlockedParameterUseParallel(this,es);
        end

        function installListenersRunAlgorithmSection(this)
            this.AlgorithmSection.RunButton.ButtonPushedFcn=@(es,ed)setAlgorithmModeAndExecute(this,'run');
            this.AlgorithmSection.StopButton.ButtonPushedFcn=@(es,ed)setAlgorithmModeAndExecute(this,'stop');
            this.AlgorithmSection.UndoRunButton.ButtonPushedFcn=@(es,ed)setAlgorithmModeAndExecute(this,'undorun');
        end

        function installListenersCloseSection(this)
            this.CloseSection.AcceptButton.ButtonPushedFcn=@(es,ed)acceptAlgorithm(getParent(this));
            this.CloseSection.CancelButton.ButtonPushedFcn=@(es,ed)cancelAlgorithm(getParent(this));
        end

        function setBlockedParameterResLevel(this,eventSource)
            resLevel=str2double(eventSource.SelectedItem);
            tool=getParent(this);
            algorithm=tool.AlgorithmSetupHelper.AlgorithmInstance;


            updateResolutionLevel(algorithm,resLevel);
        end

        function setBlockedParameterBlockSizeRows(this,eventSource)
            blockSizeRowValue=str2double(eventSource.Text);
            tool=getParent(this);
            algorithm=tool.AlgorithmSetupHelper.AlgorithmInstance;


            updateBlockSizeRows(algorithm,blockSizeRowValue);

        end

        function setBlockedParameterBlockSizeColumns(this,eventSource)
            blockSizeColumnValue=str2double(eventSource.Text);
            tool=getParent(this);
            algorithm=tool.AlgorithmSetupHelper.AlgorithmInstance;


            updateBlockSizeColumns(algorithm,blockSizeColumnValue);

        end


        function setBlockedParameterUseParallel(this,eventSource)
            useParallelFlag=eventSource.Selected;
            tool=getParent(this);
            algorithm=tool.AlgorithmSetupHelper.AlgorithmInstance;


            updateUseParallel(algorithm,useParallelFlag);
        end

        function setBlockedAutomationRegionMode(this,mode)
            switch mode
            case 'CurrentRegion'
                if strcmp(this.CurrentAutomationRegionMode,'CustomRegion')
                    this.stopPolygonDrawingAutomationRegion();
                end
                this.AutomationRegionSection.CurrentRegionToggleButton.Value=true;
                this.AutomationRegionSection.WholeImageToggleButton.Value=false;
                this.AutomationRegionSection.CustomRegionToggleButton.Value=false;
                this.CurrentAutomationRegionMode=mode;

                this.setRunButtonMode(true);

            case 'WholeImage'
                if strcmp(this.CurrentAutomationRegionMode,'CustomRegion')
                    this.stopPolygonDrawingAutomationRegion();
                end
                this.AutomationRegionSection.CurrentRegionToggleButton.Value=false;
                this.AutomationRegionSection.WholeImageToggleButton.Value=true;
                this.AutomationRegionSection.CustomRegionToggleButton.Value=false;
                this.CurrentAutomationRegionMode=mode;

                this.setRunButtonMode(true);
            case 'CustomRegion'
                this.AutomationRegionSection.CurrentRegionToggleButton.Value=false;
                this.AutomationRegionSection.WholeImageToggleButton.Value=false;
                this.AutomationRegionSection.CustomRegionToggleButton.Value=true;
                this.CurrentAutomationRegionMode=mode;

                if this.NumCustomPolygons==0
                    this.setRunButtonMode(false);
                else
                    this.setRunButtonMode(true);
                end
                this.startPolygonDrawingAutomationRegion();

            otherwise

            end
        end

        function startPolygonDrawingAutomationRegion(this)


            tool=getParent(this);
            previousLabelSelectionIndex=tool.freezeActiveLabelDefinitionItems();
            this.PreviousLabelSelectionIndex=previousLabelSelectionIndex;

            imDisplay=tool.getImageDisplay();
            imDisplay.enableDrawingPolygonForAutomationRegion();
        end

        function stopPolygonDrawingAutomationRegion(this)

            tool=getParent(this);
            tool.unfreezeActiveLabelDefinitionItems(this.PreviousLabelSelectionIndex);

            imDisplay=tool.getImageDisplay();
            imDisplay.disableDrawingPolygonForAutomationRegion();

        end

        function setAlgorithmModeAndExecute(this,mode)

            tool=getParent(this);
            switch mode
            case 'run'







                setAlgorithmMode(this,mode);

                if strcmp(this.CurrentAutomationRegionMode,'CustomRegion')
                    this.stopPolygonDrawingAutomationRegion();
                end

                setupSucceeded=setupAlgorithm(tool);

                if~setupSucceeded

                    return;
                else




                    if tool.DisplayManager.getSelectedDisplay.IsCuboidSupported

                        if tool.Session.hasPointCloudSignal&&tool.getColorByCluster
                            disableClusterVisualizationDuringAutomation(tool);
                            this.ClusterStatus=true;
                        end
                    end

                    setAlgorithmMode(this,mode);
                end






                onDone=onCleanup(@()setAlgorithmMode(this,'stop'));


                runAlgorithm(tool);

            case 'stop'


                setAlgorithmMode(this,mode);


                stopAlgorithm(tool);

            case 'undorun'


                userCanceled=undorunAlgorithm(tool);

                if tool.DisplayManager.getSelectedDisplay.IsCuboidSupported
                    if tool.Session.hasPointCloudSignal
                        this.ClusterStatus=tool.getColorByCluster;
                    end
                end


                if~userCanceled
                    setAlgorithmMode(this,mode);
                end

            otherwise
                assert(false,'Unknown algorithm mode')
            end

            if tool.DisplayManager.getSelectedDisplay.IsCuboidSupported
                if tool.Session.hasPointCloudSignal&&this.ClusterStatus
                    enableClusterVisualizationDuringAutomation(tool)
                end
            end

        end


    end
end
