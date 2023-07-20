




classdef LabelerTool<vision.internal.labeler.tool.Layout

    properties(Access=protected)



        SupportedROILabelTypes=[labelType.Rectangle...
        ,labelType.Line,labelType.PixelLabel...
        ,labelType.Polygon,labelType.ProjectedCuboid];

NumSignalsForDisplay


        LabelVisibleInternal='hover'

        ROIColorGroup='By Label';

NumRows
NumCols

ShortcutsDialog

        UseAppContainer=true
    end

    properties(GetAccess=public,...
        SetAccess=private,Transient)
Container
    end

    properties(Access=protected,Constant)



        SupportedROISublabelTypes=[labelType.Rectangle,labelType.Line...
        ,labelType.Polygon,labelType.ProjectedCuboid];




        SupportedROIAttributeTypes=[attributeType.Numeric,attributeType.String...
        ,attributeType.Logical,attributeType.List];
    end

    properties(Access=protected)

ToolName



InstanceName



IsUIBusy
    end




    properties

LabelTab


AlgorithmTab


SemanticTab



ActiveTab
    end





    properties
        IsStillRunning=false
        StopRunning=false


        StopAlgRun=true;


AlgorithmSetupHelper
    end




    properties
        DisplayManager;
        AnnotationSummaryManager;
    end




    properties

        ExceptionDialogHandles={};


ComponentBeingDestroyedListener
    end




    properties(Access=protected)

ListenerHandles
    end

    properties(Access=protected)

        IsAppClosing=false;
    end

    properties



        ShowProjCuboidTutorial=true;

        ShowPolygonTutorial=true;

        ShowLabelTypeTutorial=false;
    end


    properties(Hidden)
        FrameChangeFromVisualSummary=false;

        ROILabelDlgRequired=true;
        FrameLabelDlgRequired=true;


        IsCallFromROIInstanceSelection=false;
        IsCallFromFinalize=false;
    end

    properties
ToolType
Tool
    end


    events


ROIUpdated
    end




    methods(Abstract,Access=protected)



        getCurrentIndex(this,varargin)

    end


    methods(Abstract)
        doLoadSession(this)
    end




    methods(Abstract)


        setupSucceeded=tryToSetupAlgorithm(this)


        setupSucceeded=setupAlgorithm(this)


        runAlgorithm(this)


        userCanceled=undorunAlgorithm(this)


        acceptAlgorithm(this,varargin)
    end


    methods(Access=protected)


        function undoRedoQABCallback(this,~,~)
            if isvalid(this)
                canUndo=this.DisplayManager.isUndoAvailable();
                enableQABUndo(this.Container,canUndo)

                canRedo=this.DisplayManager.isRedoAvailable();
                enableQABRedo(this.Container,canRedo)
            end
        end


        function doUndoRedoUpdate(this)
            canUndo=this.DisplayManager.isUndoAvailable();
            enableQABUndo(this.Container,canUndo);

            canRedo=this.DisplayManager.isRedoAvailable();
            enableQABRedo(this.Container,canRedo);
        end


        function disableUndoRedo(this)

            enableQABUndo(this.Container,false)
            enableQABRedo(this.Container,false)
        end

        function setPublishSnapBehavior(this)





            containerName=char(this.GroupName);
            internal.matlab.publish.PublishFigures.setgetContainerNames(containerName);
        end


        function resetFocus(this)

            grabFocus(this.DisplayManager);
        end


        function showModalAlgorithmTab(this,hasReverseAutomation)

            if hasReverseAutomation
                isAutomationFwd=IsAutomateForward(this.LabelTab);
                updateIcons(this.AlgorithmTab,isAutomationFwd);
            end
            show(this.AlgorithmTab);
            hide(this.LabelTab);
            hideContextualSemanticTab(this);
            this.ActiveTab=this.AlgorithmTab;
        end


        function hideModalAlgorithmTab(this)

            show(this.LabelTab);
            hide(this.AlgorithmTab);
            this.ActiveTab=this.LabelTab;
        end


        function showContextualSemanticTab(this)

            show(this.SemanticTab);
            this.ActiveTab=this.SemanticTab;
            this.TabGroup.SelectedTab=getTab(this.SemanticTab);
            drawnow();
        end


        function hideContextualSemanticTab(this)


            semanticTab=getTab(this.SemanticTab);
            if hasTab(this,semanticTab)
                hide(this.SemanticTab);
            end


            labelTab=getTab(this.LabelTab);
            semanticTab=getTab(this.SemanticTab);
            selectedTab=getSelectedTab(this);



            if isempty(selectedTab)||strcmp(labelTab.Tag,selectedTab)||...
                strcmp(semanticTab.Tag,selectedTab)
                this.ActiveTab=this.LabelTab;
            else
                this.ActiveTab=this.AlgorithmTab;
            end
        end


        function finalize(this)
            finalize(this.DisplayManager);
        end




        function closeAllFigures(this)

            this.deleteComponenDestroyListener();
            close(this.ROILabelSetDisplay);
            close(this.FrameLabelSetDisplay);
            close(this.DisplayManager);
            close(this.InstructionsSetDisplay);
            if~isempty(this.AttributesSublabelsDisplay)
                close(this.AttributesSublabelsDisplay);
            end
            close(this.OverviewDisplay);
            close(this.MetadataDisplay);

            close(this.VisualSummaryDisplay);


            isShortCutsDialogOpen=~isempty(this.ShortcutsDialog)&&isvalid(this.ShortcutsDialog);
            if isShortCutsDialogOpen
                close(this.ShortcutsDialog);
            end

            if this.isImageLabeler()
                this.deleteImageBrowser();
                this.closeUifigureDialogs();
            end
            close(this.SignalNavigationDisplay);
        end


        function displayClosing(this,varargin)
            removeDisplayPlus(this,varargin{:});
        end


        function doToolbarButtonChanged(this,~,~)
            selectedDisplay=getSelectedDisplay(this);
            if isempty(selectedDisplay)
                modeSelection='none';
            else
                modeSelection=selectedDisplay.getModeSelection;
            end
            this.setMode(modeSelection);
        end


        function doPasteROIMenuCallback(this,varargin)
            paste(this,varargin)
        end


        function doPastePixelROIMenuCallback(this,varargin)
            pastePixelROI(this,varargin)
        end


        function doCopyPixelROIMenuCallback(this,varargin)
            copyPixelROI(this,varargin)
        end


        function doCutPixelROIMenuCallback(this,varargin)
            cutPixelROI(this,varargin)
        end


        function doDeletePixelROIMenuCallback(this,varargin)
            deletePixelROI(this,varargin)
        end


        function selectedDisplay=getSelectedDisplay(this)

            selectedDisplay=this.DisplayManager.getSelectedDisplay();
        end


        function displayObj=getDisplay(this,name)
            displayObj=getDisplay(this.DisplayManager,name);
        end


        function newROIInfoSet=updateSelectedROIInfo(this,signalName,oldROIInfoSet)

            N=numel(oldROIInfoSet);
...
...
...
...
...
            newROIInfo=struct('LabelName','',...
            'LabelUID','',...
            'Type','');
            newROIInfoSet=repmat(newROIInfo,[N,1]);

            for i=1:N
                oldROIInfo=oldROIInfoSet(i);
                if~isempty(oldROIInfo.UID)
                    newROIInfoSet(i).LabelName=oldROIInfo.LabelName;
                    if isempty(oldROIInfo.SublabelName)
                        newROIInfoSet(i).LabelUID=oldROIInfo.UID;
                    else

                        newROIInfoSet(i).LabelUID=getParentLabelUID(this,...
                        signalName,oldROIInfo.LabelName,...
                        oldROIInfo.SublabelName,oldROIInfo.UID);
                    end
                end
            end
        end

        function deselectROIInstances(this)

            selectedDisplay=getSelectedDisplay(this);
            selectedDisplay.deselectROIInstances();
            updateAttributesSublabelsPanelIfNeeded(this);

        end

    end

    methods

        function n=get.NumSignalsForDisplay(this)
            n=this.DisplayManager.NumDisplays-1;
        end
    end




    methods(Access=protected)


        function configureCutCopyCallbacks(this,display)

            display.configureCutCallback(@this.cut);
            display.configureCopyCallback(@this.copy);
            display.configureDeleteCallback(@this.deleteroi);
        end

        function configurePolygonCallbacks(this,display)

            display.configurePolygonSendToBackCallback(@this.sendPolygonToBack);
            display.configurePolygonBringToFrontCallback(@this.bringPolygonToFront)
        end


        function copy(this,varargin)



            selectedDisplay=getSelectedDisplay(this);
            signalName=selectedDisplay.Name;
            this.DisplayManager.setCopyDisplayName_ROI(signalName);


            selectedDisplay.Clipboard.purge();

            enablePasteFlag=selectedDisplay.copySelectedROIs();

            if~selectedDisplay.IsCuboidSupported
                copiedROIsTypes=selectedDisplay.copiedROIsType();
            else
                copiedROIsTypes=getString(message('vision:trainingtool:PastePopup'));
            end

            setPasteMenuState(this.DisplayManager,selectedDisplay.SignalType,...
            copiedROIsTypes,enablePasteFlag);


            numCopiedROIs=length(selectedDisplay.Clipboard.CopiedROIs);
            frameIdx=getLastReadFrameIdx(this,signalName);

            for idx=1:numCopiedROIs
                thisROI=selectedDisplay.Clipboard.CopiedROIs{idx};
                if~isempty(thisROI.parentName)

                    [hasAttributes,names,values]=this.Session.ROIAnnotations.getAttributeDataForThisSublabelROI(signalName,thisROI.parentName,thisROI.Label,thisROI.selfUID,frameIdx);
                    if hasAttributes
                        selectedDisplay.Clipboard.CopiedROIs{idx}.AttributeNames=names;
                        selectedDisplay.Clipboard.CopiedROIs{idx}.AttributeValues=values;
                    else
                        selectedDisplay.Clipboard.CopiedROIs{idx}.AttributeNames={''};
                        selectedDisplay.Clipboard.CopiedROIs{idx}.AttributeValues={''};
                    end
                else

                    [hasAttributes,names,values]=this.Session.ROIAnnotations.getAttributeDataForThisLabelROI(signalName,thisROI.Label,thisROI.selfUID,frameIdx);
                    if hasAttributes
                        selectedDisplay.Clipboard.CopiedROIs{idx}.AttributeNames=names;
                        selectedDisplay.Clipboard.CopiedROIs{idx}.AttributeValues=values;
                    else
                        selectedDisplay.Clipboard.CopiedROIs{idx}.AttributeNames={''};
                        selectedDisplay.Clipboard.CopiedROIs{idx}.AttributeValues={''};
                    end
                end
            end
        end


        function paste(this,varargin)


















            toDisplay=getSelectedDisplay(this);
            toSignalName=toDisplay.Name;


            fromDisplay=this.DisplayManager.getCopyDisplay_ROI();
            if isempty(fromDisplay)
                return;
            end


            if~isa(toDisplay,class(fromDisplay))





                return;
            end


            fromDisplay.Clipboard.refreshUIDs();
            this.DisplayManager.pasteSelectedROIs(fromDisplay,toDisplay);

            numCopiedROIs=length(fromDisplay.Clipboard.CopiedROIs);
            copiedROIs=fromDisplay.Clipboard.CopiedROIs;
            frameIdx=getLastReadFrameIdx(this,toSignalName);


            for idx=1:numCopiedROIs
                thisROI=copiedROIs{idx};

                if isempty(thisROI)

                    continue
                end

                for attrIdx=1:numel(thisROI.AttributeNames)
                    attribData.AttributeName=thisROI.AttributeNames{attrIdx};
                    attribData.AttributeValue=thisROI.AttributeValues{attrIdx};
                    if~isempty(thisROI.parentName)

                        if~isempty(attribData.AttributeName)
                            this.Session.ROIAnnotations.updateAttributeAnnotation(...
                            toSignalName,frameIdx,thisROI.selfUID,thisROI.parentName,thisROI.Label,attribData);
                            updateAttributesSublabelsPanel(this);
                        end
                    else

                        if~isempty(attribData.AttributeName)
                            this.Session.ROIAnnotations.updateAttributeAnnotation(...
                            toSignalName,frameIdx,thisROI.selfUID,thisROI.Label,'',attribData);
                            updateAttributesSublabelsPanel(this);
                        end
                    end
                end
            end
        end


        function doCopyDisplayNameCallbackForPixelROI(this,varargin)

            selectedDisplay=getSelectedDisplay(this);
            signalName=selectedDisplay.Name;
            this.DisplayManager.setCopyDisplayName_PixelROI(signalName);
        end


        function copyPixelROI(this,varargin)



            selectedDisplay=getSelectedDisplay(this);
            signalName=selectedDisplay.Name;
            this.DisplayManager.setCopyDisplayName_PixelROI(signalName);

            enablePixPasteFlag=selectedDisplay.allowPastePixel();
            if enablePixPasteFlag
                selectedDisplay.copyPixelROIs();
            end

            setPixPasteMenuState(this.DisplayManager,selectedDisplay.SignalType,enablePixPasteFlag);
        end


        function deletePixelROI(this,varargin)
            selectedDisplay=getSelectedDisplay(this);
            selectedDisplay.deletePixelROI();
        end


        function cutPixelROI(this,varargin)
            selectedDisplay=getSelectedDisplay(this);


            this.copyPixelROI();
            selectedDisplay.deletePixelROI();
        end


        function updatePastePixelContextMenu(this)
            fromDisplay=this.DisplayManager.getCopyDisplay_PixelROI();
            if isempty(fromDisplay)
                return;
            end
            enablePixPasteFlag=fromDisplay.pastePixelFlag();
            setPixPasteMenuState(this.DisplayManager,fromDisplay.SignalType,enablePixPasteFlag);
        end


        function pastePixelROI(this,varargin)



















            toDisplay=getSelectedDisplay(this);



            fromDisplay=this.DisplayManager.getCopyDisplay_PixelROI();
            if isempty(fromDisplay)
                return;
            end


            if~isa(toDisplay,class(fromDisplay))





                return;
            end


            fromDisplay.Clipboard.refreshUIDs();
            this.DisplayManager.pastePixelROIs(fromDisplay,toDisplay);
        end


        function cut(this,varargin)


            selectedDisplay=getSelectedDisplay(this);

            this.copy();
            selectedDisplay.deleteSelectedROIs();
            this.Session.IsChanged=true;
        end


        function deleteroi(this,varargin)


            selectedDisplay=getSelectedDisplay(this);

            selectedDisplay.deleteSelectedROIs();
            this.Session.IsChanged=true;
        end





        function doLabelIsChanged(this,~,data)




            selectedDisplay=getSelectedDisplay(this);
            if isempty(selectedDisplay)
                return;
            end

            signalName=selectedDisplay.Name;



            if isa(data,'vision.internal.labeler.tool.PixelLabelEventData')


                if hasPixelLabels(this.Session)
                    signalName=data.Source.Name;
                    if data.UpdateUndoRedo

                        currentIndex=getCurrentFrameIndex(this,signalName);
                        currentROIs=selectedDisplay.getCurrentROIs();
                        selectedDisplay.updateUndoOnLabelChange(currentIndex,currentROIs,...
                        vision.internal.labeler.tool.LabelTypeUndoRedo.PixelLabel);
                    end
                    updatePixelLabelAnnotations(this,signalName,data.Data);
                    if~isempty(this.VisualSummaryDisplay)&&isvalid(this.VisualSummaryDisplay)
                        updateVisualSummaryROICount(this,signalName,[],data);
                    end
                end


            elseif isa(data,'vision.internal.labeler.tool.ROILabelEventData')



                currentROIs=selectedDisplay.getCurrentROIs();
                currentROIs=deleteOrphanSublabelInstances(this,selectedDisplay,currentROIs);

                currentIndex=getCurrentFrameIndex(this,signalName);


                selectedDisplay.updateUndoOnLabelChange(currentIndex,currentROIs,...
                vision.internal.labeler.tool.LabelTypeUndoRedo.ShapeLabel);
                updateSessionForGivenROIs(this,selectedDisplay,currentROIs,data);
                if~isempty(this.VisualSummaryDisplay)&&isvalid(this.VisualSummaryDisplay)
                    updateVisualSummaryROICount(this,signalName,[],data);
                end
            else








            end

            doROIInstanceIsSelected(this);
            updateProjectedViewStatus(this);
        end


        function doFigKeyPress(this,~,src)






            selectedDisplay=getSelectedDisplay(this);
            isADisplaySelected=~isempty(selectedDisplay);
            if isADisplaySelected&&selectedDisplay.isLabelerInitialized()
                UserIsDrawing=selectedDisplay.getUserIsDrawing();
            else
                UserIsDrawing=false;
            end

            if UserIsDrawing
                return;
            end

            modifierKeys={'control','command'};

            keyPressed=src.Key;
            modPressed=src.Modifier;

            if strcmp(modPressed,modifierKeys{ismac()+1})
                switch keyPressed
                case 'a'

                    if isADisplaySelected
                        selectedDisplay.selectAllROIs();
                    end
                case 'c'
                    if isADisplaySelected
                        this.copy(selectedDisplay);
                    end
                case 'v'
                    if isADisplaySelected&&~isInRunLoop(this)
                        this.paste(selectedDisplay);
                    end
                case 'x'
                    if isADisplaySelected
                        this.cut(selectedDisplay);
                    end
                case 'y'
                    if isADisplaySelected
                        this.redo(selectedDisplay);
                    end
                case 'z'
                    if isADisplaySelected
                        this.undo(selectedDisplay);
                    end
                case 's'
                    this.saveSession();
                case 'o'
                    this.loadSession();
                case{'uparrow','downarrow','rightarrow','leftarrow'}
                    if isADisplaySelected
                        selectedDisplay=getSelectedDisplay(this);
                        roiInfo=selectedDisplay.selectROIInfo(this);
                        keyPressed=src.Key;
                        selectedDisplay.moveSelectedROI(roiInfo,keyPressed);
                    end
                case{'add','equal','subtract','hyphen'}
                    if isADisplaySelected
                        selectedDisplay=getSelectedDisplay(this);
                        roiInfo=selectedDisplay.selectROIInfo(this);
                        keyPressed=src.Key;
                        selectedDisplay.reshapeRectROI(roiInfo,keyPressed);
                    end
                otherwise
                    signalNavigationKeyPress(this,src);
                end
            else
                isAltPressed=strcmp(modPressed,'alt');

                if~this.IsUIBusy
                    this.IsUIBusy=true;
                    freeAfterComplete=onCleanup(@()freeUI(this));
                    if isAltPressed
                        switch keyPressed
                        case 'uparrow'
                            this.previousFrameLabelSelectionCallback();
                        case 'downarrow'
                            this.nextFrameLabelSelectionCallback();
                        otherwise
                            signalNavigationKeyPress(this,src);
                        end
                    else
                        isShiftPressed=strcmp(modPressed,'shift');

                        if isShiftPressed
                            if strcmp(keyPressed,'tab')&&isADisplaySelected
                                selectedDisplay.selectROIreverse();
                            else
                                switch keyPressed
                                case 'uparrow'
                                    pan(selectedDisplay,'down');
                                case 'downarrow'
                                    pan(selectedDisplay,'up');
                                case 'rightarrow'
                                    pan(selectedDisplay,'left');
                                case 'leftarrow'
                                    pan(selectedDisplay,'right');
                                otherwise
                                    signalNavigationKeyPress(this,src);
                                end
                            end
                        else
                            switch keyPressed
                            case 'uparrow'
                                this.previousROIPanelItemSelectionCallback();
                            case 'downarrow'
                                this.nextROIPanelItemSelectionCallback();
                            case{'delete','backspace'}
                                if isADisplaySelected
                                    selectedDisplay.deleteSelectedROIs();
                                    this.Session.IsChanged=true;
                                end
                            case 'tab'
                                if isADisplaySelected
                                    selectedDisplay.selectROI();
                                end
                            case 'return'
                                finalize(this);
                            otherwise
                                signalNavigationKeyPress(this,src);
                            end
                        end
                    end
                end




                if(numel(modPressed)~=2)||this.isInAlgoMode()
                    return;
                end
                if strcmp(modPressed{2},modifierKeys{ismac()+1})&&...
                    strcmp(modPressed{1},'shift')
                    switch keyPressed
                    case 'c'
                        copyPixelROI(this);
                        drawnow('limitrate');
                    case 'v'
                        pastePixelROI(this);
                        drawnow('limitrate');
                    case 'x'
                        cutPixelROI(this)
                        drawnow('limitrate');
                    case 'delete'
                        deletePixelROI(this);
                        drawnow('limitrate');
                    case 'equal'
                        if isADisplaySelected
                            selectedDisplay=getSelectedDisplay(this);
                            roiInfo=selectedDisplay.selectROIInfo(this);
                            keyPressed=src.Key;
                            selectedDisplay.reshapeRectROI(roiInfo,keyPressed);
                        end
                    end
                end
            end
        end


        function freeUI(this)
            this.IsUIBusy=false;
        end


        function nextFrameLabelSelectionCallback(this,varargin)

            this.FrameLabelSetDisplay.selectNextItem();
        end


        function previousFrameLabelSelectionCallback(this,varargin)

            this.FrameLabelSetDisplay.selectPrevItem();
        end


        function deleteROIwithUID(~,display,uid)
            display.deleteROIwithUID(uid);
        end


        function[validLabelUIDs,isSublabels]=getValidLabelNames(~,currentROIs)
            labelUIDs={currentROIs.ID};
            isSublabels=~cellfun(@isempty,{currentROIs.ParentName});
            validLabelUIDs=labelUIDs(~isSublabels);
        end


        function currentROIs=deleteOrphanSublabelInstances(this,display,currentROIs)
            [validLabelUIDs,isSublabels]=getValidLabelNames(this,currentROIs);

            orphanROI=[];
            hasOrphanSublabel=false;
            for i=1:numel(currentROIs)
                thisROI=currentROIs(i);
                if isSublabels(i)&&~contains(thisROI.ParentUID,validLabelUIDs)

                    deleteROIwithUID(this,display,thisROI.ID);
                    hasOrphanSublabel=true;
                    orphanROI=[orphanROI,i];
                end
            end

            if hasOrphanSublabel
                this.Session.IsChanged=true;
                currentROIs(orphanROI)=[];
            end
        end


        function doROIInstanceIsSelected(this,varargin)









            setSingleSelectedROIInstanceParentUID(this);



            selectedItemInfo=getSelectedItemInfo(this);
            roiItemDataObj=selectedItemInfo.roiItemDataObj;





            if~this.IsCallFromFinalize
                this.modifyLabelDefinitionSelection(roiItemDataObj);
            end

            selectedItemInfo=getSelectedItemInfo(this);

            isAnyItemSelected=selectedItemInfo.isAnyItemSelected;
            isPixelLabelItemSelected=selectedItemInfo.isPixelLabelItemSelected;
            isLabelSelected=selectedItemInfo.isLabelSelected;
            isGroupItemSelected=selectedItemInfo.isGroup;

            controlVisOfSublabelAttribCreateButtons(this,isAnyItemSelected,...
            isPixelLabelItemSelected,isLabelSelected,isGroupItemSelected);



            selectedDisplay=getSelectedDisplay(this);
            if isempty(selectedDisplay)
                return;
            end
            selectedDisplay.highlightChildrenOrParent();
            updateAttributesSublabelsPanelIfNeeded(this);

            setModeROIorNone(this,selectedItemInfo);


            if isprop(selectedDisplay,'ProjectedView')
                updateProjectedViewStatus(this);
            end
        end


        function newDisplay=addNewDisplayAsTab(this,dispType,signalName)
            toolType=getToolType(this);

            addNewSignalFigure(this.Container,signalName);
            thisFig=getSignalFigureByName(this.Container,signalName);

            newDisplay=this.DisplayManager.createAndAddDisplay(thisFig,dispType,toolType,signalName);


            setLabelVisiblity(newDisplay,this.LabelVisibleInternal);

            if newDisplay.IsPixelSupported


                globalColorLookupTable=this.Session.ROILabelSet.pixelColorLookupGlobal;
                updatePixelLabelerLookupNewDisplay(newDisplay,globalColorLookupTable);



                globalPixelLabelVisibility=this.Session.getGlobalPixelLabelVisibility();
                updatePixelLabelVisibilityDisplay(newDisplay,globalPixelLabelVisibility);
            end


            noCloseButton=true;

            addNewDisplayAsTabInLayout(this,newDisplay,noCloseButton);

            newDisplay.resizeFigure();


            customSource=true;
            addSource(newDisplay,signalName,customSource);
            newDisplay.installContextMenu(this.isInAlgoMode(),this.Session.getNumPixelLabels);


            newDisplay.initializePixelLabeler();
            configureCutCopyCallbacks(this,newDisplay);

            if newDisplay.IsPixelSupported

                configurePolygonCallbacks(this,newDisplay);
            end

            if dispType==displayType.PointCloud
                wireUpLidarListeners(this,newDisplay);
            end

        end




        function updateToolstrip(this)


            anyROIOrFrameLabels=this.Session.HasROILabels||this.Session.HasFrameLabels;


            anyCustomLabels=hasCustomDisplay(this)&&...
            ~isempty(this.ConnectorInstance.LabelName);

            if this.AreSignalsLoaded


                visible=true;
                changeToolbarVisibility(this,visible);


                enableControls(this.LabelTab);
                enableControls(this.AlgorithmTab);
                enableControls(this.SemanticTab);

                setModeROIorNone(this);

                enableShowLabelBoxes(this.LabelTab,...
                this.Session.hasShapeLabels);
                enableShowLabelBoxes(this.AlgorithmTab,...
                this.Session.hasShapeLabels);

                enableROIColor(this.LabelTab,...
                this.Session.hasShapeLabels);
                enableROIColor(this.AlgorithmTab,...
                this.Session.hasShapeLabels);

                enablePolygonOpacitySlider(this.LabelTab,...
                this.Session.hasPolygonLabels);
                enablePixelOpacitySlider(this.LabelTab,...
                this.Session.hasPixelLabels);



                this.LabelTab.enableAlgorithmSection(anyROIOrFrameLabels);
                this.LabelTab.enableExportSection(anyROIOrFrameLabels||anyCustomLabels);


                if isImageLabeler(this)
                    onlyOneImage=(getNumImages(this.Session)==1);
                    updateVisualSummaryButton(this,~onlyOneImage);
                else
                    updateVisualSummaryButton(this);
                end

                if anyROIOrFrameLabels
                    doROIInstanceIsSelected(this);
                end

            else

                visible=false;
                changeToolbarVisibility(this,visible);

                disableControls(this.LabelTab);
                disableControls(this.SemanticTab);
            end

            if isImageLabeler(this)

                enableImportAnnotationsButton(this.LabelTab,true);
            else

                if~this.IsVideoLabeler
                    controlLidarTabVisibility(this);
                    updateColormapSection(this);
                end
            end


            if anyROIOrFrameLabels||anyCustomLabels
                enableSaveLabelDefinitionsItem(this.LabelTab,true);
                enableNewAndSaveSessionItems(this.LabelTab);
            else
                enableSaveLabelDefinitionsItem(this.LabelTab,false);
            end

            isVisualSummaryOpen=~isempty(this.VisualSummaryDisplay)...
            &&isvalid(this.VisualSummaryDisplay);

            if isVisualSummaryOpen
                enableVisualSummaryDock(this.LabelTab,true);
            else
                enableVisualSummaryDock(this.LabelTab,false);
            end


            if this.Session.HasFrameLabels&&this.AreSignalsLoaded&&...
                this.FrameLabelSetDisplay.isValidItemSelected()
                this.FrameLabelSetDisplay.unfreezeOptionPanel();
            else
                labelIDs=[];
                this.FrameLabelSetDisplay.freezeOptionPanel();
                this.FrameLabelSetDisplay.updateFrameLabelStatus(labelIDs);
            end


            if this.isInAlgoMode&&this.Session.HasFrameLabels
                this.FrameLabelSetDisplay.freezeOptionPanel();
            end


            if~hasPixelLabels(this.Session)
                hideContextualSemanticTab(this);
            end

            isRangeSliderAvailable=(this.DisplayManager.NumDisplays>1);
            multiSignal=strcmpi(vision.internal.videoLabeler.gtlfeature('multiSignalSupport'),'on');
            if~isRangeSliderAvailable&&~(isImageLabeler(this))&&multiSignal
                hideDisplayGrid(this.LabelTab);
            end

            if~isImageLabeler(this)
                if this.ShowLidarTutorial
                    createLidarTutorialDialog(this);
                end
            end

            if this.ShowProjCuboidTutorial
                createProjectedCuboidTutorialDialog(this);
            end

            if this.ShowPolygonTutorial
                createPolygonTutorialDialog(this);
            end


            for i=2:numel(this.DisplayManager.Displays)
                selDisplay=this.DisplayManager.Displays{i};
                if isprop(selDisplay,'ProjectedView')
                    updateProjectedViewStatus(this);
                end
            end
            if~isImageLabeler(this)&&~this.IsVideoLabeler
                if~isempty(this.ProjectedViewDisplay)
                    if isvalid(this.ProjectedViewDisplay)



                        disableMultisignalButton(this.LabelTab);
                        enableSignalViewDropDownMenu(this.LabelTab,false);
                    end
                end
            end
        end





        function changeToolbarVisibility(this,visible)
            allDisplays=this.DisplayManager.getDisplays();
            for ii=2:numel(allDisplays)
                iiDisplay=allDisplays{ii};
                changeToolbarVisibility(iiDisplay,visible);
                setToolbarButtonChangedCallback(iiDisplay,@this.doToolbarButtonChanged);
            end
        end

    end




    methods(Access=public)


        function this=LabelerTool(title,instanceName)
            if nargin==0
                return;
            end


            [~,name]=fileparts(tempname);

            this.UseAppContainer=useAppContainer();
            wireUpContainer(this,title,name);
            createToolstripTabGroup(this,name);


            addTabs(this.Container,this.TabGroup);




            addContainerListeners(this.Container);

            this.ToolName=title;
            this.Tool=this.Container.App;
            this.ToolType=getToolType(this);
            this.InstanceName=instanceName;
            this.GroupName=getGroupName(this);

            if~this.UseAppContainer
                this.APP=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            end


            this.IsUIBusy=false;
        end


        function loadSession(this)




            isCanceled=this.processSessionSaving();
            if isCanceled
                return;
            end

            selectFileTitle=vision.getMessage('vision:uitools:SelectFileTitle');


            persistent fileDir;

            if isempty(fileDir)||~exist(fileDir,'dir')
                fileDir=pwd();
            end

            [fileName,pathName,userCanceled]=...
            vision.internal.labeler.tool.uigetmatfile(fileDir,selectFileTitle);


            if userCanceled||isempty(fileName)
                return;
            else

                fileDir=pathName;
            end

            this.setStatusText(vision.getMessage('vision:labeler:LoadSessionStatus',fileName));

            this.deleteComponenDestroyListener();
            this.doLoadSession(pathName,fileName);

            this.setStatusText('');

        end


        function success=saveSession(this,fileName)


            if nargin<2
                if isempty(this.Session.FileName)||~exist(this.Session.FileName,'file')
                    fileName=vision.internal.uitools.getSessionFilename(...
                    this.SessionManager.DefaultSessionFileName);
                    if isempty(fileName)
                        success=false;
                        return;
                    end
                else
                    fileName=this.Session.FileName;
                end
            end

            if hasPixelLabels(this.Session)
                finalize(this);
            end
            hFig=getDefaultFig(this.Container);
            success=saveSession(this.SessionManager,this.Session,fileName,hFig);

            if hasShapeLabels(this.Session)
                verfiyROIVisibility(this.Session);
            end

            if success
                progressDlgTitle=vision.getMessage('vision:labeler:SavingSessionTitle');
                pleaseWaitMsg=vision.getMessage('vision:labeler:PleaseWait');
                waitBarObj=vision.internal.labeler.tool.ProgressDialog(hFig,...
                progressDlgTitle,pleaseWaitMsg);

                savingSessionMsg=vision.getMessage('vision:labeler:SavingSession');
                [~,fileName]=fileparts(fileName);

                waitBarObj.setParams(0.33,savingSessionMsg);
                titleStr=getString(message(...
                'vision:labeler:ToolTitleWithSession',this.ToolName,fileName));
                setTitleBar(this,titleStr);

                this.Session.IsChanged=false;

                this.setStatusText(vision.getMessage('vision:labeler:SaveSessionStatus',fileName));
                close(waitBarObj);
            end

        end


        function saveSessionAs(this)

            fileName=vision.internal.uitools.getSessionFilename(...
            this.SessionManager.DefaultSessionFileName);
            if~isempty(fileName)
                [pathstr,name,~]=fileparts(fileName);
                sessionPath=fullfile(pathstr,[name,'_SessionData']);

                if isfolder(sessionPath)
                    rmdir(sessionPath,'s');
                end

                setIsPixelLabelChangedAll(this.Session);

                this.saveSession(fileName);
                this.Session.IsChanged=false;
            end

        end


        function show(this)

            wait(this.Container);


            this.hideModalAlgorithmTab();


            this.hideContextualSemanticTab();


            makeVisibleAtPos(this.Container);



            addOverviewFigure=false;
            addMetadataFigure=false;
            if this.isImageLabeler()
                addOverviewFigure=true;
                addMetadataFigure=true;
            end

            tmpWaitFor(this.Container);
            addFigures(this.Container,addOverviewFigure,addMetadataFigure);

            try
                setupDocContainedObjs(this);


                this.updateToolstrip();


                this.createDefaultLayoutAtLoad();

                drawnow();


                resume(this.Container);
            catch exception

                if~this.IsAppClosing
                    rethrow(exception)
                end
            end
        end




        function[labelUID,labelNames,roiPositions,roiColors,roiShapes]=...
            updateROIsAnnotations(this,signalName,roiLabelData,varargin)


            selfUIDs={roiLabelData.ID};
            parentUIDs={roiLabelData.ParentUID};
            roiNames={roiLabelData.Label};
            parentRoiNames={roiLabelData.ParentName};
            roiPositions={roiLabelData.Position};
            roiColors={roiLabelData.Color};
            roiShapes=[roiLabelData.Shape];


            frameIdx=getCurrentIndex(this,signalName);

            numROIs=numel(selfUIDs);

            labelNames=cell(numROIs,1);
            sublabelNames=cell(numROIs,1);
            labelUID=cell(numROIs,1);
            sublabelUID=cell(numROIs,1);

            isLabels=cellfun(@isempty,parentUIDs);
            for i=1:numROIs
                if isLabels(i)
                    labelUID{i}=selfUIDs{i};
                    sublabelUID{i}='';

                    labelNames{i}=roiNames{i};
                    sublabelNames{i}='';
                else
                    labelUID{i}=parentUIDs{i};
                    sublabelUID{i}=selfUIDs{i};

                    labelNames{i}=parentRoiNames{i};
                    sublabelNames{i}=roiNames{i};
                end
            end


            this.Session.addROILabelAnnotations(signalName,frameIdx,...
            labelNames,sublabelNames,labelUID,sublabelUID,roiPositions,varargin{:});

            this.Session.IsChanged=true;
        end


        function updatePixelLabelAnnotations(this,signalName,labelData)

            thisDisplay=this.DisplayManager.getDisplay(signalName);


            if isempty(this.Session.TempDirectory)

                foldername=setTempDirectory(this);
            else
                isFileNoPath=(isempty(regexp(labelData.Position,'/','once'))&&...
                isempty(regexp(labelData.Position,'\','once')));

                if isFileNoPath
                    foldername=this.Session.TempDirectory;
                else
                    foldername=[];
                end
            end

            if~isempty(foldername)

                labelData.Position=fullfile(foldername,labelData.Position);
                setLabelMatrixFilename(thisDisplay,labelData.Position);
            end



            labelNames=labelData.Label;
            labelPositions=labelData.Position;
            index=labelData.Index;
            signalName4Tool=getConvertedSignalName(this,signalName);
            TF=writeData(this.Session,signalName4Tool,labelNames,index);




            if~TF
                oldDirectory=this.Session.TempDirectory;
                [~,name]=fileparts(tempname);
                foldername=vision.internal.labeler.tool.selectDirectoryDialog(name);
                if~isempty(foldername)

                    labelData.Position=fullfile(foldername,labelData.Position);
                    setLabelMatrixFilename(thisDisplay,labelData.Position);
                end
                setTempDirectory(this.Session,foldername);
                importPixelLabelData(this.Session);
                if isfolder(oldDirectory)
                    rmdir(oldDirectory,'s');
                end
                writeData(this.Session,signalName4Tool,labelNames,index);
            end


            setPixelLabelAnnotation(this.Session,signalName4Tool,index,labelPositions);
        end


        function LabelUID=getParentLabelUID(this,signalName,labelName,...
            sublabelName,sublabelUID)
            frameIdx=getCurrentIndex(this,signalName);
            LabelUID=this.Session.getParentLabelUID(signalName,frameIdx,...
            labelName,sublabelName,sublabelUID);
        end


        function num=getNumSublabelInstances(this,signalName,labelName,...
            labelUID,sublabelNames)
            frameIdx=getCurrentIndex(this,signalName);
            num=this.Session.queryNumSublabelInstances(signalName,...
            frameIdx,labelName,labelUID,sublabelNames);
        end


        function attribInstanceData=getAttributeInstanceValue(this,...
            signalName,roiUID,attribDefData)

            frameIdx=getCurrentIndex(this,signalName);


            attribInstanceData=this.Session.getAttributeInstanceValue(...
            signalName,frameIdx,roiUID,attribDefData);
        end


        function updateAnnotationsForAttributesValue(this,signalName,...
            roiUID,labelNames,sublabelNames,attributeData)

            frameIdx=getCurrentIndex(this,signalName);


            this.Session.updateAnnotationsForAttributesValue(signalName,...
            frameIdx,roiUID,labelNames,sublabelNames,attributeData);

            this.Session.IsChanged=true;
        end


        function updateAttribAnnotationAtAttribCreation(this,attribData)
            this.Session.updateAttribAnnotationAtAttribCreation(attribData);
        end




        function foldername=setTempDirectory(this)

            [~,name]=fileparts(tempname);
            foldername=[tempdir,'Labeler_',name];

            status=mkdir(foldername);
            if~status
                foldername=vision.internal.labeler.tool.selectDirectoryDialog(name);
            end

            setTempDirectory(this.Session,foldername);
        end


        function name=getInstanceName(this)
            name=this.InstanceName;
        end


        function reconfigureROILabelSetDisplay(this)

            if this.Session.NumROILabels>=1
                hideHelperText(this.ROILabelSetDisplay);
            end


            this.ROILabelSetDisplay.selectItem(1);
            this.ROILabelSetDisplay.deleteAllItems();

            addedGroupNames={};

            for n=1:this.Session.NumROILabels


                roiLabel=this.Session.queryROILabelData(n);
                data.Label=roiLabel;
                data.Label.IsRectCuboid=any(this.SupportedROILabelTypes==labelType.Cuboid);


                data.IsNewGroup=~any(ismember(addedGroupNames,roiLabel.Group));
                addedGroupNames(end+1)={roiLabel.Group};%#ok<AGROW>
                currItemIdx=addLabelAndGroupItems(this.ROILabelSetDisplay,data,...
                this.Session.ROILabelSet);


                labelName=roiLabel.Label;
                labelAttribs=this.Session.queryROIAttributeFamilyData(labelName,'');

                for i=1:numel(labelAttribs)
                    this.ROILabelSetDisplay.appendItemAttribute(labelAttribs{i}.Name,currItemIdx);
                end


                roiSubabels=this.Session.queryROISublabelFamilyData(labelName);
                for i=1:numel(roiSubabels)


                    thisSublabel=roiSubabels{i};
                    idxInsertAfter=currItemIdx;
                    this.ROILabelSetDisplay.insertItem(thisSublabel,idxInsertAfter);
                    currItemIdx=currItemIdx+1;


                    sublabelName=thisSublabel.Sublabel;
                    sublabelAttribs=this.Session.queryROIAttributeFamilyData(labelName,sublabelName);
                    for j=1:numel(sublabelAttribs)
                        this.ROILabelSetDisplay.appendItemAttribute(sublabelAttribs{j}.Name,currItemIdx);
                    end
                end

            end

            if this.Session.NumROILabels>=1
                this.ROILabelSetDisplay.selectLastItem();
            end
            this.ROILabelSetDisplay.updateItem();

            updateDataOnItemMove(this.ROILabelSetDisplay);
        end


        function reconfigureFrameLabelSetDisplay(this)

            if this.Session.NumFrameLabels>=1
                hideHelperText(this.FrameLabelSetDisplay);
            end


            this.FrameLabelSetDisplay.deleteAllItems();

            addedGroupNames={};

            for n=1:this.Session.NumFrameLabels
                frameLabel=this.Session.queryFrameLabelData(n);
                data.Label=frameLabel;


                data.IsNewGroup=~any(ismember(addedGroupNames,frameLabel.Group));
                addedGroupNames(end+1)={frameLabel.Group};%#ok<AGROW>
                addLabelAndGroupItems(this.FrameLabelSetDisplay,data,...
                this.Session.FrameLabelSet);
                this.FrameLabelSetDisplay.selectLastItem();
            end

            this.FrameLabelSetDisplay.updateItem();


            idx=getCurrentIndex(this);
            if~isempty(idx)
                [~,~,labelIDs]=this.Session.queryFrameLabelAnnotation(idx);
                updateFrameLabelStatus(this.FrameLabelSetDisplay,labelIDs);
            end
        end


        function updateSessionWithROIsAnnotationsCore(this,display,...
            notifyExternal,rois,recomputeCurrentROI,actType)

            import vision.internal.labeler.tool.actionType
            signalName=display.Name;
            assert(actType~=actionType.Skip);
            if(actType==actionType.Append)
                updateROIsAnnotations(this,signalName,rois,true);
            else
                updateROIsAnnotations(this,signalName,rois);
            end

            if notifyExternal
                if recomputeCurrentROI
                    currentROIs=display.getCurrentROIs();
                else
                    currentROIs=rois;
                end

                evtData=vision.internal.videoLabeler.tool.ROIUpdatedEvent(currentROIs);
                notify(this,'ROIUpdated',evtData);
            end

        end


        function updateSessionWithROIsAnnotations(this,display,currentROIs,notifyExternal)



            if(nargin==3)
                notifyExternal=true;
            end

            recomputeCurrentROI=false;
            actType=vision.internal.labeler.tool.actionType.Recreate;
            updateSessionWithROIsAnnotationsCore(this,display,...
            notifyExternal,currentROIs,recomputeCurrentROI,actType);
        end


        function updateSessionForGivenROIs(this,display,currentROIs,lastROI)


            import vision.internal.labeler.tool.actionType
            actType=lastROI.ActionType;

            notifyExternal=true;

            if(actType==actionType.Skip)
                return;
            end



            if actType==actionType.Append
                rois=lastROI.Data;
                recomputeCurrentROI=true;
            else
                rois=currentROIs;
                recomputeCurrentROI=false;
            end

            updateSessionWithROIsAnnotationsCore(this,display,...
            notifyExternal,rois,recomputeCurrentROI,actType);
        end


        function isCanceled=newSession(this)



            this.setStatusText(vision.getMessage('vision:imageLabeler:NewSessionStatus'));



            isCanceled=this.processSessionSaving();

            wait(this.Container);
            if isCanceled
                resume(this.Container);
                return;
            end

            this.deleteComponenDestroyListener();
            this.cleanSession();

            this.updateFigureCloseListener();


            this.disableUndoRedo();

            this.setStatusText('');

            resume(this.Container);
        end


        function cleanSession(this)


            close(this.VisualSummaryDisplay);
            this.VisualSummaryDisplay=[];


            deleteAllItemsLabelSetDisplay(this);


            resetSession(this.Session);
            resetDisplaysInNewSession(this);
            resetNavigationControls(this);
            removeSignalNav(this);
            resetSignalMap(this.Container);
            if this.isImageLabeler()
                this.resetViewForCleanSession();
                this.resetMetadataDisplay();
                this.IsDataBlockedImage=false;
            end


            resetDrawingTools(this.SemanticTab);


            resetOpacitySliders(this.LabelTab);


            disableSublabelAttributeButtons(this);

            grabFocus(this.ROILabelSetDisplay);
            createDefaultLayoutForNewSession(this);
            drawnow();

            this.AreSignalsLoaded=false;



            this.LabelTab.changeROIColorOption('By Label');
            this.LabelTab.changeLabelDisplayOption('hover');
            this.LabelVisibleInternal='hover';

            setTitleBar(this,this.ToolName);


            this.LabelTab.setToDefaultSelectAlgorithmDropDownText();

            this.updateToolstrip();
        end


        function closeAppInstance(this,varargin)

            closeApp(this);
        end


        function deleteComponenDestroyListener(this)
            this.ComponentBeingDestroyedListener=[];
        end


        function closeApp(this)
            if useAppContainer()&&(~isvalid(this))
                return;
            end


            if~this.StopRunning
                isCanceled=this.processSessionSaving();

                if isCanceled
                    vetoClose(this.Container);
                    return;
                end
            end

            if~this.IsStillRunning

                this.IsAppClosing=true;



                closeAllFigures(this);

                approveClose(this.Container);
                this.deleteToolInstance();

            else
                this.StopRunning=true;
                return;
            end
        end

    end

    methods(Access=protected)

        function setTitleBar(this,titleStr)
            setTitleBar(this.Container,titleStr);
        end


        function[success,gTruth,pathName,fullName,fileName]=...
            importLabelAnnotationsPreWork(this,source)


            persistent fileDir;
            gTruth=[];
            success=true;
            pathName='';
            fullName='';
            fileName='';
            hFig=getDefaultFig(this.Container);
            switch source
            case 'file'
                if isempty(fileDir)||~exist(fileDir,'dir')
                    fileDir=pwd();
                end


                importAnnotations=vision.getMessage('vision:labeler:ImportAnnotations');
                fromFile=vision.getMessage('vision:labeler:FromFile');
                title=sprintf('%s %s',importAnnotations,fromFile);

                [fileName,pathName,userCanceled]=...
                vision.internal.labeler.tool.uigetmatfile(fileDir,title);


                if userCanceled||isempty(fileName)
                    return;
                end


                fileDir=pathName;

                try
                    gTruth=loadGroundTruthFromFile(this,fileName,pathName);
                catch
                    fcnName=getGtruthFcnName(this);
                    toolTitle=getTitleBar(this.Container);
                    errorMessage=getString(message('vision:labeler:UnableToLoadAnnotationsDlgMessage',...
                    fileName,toolTitle,fcnName{1}));
                    dialogName=getString(message('vision:labeler:UnableToLoadAnnotationsDlgName'));

                    vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,...
                    this.Tool);

                    success=false;
                    return;
                end
                fullName=fullfile(pathName,fileName);

            case 'workspace'
                variableTypes=getGtruthFcnName(this);
                variableDisp=variableTypes;
                [gTruth,gTruthVar,isCanceled]=...
                vision.internal.uitools.getVariablesFromWS(variableTypes,variableDisp);

                if isCanceled
                    return
                end

                pathName=pwd;
                fullName=pwd;
                fileName=gTruthVar;
            end

            if~isscalar(gTruth)
                errorMessage=getString(message('vision:labeler:ImportLabelsNotScalarGroundTruth',fileName));
                dialogName=getString(message('vision:labeler:UnableToLoadAnnotationsDlgName'));
                vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,this.Tool);

                drawnow;
                success=false;
                return;
            end

            if~gTruth.hasValidDataSource()
                errorMessage=getString(message('vision:labeler:invalidDataSource',fileName));
                dialogName=getString(message('vision:labeler:UnableToLoadAnnotationsDlgName'));
                vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,this.Tool);

                drawnow;
                success=false;
                return;
            end

        end


        function gTruth=loadGroundTruthFromFile(this,fileName,pathName)


            temp=load(fullfile(pathName,fileName),'-mat');



            fields=fieldnames(temp);
            gTruth=temp.(fields{1});

            supportedFcnNames=string(getGtruthFcnName(this));
            className=string(class(gTruth));

            if~any(supportedFcnNames==className)


                toolTitle=getTitleBar(this.Container);
                error(getString(message('vision:labeler:UnableToLoadAnnotationsDlgMessage',...
                fileName,toolTitle,supportedFcnNames{1})));
            end
        end


        function isCanceled=processSessionSaving(this)

            isCanceled=false;

            sessionChanged=this.Session.IsChanged;

            yes=vision.getMessage('MATLAB:uistring:popupdialogs:Yes');
            no=vision.getMessage('MATLAB:uistring:popupdialogs:No');
            cancel=vision.getMessage('MATLAB:uistring:popupdialogs:Cancel');

            if sessionChanged
                if isInAlgoMode(this)&&algoNeedsSaving(this)
                    selection=this.askForSavingOfAlgSession();
                else

                    hFig=getDefaultFig(this.Container);
                    selection=this.askForSavingOfSession(hFig);
                end
            else
                selection=no;
            end

            switch selection
            case yes
                success=this.saveSession();
                if~success
                    isCanceled=true;
                end
            case no

            case cancel
                isCanceled=true;
            end
        end


        function updateFigureCloseListener(this)

            deleteComponenDestroyListener(this)

            appFigComponents=[this.ROILabelSetDisplay.Fig,...
            this.SignalNavigationDisplay.Fig,...
            this.FrameLabelSetDisplay.Fig,...
            this.InstructionsSetDisplay.Fig,...
            this.AttributesSublabelsDisplay.Fig];

            for i=1:length(this.DisplayManager.Displays)
                appFigComponents=[appFigComponents,this.DisplayManager.Displays{i}.Fig];
            end




            this.ComponentBeingDestroyedListener=event.listener(...
            appFigComponents,'ObjectBeingDestroyed',@this.onComponentBeingDestroyed);
        end


        function onComponentBeingDestroyed(this,~,~)

            sessionChanged=this.Session.IsChanged;
            this.deleteComponenDestroyListener();

            yes=vision.getMessage('MATLAB:uistring:popupdialogs:Yes');
            no=vision.getMessage('MATLAB:uistring:popupdialogs:No');

            if sessionChanged
                hFig=getDefaultFig(this.Container);

                if isInAlgoMode(this)&&algoNeedsSaving(this)
                    question=vision.getMessage('vision:labeler:AlgSaveQuestion');
                    title=vision.getMessage('vision:uitools:SaveSessionTitle');

                    selection=vision.internal.labeler.handleAlert(hFig,'question',question,title,...
                    yes,no,yes);

                    if strcmp(selection,yes)

                        this.acceptAlgorithm();
                    end
                else
                    question=vision.getMessage('vision:uitools:SaveSessionQuestion');
                    title=vision.getMessage('vision:uitools:SaveSessionTitle');

                    selection=vision.internal.labeler.handleAlert(hFig,'question',question,title,...
                    yes,no,yes);
                end
            else
                selection=no;
            end

            if strcmpi(selection,yes)
                this.saveSession();
            end

            setClosingApprovalNeeded(this,false);

            approveClose(this.Container);
            close(this.Container);
            this.deleteToolInstance();
        end


        function reactToAppClientActivation(~,~,~)

        end


        function reactToAppInFocus(~)

        end


        function reactToAppFocusLost(~)

        end


        function clearAfterLastSignalRemoved(this)



            close(this.VisualSummaryDisplay);
            this.VisualSummaryDisplay=[];


            resetDisplaysInNewSession(this);
            resetNavigationControls(this);
            removeSignalNav(this);


            resetDrawingTools(this.SemanticTab);


            resetOpacitySliders(this.LabelTab);



            if isImageLabeler(this)
                this.resetViewForCleanSession();
                this.IsDataBlockedImage=false;
            end

            this.ShowNavControlTab=false;

            this.Container.makeOverviewInvisible();
            this.ShowOverviewTab=false;

            assert(~this.ShowInstructionTab);

            if~this.ShowAttributeTab

                doTileLayoutAtLoad(this);
            else


                assert(~this.ShowInstructionTab);
                assert(this.ShowAttributeTab);
                setAppLayoutFromFileName(this.Container,'defaultLayoutAttrib.xml');
            end
            resetAppFigDocLayout(this.Container,1,1)
            drawnow();

            setTitleBar(this,this.ToolName);

            this.AreSignalsLoaded=false;
            this.updateToolstrip();
        end
    end

    methods(Access=private)

        function[dispMode,selectedItemInfo]=readjustDispModeROIFromSelectedItem(this,mode)

            dispMode=mode;
            selectedItemInfo=[];
            if strcmpi(dispMode,'ROI')







                selectedItemInfo=getSelectedItemInfo(this);

                if isempty(selectedItemInfo)||isempty(selectedItemInfo.roiItemDataObj)...
                    ||~selectedItemInfo.roiItemDataObj.ROIVisibility
                    dispMode='none';
                end
            end
        end


        function toolstripMode=excludeToolstripModeNone(this,mode)













            toolstripMode=mode;
            if strcmpi(mode,'ROI')
                selectedItemInfo=getSelectedItemInfo(this);
                if isempty(selectedItemInfo)||isempty(selectedItemInfo.roiItemDataObj)...
                    ||~selectedItemInfo.roiItemDataObj.ROIVisibility
                    toolstripMode='none';
                end
            end
        end


        function setModeCore(this,dispMode,toolstripMode,selectedItemInfo)

            this.DisplayManager.setMode(dispMode,selectedItemInfo);

            this.LabelTab.reactToModeChange(toolstripMode);
            this.SemanticTab.reactToModeChange(toolstripMode);
            this.AlgorithmTab.reactToModeChange(toolstripMode);
        end

        function[selectedSignalName,selectedSignalType,...
            signalNames,selectedSignalId]=getSignalInfoFromDisplay(this)
            [selectedSignalName,selectedSignalType,signalNames,...
            selectedSignalId]=getSignalInfoFromDisplay(this.DisplayManager);
        end

        function toolType=getToolType(this)

            switch this.ToolName
            case vision.getMessage('vision:labeler:ToolTitleIL')
                toolType=vision.internal.toolType.ImageLabeler;
            case vision.getMessage('vision:labeler:ToolTitleVL')
                toolType=vision.internal.toolType.VideoLabeler;
            case vision.getMessage('vision:labeler:ToolTitleGTL')
                toolType=vision.internal.toolType.GroundTruthLabeler;
            case vision.getMessage('vision:labeler:ToolTitleLL')
                toolType=vision.internal.toolType.LidarLabeler;
            otherwise
                toolType=vision.internal.toolType.None;
            end
        end

        function tf=isImageLabeler(this)

            tf=(this.ToolType==vision.internal.toolType.ImageLabeler);
        end

        function tf=isInRunLoop(this)
            tf=this.IsStillRunning||...
            (~this.StopAlgRun);
        end

        function createToolstripTabGroup(this,name)
            this.TabGroup=matlab.ui.internal.toolstrip.TabGroup();
            this.TabGroup.Tag=append(lower(name),"_tabgroup");
        end


        function wireUpContainer(this,title,name)

            if matlab.ui.internal.desktop.isMOTW||this.UseAppContainer

                this.Container=vision.internal.labeler.tool.WebContainer(title,name);
            else


                this.Container=vision.internal.labeler.tool.ToolgroupContainer(title,name);
            end

            addlistener(this.Container,'AppClientActivated',@(src,evt)reactToAppClientActivation(this,src,evt));
            addlistener(this.Container,'AppClosed',@(~,~)closeApp(this));
            addlistener(this.Container,'AppFocusRestored',@(~,~)reactToAppInFocus(this));
            addlistener(this.Container,'AppFocusLost',@(~,~)reactToAppFocusLost(this));

            addlistener(this.Container,'UndoRequested',@(~,~)reactToUndoRequest(this));
            addlistener(this.Container,'RedoRequested',@(~,~)reactToRedoRequest(this));
            addlistener(this.Container,'HelpRequested',@(~,~)displayHelp(this));

        end
    end

    methods(Access=private)
        function reactToUndoRequest(this)
            undo(this);
        end

        function reactToRedoRequest(this)
            redo(this);
        end

        function displayHelp(this)
            doc(this.ToolName);
        end
    end



    methods





        function setMode(this,modeInToolstrip)


            [dispMode,selectedItemInfo]=readjustDispModeROIFromSelectedItem(this,modeInToolstrip);
            modeInToolstrip=excludeToolstripModeNone(this,modeInToolstrip);

            setModeCore(this,dispMode,modeInToolstrip,selectedItemInfo);
        end


        function updateDisplayAndTabName(this,oldName,newName)
            updateDisplayNameAndFigTitle(this.DisplayManager,oldName,newName);
            drawnow();
            updateSignalName(this.Session,oldName,newName);
            updateSignalNameInMap(this.Container,oldName,newName);
            imDisplay=getImageDisplay(this);
            setTabName(this,imDisplay,newName);
        end


        function setModeFromToolstrip(this)

            selectedDisplay=getSelectedDisplay(this);
            if isempty(selectedDisplay)
                modeInAxesToolbar='none';
            else
                modeInAxesToolbar=selectedDisplay.getModeSelection;
            end
            setMode(this,modeInAxesToolbar)
        end


        function setPixelModeFromToolstrip(this)
            if this.Session.getNumPixelLabels==1
                mode=getDrawMode(this.SemanticTab);
                sz=getMarkerSize(this.SemanticTab);
                alpha=getAlpha(this.SemanticTab);
                count=getSuperpixelParameters(this.SemanticTab);

                setPixelLabelMode(this,mode);
                setPixelLabelMarkerSize(this,sz);
                setPixelLabelAlpha(this,alpha);
                setSuperpixelParams(this.DisplayManager,count);
            end
        end


        function setModeROIorNone(this,varargin)
            dispMode='ROI';
            toolstripMode='ROI';
            if nargin==1
                selectedItemInfo=getSelectedItemInfo(this);
            else
                selectedItemInfo=varargin{1};
            end
            if isempty(selectedItemInfo)||isempty(selectedItemInfo.roiItemDataObj)||...
                ~selectedItemInfo.roiItemDataObj.ROIVisibility
                dispMode='none';
            end
            if(this.DisplayManager.NumDisplays<=1)||isempty(selectedItemInfo.roiItemDataObj)||...
                ~selectedItemInfo.roiItemDataObj.ROIVisibility
                toolstripMode='none';
            end
            setModeCore(this,dispMode,toolstripMode,selectedItemInfo);
        end


        function updateROIModeAndAttribs(this)
            if(this.ROILabelSetDisplay.NumItems>0)

                itemInfo=this.getSelectedROIPanelItemInfo();

                if~isempty(itemInfo.LabelName)
                    doROIPanelItemSelectionCallback(this);
                end
            end
        end

    end




    methods

        function doROILabelAdditionCallback(this,~,~)




            if((this.ROILabelSetDisplay.NumItems<1)&&this.ShowLabelTypeTutorial)
                createLabelTypeTutorialDialog(this);
            end





            labelAddMode=true;
            dlg=getROILabelDefinitionDialog(this,labelAddMode);
            wait(dlg);

            if~dlg.IsCanceled


                data=dlg.getDialogData();
                roiLabel=data.Label;
                hFig=getDefaultFig(this.Container);

                if~this.Session.isValidName(roiLabel.Label)
                    errorMessage=vision.getMessage('vision:labeler:LabelNameExistsDlgMsg',roiLabel.Label);
                    dialogName=getString(message('vision:labeler:LabelNameExistsDlgName'));
                    vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,this.Tool);
                    return;
                end

                if roiLabel.ROI==labelType.PixelLabel

                    roiLabel.PixelLabelID=this.Session.getPixelLabels();
                    ValidPixelLabelFlag=vision.internal.labeler.tool.LabelerTool.checkPixelLabelValidity(this,roiLabel);


                    updatePixelLabelerLookup(this.DisplayManager,roiLabel.Color,roiLabel.PixelLabelID);
                    if(ValidPixelLabelFlag)

                        data.Label=this.Session.addROILabel(roiLabel,hFig);
                        updateOnLabelAddition(this.ROILabelSetDisplay,data,...
                        this.Session.ROILabelSet);
                    end
                else

                    data.Label=this.Session.addROILabel(roiLabel,hFig);

                    updateOnLabelAddition(this.ROILabelSetDisplay,data,...
                    this.Session.ROILabelSet);





                end
            end


            setModeFromToolstrip(this);

            this.updateToolstrip();
        end


        function doROIPanelItemDeletionCallback(this,~,data)


            itemInfo=getItemInfoFromData(this,data.Data);

            if itemInfo.IsGroup


                displayMessage=vision.getMessage('vision:labeler:DeletionGroupWarning');
                dialogName=vision.getMessage('vision:labeler:DeletionDefinitionWarningTitle');
                yes=vision.getMessage('MATLAB:uistring:popupdialogs:Yes');
                no=vision.getMessage('MATLAB:uistring:popupdialogs:No');
                hFig=getDefaultFig(this.Container);

                selection=vision.internal.labeler.handleAlert(hFig,'questionWithWaitDlg',displayMessage,dialogName,...
                this.Tool,yes,no,yes);

                if strcmpi(selection,yes)
                    this.ROILabelDlgRequired=false;
                    updateOnGroupDelete(this.ROILabelSetDisplay,data,this.Session.ROILabelSet);
                    this.ROILabelDlgRequired=true;
                end
            else
                deleteROILabelSublabelItems(this,itemInfo,data,this.ROILabelDlgRequired);
            end

            if~hasPixelLabels(this.Session)
                if isSuperpixelEnabled(this.SemanticTab)
                    updateSuperpixelLayoutState(this.DisplayManager,false);
                end
                disableBrushOutline(this.DisplayManager);
            end
        end


        function deleteROILabelSublabelItems(this,itemInfo,data,dlgRequired)
            deleteAttrib=~isempty(data.AttributeName);
            hFig=this.Container.getDefaultFig;
            yes=vision.getMessage('MATLAB:uistring:popupdialogs:Yes');
            no=vision.getMessage('MATLAB:uistring:popupdialogs:No');

            if dlgRequired
                displayMessage=warningMessage(this,itemInfo.IsLabel,deleteAttrib);
                dialogName=vision.getMessage('vision:labeler:DeletionDefinitionWarningTitle');

                selection=vision.internal.labeler.handleAlert(hFig,'questionWithWaitDlg',displayMessage,dialogName,...
                this.Tool,yes,no,yes);
            else
                selection=yes;
            end

            if strcmpi(selection,yes)
                if itemInfo.IsLabel
                    if deleteAttrib
                        deleteROILabelAttribute(this,itemInfo.LabelName,data);
                    else
                        deleteROILabelTree(this,itemInfo.LabelName,itemInfo.IsPixelLabel);
                        updateOnLabelDelete(this.ROILabelSetDisplay,data,this.Session.ROILabelSet);

                        if~this.isImageLabeler&&~this.IsVideoLabeler
                            if itemInfo.IsLineOrLine3DLabel
                                disableLineSection(this)
                            else
                                disableCuboidSection(this);
                            end
                        end
                    end
                else
                    if deleteAttrib
                        deleteROISublabelAttribute(this,itemInfo.LabelName,itemInfo.SublabelName,data);
                    else
                        deleteROISublabelTree(this,itemInfo.LabelName,itemInfo.SublabelName);
                        updateOnLabelDelete(this.ROILabelSetDisplay,data,this.Session.ROILabelSet);
                    end
                end


                if deleteAttrib
                    this.ROILabelSetDisplay.deleteItemAttribute(data.Index,data.AttributeName);
                    deleteAttribSublabelPanelItem(this,itemInfo.LabelName,itemInfo.SublabelName,data.AttributeName);
                else
                    this.updateToolstrip();

                    setModeFromToolstrip(this);


                    this.redrawInteractiveROIs();



                    this.resetUndoRedoOnDeletion();

                    if~isempty(this.ProjectedViewDisplay)
                        if isvalid(this.ProjectedViewDisplay)




                            emptyROISrc=struct;
                            emptyROISrc.CurrentROIs=[];
                            if itemInfo.IsLineOrLine3DLabel
                                activateProjectedViewLine(this.ProjectedViewDisplay,emptyROISrc,[],[],[],[]);
                            else
                                activateProjectedViewCuboid(this.ProjectedViewDisplay,emptyROISrc,[],[],[],[]);
                            end
                        end
                    end
                end


                if itemInfo.IsLabel
                    this.DisplayManager.removeLabelFromCopyClipboard(itemInfo.LabelName);
                else

                    this.DisplayManager.removeSublabelFromCopyClipboard(itemInfo.SublabelName);
                end


                this.DisplayManager.refreshClipboard();

                selectedDisplay=getSelectedDisplay(this);
                if~isempty(selectedDisplay)
                    enablePasteFlag=selectedDisplay.copySelectedROIs();

                    if~selectedDisplay.IsCuboidSupported
                        copiedROIsTypes=selectedDisplay.copiedROIsType();
                    else
                        copiedROIsTypes=getString(message('vision:trainingtool:PastePopup'));
                    end
                    setPasteMenuState(this.DisplayManager,selectedDisplay.SignalType,copiedROIsTypes,enablePasteFlag);
                end

                if(this.ROILabelSetDisplay.NumItems==0)
                    disableSublabelAttributeButtons(this);
                    removeAttributeSublabelPanel(this);
                else
                    selectedItemInfo=getSelectedItemInfo(this);

                    isAnyItemSelected=selectedItemInfo.isAnyItemSelected;
                    isPixelLabelItemSelected=selectedItemInfo.isPixelLabelItemSelected;
                    isLabelSelected=selectedItemInfo.isLabelSelected;
                    isGroupItemSelected=selectedItemInfo.isGroup;

                    controlVisOfSublabelAttribCreateButtons(this,isAnyItemSelected,isPixelLabelItemSelected,isLabelSelected,isGroupItemSelected);
                    updateAttributesSublabelsPanelIfNeeded(this);
                end
            end
        end


        function redrawInteractiveROIs(this)
            if this.AreSignalsLoaded
                for i=1:this.NumSignalsForDisplay
                    displayId=i+1;
                    readerId=i;
                    thisdisplay=this.DisplayManager.getDisplayFromIdNoCheck(displayId);
                    sz=thisdisplay.sizeofImage();
                    frameIdx=getCurrentFrameIndex(this,readerId);
                    [data,exceptions]=this.Session.readDataBySignalId(readerId,frameIdx,sz);

                    if isempty(exceptions)
                        thisdisplay.wipeROIs();
                        thisdisplay.redrawInteractiveROIs(data);
                    end
                end
            end
        end


        function resetUndoRedoOnDeletion(this)

            this.DisplayManager.resetUndoRedoBuffer();



            resetUndoRedoPixelOnLabDefDel(this.DisplayManager);



            selectedDisplay=getSelectedDisplay(this);
            if isempty(selectedDisplay)
                return;
            end
            signalName=selectedDisplay.Name;
            currentIndex=getCurrentFrameIndex(this,signalName);
            currentROIs=selectedDisplay.getCurrentROIs();


            selectedDisplay.updateUndoOnLabelChange(currentIndex,currentROIs,0);
        end


    end





    methods


        function doFrameLabelAdditionCallback(this,~,~)



            dlg=vision.internal.labeler.tool.FrameLabelDefinitionDialog(...
            this.Tool,...
            this.Session.FrameLabelSet,...
            this.Session.ROILabelSet);


            dlg.InvalidLabelNames={'PixelLabelData'};

            wait(dlg);

            if~dlg.IsCanceled

                data=dlg.getDialogData();
                frameLabel=data.Label;

                if~this.Session.isValidName(frameLabel.Label)
                    hFig=getDefaultFig(this.Container);
                    errorMessage=vision.getMessage('vision:labeler:LabelNameExistsDlgMsg',frameLabel.Label);
                    dialogName=getString(message('vision:labeler:LabelNameExistsDlgName'));
                    vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,this.Tool);
                    return;
                end


                frameLabel=this.Session.addFrameLabel(frameLabel);
                data.Label=frameLabel;

                updateOnLabelAddition(this.FrameLabelSetDisplay,data,...
                this.Session.FrameLabelSet);
            end

            this.updateToolstrip();
        end


        function doFrameLabelModificationCallback(this,~,data)


            isLabelItemSelected=~isstruct(data.Data);

            if isLabelItemSelected
                frameLabel=data.Data;


                dlg=vision.internal.labeler.tool.FrameLabelDefinitionDialog(...
                this.Tool,...
                this.Session.FrameLabelSet,...
                this.Session.ROILabelSet,...
                frameLabel);
            else
                labelGroupName=data.Data.Group;
                dlg=vision.internal.labeler.tool.GroupModifyDialog(...
                this.Tool,labelGroupName,this.Session.FrameLabelSet,this.Container.getDefaultFig);
            end

            wait(dlg);

            if~dlg.IsCanceled

                dialogData=dlg.getDialogData;

                if isLabelItemSelected

                    frameLabel=dialogData.Label;

                    if dlg.NameChangedInEditMode
                        oldFrameLabel=data.Data.Label;
                        modifyFrameLabelName(this,oldFrameLabel,frameLabel.Label);
                    end

                    if dlg.DescriptionChangedInEditMode
                        modifyItemDescription(this.FrameLabelSetDisplay,data.Index,frameLabel);

                        updateFrameLabelDescription(this.Session,...
                        frameLabel.Label,frameLabel.Description);
                    end

                    if dlg.GroupChangedInEditMode
                        updateFrameLabelGroup(this.Session,frameLabel.Label,frameLabel.Group);


                        updateGroupOnLabelEdit(this.FrameLabelSetDisplay,dialogData,...
                        this.Session.FrameLabelSet);
                    end

                    if dlg.ColorChangedInEditMode
                        modifyFrameItemColor(this.FrameLabelSetDisplay,data.Index,frameLabel);

                        updateFrameLabelColor(this.Session,...
                        frameLabel.Label,frameLabel.Color);
                    end

                else
                    if dialogData.GroupNameChanged
                        oldGroupName=data.Data.Group;
                        newGroupName=dialogData.Group;
                        updateFrameGroupNames(this.Session,oldGroupName,newGroupName);
                        updateOnGroupNameChange(this.FrameLabelSetDisplay,data.Index,newGroupName);
                    end
                end
                this.Session.IsChanged=true;
            end
        end


        function doFrameLabelDeletionCallback(this,~,data)


            isaLabel=~isstruct(data.Data);
            yes=vision.getMessage('MATLAB:uistring:popupdialogs:Yes');
            no=vision.getMessage('MATLAB:uistring:popupdialogs:No');
            hFig=getDefaultFig(this.Container);

            if isaLabel
                if this.FrameLabelDlgRequired
                    sceneText=vision.getMessage('vision:labeler:Scene');
                    displayMessage=vision.getMessage('vision:labeler:DeletionDefinitionWarning',sceneText);
                    dialogName=vision.getMessage('vision:labeler:DeletionDefinitionWarningTitle');

                    selection=vision.internal.labeler.handleAlert(hFig,'questionWithWaitDlg',displayMessage,dialogName,...
                    this.Tool,yes,no,yes);
                else
                    selection=yes;
                end

                if strcmpi(selection,yes)
                    frameLabel=data.Data;
                    this.Session.deleteFrameLabel(frameLabel.Label);
                    updateOnLabelDelete(this.FrameLabelSetDisplay,data,this.Session.FrameLabelSet);

                    this.updateToolstrip();
                end
            else

                displayMessage=vision.getMessage('vision:labeler:DeletionGroupWarning');
                dialogName=vision.getMessage('vision:labeler:DeletionDefinitionWarningTitle');

                selection=vision.internal.labeler.handleAlert(hFig,'questionWithWaitDlg',displayMessage,dialogName,...
                this.Tool,yes,no,yes);

                if strcmpi(selection,yes)

                    this.FrameLabelDlgRequired=false;
                    updateOnGroupDelete(this.FrameLabelSetDisplay,data,this.Session.FrameLabelSet);
                    this.FrameLabelDlgRequired=true;
                end
            end
        end


        function doFrameLabelMoveCallback(this,~,data)

            groupChanged=data.Data.GroupChanged;

            if groupChanged
                labelName=data.Data.Label;
                labelGroupName=data.Data.Group;
                updateFrameLabelGroup(this.Session,labelName,labelGroupName);
            end

            labelNames=data.Data.LabelNames;
            reorderFrameLabelDefinitions(this.Session,labelNames);
        end


        function doFrameLabelSelectionCallback(this,~,data)


            isaLabel=~isstruct(data.Data);
            if isaLabel&&this.AreSignalsLoaded

                frameLabel=data.Data;


                this.DisplayManager.updateLabelSelection(frameLabel);

                unfreezeOptionPanel(this.FrameLabelSetDisplay);
            else
                freezeOptionPanel(this.FrameLabelSetDisplay);
            end
        end


        function doFrameLabelCallback(this,~,data)


            updateFrameLabelData(this,data,'add');
        end


        function doFrameUnlabelCallback(this,~,data)


            updateFrameLabelData(this,data,'delete');
        end
    end





    methods(Access=public,Hidden)


        function addToolInstance(this)
            imageslib.internal.apputil.manageToolInstances('add',...
            this.InstanceName,this);
        end




        function setClosingApprovalNeeded(this,in)
            setClosingApprovalNeeded(this.Container,in);
        end


        function deleteToolInstance(this)
            imageslib.internal.apputil.manageToolInstances('remove',...
            this.InstanceName,this);
        end
    end




    methods

        function selection=askForSavingOfAlgSession(this)

            dlg=vision.internal.labeler.tool.AlgSaveSessionDlg(this.Tool);
            wait(dlg);

            if dlg.IsAcceptSave

                this.acceptAlgorithm();


                selection=getString(message('MATLAB:uistring:popupdialogs:Yes'));
            elseif dlg.IsNo

                selection=getString(message('MATLAB:uistring:popupdialogs:No'));
            elseif dlg.IsCancel

                selection=getString(message('MATLAB:uistring:popupdialogs:Cancel'));
            end
        end


        function flag=isInAlgoMode(this)

            algTabName=getString(message('vision:labeler:AlgorithmTab'));

            tabNames={this.TabGroup.Children.Title};

            flag=~isempty(find(contains(tabNames,algTabName),1));
        end


        function flag=algoNeedsSaving(this)
            flag=this.AlgorithmTab.hasUnsavedChanges;
        end


        function startAutomation(this)







            success=tryToSetupAlgorithm(this);



            if success


                wait(this.Container);
                resetWait=onCleanup(@()resume(this.Container));


                if~hasSettingsDefined(this.AlgorithmSetupHelper)
                    disableSettings(this.AlgorithmTab);
                else
                    enableSettings(this.AlgorithmTab);
                end


                showModalAlgorithmTab(this,false);


                setAlgorithmMode(this.AlgorithmTab,'undorun');


                addInstructionsPanel(this);

                setSemanticTabForAutomation(this);

                updateVisualSummary(this);

                this.DisplayManager.resetCopyPastePixelContextMenu();

            else
                enableAllItems(this.ROILabelSetDisplay);
                enableAllItems(this.FrameLabelSetDisplay);
                unfreeze(this.ROILabelSetDisplay);
                unfreeze(this.FrameLabelSetDisplay);
                if(~isequal(this.ToolType,vision.internal.toolType.ImageLabeler))
                    if numel(this.SignalNamesForAutomation)>=1
                        restoreSignalAfterAutomation(this);
                    end
                end
            end
            if useAppContainer()
                this.Tool.WindowBounds=this.Tool.WindowBounds+1;
            end
        end


        function selectAlgorithm(this,algorithmClass)


            if isempty(algorithmClass)
                return;
            end


            configureDispatcher(this.AlgorithmSetupHelper,algorithmClass);


            enableAlgorithmSection(this.LabelTab,true);
        end


        function openSettingsDialog(this)


            closeExceptionDialogs(this);

            algorithm=this.AlgorithmSetupHelper.AlgorithmInstance;

            try
                doSettings(algorithm);
            catch ME
                dlgTitle=vision.getMessage('vision:labeler:ErrorInSettingsTitle');
                showExceptionDialog(this,ME,dlgTitle);
            end
        end


        function isPixelLabel=isPixellabelDefSelected(this,labelID)

            isPixelLabel=false;
            if labelID>0
                itemData=this.ROILabelSetDisplay.getItemData(labelID);



                isGroup=isstruct(itemData);
                if~isGroup
                    isPixelLabel=(itemData.ROI==labelType.PixelLabel);
                end
            end
        end


        function setSemanticTabForAutomation(this)

            labelID=this.ROILabelSetDisplay.CurrentSelection;
            isPixelLabel=isPixellabelDefSelected(this,labelID);

            if~isempty(labelID)
                if isPixelLabel

                    show(this.SemanticTab);
                end
            else
                hideContextualSemanticTab(this);
            end
        end


        function stopAlgorithm(this)

            this.StopAlgRun=true;
        end


        function cancelAlgorithm(this,signalNames)

            closeExceptionDialogs(this);
            finalize(this);


            uncacheAnnotations(this.Session,signalNames);

            removeInstructionsPanel(this);

            endAutomation(this);

            updateVisualSummary(this);

        end


        function endAutomation(this)

            wait(this.Container);
            resetWait=onCleanup(@()resume(this.Container));


            if hasPixelLabels(this.Session)

                temppath=this.Session.TempDirectory;
                pathstr=fileparts(temppath);
                setTempDirectory(this.Session,pathstr);


                if isfolder(temppath)
                    rmdir(temppath,'s');
                end
            end

            hideContextualSemanticTab(this);
            hideModalAlgorithmTab(this);

            unfreezeSublabelItems=true;
            unfreezeLabelPanelsWhenEndingAutomation(this,unfreezeSublabelItems);
        end


        function numLabels=getNumLabelsForScalarStruct(~,labelsIn)

            numLabels=1;
            if(labelsIn.Type==labelType.Rectangle)||...
                (labelsIn.Type==labelType.ProjectedCuboid)||...
                (labelsIn.Type==labelType.Cuboid)
                numLabels=size(labelsIn.Position,1);
            elseif((labelsIn.Type==labelType.Line)||...
                (labelsIn.Type==labelType.Polygon))
                if isnumeric(labelsIn.Position)&&ismatrix(labelsIn.Position)
                    numLabels=1;
                elseif iscell(labelsIn.Position)
                    numLabels=numel(labelsIn.Position);
                else
                    assert(false);
                end
            else
                return;
            end
        end


        function pos=getPositionFromScalarStruct(~,labelsIn,idx)

            pos=[0,0,0,0];
            if(labelsIn.Type==labelType.Rectangle)||...
                (labelsIn.Type==labelType.ProjectedCuboid)||...
                (labelsIn.Type==labelType.Cuboid)

                pos=labelsIn.Position(idx,:);
            elseif((labelsIn.Type==labelType.Line)||...
                (labelsIn.Type==labelType.Polygon))
                if isnumeric(labelsIn.Position)&&ismatrix(labelsIn.Position)

                    pos=labelsIn.Position;
                elseif iscell(labelsIn.Position)

                    pos=labelsIn.Position{idx};
                else
                    assert(false);
                end
            else
                return;
            end
        end


        function labelsOut=restructPositionAndAddUID(this,labelsIn)







            labelsOut=labelsIn;
            if~isempty(labelsIn)&&isstruct(labelsIn)
                N=numel(labelsIn);
                data=cell(N,1);
                for i=1:N
                    data{i}=expandAutoLabelStructAndAddUUID(this,labelsIn(i));
                end
                labelsOut=[data{:}];
            end

        end


        function userLabels=checkUserLabels(this,userLabels,isValid,imSize)






            if isValid
                validROILabelNames=this.AlgorithmSetupHelper.ValidROILabelNames;
                validFrameLabelNames=this.AlgorithmSetupHelper.ValidFrameLabelNames;

                if iscategorical(userLabels)

                    isValidCategorical=~isempty(userLabels)&&all(size(userLabels)==imSize);
                    if~isValidCategorical
                        error(message('vision:labeler:invalidCategoricalFromUser'));
                    end



                    categorySet=categories(userLabels);
                    [isKnownCat,knownCatIdx]=ismember(lower(categorySet),lower(validROILabelNames));
                    unknownCats=categorySet(~isKnownCat);

                    if isempty(setdiff(categorySet,unknownCats))

                        networkCategories=string();
                        for idx=1:5:length(categorySet)
                            if idx+5<=length(categorySet)
                                networkCategories=networkCategories+newline+strjoin(string(categorySet(idx:idx+5)),', ')+", ";
                            else
                                networkCategories=networkCategories+newline+strjoin(string(categorySet(idx+1:length(categorySet))),', ');
                            end
                        end
                        error(message('vision:labeler:invalidCategoricalFromNetwork',networkCategories));
                    end


                    if~isempty(unknownCats)
                        userLabels=removecats(userLabels,unknownCats);
                    end

                    oldLabelNames=categorySet(isKnownCat);
                    newLabelNames=validROILabelNames(knownCatIdx(isKnownCat));
                    needsNewLabel=~ismember(oldLabelNames,newLabelNames);
                    if any(needsNewLabel)


                        userLabels=renamecats(userLabels,oldLabelNames(needsNewLabel),newLabelNames(needsNewLabel));
                    end
                else
                    for n=1:numel(userLabels)

                        labelName=userLabels(n).Name;
                        lblType=userLabels(n).Type;



                        isValidROI=any(strcmpi(labelName,validROILabelNames));



                        isValidAttrib=true;
                        if isValidROI
                            roiLabel=this.Session.queryROILabelData(labelName);




                            if~strcmp(labelName,roiLabel.Label)
                                userLabels(n).Name=roiLabel.Label;
                            end

                            if isequal(userLabels(n).Type,labelType.Cuboid)
                                roiLabel.ROI=labelType.Cuboid;
                            end
                            isValidROI=isequal(roiLabel.ROI,lblType);


                            hasAttribDefined=this.Session.hasAttributeDefined(labelName);
                            if(hasAttribDefined)
                                validROIAttribData=this.Session.queryROIAttributeFamilyData(labelName,'');



                                [isValidAttrib,outLbl]=validateAndFillAttribute(this,validROIAttribData,userLabels(n));
                                if isfield(outLbl,'Attributes')
                                    userLabels(n).Attributes=[];
                                end
                                userLabels(n)=outLbl;
                            else

                                if isfield(userLabels(n),'Attributes')
                                    error(message('vision:labeler:undefinedAttributeInAlgo'));
                                end
                            end
                        end




                        isValidFrIdx=strcmpi(labelName,validFrameLabelNames)&isequal(lblType,labelType.Scene);
                        isValidFr=any(isValidFrIdx);




                        if isValidFr&&~strcmp(labelName,validFrameLabelNames(isValidFrIdx))
                            userLabels(n).Name=validFrameLabelNames{isValidFrIdx};
                        end



                        isValid=xor((isValidROI&&isValidAttrib),isValidFr);


                        if~isValid&&(isValidROI&&~isValidAttrib)
                            error(message('vision:labeler:invalidAttributeFromUser'));


                        end
                    end
                end
            end

            if~isValid
                error(message('vision:labeler:invalidLabelFromUser'));
            end
        end


        function readjustDrawingModeInAutomation(this)
            setModeROIorNone(this);
        end
    end

    methods(Access=private)


        function isValidAttrib=validateAttributeValue(~,attribData,attribVal)

            attribType=attribData.Type;
            if attribType==attributeType.Numeric
                isValidAttrib=isnumeric(attribVal);
            elseif attribType==attributeType.String
                isValidAttrib=isstring(attribVal)||ischar(attribVal);
            elseif attribType==attributeType.Logical
                isValidAttrib=islogical(attribVal);
            elseif attribType==attributeType.List
                isValidAttrib=isstring(attribVal)||ischar(attribVal);
                if~isValidAttrib
                    return;
                end
                attribVal=char(attribVal);
                isValidAttrib=any(strcmp(attribData.Value,attribVal));
            else
                isValidAttrib=false;
            end
        end


        function attribNames=getAttribNames(~,attribDefData)
            N=numel(attribDefData);
            attribNames=cell(N,1);
            for i=1:N
                attribNames{i}=attribDefData{i}.Name;
            end
        end


        function[isValidAttrib,matchingDefIdx]=validateUserDefinedAttributes(this,attribDefData,userAtribNames,userAtribValues)

            validAttribNames=getAttribNames(this,attribDefData);
            Nu=numel(userAtribNames);
            matchingDefIdx=zeros(Nu,1);
            for i=1:Nu

                idx=find(strcmp(validAttribNames,userAtribNames{i}));
                if numel(idx)~=1
                    isValidAttrib=false;
                    return;
                end


                thisUserDefAttribVal=userAtribValues{i};

                isValidAttrib=validateAttributeValue(this,attribDefData{i},thisUserDefAttribVal);

                if isValidAttrib
                    matchingDefIdx(i)=idx;
                end

            end

        end


        function outLabel=fillWithAttributeValue(~,attribDefData,inLabel,matchingDefIdx)

            outLabel=inLabel;
            N=numel(attribDefData);

            if isfield(inLabel,'Attributes')
                attribS=inLabel.Attributes;
                for p=1:numel(inLabel.Attributes)
                    unmatchedIdx=setdiff(1:N,matchingDefIdx{p});

                    for i=1:numel(unmatchedIdx)

                        idx=unmatchedIdx(i);
                        f=attribDefData{idx}.Name;
                        if attribDefData{idx}.Type==attributeType.List
                            attribS(p).(f)=attribDefData{idx}.Value{1};
                        else
                            attribS(p).(f)=attribDefData{idx}.Value;
                        end
                    end
                end
            else
                attribS=[];

                for i=1:N

                    f=attribDefData{i}.Name;
                    if attribDefData{i}.Type==attributeType.List
                        attribS.(f)=attribDefData{i}.Value{1};
                    else
                        attribS.(f)=attribDefData{i}.Value;
                    end
                end
            end

            outLabel.Attributes=attribS;
        end


        function[isValidAttrib,outLabel]=validateAndFillAttribute(this,attribDefData,inLabel)

            if isfield(inLabel,'Attributes')&&~isempty(inLabel.Attributes)
                numROI=getNumLabelsForScalarStruct(this,inLabel);
                userAttribS=inLabel.Attributes;

                if~isequal(numROI,numel(userAttribS))
                    error(message('vision:labeler:NumberOfAttributesMustMatchNumberOfROIs'))
                end

                matchingDefIdx=cell(numel(userAttribS),1);
                for i=1:numel(userAttribS)
                    [userAtribNames,userAtribValues]=parseUserDefinedAttributes(this,userAttribS);
                    [isValidAttrib,matchingDefIdx_i]=validateUserDefinedAttributes(this,attribDefData,userAtribNames,userAtribValues);
                    matchingDefIdx{i}=matchingDefIdx_i;
                    if~isValidAttrib
                        outLabel=inLabel;
                        return;
                    end
                end
            else
                isValidAttrib=true;
                matchingDefIdx={};
            end

            outLabel=fillWithAttributeValue(this,attribDefData,inLabel,matchingDefIdx);
        end


        function[atribNames,atribValues]=parseUserDefinedAttributes(~,attribS)
            atribNames=fieldnames(attribS);
            numAttrib=numel(atribNames);
            atribValues=cell(numAttrib,1);
            for i=1:numAttrib
                atribValues{i}=attribS.(atribNames{i});
            end
        end

    end

    methods(Access=protected)

        function doDisableAppForDrawing(this,~,~)


            visible=false;
            changeToolbarVisibility(this,visible);
            disableAllControls(this.LabelTab);

            disableControls(this.SemanticTab);
            disableControls(this.AlgorithmTab);
            if~isImageLabeler(this)&&~this.IsVideoLabeler
                disableLidarControls(this);
            end


            freezeSignalNavInteractions(this);


            freeze(this.ROILabelSetDisplay);
            disableAllItems(this.ROILabelSetDisplay);
            freeze(this.FrameLabelSetDisplay);
            disableAllItems(this.FrameLabelSetDisplay);
            freezeOptionPanel(this.FrameLabelSetDisplay);

            setPasteMenuVisibility(this.DisplayManager,'off');
            if this.Session.getNumPixelLabels>0
                setPixContextMenuVisibility(this.DisplayManager,'off');
            end
        end


        function doEnableAppForDrawing(this,~,~)


            if isvalid(this)



                unfreezeSublabelItems=~isInAlgoMode(this);
                unfreezeLabelPanelsWhenEndingAutomation(this,unfreezeSublabelItems);

                algorithmTab=getTab(this.AlgorithmTab);
                if hasTab(this,algorithmTab)
                    enableControls(this.AlgorithmTab);
                    freezeLabelPanelsWhenStartingAutomation(this);

                    if~hasSettingsDefined(this.AlgorithmSetupHelper)
                        disableSettings(this.AlgorithmTab);
                    else
                        enableSettings(this.AlgorithmTab);
                    end
                end

                if~isImageLabeler(this)&&~this.IsVideoLabeler
                    enableLidarControls(this);
                end

                unfreezeSignalNavInteractions(this);
                setPasteMenuVisibility(this.DisplayManager,'on');

                if this.Session.getNumPixelLabels>0
                    setPixContextMenuVisibility(this.DisplayManager,'on');
                end

                this.updateToolstrip();
            end
        end


        function unfreezePanelsAfterRunningAlgorithm(this)


            algorithm=this.AlgorithmSetupHelper.AlgorithmInstance;
            if(algorithm.SelectedLabelDefinitions(1).Type==labelType.PixelLabel)
                show(this.SemanticTab);
            end

            enableControls(this.LabelTab);
            updateVisualSummaryButton(this);




            unfreezeLabelPanelsWhenEndingAutomation(this,false);
            freezeLabelPanelsWhenStartingAutomation(this);

            unfreezeSignalNavInteractions(this);
        end


        function freezePanelsWhileRunningAlgorithm(this)


            freezeSignalNavInteractions(this);


            freeze(this.ROILabelSetDisplay);
            disableAllItems(this.ROILabelSetDisplay);
            freeze(this.FrameLabelSetDisplay);
            disableAllItems(this.FrameLabelSetDisplay);
            freezeOptionPanel(this.FrameLabelSetDisplay);



            visible=false;
            changeToolbarVisibility(this,visible);
            disableAllControls(this.LabelTab);
            algorithm=this.AlgorithmSetupHelper.AlgorithmInstance;
            if(algorithm.SelectedLabelDefinitions(1).Type==labelType.PixelLabel)
                hide(this.SemanticTab);
            end
        end


        function freezeLabelPanelsWhenStartingAutomation(this)


            if isvalid(this)


                invalidROILabelIdx=this.AlgorithmSetupHelper.InvalidROILabelIndices;

                [~,labelIndices]=getLabelNames(this.ROILabelSetDisplay);
                invalidROILabelIdx=labelIndices(invalidROILabelIdx);

                this.ROILabelSetDisplay.unselectToBeDisabledItems(invalidROILabelIdx);
                for idxr=1:numel(invalidROILabelIdx)
                    this.ROILabelSetDisplay.disableItem(invalidROILabelIdx(idxr));
                end

                invalidFrameLabelIdx=this.AlgorithmSetupHelper.InvalidFrameLabelIndices;
                [~,labelIndices]=getLabelNames(this.FrameLabelSetDisplay);
                invalidFrameLabelIdx=labelIndices(invalidFrameLabelIdx);
                disableFramelabelGroupItems(this);

                this.FrameLabelSetDisplay.unselectToBeDisabledItems(invalidFrameLabelIdx);
                for idxf=1:numel(invalidFrameLabelIdx)
                    this.FrameLabelSetDisplay.disableItem(invalidFrameLabelIdx(idxf));
                end


                freeze(this.ROILabelSetDisplay);
                freeze(this.FrameLabelSetDisplay);
                if isempty(this.AlgorithmSetupHelper.ValidFrameLabelNames)
                    freezeOptionPanel(this.FrameLabelSetDisplay);
                end
            end
        end


        function unfreezeLabelPanelsWhenEndingAutomation(this,varargin)


            if isvalid(this)
                if isempty(varargin)


                    unfreezeSublabelItems=true;
                else
                    unfreezeSublabelItems=varargin{1};
                end

                enableAllItems(this.ROILabelSetDisplay);
                if~unfreezeSublabelItems
                    disableSublabelDefItems(this);
                end
                enableAllItems(this.FrameLabelSetDisplay);

                unfreeze(this.ROILabelSetDisplay);
                unfreeze(this.FrameLabelSetDisplay);
                if this.Session.NumFrameLabels>=1
                    unfreezeOptionPanel(this.FrameLabelSetDisplay);
                end
            end
        end


        function doStartAppWait(this,~,~)
            wait(this.Container);
        end


        function doFinishAppWait(this,~,~)


            if isvalid(this)
                resume(this.Container);
            end
        end


        function doEnableGrabCutEditTools(this,~,~)
            if~this.UseAppContainer
                enableGrabCutEditTools(this.SemanticTab);
            else
                enableSmartPolygonEditTools(this.SemanticTab);
            end
        end


        function doMoveMultipleROI(this,varargin)
            selectedDisplay=getSelectedDisplay(this);
            selectedDisplay.doMoveMultipleROI(varargin);
        end


        function doDisableGrabCutEditTools(this,~,~)


            if isvalid(this)
                if~this.UseAppContainer
                    deselectAndDisableGrabCutEditTools(this.SemanticTab);
                else
                    deselectAndDisableSmartPolygonEditTools(this.SemanticTab);
                end
            end
        end


        function addInstructionsPanel(this)

            instructions=getInstructions(this);

            if isempty(instructions)
                return;
            end

            for n=1:numel(instructions)
                this.InstructionsSetDisplay.appendItem(instructions{n});
            end

            this.InstructionsSetDisplay.updateItem();



            algorithm=this.AlgorithmSetupHelper.AlgorithmInstance;
            setFigureTitle(this.InstructionsSetDisplay,algorithm.Name);



            if useAppContainer()
                isAttributeDisplayOn=hasLayoutAttributePanel(this.Container);
            else
                if~isempty(this.AttributesSublabelsDisplay)
                    isAttributeDisplayOn=this.AttributesSublabelsDisplay.isPanelVisible();
                else
                    isAttributeDisplayOn=false;
                end
            end
            updateTileLayoutForAutomation(this,true,isAttributeDisplayOn);


            resetFocus(this);

        end


        function updateTileLayoutForAutomation(this,showInstructionTab,isAttributeDisplayOn)
            updateTileLayout4AttribInstruct(this,showInstructionTab,...
            isAttributeDisplayOn);
        end


        function addAttributesPanel(this)

            attributes=getAttributes(this);

            if isempty(attributes)
                return;
            end

            this.AttributesSublabelsDisplay.appendItem(attributes);

            lblSublabelName='Vehicle';
            setFigureTitle(this.AttributesSublabelsDisplay,lblSublabelName);
            updateTileLayout4AttribInstruct(this,false,true);


            resetFocus(this);


        end


        function attributes=getAttributes(~)



            attributes=[];
        end


        function instructions=getInstructions(this)




            algorithm=this.AlgorithmSetupHelper.AlgorithmInstance;

            instructions=algorithm.UserDirections;

            if ischar(instructions)||isstring(instructions)
                instructions=cellstr(instructions);
            end

            if~iscell(instructions)||isequal(instructions,{''})
                instructions={};
            end
        end


        function flag=isInstructionsPanelVisible(this)
            flag=this.InstructionsSetDisplay.isPanelVisible();
        end


        function flag=isAttributesPanelVisible(this)
            if isempty(this.AttributesSublabelsDisplay)
                flag=false;
            else
                flag=this.AttributesSublabelsDisplay.isPanelVisible();
            end
        end


        function removeInstructionsPanel(this)




            this.InstructionsSetDisplay.deleteAllItems();

            if useAppContainer()
                removeInstructionsPanelWC(this.Container);
            else
                showAttributes=isAttributesPanelVisible(this);
                updateTileLayout4AttribInstruct(this,false,showAttributes);
            end


            resetFocus(this);

        end


        function removeAttributesPanel(this)




            this.AttributesSublabelsDisplay.deleteAllItems();

            showInstructions=isInstructionsPanelVisible(this);
            updateTileLayout4AttribInstruct(this,showInstructions,false);


            resetFocus(this);

        end


        function isLabel=isLabelItem(this,selectedItemIdx)
            isLabel=false;
            if(selectedItemIdx>0)
                itemData=this.ROILabelSetDisplay.getItemData(selectedItemIdx);
                isLabel=~isstruct(itemData)&&((itemData.ROI==labelType.PixelLabel)||...
                (~isprop(itemData,'Sublabel'))||...
                (isprop(itemData,'Sublabel')&&isempty(itemData.Sublabel)));
            end
        end


        function isLabel=isFrameLabelItem(this,selectedItemIdx)
            isLabel=false;
            if(selectedItemIdx>0)
                itemData=this.FrameLabelSetDisplay.getItemData(selectedItemIdx);
                isLabel=~isstruct(itemData);
            end
        end


        function labelItemId=getParentLabelItemId(this,selectedItemIdx)
            itemData=this.ROILabelSetDisplay.getItemData(selectedItemIdx);
            labelName=itemData.LabelName;
            labelItemId=this.ROILabelSetDisplay.getItemID(labelName,'');
        end


        function moveSelectionFromSublabelTo1stLabelDef(this)
            roiSelectionIdx=this.ROILabelSetDisplay.CurrentSelection;
            if roiSelectionIdx&&~isLabelItem(this,roiSelectionIdx)







                selectItemIdx=1;
                if~isLabelItem(this,selectItemIdx)
                    selectItemIdx=2;
                end
                this.ROILabelSetDisplay.selectItem(selectItemIdx);
            end
        end


        function disableSublabelDefItems(this)
            N=this.ROILabelSetDisplay.NumItems;
            for itemId=1:N
                if~isLabelItem(this,itemId)
                    this.ROILabelSetDisplay.disableItem(itemId);
                end
            end
        end


        function disableFramelabelGroupItems(this)
            N=this.FrameLabelSetDisplay.NumItems;
            for itemId=1:N
                if~isFrameLabelItem(this,itemId)
                    this.FrameLabelSetDisplay.unselectToBeDisabledItems(itemId)
                    this.FrameLabelSetDisplay.disableItem(itemId);
                end
            end
        end


        function enableSublabelDefItems(this)
            N=this.ROILabelSetDisplay.NumItems;
            for itemId=1:N
                if~isLabelItem(this,itemId)
                    this.ROILabelSetDisplay.enableItem(itemId);
                end
            end
        end


        function selectedLabelName=getSelectedLabelName(this)


            itemID=this.ROILabelSetDisplay.CurrentSelection;
            itemData=this.ROILabelSetDisplay.getItemData(itemID);
            selectedLabelName=itemData.Label;

        end


        function selectionStruct=getSelectedLabelDefinitions(this)

            selectionStruct=[];

            hasPixelLabel=false;


            roiSelectionIdx=this.ROILabelSetDisplay.CurrentSelection;

            if~isempty(roiSelectionIdx)&&isLabelItem(this,roiSelectionIdx)
                selectedLabelName=getSelectedLabelName(this);
                roiLabelDef=queryROILabelData(this.Session,selectedLabelName);

                roiDefStruct.Type=roiLabelDef.ROI;
                roiDefStruct.Name=roiLabelDef.Label;


                hasPixelLabel=roiDefStruct.Type==labelType.PixelLabel;
                if hasPixelLabel
                    roiDefStruct.PixelLabelID=roiLabelDef.PixelLabelID;
                else
                    roiDefStruct=appendAttributeDefInStrct(this.Session,roiDefStruct);
                end

                selectionStruct=cat(2,selectionStruct,roiDefStruct);
            end


            frSelectionIdx=this.FrameLabelSetDisplay.CurrentSelection;
            if frSelectionIdx
                frLabelDef=queryFrameLabelData(this.Session,frSelectionIdx);
                frDefStruct.Type=labelType.Scene;
                frDefStruct.Name=frLabelDef.Label;

                if hasPixelLabel
                    frDefStruct.PixelLabelID=[];
                else
                    if isfield(selectionStruct,'Attributes')
                        frDefStruct.Attributes=[];
                    end
                end

                selectionStruct=cat(2,selectionStruct,frDefStruct);
            end
        end


        function cleanPostSetupAlg(this)
            resume(this.Container);
            setAlgorithmMode(this.AlgorithmTab,'undorun');
        end


        function itemInfo=getItemInfoFromData(~,itemData)


            itemInfo.IsGroup=false;
            itemInfo.IsPixelLabel=false;
            itemInfo.IsRectOrCubeLabel=false;
            itemInfo.IsLineOrLine3DLabel=false;
            itemInfo.IsLabel=false;
            itemInfo.LabelName='';
            itemInfo.SublabelName='';
            itemInfo.Color=[];

            if isempty(itemData)
                return;
            end

            if isstruct(itemData)&&isfield(itemData,'Group')
                itemInfo.IsGroup=true;
                return;
            end

            if(isprop(itemData,'ROI')&&(itemData.ROI==labelType.PixelLabel))
                itemInfo.IsLabel=true;
                itemInfo.IsPixelLabel=true;
            elseif(isprop(itemData,'ROI')&&~isprop(itemData,'LabelName')&&...
                isRectOrCubeLabelDef(itemData.ROI))
                itemInfo.IsLabel=true;
                itemInfo.IsRectOrCubeLabel=true;
            elseif(isprop(itemData,'ROI')&&~isprop(itemData,'LabelName')&&...
                isLineOrLine3DLabelDef(itemData.ROI))
                itemInfo.IsLabel=true;
                itemInfo.IsLineOrLine3DLabel=true;
            else
                itemInfo.IsLabel=~isprop(itemData,'LabelName');
                itemInfo.IsPixelLabel=false;
            end

            if itemInfo.IsLabel
                itemInfo.LabelName=itemData.Label;
                itemInfo.SublabelName='';
            else
                itemInfo.LabelName=itemData.LabelName;
                itemInfo.SublabelName=itemData.Sublabel;
            end
            itemInfo.Color=itemData.Color;
        end


        function itemInfo=getSelectedROIPanelItemInfo(this)
            itemData=this.ROILabelSetDisplay.getSelectedItemData();
            itemInfo=getItemInfoFromData(this,itemData);
        end


        function selectedItemInfo=getSelectedItemInfo(this)
            itemInfo=this.getSelectedROIPanelItemInfo();

            if isempty(itemInfo.LabelName)

                if~itemInfo.IsGroup
                    isAnyItemSelected=false;
                else
                    isAnyItemSelected=true;
                end
                roiItemDataObj=[];

            else
                isAnyItemSelected=true;
                if itemInfo.IsLabel

                    roiItemDataObj=this.Session.queryROILabelData(itemInfo.LabelName);
                else

                    roiItemDataObj=this.Session.queryROISublabelData(itemInfo.LabelName,itemInfo.SublabelName);
                end

            end

            selectedItemInfo.isAnyItemSelected=isAnyItemSelected;
            selectedItemInfo.isPixelLabelItemSelected=itemInfo.IsPixelLabel;
            selectedItemInfo.isRectOrCubeLabelItemSelected=itemInfo.IsRectOrCubeLabel;
            selectedItemInfo.isLineOrLine3DLabelItemSelected=itemInfo.IsLineOrLine3DLabel;
            selectedItemInfo.isLabelSelected=itemInfo.IsLabel;
            selectedItemInfo.roiItemDataObj=roiItemDataObj;
            selectedItemInfo.isGroup=itemInfo.IsGroup;
        end

    end




    methods(Access=protected)

        function showExceptionDialog(this,ME,dlgTitle,varargin)

            this.ExceptionDialogHandles{end+1}=vision.internal.labeler.tool.ExceptionDialog(...
            this.Tool,dlgTitle,ME,'normal',varargin{:});
        end


        function closeExceptionDialogs(this)

            for n=1:numel(this.ExceptionDialogHandles)
                close(this.ExceptionDialogHandles{n});
            end
            this.ExceptionDialogHandles={};
        end
    end




    methods(Access=public)

        function loadLabelDefinitionsFromFile(this)


            proceed=this.issueImportWarning(vision.getMessage('vision:labeler:LabelDefinitions'));

            if~proceed
                return;
            end


            persistent fileDir;

            if isempty(fileDir)||~exist(fileDir,'dir')
                fileDir=pwd();
            end


            importDefinitions=vision.getMessage('vision:labeler:ImportDefinitions');
            fromFile=vision.getMessage('vision:labeler:FromFile');
            title=sprintf('%s %s',importDefinitions,fromFile);

            [fileName,pathName,userCanceled]=vision.internal.labeler.tool.uigetmatfile(fileDir,title);


            if userCanceled||isempty(fileName)
                return;
            end


            fileDir=pathName;

            this.setStatusText(vision.getMessage('vision:labeler:LoadLabelDefinitionStatus',fileName));

            this.doLoadLabelDefinitionsFromFile(fullfile(pathName,fileName));
            this.setStatusText('');
        end


        function exportLabelDefinitions(this,labelDefs)

            if nargin==1
                labelDefs=exportLabelDefinitions(this.Session);
            end

            [fileName,pathName,proceed]=uiputfile('*.mat',...
            vision.getMessage('vision:labeler:SaveLabelDefinitions'));
            if proceed
                try
                    save(fullfile(pathName,fileName),'labelDefs');
                catch
                    hFig=getDefaultFig(this.Container);
                    errorMessage=getString(message('vision:labeler:UnableToSaveDefinitionsDlgMessage'));
                    dialogName=getString(message('vision:labeler:UnableToSaveDlgName'));
                    vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,this.Tool);
                end
            end
        end


        function exportLabelAnnotationsToFile(this)

            wait(this.Container);

            resetWait=onCleanup(@()resume(this.Container));

            finalize(this);
            hFig=getDefaultFig(this.Container);

            if hasPixelLabels(this.Session)
                variableName='gTruth';
                dlgTitle=vision.getMessage('vision:labeler:ExportLabelsToFile');
                toFile=true;
                exportDlg=vision.internal.labeler.tool.ExportPixelLabelDlg(...
                this.Tool,variableName,dlgTitle,this.Session.getPixelLabelDataPath,toFile);
                wait(exportDlg);
                proceed=~exportDlg.IsCanceled;
                if proceed
                    TF=exportPixelLabelData(this.Session,exportDlg.CreatedDirectory);

                    pathName=exportDlg.VarPath;
                    this.Session.setPixelLabelDataPath(pathName);
                    fileName=exportDlg.VarName;

                    if~TF
                        errorMessage=getString(message('vision:labeler:UnableToExportDlgMessage'));
                        dialogName=getString(message('vision:labeler:UnableToExportDlgName'));
                        vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,this.Tool);
                        return;
                    end
                end

            else
                [fileName,pathName,proceed]=uiputfile('*.mat',...
                vision.getMessage('vision:labeler:ExportLabels'));
            end

            if proceed
                this.setStatusText(vision.getMessage('vision:labeler:ExportToFileStatus',fileName));

                gTruth=exportLabelAnnotations(this.Session);
                gTruth=appendCustomLabels(this,gTruth);
                if hasPixelLabels(this.Session)
                    refreshPixelLabelAnnotation(this.Session);
                end
                try
                    save(fullfile(pathName,fileName),'gTruth');
                catch
                    errorMessage=getString(message('vision:labeler:UnableToExportDlgMessage'));
                    dialogName=getString(message('vision:labeler:UnableToExportDlgName'));
                    vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,this.Tool);
                end

                this.setStatusText('');

            end
        end


        function labelsOut=appendCustomLabels(~,labels)
            labelsOut=labels;
        end


        function saveVariableToWs(this,varName,varData)
            try
                temp=evalin('base',varName);%#ok<NASGU>




                dialogName=vision.getMessage('vision:labeler:ExportWarning');
                displayMessage=vision.getMessage('vision:labeler:ExportVarExistsInWS',varName);
                hFig=getDefaultFig(this.Container);
                yes=vision.getMessage('MATLAB:uistring:popupdialogs:Yes');
                no=vision.getMessage('MATLAB:uistring:popupdialogs:No');

                selection=vision.internal.labeler.handleAlert(hFig,'questionWithWaitDlg',displayMessage,dialogName,...
                this.Tool,yes,no,yes);

                if strcmpi(selection,no)
                    return;
                end
            catch

            end

            assignin('base',varName,varData);
            evalin('base',varName);
        end
    end

    methods(Hidden)


        function doLoadLabelDefinitionsFromFile(this,fileName)

            wait(this.Container);
            resetWait=onCleanup(@()resume(this.Container));

            try

                temp=load(fileName,'-mat');



                fields=fieldnames(temp);
                definitions=temp.(fields{1});

                if this.isImageLabeler()&&this.IsDataBlockedImage




                    dialogName=vision.getMessage('vision:labeler:ImportDialog');
                    displayMessage=vision.getMessage('vision:imageLabeler:DropPixelLabelDefinationsWarning');
                    yes=vision.getMessage('vision:uitools:Yes');
                    no=vision.getMessage('vision:uitools:No');
                    hFig=getDefaultFig(this.Container);
                    selection=vision.internal.labeler.handleAlert(hFig,'questionWithWaitDlg',displayMessage,dialogName,...
                    this.Tool,yes,no);

                    if strcmpi(selection,no)
                        return
                    end
                    pixLabelRowIds=definitions.Type==labelType.PixelLabel;
                    definitions(pixLabelRowIds,:)=[];

                    if isempty(definitions)
                        return
                    end

                end

                hasSignalType=any(string(definitions.Properties.VariableNames)=="SignalType");

                if hasSignalType
                    definitions=driving.internal.videoLabeler.validation.checkLabelDefinitions(definitions);
                else
                    definitions=vision.internal.labeler.validation.checkLabelDefinitions(definitions);
                end

                if ismember('PixelLabelData',definitions.Name)

                    hFig=getDefaultFig(this.Container);
                    msg=vision.getMessage('vision:labeler:LabelDefContainsPixelLabelDataMsg');
                    title=vision.getMessage('vision:labeler:LabelNameInvalidDlgName');
                    vision.internal.labeler.handleAlert(hFig,'errorWithModal',msg,title);
                    wait(this.Container);
                    return
                end

                [labelDefTable,customLabelDef]=vision.internal.labeler.splitCustomLabelDefinitions(definitions);


                deleteAllItemsLabelSetDisplay(this);


                this.Session.loadLabelDefinitions(labelDefTable);




                if hasPixelLabels(this.Session)
                    for i=1:this.Session.ROILabelSet.NumLabels
                        roiLabelType=this.Session.ROILabelSet.DefinitionStruct(i).Type;
                        roiLabelColor=this.Session.ROILabelSet.DefinitionStruct(i).Color;
                        pixelLabelID=this.Session.ROILabelSet.DefinitionStruct(i).PixelLabelID;

                        if isequal(roiLabelType,labelType.PixelLabel)
                            updatePixelLabelerLookup(this.DisplayManager,roiLabelColor,...
                            pixelLabelID);
                        end
                    end
                end

                hasCustomDisp=hasCustomDisplay(this);
                if hasCustomDisp&&(~isempty(customLabelDef))

                    customDefinitions.CustomLabelName=string({customLabelDef.CustomLabelName});
                    customDefinitions.CustomLabelDesc=string({customLabelDef.CustomLabelDesc});
                    customDefinitions.CustomLabelGroup={customLabelDef.CustomLabelGroup};

                    setCustomLabelDefinition(this,customDefinitions);
                end
            catch
                handleLoadDefinitionError(this,fileName,this.ToolName);
                return;
            end




            if~this.IsAppClosing
                if this.isImageLabeler()
                    reconfigureLabelPanelsAndToolstrip(this);
                    if hasImages(this.Session)
                        drawImage(this,this.getCurrentIndex(),true);
                    end
                else
                    reconfigureUI(this);
                end
            end
        end


        function flag=hasCustomDisplay(~)
            flag=false;
        end


        function fcnName=getGtruthFcnName(~)
            fcnName={'groundTruth'};
        end
    end




    methods(Access=public)




        function setPixelLabelMode(this,mode)
            setPixelLabelMode(this.DisplayManager,mode);
        end





        function updateSuperpixelLayout(this,count,disableLayout)
            updateSuperpixelLayout(this.DisplayManager,count,disableLayout);
        end





        function setPixelLabelMarkerSize(this,sz)
            setPixelLabelMarkerSize(this.DisplayManager,sz);
        end





        function setPixelLabelAlpha(this,alpha)
            setPixelLabelAlpha(this.DisplayManager,alpha);
            this.LabelTab.setPixelOpacitySliderValue(alpha);
            this.SemanticTab.setPixelOpacitySliderValue(alpha);
        end





        function updatePixelColorLookup(this)



            for i=1:this.Session.ROILabelSet.NumLabels
                roiLabelType=this.Session.ROILabelSet.DefinitionStruct(i).Type;
                roiLabelColor=this.Session.ROILabelSet.DefinitionStruct(i).Color;
                pixelLabelID=this.Session.ROILabelSet.DefinitionStruct(i).PixelLabelID;

                if isequal(roiLabelType,labelType.PixelLabel)
                    updatePixelLabelerLookup(this.DisplayManager,roiLabelColor,...
                    pixelLabelID);
                end
            end
        end
    end




    methods


        function viewShortcutsDialog(this)

            wait(this.Container);
            restoreWaitState=onCleanup(@()resume(this.Container));

            isShortcutsDialogOpen=~isempty(this.ShortcutsDialog)&&isvalid(this.ShortcutsDialog);


            if isShortcutsDialogOpen
                movegui(this.ShortcutsDialog.FigureHandle,'onscreen');
                figure(this.ShortcutsDialog.FigureHandle);
            else
                this.ShortcutsDialog=vision.internal.labeler.tool.ShortcutsDialog(getLocation(this.Container),...
                this.ToolType,@this.closeShortcutsDialog);
            end

        end


        function closeShortcutsDialog(this,~,~)
            delete(this.ShortcutsDialog);
        end

    end




    methods(Access=public)

        function doShowLabels(this,src,~)


            switch src.SelectedIndex
            case 1
                val='hover';

            case 2
                val='on';

            case 3
                val='off';
            end
            this.LabelVisibleInternal=val;
            setLabelVisiblity(this.DisplayManager,val);
            this.Session.setLabelVisiblityInSession(val);


            this.LabelTab.updateLabelDisplayMode(src.SelectedIndex);
            this.AlgorithmTab.updateLabelDisplayMode(src.SelectedIndex);
        end

        function changeROIColor(this,src,~)


            switch src.SelectedIndex
            case 1
                val='By Label';

            case 2
                val='By Instance';
            end
            this.ROIColorGroup=val;
            setROIColorByGroup(this.DisplayManager,val,this.Session.ROILabelSet.DefinitionStruct);

        end





        function setPolygonLabelAlpha(this,alpha)
            setPolygonLabelAlpha(this.DisplayManager,alpha);
        end





        function sendPolygonToBack(this,varargin)
            sendPolygonToBack(this.DisplayManager);
        end





        function bringPolygonToFront(this,varargin)
            bringPolygonToFront(this.DisplayManager);
        end
    end




    methods

        function viewLabelSummary(this)


            wait(this.Container);
            restoreWaitState=onCleanup(@()resume(this.Container));

            isVisualSummaryOpen=~isempty(this.VisualSummaryDisplay)&&isvalid(this.VisualSummaryDisplay);


            if isVisualSummaryOpen
                figure(this.VisualSummaryDisplay.VisualSummaryFigure);
                return;
            end



            currentTime=getCurrentValueForSlider(this);


            this.AnnotationSummaryManager=vision.internal.labeler.annotation.AnnotationSummaryManager(this.Session,currentTime);
            createAndAddAnnotationSummaries(this);



            this.VisualSummaryDisplay=vision.internal.labeler.tool.VisualSummaryDisplay(...
            this.AnnotationSummaryManager,this.ToolType);

            configure(this.VisualSummaryDisplay,@this.doFigKeyPress,...
            @this.handleCloseVisualSummary);

            addFigureToApp(this.VisualSummaryDisplay,this.Container);

            configureVisualSummaryListeners(this);

            enableVisualSummaryDock(this.LabelTab,true);
        end


        function handleCloseVisualSummary(this,~,~)
            delete(this.VisualSummaryDisplay);
            for idx=1:size(this.ListenerHandles,2)
                delete(this.ListenerHandles{idx});
            end
            enableVisualSummaryDock(this.LabelTab,false);
            setVisualSummaryDockItem(this.LabelTab,false);
        end


        function configureVisualSummaryListeners(this)


            this.ListenerHandles{1}=addlistener(this.Session.ROILabelSet,'LabelAdded',@this.addROISummaryItem);
            this.ListenerHandles{end+1}=addlistener(this.Session.ROILabelSet,'LabelRemoved',@this.deleteROISummaryItem);
            this.ListenerHandles{end+1}=addlistener(this.Session.ROILabelSet,'LabelChanged',@this.changeROISummaryItem);

            this.ListenerHandles{end+1}=addlistener(this.Session.FrameLabelSet,'LabelAdded',@this.addSceneSummaryItem);
            this.ListenerHandles{end+1}=addlistener(this.Session.FrameLabelSet,'LabelRemoved',@this.deleteSceneSummaryItem);
            this.ListenerHandles{end+1}=addlistener(this.Session.FrameLabelSet,'LabelChanged',@this.changeSceneSummaryItem);

            this.ListenerHandles{end+1}=addlistener(this.VisualSummaryDisplay,'SliderLineMoved',@this.updateOnSliderMove);
            this.ListenerHandles{end+1}=addlistener(this.VisualSummaryDisplay,'SliderLineRelease',@this.updateOnSliderRelease);
            this.ListenerHandles{end+1}=addlistener(this.VisualSummaryDisplay,'ButtonPressed',@this.updateOnVSButtonPress);

            this.ListenerHandles{end+1}=addlistener(this.VisualSummaryDisplay,'SignalChanged',@this.updateVSummaryOnSignalChange);

            this.ListenerHandles{end+1}=addlistener(this.VisualSummaryDisplay,'FigureDocked',@this.onVisualSummaryDock);
            this.ListenerHandles{end+1}=addlistener(this.VisualSummaryDisplay,'FigureUndocked',@this.onVisualSummaryUndock);
            this.ListenerHandles{end+1}=addlistener(this.VisualSummaryDisplay,'FigureClosed',@this.onVisualSummaryClose);
        end


        function updateVisualSummary(this)

            if~isempty(this.VisualSummaryDisplay)&&isvalid(this.VisualSummaryDisplay)
                if(isImageLabeler(this))
                    selectedSignalName='';
                    selectedSignalType=vision.labeler.loading.SignalType.Image;
                else
                    selectedSignalName=string(getSelectedSignalNameInVS(this));
                    displayObj=getDisplay(this,selectedSignalName);
                    selectedSignalType=displayObj.SignalType;
                end

                annotationSummary=getAnnotationInfoForSummary(this,selectedSignalName,selectedSignalType);
                annotationSummary.CurrentValue=getCurrentValueForSlider(this);
                updateAllItems(this.VisualSummaryDisplay,annotationSummary);
            end
        end

        function updateVisualSummaryWithModifiedSignals(this)
            if~isempty(this.VisualSummaryDisplay)&&isvalid(this.VisualSummaryDisplay)
                currentTime=getCurrentValueForSlider(this);
                this.AnnotationSummaryManager=vision.internal.labeler.annotation.AnnotationSummaryManager(this.Session,currentTime);
                createAndAddAnnotationSummaries(this);
                annoSummaryManager=this.AnnotationSummaryManager;
                updateVisualSummaryWithModifiedSignal(this.VisualSummaryDisplay,annoSummaryManager,this.ToolType);
            end
        end


        function updateVisualSummaryInAlgorithmMode(this)


            currentTime=getCurrentValueForSlider(this);
            this.AnnotationSummaryManager=vision.internal.labeler.annotation.AnnotationSummaryManager(this.Session,currentTime);
            createAndAddAnnotationSummaries(this);
            annoSummaryManager=this.AnnotationSummaryManager;
            updateVisualSummaryInAlgorithm(this.VisualSummaryDisplay,annoSummaryManager,this.ToolType);
        end
    end




    methods(Access=protected)

        function undoHelper(this,signalName,selectedDisplay,currentIndex)
            toUpdate=selectedDisplay.undoROI(currentIndex);
            if(toUpdate)
                currentROIs=selectedDisplay.getCurrentROIs();
                updateSessionWithROIsAnnotations(this,selectedDisplay,currentROIs);
            end

            if~isImageLabeler(this)
                if~isempty(this.ProjectedViewDisplay)&&isvalid(this.ProjectedViewDisplay)

                    this.emptyProjectedView();
                end
            end

            if~isempty(this.VisualSummaryDisplay)&&isvalid(this.VisualSummaryDisplay)
                if(this.Session.getNumPixelLabels()>0)

                    data=selectedDisplay.getEventDataFouVisualSummaryUpdate(currentIndex);
                else
                    data=[];
                end
                updateVisualSummaryROICount(this,signalName,[],data);
            end


            selectedDisplay.unhighlightCurrentROIs();
            updateAttributesSublabelsPanelIfNeeded(this);
            this.Session.IsChanged=true;
        end


        function redoHelper(this,signalName,selectedDisplay,currentIndex)
            toUpdate=selectedDisplay.redoROI(currentIndex);
            if(toUpdate)
                currentROIs=selectedDisplay.getCurrentROIs();
                updateSessionWithROIsAnnotations(this,selectedDisplay,currentROIs);
            end
            if~isempty(this.VisualSummaryDisplay)&&isvalid(this.VisualSummaryDisplay)
                if(this.Session.getNumPixelLabels()>0)
                    data=selectedDisplay.getEventDataFouVisualSummaryUpdate(currentIndex);
                else
                    data=[];
                end
                updateVisualSummaryROICount(this,signalName,[],data);
            end


            selectedDisplay.unhighlightCurrentROIs();
            updateAttributesSublabelsPanelIfNeeded(this);
            this.Session.IsChanged=true;
        end
    end


    methods(Access=protected)




        function addROISummaryItem(this,~,data)
            labelData=this.Session.ROILabelSet.queryLabel(data.Label);
            roiLabel.Names={labelData.Label};
            roiLabel.Colors={labelData.Color};
            roiLabel.Type={labelData.ROI};
            if(isImageLabeler(this))
                signalNameInVS='';
                annotationInfo.ROILabelDefs=roiLabel;
            else
                signalNameInVS=string(getSelectedSignalNameInVS(this));
                displayObj=getDisplay(this,signalNameInVS);
                selectedSignalType=displayObj.SignalType;
                annotationInfo.ROILabelDefs=getSupportedLabelDefs(this,roiLabel,selectedSignalType);
            end

            annotationInfo.TimeVector=getXAxisForSummary(this,signalNameInVS);
            annotationInfo.NumROIAnnotations.(labelData.Label)=zeros(1,length(annotationInfo.TimeVector));
            annotationInfo.CurrentValue=getCurrentValueForSlider(this);
            if~isempty(annotationInfo.ROILabelDefs.Names)
                this.VisualSummaryDisplay.addROISummaryItems(annotationInfo);
                this.VisualSummaryDisplay.doPanelPositionUpdate();
            end
        end


        function addSceneSummaryItem(this,~,data)
            labelData=this.Session.FrameLabelSet.queryLabel(data.Label);
            sceneLabel.Names={labelData.Label};
            sceneLabel.Colors={labelData.Color};
            annotationInfo.SceneLabelDefs=sceneLabel;

            signalNameInVS=getSelectedSignalNameInVS(this);

            annotationInfo.TimeVector=getXAxisForSummary(this,signalNameInVS);
            annotationInfo.NumSceneAnnotations.(labelData.Label)=zeros(1,length(annotationInfo.TimeVector));
            annotationInfo.CurrentValue=getCurrentValueForSlider(this);

            this.VisualSummaryDisplay.addSceneSummaryItems(annotationInfo);
            this.VisualSummaryDisplay.doPanelPositionUpdate();
        end


        function deleteROISummaryItem(this,~,data)
            if isVisualSummaryOpen(this)
                newData.LabelName=data.Label;
                newData.Index=this.roiLabelNameToID(data.Label);
                newData.ROINumLabels=this.Session.ROILabelSet.NumLabels;
                newData.SceneNumLabels=this.Session.FrameLabelSet.NumLabels;
                this.VisualSummaryDisplay.deleteROIItem(newData);
            end
        end


        function changeROISummaryItem(this,~,data)
            if isVisualSummaryOpen(this)
                if~isempty(data.Color)
                    index=this.roiLabelNameToID(data.Label);
                    this.VisualSummaryDisplay.changeColorROIItem(index,data.Label,data.Color);
                elseif~isempty(data.Label)
                    index=this.roiLabelNameToID(data.OldLabel);
                    this.VisualSummaryDisplay.renameROIItem(index,data.OldLabel,data.Label);
                end
            end
        end


        function changeSceneSummaryItem(this,~,data)
            if isVisualSummaryOpen(this)
                if~isempty(data.Color)
                    index=this.sceneLabelNameToID(data.Label);
                    this.VisualSummaryDisplay.changeColorsceneItem(index,data.Label,data.Color);
                elseif~isempty(data.OldLabel)
                    index=this.sceneLabelNameToID(data.Label);
                    this.VisualSummaryDisplay.renamesceneItem(index,data.OldLabel,data.Label);
                end
            end
        end


        function deleteSceneSummaryItem(this,~,data)
            newData.LabelName=data.Label;
            newData.Index=this.sceneLabelNameToID(data.Label);
            this.VisualSummaryDisplay.deleteSceneItem(newData);
        end




        function updateVisualSummaryROICount(this,signalName,~,data)

            if isa(data,'vision.internal.labeler.tool.PixelLabelEventData')
                currentReadIndex=data.Data.Index;
            else
                currentReadIndex=getCurrentFrameIndex(this,signalName);
            end


            allLabelNames=getROILabelNames(this.VisualSummaryDisplay);
            labelCounts=zeros(numel(allLabelNames),1);
            isPixelLabel=zeros(numel(allLabelNames),1);
            isChanged=zeros(numel(allLabelNames),1);
            allLabelIDs=zeros(numel(allLabelNames),1);
            for idx=1:numel(allLabelNames)
                allLabelIDs(idx)=this.roiLabelNameToID(allLabelNames{idx});
                if this.Session.isaPixelLabel(allLabelNames{idx})
                    isPixelLabel(idx)=true;
                else
                    isChanged(idx)=true;
                end
            end


            [~,labelNames,sublabelNames]=this.Session.ROIAnnotations.queryAnnotationBySignalName(signalName,currentReadIndex);
            for idx=1:numel(labelNames)
                if isempty(sublabelNames{idx})
                    markedLabelID=this.roiLabelNameToID(labelNames{idx});
                    labelCounts(markedLabelID==allLabelIDs)=labelCounts(markedLabelID==allLabelIDs)+1;
                end
            end


            if isa(data,'vision.internal.labeler.tool.PixelLabelEventData')
                allPixelLabelIDs={this.Session.ROILabelSet.DefinitionStruct.PixelLabelID};

                for idx=1:numel(allLabelNames)

                    if this.Session.isaPixelLabel(allLabelNames{idx})

                        markedLabelID=this.roiLabelNameToID(allLabelNames{idx});
                        labelCounts(markedLabelID==allLabelIDs)=sum(data.Data.Label(:)==allPixelLabelIDs{idx})/numel(data.Data.Label);
                        isChanged(markedLabelID==allLabelIDs)=true;
                    end
                end
            end

            if isa(data,'vision.internal.labeler.tool.PixelLabelEventData')
                currentUpdateIndex=data.Data.Index-getStartIndex(this,signalName)+1;
            else
                currentUpdateIndex=getCurrentFrameIndex(this,signalName)-getStartIndex(this,signalName)+1;
            end
            if(currentUpdateIndex==getEndIndex(this,signalName))
                isChangeInLastFrame=1;
            else
                isChangeInLastFrame=0;
            end

            if isImageLabeler(this)
                isChangeInLastFrame=0;
                signalName='';
            end
            this.VisualSummaryDisplay.updateROICounts(allLabelIDs,signalName,labelCounts,currentUpdateIndex,isPixelLabel,isChanged,isChangeInLastFrame);
        end


        function updateVisualSummarySceneCount(this,signalName,labelName,currentIndices,value)

            if isVisualSummaryOpen(this)



                startIndex=getStartIndex(this,signalName);
                currentIndices=currentIndices-startIndex+1;
                if(currentIndices==getEndIndex(this,signalName))
                    isChangeInLastFrame=1;
                else
                    isChangeInLastFrame=0;
                end
                labelID=this.sceneLabelNameToID(labelName);

                updateSceneCounts(this.VisualSummaryDisplay,signalName,labelID,labelName,value,currentIndices,isChangeInLastFrame);
            end
        end


        function updateVisualSummaryXAxes(this,~,~)
            updateVisualSummaryWithModifiedSignals(this);
        end


        function updateVisualSummarySlider(this,~,~)
            currentValue=getCurrentValueForSlider(this);
            updateSliderLine(this.VisualSummaryDisplay,currentValue);
        end


        function onVisualSummaryDock(this,varargin)



            setDisplayTileLocation(this,this.VisualSummaryDisplay,1);
            setTabName(this,this.VisualSummaryDisplay,this.NameVisualSummaryDisplay);

            enableVisualSummaryButton(this.LabelTab,false);
            setVisualSummaryDockItem(this.LabelTab,true);
        end

        function updateVSummaryOnSignalChange(this,varargin)

            selectedSignalName=varargin{2}.Source.SelectedSignalName;
            displayObj=getDisplay(this,selectedSignalName);
            selectedSignalType=displayObj.SignalType;
            isValidRange=isSignalRangeValid(this,selectedSignalName);
            if isValidRange
                annotationInfo=getAnnotationInfoForSummary(this,selectedSignalName,selectedSignalType);
                annotationInfo.CurrentValue=getCurrentValueForSlider(this);
            else
                annotationInfo=[];
            end
            this.VisualSummaryDisplay.updateVSummaryOnSignalChange(annotationInfo,selectedSignalType,isValidRange);
        end


        function onVisualSummaryUndock(this,varargin)
            enableVisualSummaryButton(this.LabelTab,true);
            setVisualSummaryDockItem(this.LabelTab,false);
        end


        function onVisualSummaryClose(this,varargin)



            if~this.IsAppClosing
                enableVisualSummaryButton(this.LabelTab,true);
            end
        end


        function enableSliderCallback(this,flag)


            if~isempty(this.VisualSummaryDisplay)&&isvalid(this.VisualSummaryDisplay)
                this.VisualSummaryDisplay.configureSliderCallback(flag);
            end
        end




        function updateOnVSButtonPress(this,~,data)









            selectedSignalName=data.SignalName;

            if data.IsLeftBtnPressed
                searchFrom='last';
                searchStartIdx=getStartIndex(this,selectedSignalName);
                searchEndIdx=max(getCurrentIndex(this,selectedSignalName)-1,searchStartIdx);
            else
                searchFrom='first';
                searchEndIdx=getEndIndex(this,selectedSignalName);
                searchStartIdx=min(getCurrentIndex(this,selectedSignalName)+1,searchEndIdx);
            end



            indices=searchStartIdx:searchEndIdx;


            if data.IsGlobalButton
                roiLabelNames={this.Session.ROILabelSet.DefinitionStruct.Name};
                sceneLabelNames={this.Session.FrameLabelSet.DefinitionStruct.Name};
            else
                roiLabelNames={};
                sceneLabelNames={};
                if data.IsCompareButton
                    if strcmpi(data.LabelType,'scene')
                        sceneLabelNames={this.Session.FrameLabelSet.DefinitionStruct(data.LabelName).Name};
                    else
                        roiLabelNames={this.Session.ROILabelSet.DefinitionStruct(data.LabelName).Name};
                    end
                else
                    if strcmpi(data.LabelType,'scene')
                        sceneLabelNames={data.LabelName};
                    else
                        roiLabelNames={data.LabelName};
                    end
                end
            end

            numIndices=length(indices);


            indicesPerIter=100;
            iterCount=0;
            startIdx=0;
            endIdx=0;



            while numIndices>0
                if strcmp(searchFrom,'first')
                    startIdx=endIdx+1;
                    if numIndices>indicesPerIter
                        endIdx=startIdx+indicesPerIter-1;
                    else
                        endIdx=startIdx+numIndices-1;
                    end
                else
                    endIdx=numIndices;
                    if numIndices>indicesPerIter
                        startIdx=endIdx-indicesPerIter+1;
                    else
                        startIdx=endIdx-numIndices+1;
                    end
                end


                queryIndices=indices(startIdx:endIdx);

                roiNumAnnotations=queryROISummary(this.Session,selectedSignalName,roiLabelNames,queryIndices);
                sceneNumAnnotations=querySceneSummary(this.Session,selectedSignalName,sceneLabelNames,queryIndices);

                totalNumAnnotations=zeros(1,numel(queryIndices));

                for idx=1:numel(roiLabelNames)
                    totalNumAnnotations=totalNumAnnotations+roiNumAnnotations.(roiLabelNames{idx});
                end

                for idx=1:numel(sceneLabelNames)
                    totalNumAnnotations=totalNumAnnotations+sceneNumAnnotations.(sceneLabelNames{idx});
                end


                jumpIndex=find(totalNumAnnotations==0,1,searchFrom);

                if~isempty(jumpIndex)
                    break;
                else
                    numIndices=numIndices-indicesPerIter;
                    iterCount=iterCount+1;
                end
            end


            if isempty(jumpIndex)||(jumpIndex==0)
                jumpIndex=getCurrentIndex(this,selectedSignalName);
            else
                jumpIndex=searchStartIdx+(startIdx-1)+(jumpIndex-1);
            end

            updateFrameAndSlider(this,selectedSignalName,jumpIndex);
        end


        function TF=isVisualSummaryOpen(this)
            TF=~isempty(this.VisualSummaryDisplay)&&isvalid(this.VisualSummaryDisplay);
        end


        function doReopenVisualSummary(this,reopenVisualSummary,visualSummaryDocked)

            if reopenVisualSummary||visualSummaryDocked
                openVisualSummary(this);

drawnow
                if visualSummaryDocked
                    dockVisualSummary(this.VisualSummaryDisplay);
                end
            end
        end


        function reopenVisualSummary=getReopenVisualSummaryFlag(this)


            reopenVisualSummary=false;
            if~isempty(this.VisualSummaryDisplay)&&isvalid(this.VisualSummaryDisplay)
                if ishandle(this.VisualSummaryDisplay.VisualSummaryFigure)
                    close(this.VisualSummaryDisplay.VisualSummaryFigure);
                end
                handleCloseVisualSummary(this);
                reopenVisualSummary=true;
            end
        end


        function isVisualSummaryOpen=openVisualSummary(this)
            anyLabels=this.Session.HasROILabels||this.Session.HasFrameLabels;

            if anyLabels
                enableVisualSummaryButton(this.LabelTab,true);
                viewLabelSummary(this);
            else
                enableVisualSummaryButton(this.LabelTab,false);
            end

            isVisualSummaryOpen=~isempty(this.VisualSummaryDisplay)&&isvalid(this.VisualSummaryDisplay);
        end


        function updateVisualSummaryButton(this,additionalConditions)

            if nargin<2
                additionalConditions=true;
            end

            anyLabels=this.Session.HasROILabels||this.Session.HasFrameLabels;

            isVisualSummaryDocked=~isempty(this.VisualSummaryDisplay)...
            &&isvalid(this.VisualSummaryDisplay)...
            &&isDocked(this.VisualSummaryDisplay);

            enableFlag=anyLabels&&~isVisualSummaryDocked&&additionalConditions;
            enableVisualSummaryButton(this.LabelTab,enableFlag);
        end



        function configureDisplays(this)




            configure(this.ROILabelSetDisplay,...
            @(varargin)this.protectOnDelete(@this.doROIPanelItemSelectionCallback,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doROILabelAdditionCallback,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doROISublabelAdditionCallback,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doROIAttributeAdditionCallback,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doROIPanelItemModificationCallback,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doROIPanelItemDeletionCallback,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doROIPanelItemMoveCallback,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doROIPanelItemBeingEditedCallback,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doROIPanelItemROIVisibilityCallback,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doFigKeyPress,varargin{:}));


            configure(this.FrameLabelSetDisplay,...
            @(varargin)this.protectOnDelete(@this.doFrameLabelCallback,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doFrameUnlabelCallback,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doFrameLabelSelectionCallback,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doFrameLabelAdditionCallback,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doFrameLabelModificationCallback,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doFrameLabelDeletionCallback,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doFrameLabelMoveCallback,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doFigKeyPress,varargin{:}));

            configure(this.AttributesSublabelsDisplay,...
            @(varargin)this.protectOnDelete(@this.doAttributePanelItemModificationCallback,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doFigKeyPress,varargin{:}));

            configure(this.SignalNavigationDisplay,...
            @(varargin)this.protectOnDelete(@this.doFigKeyPress,varargin{:}));

            defaultDisplay=getDefaultDisplay(this.DisplayManager);
            addlistener(defaultDisplay,'DisplayClosing',@(src,evt)this.displayClosing(evt.DisplayFig,evt.IsAppClosing));
        end

    end

    methods



        function configureNewDisplay(this,newDisplay)
            configure(newDisplay,...
            @(varargin)this.protectOnDelete(@this.doFigKeyPress,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doLabelIsChanged,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doROIInstanceIsSelected,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doStartAppWait,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doFinishAppWait,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doDisableAppForDrawing,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doEnableAppForDrawing,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doEnableGrabCutEditTools,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doDisableGrabCutEditTools,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doMoveMultipleROI,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doToolbarButtonChanged,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doPasteROIMenuCallback,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doPastePixelROIMenuCallback,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doCopyDisplayNameCallbackForPixelROI,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doCopyPixelROIMenuCallback,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doCutPixelROIMenuCallback,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doDeletePixelROIMenuCallback,varargin{:}));

            configureNewDisplayHelper(this,newDisplay);

            addlistener(newDisplay,'DisplayClosing',@(src,evt)this.displayClosing(evt.DisplayFig,evt.IsAppClosing));
            addlistenerForUpdateUndoRedoQAB(newDisplay,@this.undoRedoQABCallback);
        end
    end


    methods(Access=private)





        function signalNameInVS=getSelectedSignalNameInVS(this)
            if numel(this.AnnotationSummaryManager.SignalNames)<1
                signalNameInVS='';
            elseif numel(this.AnnotationSummaryManager.SignalNames{:})==1
                signalNameInVS=this.AnnotationSummaryManager.SignalNames{1};
            else
                signalNameInVS=this.VisualSummaryDisplay.getSelectedSignalName();
            end
        end


        function createAndAddAnnotationSummaries(this)

            [selectedSignalName,selectedSignalType,signalNames,selectedSignalId]=getSignalInfoFromDisplay(this);
            isValidRange=isSignalRangeValid(this,selectedSignalName);

            if((~isempty(selectedSignalName))&&isValidRange)
                annotationInfo=getAnnotationInfoForSummary(this,selectedSignalName,selectedSignalType);
                annotationInfo.CurrentValue=getCurrentValueForSlider(this);
            else
                annotationInfo=[];
            end
            createAndAddAnnotationSummary(this.AnnotationSummaryManager,...
            annotationInfo,selectedSignalId,selectedSignalType,...
            signalNames,isValidRange);
        end


        function id=roiLabelNameToID(this,name)
            labelNames=getROILabelNames(this.VisualSummaryDisplay);
            id=find(strcmpi(name,labelNames));
        end


        function id=sceneLabelNameToID(this,name)
            labelNames={this.Session.FrameLabelSet.DefinitionStruct.Name};
            id=find(strcmpi(name,labelNames));
        end
    end


    methods(Static)

        function ValidPixelLabelFlag=checkPixelLabelValidity(this,roiLabel)
            NumPixelLabels=getNumPixelLabels(this.Session);
            ValidPixelLabelFlag=true;





            if(NumPixelLabels>=255&&isempty(roiLabel.PixelLabelID))
                ValidPixelLabelFlag=false;
                tool=this.Tool;
                hFig=getDefaultFig(this.Container);
                errorMessage=vision.getMessage('vision:labeler:PixelIdExceeds255',roiLabel.Label);
                dialogName=getString(message('vision:labeler:PixelIdExceedsDlgName'));
                vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,tool);
                return;
            end
        end
    end


    methods(Access=protected)


        function proceedFurther=issueImportWarning(this,warningMessage)

            hasAnyLabelDefs=this.ROILabelSetDisplay.NumItems>0||this.FrameLabelSetDisplay.NumItems>0;

            if hasAnyLabelDefs

                dialogName=vision.getMessage('vision:labeler:ImportDialog');
                displayMessage=vision.getMessage('vision:labeler:ImportWarningDisplay',warningMessage);
                hFig=getDefaultFig(this.Container);
                yes=vision.getMessage('MATLAB:uistring:popupdialogs:Yes');
                no=vision.getMessage('MATLAB:uistring:popupdialogs:No');

                selection=vision.internal.labeler.handleAlert(hFig,'questionWithWaitDlg',displayMessage,dialogName,...
                this.Tool,yes,no,yes);

                if strcmpi(selection,no)
                    proceedFurther=false;
                else
                    proceedFurther=true;
                end
            else
                proceedFurther=true;
            end
        end


        function deleteAllItemsLabelSetDisplay(this)
            deleteAllItems(this.ROILabelSetDisplay);
            deleteAllItems(this.FrameLabelSetDisplay);
            if~isempty(this.AttributesSublabelsDisplay)
                deleteAllItems(this.AttributesSublabelsDisplay);
            end
        end


        function handleLoadDefinitionError(this,fullFileName,toolName)
            [~,fileName,ext]=fileparts(fullFileName);
            fileName=strcat(fileName,ext);
            hFig=getDefaultFig(this.Container);
            errorMessage=getString(message('vision:labeler:UnableToLoadDefinitionsDlgMessage',fullFileName,fileName,toolName));
            dialogName=getString(message('vision:labeler:UnableToLoadDefinitionsDlgName'));
            vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,this.Tool);

            resume(this.Container);
            drawnow();
        end


        function canImportLabels=importPixelLabelHelper(this,gTruth,currentDefinitions)

            if isa(gTruth,'groundTruthMultisignal')
                labelTypeCol='LabelType';
            else
                labelTypeCol='Type';
            end

            isPixelLabelType=gTruth.LabelDefinitions.(labelTypeCol)==labelType.PixelLabel;
            hasPixelLabels=any(isPixelLabelType);
            currentSessionHasPixelLabels=this.Session.hasPixelLabels;
            canImportLabels=false;
            hFig=getDefaultFig(this.Container);

            if hasPixelLabels

                id=gTruth.LabelDefinitions{isPixelLabelType,'PixelLabelID'};

                isError=false;


                allScalarLabelIDs=all(cellfun(@(x)isscalar(x),id));
                if~allScalarLabelIDs
                    isError=true;
                else
                    anyLabelIDAreZero=any(cellfun(@(x)x==0,id));
                    if anyLabelIDAreZero
                        isError=true;
                    end
                end

                if isError
                    errorMessage='Pixel label IDs must be scalars and be between 1 and 255.';
                    dialogName='Invalid PixelLabelID';
                    vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,this.Tool);

                    return;
                end

                if currentSessionHasPixelLabels


                    labelDefinitions=gTruth.LabelDefinitions;


                    currentPixelDefinitions=currentDefinitions(currentDefinitions.(labelTypeCol)==labelType.PixelLabel,:);
                    labelDefinitions=labelDefinitions(labelDefinitions.(labelTypeCol)==labelType.PixelLabel,:);

                    if height(currentPixelDefinitions)~=height(labelDefinitions)

                        errorMessage=vision.getMessage('vision:labeler:ImportIncompatibleGroundTruthNameMismatch');
                        dialogName=vision.getMessage('vision:labeler:ImportError');
                        vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,this.Tool);
                        return

                    else

                        currentPixelDefinitions=sortrows(currentPixelDefinitions,'Name');
                        labelDefinitions=sortrows(labelDefinitions,'Name');

                        namesMatch=isequal(currentPixelDefinitions.Name,labelDefinitions.Name);
                        idsMatch=isequal(currentPixelDefinitions.PixelLabelID,labelDefinitions.PixelLabelID);

                        canImportLabels=namesMatch&&idsMatch;

                        if~namesMatch
                            errorMessage=vision.getMessage('vision:labeler:ImportIncompatibleGroundTruthNameMismatch');
                            dialogName=vision.getMessage('vision:labeler:ImportError');
                            vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,this.Tool);
                            return;
                        end

                        if~idsMatch
                            errorMessage=vision.getMessage('vision:labeler:ImportIncompatibleGroundTruthLabelIDMismatch');
                            dialogName=vision.getMessage('vision:labeler:ImportError');
                            vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,this.Tool);
                            return;
                        end
                    end

                else
                    canImportLabels=true;
                end
            else

                canImportLabels=true;
            end
        end


        function out=expandAutoLabelStructAndAddUUID(this,in)
            N=getNumLabelsForScalarStruct(this,in);
            hasAttributes=isfield(in,'Attributes');
            if hasAttributes
                out(1,N)=struct('Name','','Type',[],'Position',[],'LabelUID','','Attributes',[]);
            else
                out(1,N)=struct('Name','','Type',[],'Position',[],'LabelUID','');
            end
            for i=1:N
                out(i).Name=in.Name;
                out(i).Type=in.Type;
                out(i).Position=getPositionFromScalarStruct(this,in,i);
                out(i).LabelUID=vision.internal.getUniqueID();

                if hasAttributes&&~isempty(in.Attributes)
                    out(i).Attributes=in.Attributes(i);
                end
            end
        end

    end

    methods(Access=protected)



        function modifyAttribNameInLeftPanel(this,attribData,newName)

            currItemIdx=this.ROILabelSetDisplay.CurrentSelection;
            this.ROILabelSetDisplay.modifyItemAttributeName(currItemIdx,attribData,newName);
        end


        function modifyLabelNameInLeftPanel(this,oldLabelName,newLabelName)

            currItemIdx=this.ROILabelSetDisplay.CurrentSelection;
            this.ROILabelSetDisplay.modifyItemName(currItemIdx,newLabelName,true);

            roiSublabel=this.Session.ROISublabelSet.querySublabelFamily(newLabelName);
            for i=1:numel(roiSublabel)
                itemID=this.ROILabelSetDisplay.getItemID(oldLabelName,roiSublabel{i}.Sublabel);
                assert(itemID>0);
                this.ROILabelSetDisplay.modifyItemName(itemID,newLabelName,false);
            end
        end


        function modifyFrameLabelNameInLeftPanel(this,newFrameLabelName)
            currItemIdx=this.FrameLabelSetDisplay.CurrentSelection;
            this.FrameLabelSetDisplay.modifyItemName(currItemIdx,newFrameLabelName,true);
        end


        function modifyColorInLabelDefinitionPanel(this,newLabelColor)
            this.ROILabelSetDisplay.modifyItemColor(newLabelColor);
        end


        function modifySublabelNameInLeftPanel(this,newSublabelName)
            currItemIdx=this.ROILabelSetDisplay.CurrentSelection;
            this.ROILabelSetDisplay.modifyItemName(currItemIdx,newSublabelName,true);
        end


        function modifyLabelNameInCurrentROIs(this,oldLabelName,newLabelName)
            this.DisplayManager.modifyLabelNameInCurrentROIs(oldLabelName,newLabelName);
        end


        function modifyLabelColorInCurrentROIs(this,LabelName,newLabelColor)
            this.DisplayManager.modifyLabelColorInCurrentROIs(LabelName,newLabelColor);
        end


        function modifySublabelNameInCurrentROIs(this,labelName,oldSublabelName,newSublabelName)
            this.DisplayManager.modifySublabelNameInCurrentROIs(labelName,oldSublabelName,newSublabelName);
        end


        function modifySublabelColorInCurrentROIs(this,labelName,sublabelName,newSublabelColor)
            this.DisplayManager.modifySublabelColorInCurrentROIs(labelName,sublabelName,newSublabelColor);
        end


        function modifyLabelOrSublabelColor(this,roiLabelSublabel,oldSelectionInfo)
            isLabelSelected=oldSelectionInfo.IsLabelItemSelected;

            if isLabelSelected
                oldLabelColor=oldSelectionInfo.Color;
                newLabelColor=roiLabelSublabel.Color;

                modifyLabelSelection(this,oldLabelColor,newLabelColor);

                modifyLabelColor(this,oldSelectionInfo.LabelName,newLabelColor);

                modifyColorInLabelDefinitionPanel(this,newLabelColor);
                if~isequal(roiLabelSublabel.ROI,labelType.PixelLabel)
                    modifyLabelColorInCurrentROIs(this,oldSelectionInfo.LabelName,newLabelColor);
                else
                    updatePixelLabelerLookup(this.DisplayManager,newLabelColor,roiLabelSublabel.PixelLabelID);
                    updateActivePolygonColorInCurrentFrame(this.DisplayManager,oldSelectionInfo.LabelName,newLabelColor);
                    this.DisplayManager.updatePixelLabelColorInCurrentFrame();
                end

            else
                labelName=oldSelectionInfo.LabelName;
                subLabelName=oldSelectionInfo.SublabelName;
                oldSubLabelColor=oldSelectionInfo.Color;
                newSubLabelColor=roiLabelSublabel.Color;

                modifySublabelSelection(this,labelName,oldSubLabelColor,newSubLabelColor);
                modifySublabelColor(this,labelName,subLabelName,newSubLabelColor);

                modifyColorInLabelDefinitionPanel(this,newSubLabelColor);
                modifySublabelColorInCurrentROIs(this,labelName,subLabelName,newSubLabelColor);

            end

            updateAttributesSublabelsPanel(this);
        end


        function modifyLabelSelection(this,oldProperty,newProperty)
            selectedItemInfo=getSelectedItemInfo(this);

            isAnyItemSelected=selectedItemInfo.isAnyItemSelected;
            roiItemDataObj=selectedItemInfo.roiItemDataObj;
            if isAnyItemSelected
                assert(isa(roiItemDataObj,'vision.internal.labeler.ROILabel'))
                if ischar(oldProperty)
                    if strcmp(roiItemDataObj.Label,oldProperty)
                        roiItemDataObj.Label=newProperty;
                    end
                else
                    if isequal(roiItemDataObj.Color,oldProperty)
                        roiItemDataObj.Color=newProperty;
                    end
                end
                this.DisplayManager.updateLabelSelection(roiItemDataObj);
            end
        end


        function modifySublabelSelection(this,labelName,oldProperty,newProperty)
            selectedItemInfo=getSelectedItemInfo(this);

            isAnyItemSelected=selectedItemInfo.isAnyItemSelected;
            roiItemDataObj=selectedItemInfo.roiItemDataObj;
            if isAnyItemSelected
                assert(strcmp(roiItemDataObj.LabelName,labelName));
                assert(isa(roiItemDataObj,'vision.internal.labeler.ROISublabel'))
                if ischar(oldProperty)
                    if strcmp(roiItemDataObj.Sublabel,oldProperty)
                        roiItemDataObj.Sublabel=newProperty;
                    end
                else
                    if isequal(roiItemDataObj.Color,oldProperty)
                        roiItemDataObj.Color=newProperty;
                    end
                end
                this.DisplayManager.updateLabelSelection(roiItemDataObj);
            end
        end


        function modifyLabelOrSublabelName(this,roiLabelSublabel,oldSelectionInfo)
            isLabelSelected=oldSelectionInfo.IsLabelItemSelected;

            if isLabelSelected
                oldLabelName=oldSelectionInfo.LabelName;
                newLabelName=roiLabelSublabel.Label;

                modifyLabelSelection(this,oldLabelName,newLabelName);

                modifyLabelName(this,oldLabelName,newLabelName);

                modifyLabelNameInLeftPanel(this,oldLabelName,newLabelName);
                if~isequal(roiLabelSublabel.ROI,labelType.PixelLabel)
                    modifyLabelNameInCurrentROIs(this,oldLabelName,newLabelName);
                else
                    updateActivePolygonNameInCurrentFrame(this.DisplayManager,oldLabelName,newLabelName);
                end
            else
                labelName=oldSelectionInfo.LabelName;
                oldSublabelName=oldSelectionInfo.SublabelName;
                newSublabelName=roiLabelSublabel.Sublabel;

                modifySublabelSelection(this,labelName,oldSublabelName,newSublabelName);
                modifySublabelName(this,labelName,oldSublabelName,newSublabelName);

                modifySublabelNameInLeftPanel(this,newSublabelName);
                modifySublabelNameInCurrentROIs(this,labelName,oldSublabelName,newSublabelName);

            end

            updateAttributesSublabelsPanel(this);
        end


        function modifySublabelColor(this,labelName,subLabelName,newSublabelColor)
            this.Session.modifySublabelColor(labelName,subLabelName,newSublabelColor);
        end


        function modifyAttributeName(this,attribData,newName)
            isLabelSelected=isempty(attribData.SublabelName);
            if isLabelSelected
                modifyNameOfLabelAttribute(this,attribData,newName);
            else
                modifyNameOfSublabelAttribute(this,attribData,newName);
            end
            modifyAttribNameInAttribSublabelPanel(this,attribData,newName);
            modifyAttribNameInLeftPanel(this,attribData,newName);
        end


        function modifyAttributeValue(this,attribData,newValue)
            isLabelSelected=isempty(attribData.SublabelName);
            if isLabelSelected
                modifyValueOfLabelAttributeList(this,attribData,newValue);
            else
                modifyValueOfSublabelAttributeList(this,attribData,newValue);
            end
            modifyAttribListInAttribSublabelPanel(this,attribData,newValue);
        end


        function modifyAttributeDescription(this,attribData,newDescription)
            isLabelSelected=isempty(attribData.SublabelName);
            if isLabelSelected
                modifyDescOfLabelAttribute(this,attribData,newDescription);
            else
                modifyDescOfSublabelAttribute(this,attribData,newDescription);
            end
            modifyAttribDescriptionInAttribSublabelPanel(this,attribData,newDescription);
        end


        function modifyItemMenuLabel(this,roi)

            isLabel=isa(roi,'vision.internal.labeler.ROILabel');
            if isLabel
                labelName=roi.Label;
                sublabelName='';
            else
                labelName=roi.LabelName;
                sublabelName=roi.Sublabel;
            end

            itemID=this.ROILabelSetDisplay.getItemID(labelName,sublabelName);
            this.ROILabelSetDisplay.modifyItemMenuLabel(itemID,isLabel);
        end


        function nextROIPanelItemSelectionCallback(this,varargin)

            this.ROILabelSetDisplay.selectNextItem();
        end


        function previousROIPanelItemSelectionCallback(this,varargin)

            this.ROILabelSetDisplay.selectPrevItem();
        end


        function roiSublabel=updateSublabelDefColor(this,roiSublabel)
            if isempty(roiSublabel.Color)
                labelName=roiSublabel.LabelName;
                color=this.Session.ROILabelSet.queryLabelColor(labelName);
                roiSublabel.Color=color;
            end
        end


        function doROIPanelItemModificationCallback(this,~,data)


            itemInfo=getItemInfoFromData(this,data.Data);

            isLabelItemSelected=itemInfo.IsLabel;
            isGroupItemSelected=itemInfo.IsGroup;
            labelName=itemInfo.LabelName;
            sublabelName=itemInfo.SublabelName;
            color=itemInfo.Color;

            itemID=data.Index;

            if isLabelItemSelected
                roiLabel=this.Session.ROILabelSet.queryLabel(labelName);
                sublabelNames=this.Session.queryROISublabelFamilyNames(labelName);



                labelAddMode=false;
                dlg=getROILabelDefinitionDialog(this,labelAddMode,roiLabel,sublabelNames);
            elseif isGroupItemSelected
                labelGroupName=data.Data.Group;
                dlg=vision.internal.labeler.tool.GroupModifyDialog(...
                this.Tool,labelGroupName,this.Session.ROILabelSet,this.Container.getDefaultFig);
            else
                roiSublabel=this.Session.ROISublabelSet.querySublabel(labelName,sublabelName);
                roiSublabel=updateSublabelDefColor(this,roiSublabel);

                dlg=vision.internal.labeler.tool.ROISublabelDefinitionDialog(...
                this.Tool,this.Session.ROISublabelSet,this.SupportedROISublabelTypes,labelName,roiSublabel,[]);
            end

            wait(dlg);

            if~dlg.IsCanceled

                dialogData=dlg.getDialogData();

                if isLabelItemSelected



                    toUpdate=[dlg.ColorChangedInEditMode;dlg.NameChangedInEditMode];

                    dialogData.Color=dlg.Color;

                    roiLabel=dialogData.Label;
                    if~isempty(data.Data.PixelLabelID)
                        roiLabel.PixelLabelID=data.Data.PixelLabelID;
                    end

                    if dlg.NameChangedInEditMode
                        oldSelectionInfo=struct('IsLabelItemSelected',isLabelItemSelected,...
                        'LabelName',labelName,...
                        'SublabelName',sublabelName,...
                        'Color',color);

                        if~this.Session.isValidName(roiLabel.Label)
                            hFig=getDefaultFig(this.Container);
                            errorMessage=vision.getMessage('vision:labeler:LabelNameExistsDlgMsg',roiLabel.Label);
                            dialogName=getString(message('vision:labeler:LabelNameExistsDlgName'));
                            vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,this.Tool);
                            return;
                        end
                        modifyLabelOrSublabelName(this,roiLabel,oldSelectionInfo);
                        this.DisplayManager.updateLabelInUndoRedoBuffer(roiLabel,oldSelectionInfo,toUpdate);
                        this.DisplayManager.renameLabelInClipboard(roiLabel,oldSelectionInfo);

                        if toUpdate(1)&&toUpdate(2)

                            labelName=roiLabel.Label;
                        end
                    end

                    if dlg.ColorChangedInEditMode
                        oldSelectionInfo=struct('IsLabelItemSelected',isLabelItemSelected,...
                        'LabelName',labelName,...
                        'SublabelName',sublabelName,...
                        'Color',color);
                        modifyLabelOrSublabelColor(this,roiLabel,oldSelectionInfo);
                        this.DisplayManager.updateLabelInUndoRedoBuffer(roiLabel,oldSelectionInfo,toUpdate);
                        if~isequal(roiLabel.ROI,labelType.PixelLabel)
                            this.DisplayManager.colorChangeInClipboard(roiLabel,oldSelectionInfo);
                        else





                            this.DisplayManager.colorChangeInClipboardPixel(roiLabel);
                        end
                    end

                    if dlg.DescriptionChangedInEditMode
                        modifyItemDescription(this.ROILabelSetDisplay,itemID,roiLabel);

                        updateROILabelDescription(this.Session,...
                        roiLabel.Label,roiLabel.Description);
                    end

                    if dlg.GroupChangedInEditMode
                        updateROILabelGroup(this.Session,roiLabel.Label,roiLabel.Group);


                        updateGroupOnLabelEdit(this.ROILabelSetDisplay,dialogData,...
                        this.Session.ROILabelSet);
                    end

                elseif isGroupItemSelected

                    if dialogData.GroupNameChanged
                        oldGroupName=data.Data.Group;
                        newGroupName=dialogData.Group;
                        updateROIGroupNames(this.Session,oldGroupName,newGroupName);
                        updateOnGroupNameChange(this.ROILabelSetDisplay,itemID,newGroupName);
                    end

                else



                    toUpdate=[dlg.ColorChangedInEditMode;dlg.NameChangedInEditMode];

                    dialogData.Color=dlg.Color;

                    roiSubLabel=dialogData;

                    if dlg.NameChangedInEditMode
                        oldSelectionInfo=struct('IsLabelItemSelected',isLabelItemSelected,...
                        'LabelName',labelName,...
                        'SublabelName',sublabelName);

                        modifyLabelOrSublabelName(this,roiSubLabel,oldSelectionInfo);
                        this.DisplayManager.updateLabelInUndoRedoBuffer(roiSubLabel,oldSelectionInfo,toUpdate);
                        this.DisplayManager.renameLabelInClipboard(roiSubLabel,oldSelectionInfo);
                        if toUpdate(1)&&toUpdate(2)

                            sublabelName=roiSubLabel.Sublabel;
                        end
                    end

                    if dlg.DescriptionChangedInEditMode
                        modifyItemDescription(this.ROILabelSetDisplay,itemID,roiSubLabel);

                        if dlg.NameChangedInEditMode
                            sublabelName=roiSubLabel.Sublabel;
                        end
                        updateSublabelDescriptionFromName(this.Session.ROISublabelSet,...
                        labelName,sublabelName,roiSubLabel.Description);
                    end

                    if dlg.ColorChangedInEditMode
                        oldSelectionInfo=struct('IsLabelItemSelected',isLabelItemSelected,...
                        'LabelName',labelName,...
                        'SublabelName',sublabelName,...
                        'Color',color);
                        modifyLabelOrSublabelColor(this,roiSubLabel,oldSelectionInfo);
                        this.DisplayManager.updateLabelInUndoRedoBuffer(roiSubLabel,oldSelectionInfo,toUpdate);
                        this.DisplayManager.colorChangeInClipboard(roiSubLabel,oldSelectionInfo);
                    end
                end

                this.Session.IsChanged=true;
            end
        end


        function dlg=getROILabelDefinitionDialog(this,labelAddMode,roiLabel,sublabelNames)
            if nargin>2
                dlg=vision.internal.labeler.tool.ROILabelDefinitionDialog(...
                this.Tool,...
                this.Session.ROILabelSet,...
                this.Session.FrameLabelSet,...
                this.SupportedROILabelTypes,labelAddMode,...
                roiLabel,sublabelNames);
            else
                dlg=vision.internal.labeler.tool.ROILabelDefinitionDialog(...
                this.Tool,...
                this.Session.ROILabelSet,...
                this.Session.FrameLabelSet,...
                this.SupportedROILabelTypes,...
                labelAddMode);
            end
        end


        function doROIPanelItemMoveCallback(this,~,data)

            groupChanged=data.Data.GroupChanged;

            if groupChanged
                labelName=data.Data.Label;
                labelGroupName=data.Data.Group;
                updateROILabelGroup(this.Session,labelName,labelGroupName);
            end

            labelNames=data.Data.LabelNames;
            reorderROILabelDefinitions(this.Session,labelNames);
        end


        function doROIPanelItemROIVisibilityCallback(this,~,data)

            selectedItemInfo=getSelectedItemInfo(this);
            selectedLabelData=data.Data;

            if~isequal(selectedLabelData.ROI,labelType.PixelLabel)
                this.DisplayManager.changeVisibilitySelectedROI(selectedLabelData,selectedItemInfo);

                this.DisplayManager.roiVisibilityChangeInClipboard(selectedLabelData);
            else
                this.DisplayManager.changeVisibilitySelectedPixelROI(selectedLabelData,selectedItemInfo);


                this.DisplayManager.roiVisibilityChangeInClipboardPixel(selectedLabelData);



                enableControls(this.SemanticTab);
                if strcmp(selectedLabelData.Label,selectedItemInfo.roiItemDataObj.Label)...
                    &&~selectedLabelData.ROIVisibility
                    disableControls(this.SemanticTab);
                end
            end

            if isa(selectedLabelData,'vision.internal.labeler.ROILabel')
                this.Session.modifyLabelROIVisibility(selectedLabelData);
            else
                this.Session.modifySubLabelROIVisibility(selectedLabelData);
            end

            this.DisplayManager.updateLabelVisibilityInUndoRedoBuffer(selectedLabelData);
            this.Session.IsChanged=true;
        end


        function doROIAttributeAdditionCallback(this,~,~)


            itemInfo=getSelectedROIPanelItemInfo(this);

            invalidNames=this.Session.getNamesUnderHierarchy(itemInfo.LabelName,itemInfo.SublabelName);


            dlg=vision.internal.labeler.tool.ROIAttributeDefinitionDialog(...
            this.Tool,this.Session.ROIAttributeSet,this.SupportedROIAttributeTypes,...
            itemInfo.LabelName,itemInfo.SublabelName,invalidNames);
            wait(dlg);

            if~dlg.IsCanceled


                attribData=dlg.getDialogData();

                hFig=getDefaultFig(this.Container);
                attribData=this.Session.addROIAttribute(attribData,hFig);



                currItemIdx=this.ROILabelSetDisplay.CurrentSelection;



                this.ROILabelSetDisplay.appendItemAttribute(attribData,currItemIdx);

                numAttributes=this.Session.getNumAttributes();
                if numAttributes==1
                    updateAttributesSublabelsPanelIfNeeded(this);
                else
                    if canAppendAttributeItemInAttribCreation(this,attribData)
                        appendAttributeToAttributesSublabelsPanel(this,attribData);
                        setEnablenessOfAttribPanelItems(this);
                    end
                end

                updateAttribAnnotationAtAttribCreation(this,attribData);
            end

        end


        function doAttributePanelItemModificationCallback(this,~,data)







            attributeData=data.Data;

            [labelName,sublabelName,roiData]=getFirstSelectedROIInstanceInfo(this);
            selectedDisplay=getSelectedDisplay(this);
            signalName=selectedDisplay.Name;
            updateAnnotationsForAttributesValue(this,signalName,roiData.ID,labelName,sublabelName,attributeData);
            this.Session.IsChanged=true;

        end


        function doROIPanelItemBeingEditedCallback(this,~,data)

            atrribName=data.Data;
            editAttrib=~isempty(atrribName);

            if~editAttrib
                return;
            end

            itemIdx=data.Index;
            itemInfo=this.getROIPanelItemInfo(itemIdx);

            labelName=itemInfo.LabelName;
            sublabelName=itemInfo.SublabelName;

            invalidNames=this.Session.getNamesUnderHierarchy(labelName,sublabelName);

            attribData=this.Session.ROIAttributeSet.queryAttribute(labelName,sublabelName,atrribName);

            dlg=vision.internal.labeler.tool.ROIAttributeDefinitionEditDialog(...
            this.Tool,this.Session.ROIAttributeSet,attribData,invalidNames);
            wait(dlg);

            if~dlg.IsCanceled
                if dlg.NameChanged
                    modifyAttributeName(this,attribData,dlg.Name);
                    this.DisplayManager.renameAttribInClipboard(attribData,dlg.Name);
                    attribData.Name=dlg.Name;
                end

                if dlg.ValueChanged
                    modifyAttributeValue(this,attribData,dlg.Value);
                end

                if dlg.DescriptionChanged
                    modifyAttributeDescription(this,attribData,dlg.Description);
                end
            end
        end


        function removeAttributeSublabelPanel(this)
            if useAppContainer()
                makeAttribSublabelInvisible(this.Container);
            else
                [this.NumRows,this.NumCols]=getGridLayout(this);
                if this.NumRows>=1&&this.NumCols<=3
                    displayGridNumRows=this.NumRows;
                    displayGridNumCols=this.NumCols;
                    createXMLandGenerateLayout(this,displayGridNumRows,displayGridNumCols);
                end
                updateTileLayout4AttribInstruct(this,false,false);
            end

            selectedDisplay=getSelectedDisplay(this);
            if~isempty(selectedDisplay)&&...
                selectedDisplay.IsCuboidSupported&&selectedDisplay.ProjectedView
                createProjectedViewLayout(this);
            end
        end


        function tf=isCoboidLabelDefSelected(this)

            selectedItemInfo=this.getSelectedROIPanelItemInfo();
            tf=~isempty(selectedItemInfo)&&...
            ~selectedItemInfo.IsGroup&&...
            selectedItemInfo.IsLabel&&...
            ~selectedItemInfo.IsPixelLabel&&...
            selectedItemInfo.IsRectOrCubeLabel;
        end



        function[labelName,sublabelName,roiData]=getFirstSelectedROIInstanceInfo(this)
            selectedDisplay=getSelectedDisplay(this);
            [labelName,sublabelName,roiData]=selectedDisplay.getFirstSelectedROIInstanceInfo();
        end


        function[labelName,roiData]=getOneSelectedROILabelInstanceInfo(this)
            [labelName,roiData]=this.DisplayManager.getOneSelectedROILabelInstanceInfo();
        end


        function setSingleSelectedROIInstanceParentUID(this)
            selectedDisplay=getSelectedDisplay(this);
            if isempty(selectedDisplay)
                return;
            end
            signalName=selectedDisplay.Name;
            prevSelectedROIInfo=selectedDisplay.getSingleSelectedROIInstanceInfo();
            curSelectedROIInfo=updateSelectedROIInfo(this,signalName,prevSelectedROIInfo);
            selectedDisplay.setSingleSelectedROIInstanceInfo(curSelectedROIInfo);

        end


        function itemInfo=getROIPanelItemInfo(this,itemIdx)
            itemData=this.ROILabelSetDisplay.getItemData(itemIdx);
            itemInfo=getItemInfoFromData(this,itemData);
        end


        function enableSublabelDefCreateButton(this)
            this.ROILabelSetDisplay.enableSublabelDefCreateButton();
        end


        function enableAttributeDefCreateButton(this)
            this.ROILabelSetDisplay.enableAttributeDefCreateButton();
        end


        function disableSublabelDefCreateButton(this)
            this.ROILabelSetDisplay.disableSublabelDefCreateButton();
        end


        function disableAttributeDefCreateButton(this)
            this.ROILabelSetDisplay.disableAttributeDefCreateButton();
        end


        function disableSublabelAttributeButtons(this)
            disableSublabelDefCreateButton(this);
            disableAttributeDefCreateButton(this);
        end


        function controlVisOfSublabelAttribCreateButtons(this,isAnyItemSelected,...
            isPixelLabelItemSelected,isLabelSelected,isGroupItem)
            if~isAnyItemSelected
                disableSublabelDefCreateButton(this);
                disableAttributeDefCreateButton(this);
            else
                if isPixelLabelItemSelected||isGroupItem
                    disableSublabelDefCreateButton(this);
                    disableAttributeDefCreateButton(this);
                else
                    if isInAlgoMode(this)


                        disableSublabelDefCreateButton(this);
                        disableAttributeDefCreateButton(this);
                    elseif~isInAlgoMode(this)&&isLabelSelected
                        enableSublabelDefCreateButton(this);
                        enableAttributeDefCreateButton(this);
                    else
                        disableSublabelDefCreateButton(this);
                        enableAttributeDefCreateButton(this);
                    end
                end
            end
        end


        function N=numROIInstanceSelected(this)
            N=0;
            selectedDisplay=getSelectedDisplay(this);
            if isempty(selectedDisplay)
                return;
            end
            N=selectedDisplay.getNumROIInstanceSelected();
        end


        function TF=canAppendAttributeItemInAttribCreation(this,attribData)
            N=numROIInstanceSelected(this);

            if N==1
                [labelName,sublabelName,~]=getFirstSelectedROIInstanceInfo(this);

                if strcmp(attribData.LabelName,labelName)&&...
                    strcmp(attribData.SublabelName,sublabelName)
                    TF=true;
                else
                    TF=false;
                end
            else




                TF=true;
            end
        end


        function[TF,forROIInstance]=canAppendSublabelInfoItemInSublabelCreation(this,subLabelData)
            N=numROIInstanceSelected(this);

            forROIInstance=false;
            if N==1
                [labelName,sublabelName,~]=getFirstSelectedROIInstanceInfo(this);

                if~isempty(sublabelName)
                    TF=false;
                else
                    if strcmp(subLabelData.LabelName,labelName)
                        TF=true;
                        forROIInstance=true;
                    else
                        TF=false;
                    end
                end
            else




                TF=true;
            end
        end


        function isDisplayReadyForROI=getModeFromSelectedItem(this,selectedROIItemDataObj)

            isDisplayReadyForROI=this.DisplayManager.getModeFromSelectedItem(selectedROIItemDataObj);
        end


        function shouldPanelBeVisibile=shouldAttribSublabelPanelBeVisible(this)


            numSublabels=this.Session.getNumSublabels();
            numAttributes=this.Session.getNumAttributes();

            shouldPanelBeVisibile=(numSublabels>0)||(numAttributes>0);
        end


        function setEnablenessOfAttribPanelItems(this)
            N=numROIInstanceSelected(this);
            if N==1
                enableAttribPanel=true;
            else
                enableAttribPanel=false;
            end
            if enableAttribPanel
                this.AttributesSublabelsDisplay.enableAttribPanel();
            else
                this.AttributesSublabelsDisplay.disableAttribPanel();
            end
        end


        function updateAttributesSublabelsPanel(this)


            N=numROIInstanceSelected(this);
            singleROIselected=false;

            if N==1
                selectedDisplay=getSelectedDisplay(this);
                signalName=selectedDisplay.Name;
                [labelName,sublabelName,roiData]=this.getFirstSelectedROIInstanceInfo();
                itemColor=roiData.Color;
                singleROIselected=true;
                isPixelLabelItemSelected=false;
                isGroupItemSelected=false;
            else
                roiData=[];
                itemInfo=this.getSelectedROIPanelItemInfo();
                isPixelLabelItemSelected=itemInfo.IsPixelLabel;
                labelName=itemInfo.LabelName;
                sublabelName=itemInfo.SublabelName;
                itemColor=itemInfo.Color;
                isGroupItemSelected=itemInfo.IsGroup;
            end

            if~isGroupItemSelected

                this.AttributesSublabelsDisplay.updatePanelDetail(labelName,sublabelName,itemColor);


                attribDefData=this.Session.queryROIAttributeFamilyData(labelName,sublabelName);
                if singleROIselected
                    attribInstanceData=getAttributeInstanceValue(this,signalName,roiData.ID,attribDefData);
                else
                    attribInstanceData=attribDefData;
                end

                this.AttributesSublabelsDisplay.updateAttribInAttributesSublabelsPanel(labelName,sublabelName,attribDefData,attribInstanceData);
                if singleROIselected
                    this.AttributesSublabelsDisplay.enableAttribPanel();
                else
                    this.AttributesSublabelsDisplay.disableAttribPanel();
                end




                if isempty(sublabelName)
                    sublabelNames=this.Session.queryROISublabelFamilyNames(labelName);
                    if singleROIselected

                        numSublabelInstances=getNumSublabelInstances(this,signalName,labelName,roiData.ID,sublabelNames);
                    else
                        numSublabelInstances=zeros(1,numel(sublabelNames));
                    end

                    this.AttributesSublabelsDisplay.updateSublblInAttributesSublabelsPanel(labelName,sublabelNames,isPixelLabelItemSelected,numSublabelInstances,singleROIselected);
                else
                    this.AttributesSublabelsDisplay.deleteSublabelInfoItems();
                    this.AttributesSublabelsDisplay.showNoSublabelAllowedMessage();
                end
            else
                updatePanelDetail(this.AttributesSublabelsDisplay);
                updateAttribInAttributesSublabelsPanel(this.AttributesSublabelsDisplay);
                updateSublblInAttributesSublabelsPanel(this.AttributesSublabelsDisplay);
            end
        end


        function appendAttributeToAttributesSublabelsPanel(this,attribData)
            this.AttributesSublabelsDisplay.appendAttribute(attribData);
        end


        function modifyAttribListInAttribSublabelPanel(this,oldAttribData,val)
            this.AttributesSublabelsDisplay.modifyListAttributeItems(oldAttribData,val);
        end


        function appendSublabelInfoToAttributesSublabelsPanel(this,subLabelData)
            this.AttributesSublabelsDisplay.appendSublabelInfo(subLabelData);

        end


        function modifyAttribNameInAttribSublabelPanel(this,oldAttribData,newName)
            this.AttributesSublabelsDisplay.modifyAttributeName(oldAttribData,newName);
        end


        function modifyAttribDescriptionInAttribSublabelPanel(this,oldAttribData,newDescription)
            this.AttributesSublabelsDisplay.modifyAttributeDescription(oldAttribData,newDescription);
        end


        function modifyLabelNameInAttribSublabelPanel(this,newLabelName)
            isPanelVisible=this.AttributesSublabelsDisplay.isPanelVisible();
            if isPanelVisible
                this.AttributesSublabelsDisplay.modifyLabelName(newLabelName);
            end
        end


        function idxInsertAfter=sublabelInsertAfterIdx(this,labelName)


            idxOffset=this.Session.numExistingSublabels(labelName)-1;
            currIdx=this.ROILabelSetDisplay.CurrentSelection;
            idxInsertAfter=currIdx+idxOffset;
        end


        function doROISublabelAdditionCallback(this,~,~)

            itemInfo=getSelectedROIPanelItemInfo(this);

            invalidNames=this.Session.getNamesUnderHierarchy(itemInfo.LabelName);


            dlg=vision.internal.labeler.tool.ROISublabelDefinitionDialog(...
            this.Tool,...
            this.Session.ROISublabelSet,...
            this.SupportedROISublabelTypes,...
            itemInfo.LabelName,...
            [],...
            invalidNames,...
            itemInfo.Color);
            wait(dlg);

            if~dlg.IsCanceled



                subLabelData=dlg.getDialogData();


                subLabelData=this.Session.addROISublabel(subLabelData);

                idxInsertAfter=sublabelInsertAfterIdx(this,subLabelData.LabelName);


                this.ROILabelSetDisplay.insertItem(subLabelData,idxInsertAfter);
                this.ROILabelSetDisplay.updateItem();




                numSublabels=this.Session.getNumSublabels();
                if numSublabels==1
                    updateAttributesSublabelsPanelIfNeeded(this);
                else
                    [TF,forROIInstance]=canAppendSublabelInfoItemInSublabelCreation(this,subLabelData);
                    if TF
                        sublabelInfo.LabelName=subLabelData.LabelName;
                        sublabelInfo.SublabelName=subLabelData.Sublabel;
                        sublabelInfo.NumSublabelInstances=0;
                        sublabelInfo.ForROIInstance=forROIInstance;
                        appendSublabelInfoToAttributesSublabelsPanel(this,sublabelInfo);
                    end
                end
            end
        end


        function removeAttributesOfLabelOrSublabel(this,labelName,sublabelName)

            [~,childAttribNames]=this.Session.queryChildAttributeIDNames(labelName,sublabelName);
            N=this.numElement(childAttribNames);
            for j=1:N
                attribName=childAttribNames{j};
                this.Session.deleteROIAttribute(labelName,sublabelName,attribName);
            end
        end


        function removeAttributesOfLabel(this,labelName)
            removeAttributesOfLabelOrSublabel(this,labelName,'');
        end


        function removeAttributesOfSublabel(this,labelName,sublabelName)
            removeAttributesOfLabelOrSublabel(this,labelName,sublabelName);
        end


        function deleteROILabelAttribute(this,labelName,data)
            this.Session.deleteROIAttribute(labelName,'',data.AttributeName);
        end


        function deleteROISublabelAttribute(this,labelName,sublabelName,data)
            this.Session.deleteROIAttribute(labelName,sublabelName,data.AttributeName);
        end


        function modifyNameOfLabelAttribute(this,attribData,newName)
            labelName=attribData.LabelName;
            attribOldName=attribData.Name;
            this.Session.modifyNameOfAttribute(labelName,'',attribOldName,newName);
        end


        function modifyNameOfSublabelAttribute(this,attribData,newName)
            labelName=attribData.LabelName;
            sublabelName=attribData.SublabelName;
            attribOldName=attribData.Name;
            this.Session.modifyNameOfAttribute(labelName,sublabelName,attribOldName,newName);
        end


        function modifyLabelName(this,oldLabelName,newLabelName)
            this.Session.modifyLabelName(oldLabelName,newLabelName);
        end


        function modifyLabelColor(this,labelName,newLabelColor)
            this.Session.modifyLabelColor(labelName,newLabelColor);
        end


        function modifySublabelName(this,labelName,oldSublabelName,newSublabelName)
            this.Session.modifySublabelName(labelName,oldSublabelName,newSublabelName);
        end


        function modifyFrameLabelName(this,oldFrameLabelName,newFrameLabelName)
            this.Session.modifyFrameLabelName(oldFrameLabelName,newFrameLabelName);
            modifyFrameLabelNameInLeftPanel(this,newFrameLabelName)
        end


        function modifyValueOfLabelAttributeList(this,attribData,val)
            labelName=attribData.LabelName;
            attribName=attribData.Name;
            this.Session.modifyValueOfAttributeList(labelName,'',attribName,val);
        end


        function modifyValueOfSublabelAttributeList(this,attribData,val)
            labelName=attribData.LabelName;
            sublabelName=attribData.SublabelName;
            attribName=attribData.Name;
            this.Session.modifyValueOfAttributeList(labelName,sublabelName,attribName,val);
        end


        function modifyDescOfLabelAttribute(this,attribData,newDesc)
            labelName=attribData.LabelName;
            attribName=attribData.Name;
            this.Session.modifyAttributeDescription(labelName,'',attribName,newDesc);
        end


        function modifyDescOfSublabelAttribute(this,attribData,newDesc)
            labelName=attribData.LabelName;
            sublabelName=attribData.SublabelName;
            attribName=attribData.Name;
            this.Session.modifyAttributeDescription(labelName,sublabelName,attribName,newDesc);
        end


        function N=numElement(~,cellStr)
            if(length(cellStr)==1)&&isempty(cellStr{1})
                N=0;
            else
                N=length(cellStr);
            end

        end


        function sublabelItemID=createSublabelItemID(this,labelName,sublabelName)

            sublabelItemID=this.ROILabelSetDisplay.getItemID(labelName,sublabelName);
        end


        function attribItemID=createAttributeItemID(this,attributeName)
            attribItemID=this.AttributesSublabelsDisplay.getItemID(attributeName);
        end


        function removeSublabelWithAttributes(this,labelName)

            wait(this.Container);

            [~,childSublabelNames]=this.Session.queryChildSublabelIDNames(labelName);
            numSublabels=this.numElement(childSublabelNames);

            for idx=1:numSublabels
                removeAttributesOfSublabel(this,labelName,childSublabelNames{idx});
                this.Session.deleteROISublabel(labelName,childSublabelNames{idx});
            end

            resume(this.Container);
        end


        function deleteAttribSublabelPanelEntries(this)
            this.AttributesSublabelsDisplay.deleteAllItems();
        end


        function deleteAttribSublabelPanelItem(this,labelName,sublabelName,attributeName)
            attribItemID=createAttributeItemID(this,attributeName);
            this.AttributesSublabelsDisplay.deleteItemWithID(attribItemID);
            this.AttributesSublabelsDisplay.updateFirstItemTextIfNeeded(labelName,sublabelName);
        end


        function deleteROILabelTree(this,labelName,isPixelLabelSelected)

            if isPixelLabelSelected
                roiData=this.Session.queryROILabelData(labelName);

                finalize(this);
                deletePixelLabelData(this.Session,roiData.PixelLabelID);
                if this.AreSignalsLoaded
                    this.DisplayManager.deletePixelLabelData(roiData.PixelLabelID);
                end

                selectStruct.Label=labelName;
                this.deleteROISummaryItem([],selectStruct);
            end

            if(~isPixelLabelSelected)

                removeSublabelWithAttributes(this,labelName);


                removeAttributesOfLabel(this,labelName);

                deleteAttribSublabelPanelEntries(this);
            else


                this.DisplayManager.disableContextMenuCopyPastePixel(...
                this.Session.getNumPixelLabels(),roiData);
            end

            this.Session.deleteROILabel(labelName);


        end


        function deleteROISublabelTree(this,labelName,sublabelName)


            removeAttributesOfSublabel(this,labelName,sublabelName);
            this.Session.deleteROISublabel(labelName,sublabelName);

            deleteAttribSublabelPanelEntries(this);
        end


        function displayMessage=warningMessage(this,isLabelSelected,deleteAttrib)
            if deleteAttrib
                displayMessage=vision.getMessage('vision:labeler:DeletionAttribDefinitionWarning');
            else
                if isLabelSelected
                    if this.isImageLabeler||this.IsVideoLabeler
                        displayMessage=vision.getMessage('vision:labeler:DeletionLabelDefinitionWarning');
                    else
                        displayMessage=vision.getMessage('lidar:labeler:DeletionLabelDefinitionWarningLidar');
                    end
                else
                    displayMessage=vision.getMessage('vision:labeler:DeletionSublabelDefinitionWarning');
                end
            end
        end


        function updateAttributesSublabelsPanelIfNeeded(this)








            isPanelVisible=this.AttributesSublabelsDisplay.isPanelVisible();

            shouldPanelBeVisibile=shouldAttribSublabelPanelBeVisible(this);

            if shouldPanelBeVisibile&&~isPanelVisible
                if useAppContainer()
                    makeAttribSublabelVisible(this.Container);
                else

                    showInstructionTab=false;
                    showAttributeTab=true;
                    [this.NumRows,this.NumCols]=getGridLayout(this);
                    if this.NumRows>=1&&this.NumCols<=3
                        displayGridNumRows=this.NumRows;
                        displayGridNumCols=this.NumCols;
                        createXMLandGenerateLayout(this,displayGridNumRows,displayGridNumCols);
                    end
                    updateTileLayout4AttribInstruct(this,showInstructionTab,showAttributeTab);
                end

            end

            if shouldPanelBeVisibile||isPanelVisible


                updateAttributesSublabelsPanel(this);
            end
        end


        function selectROIDefinition(this,display,selectedLabel,labelName,sublabelName)
            if(isLabelDef(this,display,selectedLabel)&&...
                strcmp(selectedLabel.Label,labelName)&&...
                isempty(sublabelName))||...
                (isSublabelDef(this,display,selectedLabel)&&...
                strcmp(selectedLabel.LabelName,labelName)&&...
                (isempty(sublabelName)||strcmp(selectedLabel.Sublabel,sublabelName)))

            else
                itemID=this.ROILabelSetDisplay.getItemID(labelName,sublabelName);
                this.IsCallFromROIInstanceSelection=true;
                this.ROILabelSetDisplay.selectItem(itemID);
            end
        end


        function selectROILabelDefinition(this,display,selectedLabel,labelName)
            if(isLabelDef(this,display,selectedLabel)&&...
                strcmp(selectedLabel.Label,labelName))

            else
                itemID=this.ROILabelSetDisplay.getItemID(labelName,'');
                this.IsCallFromROIInstanceSelection=true;
                this.ROILabelSetDisplay.selectItem(itemID);
            end
        end


        function modifyLabelDefinitionSelection(this,selectedLabel)






...
...
...
...
...
...
...
...
...
...
...
...
...
...
            selectedDisplay=getSelectedDisplay(this);
            if isempty(selectedDisplay)
                return;
            end


            numROIInstanceSelected=selectedDisplay.getNumROIInstanceSelected();
            if numROIInstanceSelected==0
                return;
            else
                if numROIInstanceSelected==1
                    roiInfo=selectedDisplay.getSingleSelectedROIInstanceInfo();



                    labelName=roiInfo.LabelName;
                    sublabelName=roiInfo.SublabelName;


                    if isSublabelInstance(this,selectedDisplay,labelName,sublabelName)&&...
                        isLabelDef(this,selectedDisplay,selectedLabel)&&...
                        strcmp(labelName,selectedLabel.Label)

                    else
                        selectROIDefinition(this,selectedDisplay,selectedLabel,labelName,sublabelName);
                    end
                else
                    [labelNameF,~]=selectedDisplay.getOneSelectedROILabelInstanceInfo();
                    if~isempty(labelNameF)
                        selectROILabelDefinition(this,selectedDisplay,selectedLabel,labelNameF);
                    else
                        [labelNameF,sublabelNameF,~]=getFirstSelectedROIInstanceInfo(this);
                        selectROIDefinition(this,selectedDisplay,selectedLabel,labelNameF,sublabelNameF);
                    end
                end
            end

        end


        function tf=isSublabelInstance(~,display,labelName,sublabelName)
            tf=display.isSublabelInstance(labelName,sublabelName);
        end


        function tf=isLabelDef(~,display,selectedLabel)
            tf=display.isLabelDef(selectedLabel);
        end


        function tf=isSublabelDef(~,display,selectedLabel)
            tf=display.isSublabelDef(selectedLabel);
        end



        function doROIPanelItemSelectionCallback(this,varargin)



            selectedItemInfo=getSelectedItemInfo(this);

            isAnyItemSelected=selectedItemInfo.isAnyItemSelected;
            isPixelLabelItemSelected=selectedItemInfo.isPixelLabelItemSelected;
            isLabelSelected=selectedItemInfo.isLabelSelected;
            roiItemDataObj=selectedItemInfo.roiItemDataObj;
            isGroupItemSelected=selectedItemInfo.isGroup;

            if isAnyItemSelected

                controlVisOfSublabelAttribCreateButtons(this,isAnyItemSelected,...
                isPixelLabelItemSelected,isLabelSelected,isGroupItemSelected);
                if~isGroupItemSelected
                    updateAttributesSublabelsPanelIfNeeded(this);
                else
                    updatePanelDetail(this.AttributesSublabelsDisplay);
                    updateAttribInAttributesSublabelsPanel(this.AttributesSublabelsDisplay);
                    updateSublblInAttributesSublabelsPanel(this.AttributesSublabelsDisplay);
                end

                setModeROIorNone(this,selectedItemInfo);


                if(0)

                    if isDisplayReadyForROI


                        this.setStatusText('');
                    else

                        if isa(roiItemDataObj,'vision.internal.labeler.ROISublabel')

                            this.setStatusText(vision.getMessage('vision:labeler:CannotDrawSubLabelStatus',roiItemDataObj.LabelName,roiItemDataObj.Sublabel));
                        end
                    end
                end

                if~isGroupItemSelected
                    this.DisplayManager.updateLabelSelection(roiItemDataObj);
                    if~this.IsCallFromROIInstanceSelection
                        this.DisplayManager.modifyLabelInstanceSelection(roiItemDataObj);
                    end
                    this.IsCallFromROIInstanceSelection=false;
                    setSingleSelectedROIInstanceParentUID(this);
                end


                this.IsCallFromFinalize=true;
                resetSuperPixelLayout(this.DisplayManager);
                this.IsCallFromFinalize=false;

                isPixelLabel=~isempty(roiItemDataObj)&&(roiItemDataObj.ROI==labelType.PixelLabel);

                if isPixelLabel
                    showContextualSemanticTab(this);
                    if isSuperpixelEnabled(this.SemanticTab)
                        updateSuperpixelLayoutState(this.DisplayManager,true);
                    end

                    if this.AreSignalsLoaded
                        numSignals=getNumberOfSignals(this.Session);

                        for signalId=1:numSignals
                            displayId=signalId+1;
                            display=this.DisplayManager.getDisplayFromIdNoCheck(displayId);
                            display.updateBrushOutline(roiItemDataObj.Color);
                            display.updateSuperpixelState();

                            if handleException(this)
                                return;
                            end
                        end
                    end
                else
                    hideContextualSemanticTab(this);
                    if isSuperpixelEnabled(this.SemanticTab)
                        updateSuperpixelLayoutState(this.DisplayManager,false);
                    end
                    disableBrushOutline(this.DisplayManager);
                end

                if~isGroupItemSelected
                    modifyItemMenuLabel(this,roiItemDataObj);
                end


                doUndoRedoUpdate(this);


                if~isempty(varargin)&&(this.Session.getNumPixelLabels==1)

                    this.DisplayManager.enableContextMenuCopyPastePixel...
                    (this.Session.getNumPixelLabels());
                end



                if~isImageLabeler(this)&&~this.IsVideoLabeler
                    if isRectOrCubeLabelDef(roiItemDataObj.ROI)
                        disableLineSection(this);
                        enableCuboidSection(this);
                    elseif isLineOrLine3DLabelDef(roiItemDataObj.ROI)
                        disableCuboidSection(this);
                        enableLineSection(this);
                    end
                end
            end

        end
    end

    methods

        function name=getGroupName(this)
            name=getGroupName(this.Container);
        end

        function c=getContainer(this)
            c=this.Container;
        end

        function showTearOffDialog(this,tearOffPopUp,toolstripBtn,isFloat)
            if nargin==3
                isFloat=[];
            end

            showTearOffDialog(this.Container,tearOffPopUp,toolstripBtn,isFloat);






        end
    end


    methods(Hidden)



        function ExecuteAlgorithmTestingHook(this,mode)
            ExecuteAlgorithmTestingHook(this.AlgorithmTab,mode);
        end


        function SelectAlgorithmTestingHook(this,algorithmName)
            SelectAlgorithmTestingHook(this.LabelTab,algorithmName);
        end


        function ready=IsUIReadyForTesting(this)
            ready=~this.IsUIBusy;
        end

    end

    methods(Access=public,Hidden)

        function createProjectedCuboidTutorialDialog(this)


            if hasProjCuboidLabels(this.Session)&&hasSignal(this.Session)




                this.ShowProjCuboidTutorial=false;

                s=settings;

                messageStrings={getString(message('vision:labeler:ProjCuboidTutorial1')),...
                getString(message('vision:labeler:ProjCuboidTutorial2')),...
                getString(message('vision:labeler:ProjCuboidTutorial3'))};

                titleString=getString(message('vision:labeler:ProjCuboidTutorialTitle'));

                basePath=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+images');
                imagePaths={fullfile(basePath,'ProjCuboidTutorial1.png'),...
                fullfile(basePath,'ProjCuboidTutorial2.png'),...
                fullfile(basePath,'ProjCuboidTutorial3.png')};
                flag=s.vision.labeler.OpenWithAppContainer.ActiveValue;
                getProjCuboidTutorialDialog(this,imagePaths,messageStrings,titleString,s,flag);
            end
        end

        function getProjCuboidTutorialDialog(this,imagePaths,messageStrings,titleString,settings,flag)
            images.internal.app.TutorialDialog(imagePaths,...
            messageStrings,titleString,...
            settings.vision.videoLabeler.ShowProjCuboidTutorialDialog,...
            flag);
        end


        function createPolygonTutorialDialog(this)


            if hasPolygonLabels(this.Session)&&hasSignal(this.Session)




                this.ShowPolygonTutorial=false;

                s=settings;

                messageStrings={getString(message('vision:labeler:PolygonTutorial1')),...
                getString(message('vision:labeler:PolygonTutorial2'))};

                titleString=getString(message('vision:labeler:PolygonTutorialTitle'));

                basePath=fullfile(toolboxdir('vision'),'vision',...
                '+vision','+internal','+labeler','+tool','+images');
                imagePaths={fullfile(basePath,'PolygonTutorial1.png'),...
                fullfile(basePath,'PolygonTutorial2.png')};
                flag=s.vision.labeler.OpenWithAppContainer.ActiveValue;
                getPolygonDialog(this,imagePaths,messageStrings,titleString,s,flag);
            end

        end

        function getPolygonDialog(~,imagePaths,messageStrings,titleString,settings,flag)
            images.internal.app.TutorialDialog(imagePaths,...
            messageStrings,titleString,...
            settings.vision.videoLabeler.ShowPolygonTutorialDialog,flag);
        end



        function createLabelTypeTutorialDialog(this)









            s=settings;

            messageStrings={'The quick brown fox jumped over the lazy dog. The quick brown fox jumped over the lazy dog. '};

            titleString=getString(message('vision:labeler:LabelTypeTutorialTitle'));

            basePath=fullfile(toolboxdir('vision'),'vision','+vision',...
            '+internal','+labeler','+tool','+images');
            imagePaths={fullfile(basePath,'LabelTypeTutorial2.png')};
            flag=s.vision.labeler.OpenWithAppContainer.ActiveValue;
            getLabelTypeDialog(this,imagePaths,messageStrings,titleString,s,flag);

        end

        function getLabelTypeDialog(~,imagePaths,messageStrings,titleString,settings,flag)
            images.internal.app.TutorialDialog(imagePaths,...
            messageStrings,titleString,...
            settings.vision.videoLabeler.ShowLabelTypeTutorialDialog,...
            flag);
        end

    end
end


function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('useAppContainer');
end


function tf=isRectOrCubeLabelDef(roiType)


    tf=(roiType==labelType.Cuboid)||(roiType==labelType.Rectangle);
end


function tf=isLineOrLine3DLabelDef(roiType)


    tf=roiType==labelType.Line;
end
