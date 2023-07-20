


classdef LabelTab<vision.internal.uitools.NewAbstractTab2

    properties(Access=protected)

FileSection
ViewSection
OpacitySection
AlgorithmSection
VisualSummarySection
ResourcesSection
LayoutSection
ExportSection
    end

    methods(Access=public)
        function this=LabelTab(tool,tabName)
            this@vision.internal.uitools.NewAbstractTab2(tool,tabName);

            this.createWidgets();
            this.installListeners();
        end

        function testers=getTesters(this)
            testers.algorithmTester=this.AlgorithmSection;
            testers.visualSummaryTester=this.VisualSummarySection;
            testers.exportTester=this.ExportSection;
        end
    end

    methods(Abstract,Access=protected)
        repo=getAlgorithmRepository(this)
    end




    methods(Access=public)


        function reactToModeChange(~,~)

        end

        function enableSaveLabelDefinitionsItem(this,flag)
            this.ExportSection.ExportButton.Enabled=flag;
            this.ExportSection.SaveDefinitions.Enabled=flag;
        end

        function enableNewAndSaveSessionItems(this)
            this.FileSection.NewSessionButton.Enabled=true;
            this.FileSection.SaveButton.Enabled=true;
        end

        function enableShowLabelBoxes(this,roiFlag)
            this.ViewSection.ShowLabelsDropDown.Enabled=roiFlag;
        end

        function enableROIColor(this,roiFlag)
            this.ViewSection.ROIColorDropDown.Enabled=roiFlag;
        end

        function enablePolygonOpacitySlider(this,roiFlag)
            this.OpacitySection.PolygonOpacitySlider.Enabled=roiFlag;
        end

        function enablePixelOpacitySlider(this,roiFlag)
            this.OpacitySection.PixelLabelOpacitySlider.Enabled=roiFlag;
        end

        function changeLabelDisplayOption(this,val)


            switch val
            case 'hover'
                idx=1;

            case 'on'
                idx=2;

            case 'off'
                idx=3;
            end
            this.ViewSection.ShowLabelsDropDown.SelectedIndex=idx;
        end

        function changeROIColorOption(this,val)


            switch val
            case 'By Label'
                idx=1;

            case 'By Instance'
                idx=2;

            end
            this.ViewSection.ROIColorDropDown.SelectedIndex=idx;
        end

        function setPixelOpacitySliderValue(this,value)
            this.OpacitySection.PixelLabelOpacitySlider.Value=value;
        end

        function setPolygonOpacitySliderValue(this,value)
            this.OpacitySection.PolygonOpacitySlider.Value=value;
        end

        function setToDefaultSelectAlgorithmDropDownText(this)
            this.AlgorithmSection.SelectAlgorithmDropDown.Text=...
            vision.getMessage(this.AlgorithmSection.DefaultSelectionTextID);
        end

        function resetOpacitySliders(this)
            this.setPixelOpacitySliderValue(50);
            this.setPolygonOpacitySliderValue(0);
        end

        function enableAlgorithmSection(this,flag)
            if flag
                this.AlgorithmSection.Section.enableAll();


                if~isAlgorithmSelected(this.AlgorithmSection)
                    this.AlgorithmSection.AutomateButton.Enabled=false;
                end
            else
                this.AlgorithmSection.Section.disableAll();
            end
        end

        function enableImportAnnotationsButton(this,flag)
            this.FileSection.ImportAnnotationsFromFile.Enabled=flag;
            this.FileSection.ImportAnnotationsFromWS.Enabled=flag;
        end

        function enableExportSection(this,flag)
            this.ExportSection.ExportButton.Enabled=flag;
            this.ExportSection.ExportAnnotationsToFile.Enabled=flag;
            this.ExportSection.ExportAnnotationsToWS.Enabled=flag;
        end

        function TF=isAlgorithmSelected(this)
            TF=this.AlgorithmSection.isAlgorithmSelected;
        end

        function enableVisualSummaryButton(this,flag)
            this.VisualSummarySection.VisualSummaryButton.Enabled=flag;
        end



        function enableVisualSummaryDock(~,~)
        end

        function setVisualSummaryDockItem(~,~)
        end

        function updateLabelDisplayMode(this,val)


            currentVal=this.ViewSection.ShowLabelsDropDown.SelectedIndex;
            if~isequal(currentVal,val)
                this.ViewSection.ShowLabelsDropDown.SelectedIndex=val;
            end
        end
    end




    methods(Access=protected,Hidden)

        function createViewSection(this)
            this.ViewSection=vision.internal.labeler.tool.sections.ViewSection;
            this.addSectionToTab(this.ViewSection);
        end

        function createOpacitySection(this)
            this.OpacitySection=vision.internal.labeler.tool.sections.OpacitySection;
            this.addSectionToTab(this.OpacitySection);
        end

        function createAlgorithmSection(this)
            tool=getParent(this);
            this.AlgorithmSection=vision.internal.labeler.tool.sections.AlgorithmSection(tool);
            this.addSectionToTab(this.AlgorithmSection);
        end

        function createVisualSummarySection(this)
            this.VisualSummarySection=vision.internal.labeler.tool.sections.VisualSummarySection;
            this.addSectionToTab(this.VisualSummarySection);
        end

        function createExportSection(this)
            this.ExportSection=vision.internal.labeler.tool.sections.ExportSection;
            this.addSectionToTab(this.ExportSection);
        end

        function createResourcesSection(this)
            this.ResourcesSection=vision.internal.labeler.tool.sections.ResourcesSection;
            this.addSectionToTab(this.ResourcesSection);
        end
    end




    methods(Access=protected,Hidden)

        function installListenersViewSection(this)
            this.ViewSection.ShowLabelsDropDown.ValueChangedFcn=@(es,ed)doShowLabels(getParent(this),this.ViewSection.ShowLabelsDropDown);
            this.ViewSection.ROIColorDropDown.ValueChangedFcn=@(es,ed)changeROIColor(getParent(this),this.ViewSection.ROIColorDropDown);

        end


        function installListenersOpacitySection(this)

            this.OpacitySection.PolygonOpacitySlider.ValueChangedFcn=@(~,~)setPolygonLabelAlpha(getParent(this),this.OpacitySection.PolygonOpacitySlider.Value/100);
            this.OpacitySection.PixelLabelOpacitySlider.ValueChangedFcn=@(~,~)setPixelLabelAlpha(getParent(this),this.OpacitySection.PixelLabelOpacitySlider.Value);

        end

        function installListenersVisualSummarySection(this)
            parent=getParent(this);
            this.VisualSummarySection.VisualSummaryButton.ButtonPushedFcn=@(varargin)protectOnDelete(this,@(varargin)viewLabelSummary(parent),varargin{:});
        end

        function installListenersLayoutSection(this)
            parent=getParent(this);
            this.LayoutSection.LayoutButton.ButtonPushedFcn=@(varargin)protectOnDelete(this,@(varargin)restoreDefaultLayout(parent,false),varargin{:});
        end

        function installListenersExportSection(this)
            parent=getParent(this);
            this.ExportSection.SaveDefinitions.ItemPushedFcn=@(varargin)protectOnDelete(this,@(varargin)exportLabelDefinitions(parent),varargin{:});
            this.ExportSection.ExportAnnotationsToWS.ItemPushedFcn=@(varargin)protectOnDelete(this,@(varargin)exportLabelAnnotationsToWS(parent),varargin{:});
            this.ExportSection.ExportAnnotationsToFile.ItemPushedFcn=@(varargin)protectOnDelete(this,@(varargin)exportLabelAnnotationsToFile(parent),varargin{:});
        end

        function installListenerResourcesSection(this)
            parent=getParent(this);
            this.ResourcesSection.ViewShortcutsButton.ButtonPushedFcn=@(varargin)protectOnDelete(this,@(varargin)viewShortcutsDialog(parent),varargin{:});
        end
    end




    methods(Access=protected,Hidden)

        function popup=addAlgorithmPopupList(this)

            import matlab.ui.internal.toolstrip.*;
            popup=PopupList();

            if this.AlgorithmSection.RefreshPopupList


                repo=getAlgorithmRepository(this);
                popupList=this.AlgorithmSection.AlgorithmPopupList;

                for n=1:this.AlgorithmSection.NumAlgorithms
                    alg=repo.AlgorithmList{n};
                    popupList{n}.ItemPushedFcn=@(es,ed)algorithmSelected(this,alg,es);
                end

                for i=1:numel(this.AlgorithmSection.AlgorithmPopupList)
                    popup.add(popupList{i});
                end
                this.AlgorithmSection.RefreshPopupList=false;
            else

                popup=this.AlgorithmSection.SelectAlgorithmDropDown.Popup;
            end
        end

        function algorithmSelected(this,alg,evtsrc,varargin)


            algorithmName=evtsrc.Text;
            this.AlgorithmSection.SelectAlgorithmDropDown.Text=algorithmName;


            selectAlgorithm(getParent(this),alg);
        end
    end

    methods(Abstract)
        enableControls(this)
        disableControls(this)
        disableAllControls(this)
    end

    methods(Abstract,Access=protected)
        createWidgets(this)
        installListeners(this)
    end




    methods(Hidden,Access=public)
        function SelectAlgorithmTestingHook(this,alg)
            repo=this.getAlgorithmRepository();

            evtsrc.Text=alg;
            this.algorithmSelected(repo.AlgorithmList{repo.Names==alg},evtsrc);

        end
    end
end

function iShowROILabelCheckBox(this)

end

function iShowSceneLabelCheckBox(this)

end
