




classdef AlgorithmTab<vision.internal.uitools.NewAbstractTab2


    properties(Access=protected)

ViewSection
SettingsSection
AlgorithmSection
CloseSection


        IsSettingsNeeded=true


        CurrentMode='undorun'
    end

    properties(Access=private)
        ClusterStatus=false;
    end

    methods(Access=public)
        function this=AlgorithmTab(tool)
            tabName=getString(message('vision:labeler:AlgorithmTab'));
            this@vision.internal.uitools.NewAbstractTab2(tool,tabName);

            this.createWidgets();
            this.installListeners();
        end

        function testers=getTesters(~)
            testers=[];
        end

        function disableSettings(this)
            this.IsSettingsNeeded=false;
            this.SettingsSection.Section.disableAll();
        end

        function enableSettings(this)
            this.IsSettingsNeeded=true;
            this.SettingsSection.Section.enableAll();
        end


        function reactToModeChange(~,~)
        end

        function enableControls(this)
            this.ViewSection.Section.enableAll();
            setAlgorithmMode(this,this.CurrentMode);
        end

        function enableShowLabelBoxes(this,roiFlag)
            this.ViewSection.ShowLabelsDropDown.Enabled=roiFlag;
        end

        function enableROIColor(this,roiFlag)
            this.ViewSection.ROIColorDropDown.Enabled=roiFlag;
        end

        function setAlgorithmMode(this,mode)

            switch mode
            case 'run'
                this.AlgorithmSection.RunButton.Enabled=false;
                this.AlgorithmSection.StopButton.Enabled=true;
                this.AlgorithmSection.UndoRunButton.Enabled=false;
                this.SettingsSection.SettingsButton.Enabled=false;
                this.CloseSection.Section.disableAll();

            case 'stop'

                this.AlgorithmSection.RunButton.Enabled=false;
                this.AlgorithmSection.StopButton.Enabled=false;
                this.AlgorithmSection.UndoRunButton.Enabled=true;
                this.SettingsSection.SettingsButton.Enabled=false;
                this.CloseSection.Section.enableAll();

            case 'undorun'

                this.AlgorithmSection.RunButton.Enabled=true;
                this.AlgorithmSection.StopButton.Enabled=false;
                this.AlgorithmSection.UndoRunButton.Enabled=false;
                this.SettingsSection.SettingsButton.Enabled=this.IsSettingsNeeded&&true;
                this.CloseSection.AcceptButton.Enabled=false;
                this.CloseSection.CancelButton.Enabled=true;

            otherwise

                assert(false,'Unrecognized switch expression')

            end

            this.CurrentMode=mode;
        end

        function flag=hasUnsavedChanges(this)
            flag=strcmp(this.CurrentMode,'stop');
        end

        function updateLabelDisplayMode(this,val)


            currentVal=this.ViewSection.ShowLabelsDropDown.SelectedIndex;
            if~isequal(currentVal,val)
                this.ViewSection.ShowLabelsDropDown.SelectedIndex=val;
            end
        end
    end




    methods(Access=protected)

        function createViewSection(this)
            this.ViewSection=vision.internal.labeler.tool.sections.ViewSection;
            this.addSectionToTab(this.ViewSection);
        end

        function createSettingsSection(this)
            this.SettingsSection=vision.internal.labeler.tool.sections.SettingsSection;
            this.addSectionToTab(this.SettingsSection);
        end

        function createRunAlgorithmSection(this)
            this.AlgorithmSection=vision.internal.labeler.tool.sections.RunAlgorithmSection;
            this.addSectionToTab(this.AlgorithmSection);
        end
    end




    methods(Access=protected)


        function installListenersViewSection(this)
            this.ViewSection.ShowLabelsDropDown.ValueChangedFcn=@(es,ed)doShowLabels(getParent(this),this.ViewSection.ShowLabelsDropDown);
            this.ViewSection.ROIColorDropDown.ValueChangedFcn=@(es,ed)changeROIColor(getParent(this),this.ViewSection.ROIColorDropDown);
        end

        function installListenersSettingsSection(this)
            this.SettingsSection.SettingsButton.ButtonPushedFcn=@(es,ed)openSettingsDialog(getParent(this));
        end

        function installListenersRunAlgorithmSection(this)
            this.AlgorithmSection.RunButton.ButtonPushedFcn=@(es,ed)setAlgorithmModeAndExecute(this,'run');
            this.AlgorithmSection.StopButton.ButtonPushedFcn=@(es,ed)setAlgorithmModeAndExecute(this,'stop');
            this.AlgorithmSection.UndoRunButton.ButtonPushedFcn=@(es,ed)setAlgorithmModeAndExecute(this,'undorun');
        end



        function setAlgorithmModeAndExecute(this,mode)

            tool=getParent(this);
            switch mode
            case 'run'







                setAlgorithmMode(this,mode);


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

    methods(Abstract,Access=protected)
        createWidgets(this)
        installListeners(this)
    end
end
