



classdef LabelTab<vision.internal.videoLabeler.tool.LabelTab


    methods(Access=public)
        function this=LabelTab(tool)
            this@vision.internal.videoLabeler.tool.LabelTab(tool);
        end
    end

    methods(Access=protected)

        function createWidgets(this)
            this.createFileSection();
            this.createViewSection();
            this.createAlgorithmSection();
            this.createResourcesSection();
            this.createVisualSummarySection();
            this.createLayoutSection();
            this.createExportSection();
        end

        function createFileSection(this)
            this.FileSection=lidar.internal.lidarLabeler.tool.sections.FileSection;

            this.addSectionToTab(this.FileSection);
        end

        function createViewSection(this)
            tool=getParent(this);
            this.ViewSection=lidar.internal.lidarLabeler.tool.sections.ViewSection(tool);
            this.addSectionToTab(this.ViewSection);
        end

        function createLayoutSection(this)
            tool=getParent(this);
            this.LayoutSection=lidar.internal.lidarLabeler.tool.sections.LayoutSection(tool);
            this.addSectionToTab(this.LayoutSection);
        end

        function createAlgorithmSection(this)
            tool=getParent(this);
            this.AlgorithmSection=lidar.internal.lidarLabeler.tool.sections.AlgorithmSection(tool);
            this.addSectionToTab(this.AlgorithmSection);
        end

        function repo=getAlgorithmRepository(this)

            repo=lidar.internal.lidarLabeler.LidarLabelerAlgorithmRepository.getInstance();
        end

    end

    methods(Access=public)

        function enableControls(this)
            this.FileSection.Section.enableAll();
            this.enableImportAnnotationItems();
            enableAlgorithmSection(this,true);
            this.ViewSection.Section.enableAll();
            this.ExportSection.Section.enableAll();
        end

        function disableControls(this)
            this.AlgorithmSection.Section.disableAll();
            this.ViewSection.ShowLabelsDropDown.Enabled=false;

            this.FileSection.NewSessionButton.Enabled=false;
            this.FileSection.SaveButton.Enabled=false;

            this.VisualSummarySection.Section.disableAll();
            this.ExportSection.Section.disableAll();
            this.ExportSection.ExportAnnotationsToFile.Enabled=false;
            this.ExportSection.ExportAnnotationsToWS.Enabled=false;
        end

        function disableControlsForPlayback(this)
            this.FileSection.Section.disableAll();
            this.AlgorithmSection.Section.disableAll();
            this.ViewSection.ShowLabelsDropDown.Enabled=false;
            this.VisualSummarySection.Section.disableAll();
            this.ExportSection.Section.disableAll();
        end

        function disableAllControls(this)
            this.FileSection.Section.disableAll();
            this.ViewSection.Section.disableAll();
            this.AlgorithmSection.Section.disableAll();
            this.VisualSummarySection.Section.disableAll();
            this.ExportSection.Section.disableAll();
        end

    end




    methods(Hidden,Access=public)
        function SelectAlgorithmTestingHook(this,alg)
            repo=this.getAlgorithmRepository();

            evtsrc.Text=alg;
            algorithms=repo.AlgorithmList{repo.Names==alg};
            this.algorithmSelected(algorithms,evtsrc);

        end
    end
end
