




classdef AlgorithmTab<vision.internal.labeler.tool.AlgorithmTab

    methods(Access=public)

        function this=AlgorithmTab(tool)
            this@vision.internal.labeler.tool.AlgorithmTab(tool);
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
            this.CloseSection=vision.internal.imageLabeler.tool.sections.CloseSection;
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
end
