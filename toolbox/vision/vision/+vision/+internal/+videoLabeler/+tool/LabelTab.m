



classdef LabelTab<vision.internal.labeler.tool.LabelTab

    methods(Access=public)

        function this=LabelTab(tool)
            tabName=getString(message('vision:labeler:LabelingTab'));
            this@vision.internal.labeler.tool.LabelTab(tool,tabName);
        end

        function flag=IsAutomateForward(this)
            flag=this.AlgorithmSection.ConfigureTearOff.AutomateForward;
        end

        function algConfig=getAlgorithmConfigurationSettings(this)
            algConfig.AutomateForward=this.AlgorithmSection.ConfigureTearOff.AutomateForward;
            algConfig.StartAtCurrentTime=this.AlgorithmSection.ConfigureTearOff.StartAtCurrentTime;
            algConfig.ImportROIs=this.AlgorithmSection.ConfigureTearOff.ImportROIs;
        end

        function algConfig=getSelectedSignals(this)
            setSelectedDisplay(this);
            algConfig.SelectedSignals=this.AlgorithmSection.SelectSignals.SelectedSignals;
        end

        function enableControls(this)
            this.FileSection.Section.enableAll();
            enableAlgorithmSection(this,true);
            this.ResourcesSection.Section.enableAll();
            this.ViewSection.Section.enableAll();
            this.OpacitySection.Section.enableAll();
            this.LayoutSection.Section.enableAll();
            this.ExportSection.Section.enableAll();
        end

        function disableControlsForPlayback(this)
            this.FileSection.Section.disableAll();
            this.AlgorithmSection.Section.disableAll();
            this.ViewSection.ShowLabelsDropDown.Enabled=false;
            this.ViewSection.ROIColorDropDown.Enabled=false;
            this.ResourcesSection.Section.disableAll();
            this.VisualSummarySection.Section.disableAll();
            this.OpacitySection.Section.disableAll();
            this.ExportSection.Section.disableAll();
        end

        function enableImportAnnotationItems(this)
            this.FileSection.ImportAnnotationsFromFile.Enabled=true;
            this.FileSection.ImportAnnotationsFromWS.Enabled=true;
        end

        function disableControls(this)
            this.FileSection.Section.enableAll();
            this.FileSection.NewSessionButton.Enabled=false;
            this.FileSection.SaveButton.Enabled=false;

            this.AlgorithmSection.Section.disableAll();
            this.ViewSection.ShowLabelsDropDown.Enabled=false;
            this.ViewSection.ROIColorDropDown.Enabled=false;

            this.VisualSummarySection.Section.disableAll();
            this.OpacitySection.Section.disableAll();
            this.ExportSection.Section.disableAll();

            this.ExportSection.ExportAnnotationsToFile.Enabled=false;
            this.ExportSection.ExportAnnotationsToWS.Enabled=false;
        end

        function disableAllControls(this)
            this.FileSection.Section.disableAll();
            this.ViewSection.Section.disableAll();
            this.OpacitySection.Section.disableAll();
            this.AlgorithmSection.Section.disableAll();
            this.VisualSummarySection.Section.disableAll();
            this.ExportSection.Section.disableAll();
            this.LayoutSection.Section.disableAll();
        end

        function enableSignalSelection(this)
            this.AlgorithmSection.SelectSignalsButton.Enabled=true;
        end

        function disableSignalSelection(this)
            this.AlgorithmSection.SelectSignalsButton.Enabled=false;
        end

        function updateSelectedSignals(this,signalsInfo)
            for i=1:numel(signalsInfo)
                this.AlgorithmSection.SelectSignals.SignalList(i).signalName=signalsInfo(i).signalName;
                this.AlgorithmSection.SelectSignals.SignalList(i).isVisible=signalsInfo(i).isVisible;
            end
        end

        function clearSelectedSignals(this)
            this.AlgorithmSection.SelectSignals.SignalList=[];
            this.AlgorithmSection.SelectSignals.PrevActiveSignalIndex=[];
        end

        function signalsInfo=getSelectedSignalsForAutomation(this)
            signalsListInfo=this.AlgorithmSection.SelectSignals.SignalList;
            signalsInfo=[];
            for i=1:numel(signalsListInfo)
                temp.signalName=signalsListInfo(i).signalName;
                temp.isVisible=signalsListInfo(i).isVisible;
                signalsInfo=[signalsInfo,temp];%#ok<AGROW>
            end
        end

        function enableAlgorithmSection(this,flag)
            enableAlgorithmSection@vision.internal.labeler.tool.LabelTab(this,flag);
            if flag&&isMultiSignal(this)
                if numel(this.AlgorithmSection.SelectSignals.SignalList)<2
                    disableSignalSelection(this);
                end
            end
        end

        function enableVisualSummaryDock(this,flag)
            this.LayoutSection.VisualSummaryDockItem.Enabled=flag;
        end

        function setVisualSummaryDockItem(this,flag)
            this.LayoutSection.VisualSummaryDockItem.Value=flag;
        end

        function disableMultisignalButton(this)
            disableMultisignalButton(this.LayoutSection);
        end

        function enableMultisignalButton(this)
            enableMultisignalButton(this.LayoutSection);
        end

        function enableSignalViewDropDownMenu(this,flag)
            enableSignalViewDropDownMenu(this.LayoutSection,flag);
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

            tool=getParent(this);
            multiSignal=strcmpi(vision.internal.videoLabeler.gtlfeature('multiSignalSupport'),'on');

            if tool.isVideoLabeler||~multiSignal
                this.FileSection=vision.internal.videoLabeler.tool.sections.FileSection;
            else
                this.FileSection=vision.internal.labeler.tool.sections.FileSection;
            end

            this.addSectionToTab(this.FileSection);
        end

        function createViewSection(this)
            this.ViewSection=vision.internal.labeler.tool.sections.ViewSection();
            this.addSectionToTab(this.ViewSection);
        end

        function createLayoutSection(this)
            tool=getParent(this);
            this.LayoutSection=vision.internal.videoLabeler.tool.sections.LayoutSection(tool);
            this.addSectionToTab(this.LayoutSection);
        end

        function createAlgorithmSection(this)
            tool=getParent(this);
            this.AlgorithmSection=vision.internal.videoLabeler.tool.sections.AlgorithmSection(tool);
            this.addSectionToTab(this.AlgorithmSection);
        end
    end




    methods(Access=protected)
        function installListeners(this)
            this.installListenersFileSection();
            this.installListenersAlgorithmSection();
            this.installListenersViewSection();
            this.installListenersOpacitySection();
            this.installListenerLayoutDropDown();
            this.installListenerResourcesSection();
            this.installListenersVisualSummarySection();
            this.installListenersLayoutSection();
            this.installListenersExportSection();
            this.installListenersMultisignalLayoutSection();
        end

    end

    methods(Access=private)
        function installListenersFileSection(this)

            tool=getParent(this);
            multiSignal=strcmpi(vision.internal.videoLabeler.gtlfeature('multiSignalSupport'),'on');

            if tool.isVideoLabeler||~multiSignal
                this.FileSection.LoadVideo.ItemPushedFcn=@(es,ed)loadVideo(getParent(this));
                this.FileSection.LoadImageSequence.ItemPushedFcn=@(es,ed)loadImageSequence(getParent(this));
                this.FileSection.LoadCustomReader.ItemPushedFcn=@(es,ed)loadCustomReader(getParent(this));
            else
                this.FileSection.AddSignalsItem.ItemPushedFcn=@(es,ed)addSignals(getParent(this));
            end

            this.FileSection.NewSessionButton.ButtonPushedFcn=@(es,ed)newSession(getParent(this));
            this.FileSection.LoadSessionButton.ButtonPushedFcn=@(es,ed)loadSession(getParent(this));
            this.FileSection.LoadDefinitions.ItemPushedFcn=@(es,ed)loadLabelDefinitionsFromFile(getParent(this));
            this.FileSection.ImportAnnotationsFromFile.ItemPushedFcn=@(es,ed)importLabelAnnotations(getParent(this),'file');
            this.FileSection.ImportAnnotationsFromWS.ItemPushedFcn=@(es,ed)importLabelAnnotations(getParent(this),'workspace');
            this.FileSection.SaveSession.ItemPushedFcn=@(es,ed)saveSession(getParent(this));
            this.FileSection.SaveAsSession.ItemPushedFcn=@(es,ed)saveSessionAs(getParent(this));
        end

        function installListenersAlgorithmSection(this)
            this.AlgorithmSection.SelectAlgorithmDropDown.DynamicPopupFcn=@(es,ed)addAlgorithmPopupList(this);
            if useAppContainer()
                this.AlgorithmSection.ConfigureButton.DynamicPopupFcn=@(es,ed)showConfigureAutomationPopupList(this);
            else
                this.AlgorithmSection.ConfigureButton.ButtonPushedFcn=@(es,ed)showConfigureTearOff(this);
            end
            this.AlgorithmSection.AutomateButton.ButtonPushedFcn=@(es,ed)showAlgorithmTab(this);
            if isMultiSignal(this)
                this.AlgorithmSection.SelectSignalsButton.ButtonPushedFcn=@(es,ed)showSelectSignals(this);
            end
        end

        function installListenerLayoutDropDown(this)
            this.LayoutSection.LayoutButton.DynamicPopupFcn=@(es,ed)getLayoutPopup(this);
        end

        function installListenersMultisignalLayoutSection(this)
            if~useAppContainer()
                this.LayoutSection.MultisignalButton.ButtonPushedFcn=@(es,ed)createMultisignalGrid(this);
            else
                this.LayoutSection.MultisignalButton.ValueChangedFcn=@(es,ed)setSelection(this);
            end
            this.LayoutSection.SignalListDropDownButton.DynamicPopupFcn=@(es,ed)this.addSignalPopupList();
        end

        function popup=getLayoutPopup(this)
            popup=getLayoutPopup(this.LayoutSection);

            if isPopupRefreshed(this.LayoutSection)

                this.LayoutSection.DefaultLayoutItem.ItemPushedFcn=@(es,ed)restoreDefaultLayout(getParent(this),false);

                for i=1:numel(this.LayoutSection.LayoutRepo)
                    fullFileName=this.LayoutSection.LayoutRepo(i);
                    this.LayoutSection.LayoutItems{i}.ItemPushedFcn=@(es,ed)loadLayoutFromFile(this,fullFileName);
                end

                this.LayoutSection.SavedLayoutItem.ItemPushedFcn=@(es,ed)saveLayoutToFile(this);
                this.LayoutSection.VisualSummaryDockItem.ValueChangedFcn=@(es,ed)dockVisualSummary(this);

                setIsRefreshed(this.LayoutSection,false);
            end
        end

        function createMultisignalGrid(this)


            if~isempty(this.LayoutSection.MultisignalGrid)
                delete(this.LayoutSection.MultisignalGrid);
                this.LayoutSection.MultisignalGrid=[];
            end


            usrfcn=@(~,~,hPicker)onSelection(this,hPicker);



            numOccupiedDisplays=9;




            this.LayoutSection.MultisignalGrid=uiservices.DimensionPicker(getSignalFig(getParent(this)),...
            'Callback',usrfcn,...
            'DefaultDimensions',[3,3],...
            'NumOccupiedTiles',numOccupiedDisplays,...
            'AutoGrow',false);


            [xLoc,yLoc]=getDiamtionPickerLocation(this.LayoutSection.MultisignalButton);


            this.LayoutSection.MultisignalGrid.show(xLoc,yLoc);
        end

        function onSelection(this,hPicker)

            createAndPopulateDisplayGrid(getParent(this),...
            hPicker.SelectedDimensions(1),hPicker.SelectedDimensions(2));
        end

        function setSelection(this)
            labelingTool=getParent(this);
            r=this.LayoutSection.MultisignalButton.Selection.row;
            c=this.LayoutSection.MultisignalButton.Selection.column;
            labelingTool.Tool.DocumentGridDimensions=[c,r];
        end

        function saveLayoutToFile(this)
            saveLayoutToFile(getParent(this));
            enableFlag=this.LayoutSection.VisualSummaryDockItem.Enabled;
            refreshLayoutPopup(this.LayoutSection);
            this.LayoutSection.VisualSummaryDockItem.Enabled=enableFlag;
        end

        function loadLayoutFromFile(this,fullFileName)
            loaded=loadLayoutFromFile(getParent(this),fullFileName);
            if~loaded
                refreshLayoutPopup(this.LayoutSection);
                setIsRefreshed(this.LayoutSection,false);
            end
        end

        function dockVisualSummary(this)
            dock=this.LayoutSection.VisualSummaryDockItem.Value;
            dockVisualSummary(getParent(this),dock);
        end

        function showAlgorithmTab(this)

            hide(this.AlgorithmSection.ConfigureTearOff);

            startAutomation(getParent(this));
        end

        function showConfigureTearOff(this)
            show(this.AlgorithmSection.ConfigureTearOff);
        end

        function popup=showConfigureAutomationPopupList(this)
            popup=showConfigureAutomation(this.AlgorithmSection.ConfigureTearOff);
        end

        function showSelectSignals(this)
            activeSignalIndex=setSelectedDisplay(this);
            show(this.AlgorithmSection.SelectSignals,activeSignalIndex);
        end
    end

    methods
        function hideDisplayGrid(this)
            disableMultisignalButton(this.LayoutSection);
        end
    end

    methods(Access=protected)
        function repo=getAlgorithmRepository(this)
            if isVideoLabeler(this)
                repo=vision.internal.labeler.VideoLabelerAlgorithmRepository.getInstance();
            else
                repo=vision.internal.videoLabeler.MultiSignalLabelerAlgorithmRepository.getInstance();
            end

        end

        function tf=isVideoLabeler(this)
            tf=strcmpi(getInstanceName(getParent(this)),'videoLabeler');
        end

    end

    methods(Hidden)
        function selectGrid(this,hPicker)
            if~useAppContainer()
                onSelection(this,hPicker);
            else
                this.LayoutSection.MultisignalButton.Selection=struct(...
                'row',hPicker.SelectedDimensions(1),'column',hPicker.SelectedDimensions(2));
                setSelection(this);
            end
        end

        function activeSignalIndex=setSelectedDisplay(this)
            DisplayManager=getParent(this).DisplayManager;
            isANewDispSelected=DisplayManager.IsANewDispSelected;
            setDispFigSelection(this.AlgorithmSection.SelectSignals,isANewDispSelected)
            selectedDisplay=getSelectedDisplay(DisplayManager);
            for i=1:numel(this.AlgorithmSection.SelectSignals.SignalList)
                isActiveSignal=strcmp(this.AlgorithmSection.SelectSignals.SignalList(i).signalName,selectedDisplay.Name);
                if(isActiveSignal)
                    activeSignalIndex=i;
                    setCurrentSelection(this.AlgorithmSection.SelectSignals,i);
                end
            end
        end
    end




    methods
        function updateSignalList(this,evtData)
            if strcmp(evtData.EventName,'AddedSignals')
                index=numel(this.LayoutSection.SignalList);
                for i=1:numel(evtData.AddedSignals.SignalNames)
                    this.LayoutSection.SignalList(index+i).signalName=...
                    evtData.AddedSignals.SignalNames(i);
                    this.LayoutSection.SignalList(index+i).isVisible=true;
                end
                this.LayoutSection.SignalListModified=true;
            else
                for i=1:numel(evtData.RemovedSignals)
                    index=find(contains([this.LayoutSection.SignalList.signalName],evtData.RemovedSignals(i)),1);
                    this.LayoutSection.SignalList(index)=[];
                end
                this.LayoutSection.SignalListModified=true;
            end

            if isempty(this.LayoutSection.SignalList)
                this.LayoutSection.enableSignalViewDropDownMenu(false);
            else
                this.LayoutSection.enableSignalViewDropDownMenu(true);
            end

            if this.LayoutSection.SignalListModified
                this.refreshSignalPopupList()
            end

        end

        function updateSignalSelectionList(this,evtData)
            if strcmp(evtData.EventName,'AddedSignals')
                if(~isempty(this.AlgorithmSection.SelectSignals))
                    index=numel(this.AlgorithmSection.SelectSignals.SignalList);
                else
                    index=0;
                end
                for i=1:numel(evtData.AddedSignals.SignalNames)
                    this.AlgorithmSection.SelectSignals.SignalList(index+i).signalName=...
                    evtData.AddedSignals.SignalNames(i);
                    this.AlgorithmSection.SelectSignals.SignalList(index+i).isVisible=false;
                end
                this.AlgorithmSection.SelectSignals.SignalListModified=true;
            else
                for i=1:numel(evtData.RemovedSignals)
                    index=find(contains([this.AlgorithmSection.SelectSignals.SignalList.signalName],evtData.RemovedSignals(i)),1);
                    this.AlgorithmSection.SelectSignals.SignalList(index)=[];
                end
                this.AlgorithmSection.SelectSignals.SignalListModified=true;
            end

            if this.AlgorithmSection.SelectSignals.SignalListModified
                this.AlgorithmSection.SelectSignals.updateSelectedSignals();
            end
        end


        function signalList=getSignalList(this)
            signalList=this.LayoutSection.SignalList;
        end


        function refreshSignalPopupList(this)
            import matlab.ui.internal.toolstrip.*;

            if isempty(this.LayoutSection.SignalList)
                return;
            end

            this.LayoutSection.SignalPopupList={};
            for i=1:numel(this.LayoutSection.SignalList)
                this.LayoutSection.SignalPopupList{i}=...
                ListItemWithCheckBox(this.LayoutSection.SignalList(i).signalName);
                this.LayoutSection.SignalPopupList{i}.ShowDescription=false;
                this.LayoutSection.SignalPopupList{i}.Value=...
                this.LayoutSection.SignalList(i).isVisible;
                this.LayoutSection.SignalPopupList{i}.ValueChangedFcn=...
                @(es,ed)signalSelected(this,i);
            end


            this.LayoutSection.SignalPopupList{end+1}=PopupListHeader(vision.getMessage('vision:labeler:AllSignalFunc'));


            this.LayoutSection.SignalPopupList{end+1}=ListItemWithCheckBox(vision.getMessage('vision:labeler:ShowAllSignals'));
            this.LayoutSection.SignalPopupList{end}.ShowDescription=false;


            this.LayoutSection.SignalPopupList{end}.Enabled=...
            any(~[this.LayoutSection.SignalList.isVisible]);
            this.LayoutSection.SignalPopupList{end}.Value=false;
            this.LayoutSection.SignalPopupList{end}.ValueChangedFcn=...
            @(es,ed)showAllSignals(this);
        end


        function popup=addSignalPopupList(this)
            import matlab.ui.internal.toolstrip.*;
            popup=PopupList();
            if this.LayoutSection.SignalListModified
                this.LayoutSection.SignalListDropDownButton.Popup=[];
                for i=1:numel(this.LayoutSection.SignalPopupList)
                    popup.add(this.LayoutSection.SignalPopupList{i})
                end
                this.LayoutSection.SignalListModified=false;
            else
                popup=this.LayoutSection.SignalListDropDownButton.Popup;
            end
        end


        function refreshSignalViewList(this)


            this.LayoutSection.SignalList=[];
            this.LayoutSection.SignalPopupList={};
            this.LayoutSection.SignalListModified=false;
            this.LayoutSection.enableSignalViewDropDownMenu(false);
        end


        function updateSignalsAfterAutomation(this)

            DisplayManager=getParent(this).DisplayManager;
            for i=1:(DisplayManager.NumDisplays-1)

                display=DisplayManager.Displays{i+1};

                if strcmp(display.Fig.Visible,'off')
                    this.LayoutSection.SignalList(i).isVisible=false;
                    this.LayoutSection.SignalPopupList{i}.Value=false;
                else
                    this.LayoutSection.SignalList(i).isVisible=true;
                    this.LayoutSection.SignalPopupList{i}.Value=true;
                end
            end
        end

        function tf=isMultiSignal(this)
            tool=getParent(this);
            tf=isequal(tool.ToolType,vision.internal.toolType.GroundTruthLabeler);
        end
    end

    methods(Access=protected,Hidden)

        function signalSelected(this,index)

            DisplayManager=getParent(this).DisplayManager;
            this.LayoutSection.SignalList(index).isVisible=...
            ~this.LayoutSection.SignalList(index).isVisible;

            i=2;
            while~strcmp(DisplayManager.Displays{i}.Name,...
                this.LayoutSection.SignalPopupList{index}.Text)
                i=i+1;
            end

            displayToHide=DisplayManager.Displays{i};

            tool=getParent(this);
            container=tool.Container;

            if this.LayoutSection.SignalPopupList{index}.Value
                makeSignalVisible(container,displayToHide);
            else
                makeSignalInvisible(container,displayToHide);


                this.LayoutSection.SignalPopupList{end}.Enabled=true;
                this.LayoutSection.SignalPopupList{end}.Value=false;
            end

            if all([this.LayoutSection.SignalList.isVisible])

                this.LayoutSection.SignalPopupList{end}.Enabled=false;
            end
        end

        function showAllSignals(this)

            DisplayManager=getParent(this).DisplayManager;
            for i=1:(DisplayManager.NumDisplays-1)

                display=DisplayManager.Displays{i+1};
                makeFigureVisible(display);



                this.LayoutSection.SignalList(i).isVisible=true;
                this.LayoutSection.SignalPopupList{i}.Value=true;
            end


            this.LayoutSection.SignalPopupList{end}.Enabled=false;

            this.LayoutSection.SignalPopupList{end}.Value=false;
        end
    end
end

function[xLoc,yLoc]=getDiamtionPickerLocation(multisignalButton)
    xLoc=0;
    yLoc=0;


    child=multisignalButton;
    parent=multisignalButton.Parent;
    while~isempty(parent)
        child=parent;
        parent=child.Parent;
    end
    if isa(child,'matlab.ui.internal.toolstrip.Toolstrip')
        Toolstrip=child;
    else
        return;
    end

    if~isempty(Toolstrip.ToolstripSwingService)

        janchor=Toolstrip.ToolstripSwingService.Registry.getWidgetById(multisignalButton.getId());


        buttonLoc=javaMethodEDT('getLocationOnScreen',janchor);
        buttonHeight=javaMethodEDT('getHeight',janchor);

        xLoc=buttonLoc.getX;
        yLoc=buttonLoc.getY+buttonHeight;
    end
end

function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end