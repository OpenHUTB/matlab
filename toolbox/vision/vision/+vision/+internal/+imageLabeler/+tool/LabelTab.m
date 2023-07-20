



classdef LabelTab<vision.internal.labeler.tool.LabelTab

    properties(Access=private)
Parent
TabGroup
Tab
    end

    methods(Access=public)
        function this=LabelTab(tool)
            tabName=getString(message('vision:imageLabeler:LabelingTab'));
            this@vision.internal.labeler.tool.LabelTab(tool,tabName);
        end

        function enableControls(this)
            this.FileSection.Section.enableAll();
            this.ViewSection.Section.enableAll();
            this.OpacitySection.Section.enableAll();
            this.AlgorithmSection.Section.enableAll();
            this.ResourcesSection.Section.enableAll();
            this.ExportSection.Section.enableAll();
        end

        function disableControls(this)
            this.FileSection.ImportAnnotationsFromFile.Enabled=false;
            this.FileSection.ImportAnnotationsFromWS.Enabled=false;
            this.FileSection.NewSessionButton.Enabled=false;
            this.FileSection.SaveButton.Enabled=false;

            this.ViewSection.ShowLabelsDropDown.Enabled=false;
            this.ViewSection.ROIColorDropDown.Enabled=false;
            this.OpacitySection.Section.disableAll();
            this.AlgorithmSection.Section.disableAll();
            this.VisualSummarySection.Section.disableAll();
            this.ExportSection.Section.disableAll();

            this.ExportSection.ExportAnnotationsToFile.Enabled=false;
            this.ExportSection.ExportAnnotationsToWS.Enabled=false;
        end

        function disableAllControls(this)
            this.FileSection.Section.disableAll();
            this.ViewSection.Section.disableAll();
            this.AlgorithmSection.Section.disableAll();
            this.VisualSummarySection.Section.disableAll();
            this.ExportSection.Section.disableAll();
        end

        function setAlgorithmSectionBlockedImageLabelingMode(this,flag)
            this.AlgorithmSection.IsBlockedImageLabelingMode=flag;
            this.AlgorithmSection.refreshAlgorithmList();
        end

        function setAlgorithmSectionAutomateButton(this,flag)


            if flag
                this.AlgorithmSection.Section.enableAll();
                this.AlgorithmSection.AutomateButton.Description=getString(message('vision:labeler:RunAlgorithmButtonToolTip'));
            else
                this.AlgorithmSection.Section.disableAll();
                this.AlgorithmSection.AutomateButton.Description=getString(message('vision:imageLabeler:DisabledRunAlgorithmButtonToolTip'));
            end
        end

    end




    methods(Access=public)

        function setShowOverviewListItem(this,TF)
            this.LayoutSection.ShowOverview.Value=TF;
        end

        function enableShowOverviewListItem(this,TF)
            this.LayoutSection.ShowOverview.Enabled=TF;
        end

        function enableLoadImagesDatastore(this,TF)
            this.FileSection.LoadImagesDatastore.Enabled=TF;
        end

    end




    methods(Access=protected)
        function createWidgets(this)
            this.createFileSection();
            this.createViewSection();
            this.createOpacitySection();
            this.createAlgorithmSection();
            this.createResourcesSection();
            this.createVisualSummarySection();
            this.createLayoutSection();
            this.createExportSection();
        end
    end

    methods(Access=protected)
        function createFileSection(this)
            this.FileSection=vision.internal.imageLabeler.tool.sections.FileSection;
            this.addSectionToTab(this.FileSection);
        end

        function createExportSection(this)
            this.ExportSection=vision.internal.imageLabeler.tool.sections.ExportSection;
            this.addSectionToTab(this.ExportSection);
        end

        function createAlgorithmSection(this)
            tool=getParent(this);
            this.AlgorithmSection=vision.internal.imageLabeler.tool.sections.AlgorithmSection(tool);
            this.addSectionToTab(this.AlgorithmSection);
        end

        function createViewSection(this)
            this.ViewSection=vision.internal.imageLabeler.tool.sections.ViewSection();
            this.addSectionToTab(this.ViewSection);
        end

        function createLayoutSection(this)
            this.LayoutSection=vision.internal.imageLabeler.tool.sections.LayoutSection();
            this.addSectionToTab(this.LayoutSection);
        end

        function createOpacitySection(this)
            this.OpacitySection=vision.internal.labeler.tool.sections.OpacitySection();
            this.addSectionToTab(this.OpacitySection);
        end
    end





    methods(Access=protected)
        function installListeners(this)
            this.installListenersFileSection();
            this.installListenersViewSection();
            this.installListenersOpacitySection();
            this.installListenersAlgorithmSection();
            this.installListenerResourcesSection();
            this.installListenersVisualSummarySection();
            this.installListenersLayoutSection();
            this.installListenersExportSection();
        end
    end

    methods(Access=protected)
        function installListenersFileSection(this)
            parent=getParent(this);

            this.FileSection.NewSessionButton.ButtonPushedFcn=@(varargin)protectOnDelete(this,@(varargin)newSession(parent),varargin{:});
            this.FileSection.LoadImagesDirectory.ItemPushedFcn=@(varargin)protectOnDelete(this,@(varargin)loadImage(parent),varargin{:});
            this.FileSection.LoadImagesDatastore.ItemPushedFcn=@(varargin)protectOnDelete(this,@(varargin)loadImageFromDataStore(parent),varargin{:});

            this.FileSection.LoadDefinitions.ItemPushedFcn=@(varargin)protectOnDelete(this,@(varargin)loadLabelDefinitionsFromFile(parent),varargin{:});
            this.FileSection.LoadSessionButton.ButtonPushedFcn=@(varargin)protectOnDelete(this,@(varargin)loadSession(parent),varargin{:});
            this.FileSection.SaveSession.ItemPushedFcn=@(varargin)protectOnDelete(this,@(varargin)saveSession(parent),varargin{:});
            this.FileSection.SaveAsSession.ItemPushedFcn=@(varargin)protectOnDelete(this,@(varargin)saveSessionAs(parent),varargin{:});
            this.FileSection.ImportAnnotationsFromWS.ItemPushedFcn=@(varargin)protectOnDelete(this,@(varargin)importLabelAnnotations(parent,'workspace'),varargin{:});
            this.FileSection.ImportAnnotationsFromFile.ItemPushedFcn=@(varargin)protectOnDelete(this,@(varargin)importLabelAnnotations(parent,'file'),varargin{:});
        end

        function installListenersAlgorithmSection(this)
            this.AlgorithmSection.SelectAlgorithmDropDown.DynamicPopupFcn=@(varargin)protectOnDelete(this,@(varargin)iAddAlgorithmPopupList(this),varargin{:});
            this.AlgorithmSection.AutomateButton.ButtonPushedFcn=@(varargin)protectOnDelete(this,@(varargin)showAlgorithmTab(this),varargin{:});
        end

        function installListenersLayoutSection(this)
            parent=getParent(this);
            this.LayoutSection.LayoutButton.ButtonPushedFcn=@(varargin)protectOnDelete(this,@(varargin)restoreDefaultLayout(parent,false),varargin{:});
            this.LayoutSection.DefaultLayout.ItemPushedFcn=@(varargin)protectOnDelete(this,@(varargin)restoreDefaultLayout(parent,false),varargin{:});
            this.LayoutSection.ShowOverview.ValueChangedFcn=@(varargin)protectOnDelete(this,@(varargin)toggleOverviewAndSetLayout(parent,varargin{2}.EventData.NewValue),varargin{:});
        end

        function showAlgorithmTab(this)
            parent=getParent(this);
            startAutomation(parent);
        end

    end

    methods(Access=protected)
        function repo=getAlgorithmRepository(~)

            repo=vision.internal.imageLabeler.ImageLabelerAlgorithmRepository.getInstance();
        end

    end
end

function popup=iAddAlgorithmPopupList(this)




    import matlab.ui.internal.toolstrip.*;
    popup=PopupList();

    if this.AlgorithmSection.RefreshPopupList


        repo=getAlgorithmRepository(this);
        popupList=this.AlgorithmSection.AlgorithmPopupList;
        for id=1:numel(popupList)
            if isa(popupList{id},'matlab.ui.internal.toolstrip.ListItem')&&isempty(popupList{id}.ItemPushedFcn)


                algIndex=strcmp(popupList{id}.Text,repo.Names);
                alg=repo.AlgorithmList{algIndex};
                popupList{id}.ItemPushedFcn=@(es,ed)algorithmSelected(this,alg,es);
            end

            popup.add(popupList{id});
        end

        this.AlgorithmSection.RefreshPopupList=false;
    else

        popup=this.AlgorithmSection.SelectAlgorithmDropDown.Popup;
    end
end