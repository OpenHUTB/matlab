




classdef AlgorithmTab<vision.internal.labeler.tool.AlgorithmTab

    methods(Access=public)

        function this=AlgorithmTab(tool)
            this@vision.internal.labeler.tool.AlgorithmTab(tool);
        end

        function updateIcons(this,isAutomationFwd)

            if isAutomationFwd
                this.AlgorithmSection.RunButton.Icon=matlab.ui.internal.toolstrip.Icon.RUN_24;
                this.AlgorithmSection.RunButton.Text=vision.getMessage('vision:labeler:Run');
                this.setToolTipText(this.AlgorithmSection.RunButton,'vision:labeler:SelectRunAlgorithmTooltip');
            else
                source=fullfile(matlabroot,'toolbox','vision',...
                'vision','+vision','+internal','+labeler','+tool','+icons','RunBack_24.png');
                runBackIcon=matlab.ui.internal.toolstrip.Icon(source);
                this.AlgorithmSection.RunButton.Icon=runBackIcon;
                this.AlgorithmSection.RunButton.Text=vision.getMessage('vision:labeler:RunReverse');
                this.setToolTipText(this.AlgorithmSection.RunButton,'vision:labeler:SelectReverseRunAlgorithmTooltip');
            end
        end

        function enableControlsForPlayback(this)
            setAlgorithmMode(this,this.CurrentMode);
        end

        function disableControlsForPlayback(this)
            disableAll(this.SettingsSection.Section);
            disableAll(this.AlgorithmSection.Section);
            disableAll(this.CloseSection.Section);
        end

        function disableControls(this)
            this.ViewSection.Section.disableAll();
            this.SettingsSection.Section.disableAll();
            this.AlgorithmSection.Section.disableAll();
            this.CloseSection.Section.disableAll();
        end
    end




    methods(Access=protected)

        function createWidgets(this)
            this.createViewSection();
            this.createSettingsSection();
            this.createRunAlgorithmSection();
            this.createCloseSection();
        end

        function createCloseSection(this)
            this.CloseSection=vision.internal.videoLabeler.tool.sections.CloseSection;
            this.addSectionToTab(this.CloseSection);
        end
    end




    methods(Access=protected)

        function installListeners(this)
            this.installListenersViewSection();
            this.installListenersSettingsSection();
            this.installListenersRunAlgorithmSection();
            this.installListenersCloseSection();
        end

        function installListenersCloseSection(this)
            this.CloseSection.AcceptButton.ButtonPushedFcn=@(es,ed)acceptAlgorithm(getParent(this));
            this.CloseSection.CancelButton.ButtonPushedFcn=@(es,ed)cancelAlgorithm(getParent(this));
        end

    end




    methods(Hidden)
        function ExecuteAlgorithmTestingHook(this,mode)
            setAlgorithmModeAndExecute(this,mode);
        end
    end
end
