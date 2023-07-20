
classdef TemporalLabelingTool<vision.internal.labeler.tool.LabelerTool







    properties(Access=protected)
        NameNoneDisplay='Signal';
        DefaultLayoutFileName='defaultLayout.xml';
        DefaultLayoutWAttribFileName='defaultLayoutAttrib.xml';
    end


    properties(Access=protected)




IsAutomationForward
    end




    properties(SetObservable=true)
AreSignalsLoaded
    end

    properties(Access=protected)

LidarTab

RangeSliderObj
SignalLoadController

        LastSelectedDisplay='';




CaughtReadException

    end


    properties(Access=protected)




AlgorithmConfiguration


CachedInterval



SignalsSelected
    end


    properties(Hidden)

        SavedStateOfClusterVisuals=false;
        ViewClustersPreviousState=false;
        ClustersStateDuringAutomation=false;
        ClustersWhenScrubberDragged=false;
    end


    properties




        IsVideoLabeler=false




        ShowLidarTutorial=true

FlagStartTime
FlagEndTime
SignalTimeVector

        IsScrubberMoved=false;

DisplaysForAutomation

MasterSignalBeforeAutomation

SelectedDisplayName

NumSignalsForAutomation

        IsValidPtCloudType=false;

        SignalNamesForAutomation='';

        NumRowsInLayout=1;

        NumColsInLayout=1;
    end

    properties(Access=public)
ProjectedViewDisplay
ProjectedViewListenerHandles
    end




    methods(Access=public)


        function this=TemporalLabelingTool(title,instanceName)
            this=this@vision.internal.labeler.tool.LabelerTool(title,instanceName);
        end


        function doLoadSession(this,pathName,fileName,varargin)

            onProjectedViewClose(this);


            wait(this.Container);

            hFig=this.Container.getDefaultFig;
            loadedSession=this.SessionManager.loadSession(pathName,fileName,hFig);

            if isempty(loadedSession)
                resume(this.Container);
                return;
            end


            removedSignals=getSignalNames(this.Session);
            for idx=1:numel(removedSignals)
                removedSignalName=removedSignals(idx);
                removeDisplayPlus(this,getDisplayFig(this.DisplayManager,...
                removedSignalName),false);
            end


            this.refreshSignalViewList();



            reopenVisualSummary=getReopenVisualSummaryFlag(this);

            handleConnectorForNewSession(this);
            addSessionCustomDisplay(this,...
            loadedSession.ConnectorHandle,varargin{:});

            progressDlgTitle=vision.getMessage('vision:labeler:LoadProgressTitle');
            pleaseWaitMsg=vision.getMessage('vision:labeler:PleaseWait');
            waitBarObj=vision.internal.labeler.tool.ProgressDialog(hFig,...
            progressDlgTitle,pleaseWaitMsg);


            signalModel=getSignalModel(loadedSession);
            signalLoadController=createSignalLoadController(this,signalModel);
            [oldSignalNames,newSignalNames]=handleSourceLoadFailures(signalLoadController,...
            getAlternateFilePath(loadedSession),isVideoLabeler(this));
            loadedSession.updateSignalNameMultiple(oldSignalNames,newSignalNames);
            fixDataLoadingIssues(loadedSession);


            sourceNames=getSourceNamesNotLoaded(loadedSession);
            if~isempty(sourceNames)
                resume(this.Container);
                close(waitBarObj);

                formattedSourceNames=string(newline)+string(newline);

                for idx=1:numel(sourceNames)
                    formattedSourceNames=formattedSourceNames+sourceNames(idx)+newline;
                end
                errorMessage=vision.getMessage('vision:labeler:SignalSourceLoadError',formattedSourceNames);
                dialogName=vision.getMessage('vision:labeler:SignalSourceLoadErrorTitle');
                vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,...
                this.Tool);

                return;
            end

            if this.IsAppClosing

                close(waitBarObj);
            else
                loadingSessionMsg=vision.getMessage('vision:labeler:LoadingSession');
                waitBarObj.setParams(0.33,loadingSessionMsg);






                deleteAllItemsLabelSetDisplay(this);


                disableSublabelAttributeButtons(this);

                if signalModel.getNumberOfSignals()==0
                    resetNavigationControls(this);
                    removeSignalNav(this);
                    createDefaultLayoutForNewSession(this);
                end

                this.Session=loadedSession;



                this.LabelVisibleInternal=loadedSession.ShowROILabelMode;
                this.LabelTab.changeLabelDisplayOption(loadedSession.ShowROILabelMode);

                this.SignalLoadController=createSignalLoadController(this);


                updatingSessionMsg=vision.getMessage('vision:labeler:UpdatingSession');
                waitBarObj.setParams(0.33,updatingSessionMsg);

                close(waitBarObj);


                if hasPixelLabels(this.Session)
                    setTempDirectory(this);
                end


                TF=importPixelLabelData(this.Session);



                if~TF
                    oldDirectory=this.Session.TempDirectory;
                    [~,name]=fileparts(tempname);
                    foldername=vision.internal.labeler.tool.selectDirectoryDialog(name);
                    setTempDirectory(this.Session,foldername);
                    importPixelLabelData(this.Session);
                    if isfolder(oldDirectory)
                        rmdir(oldDirectory,'s');
                    end
                end

                updateSignalModel(this.Session,[]);
                this.Session.IsChanged=false;

                if hasPixelLabels(this.Session)

                    this.updatePixelColorLookup();
                end

                applyRangeSliderInfoFromSession(this);


                reconfigureROILabelSetDisplay(this);
                reconfigureFrameLabelSetDisplay(this);

                if~isempty(this.Session.ConnectorHandle)
                    if~isempty(this.Session.CustomLabels)&&~isempty(this.Session.CustomLabels.CustomLabelName)
                        setCustomLabels(this,this.Session.CustomLabels);
                    end
                end

                [~,fileName]=fileparts(fileName);

                titleStr=getString(message(...
                'vision:labeler:ToolTitleWithSession',this.ToolName,fileName));
                setTitleBar(this.Container,titleStr);
                layout=getLabelModeLayout(this.Session,this.Tool);
                visualSummaryDocked=checkVSDockedFromLayout(this,layout);
                doReopenVisualSummary(this,reopenVisualSummary,visualSummaryDocked);
drawnow
                if~useAppContainer()
                    loadLayoutFromSessionIfPossible(this);
                end


                if hasPointCloudSignal(this.Session)
                    this.retainClusterVisualizationState(this.Session.ClusterViewStatus);

                    this.loadProjectedViewFromSession(this.Session.ProjectedViewStatus);
                end

                resume(this.Container);
            end
        end



        function isClustered=getColorByCluster(this)
            display=this.DisplayManager.Displays;
            isClustered=false;
            for i=1:numel(display)

                if(display{i}.SignalType==vision.labeler.loading.SignalType.PointCloud)
                    isClustered=isClustered||display{i}.ColorByCluster;
                end

            end
        end

        function changeClusterSettingsState(this,disableCuboidSection)
            this.LidarTab.changeClusterSettingsState(disableCuboidSection);
        end

        function updateColormapSection(this)
            if getColorByCluster(this)
                this.LidarTab.disableColormapSection();
            else
                this.LidarTab.enableColormapSection();
            end
        end


        function emptyProjectedView(this)


            emptyROISrc=struct;
            emptyROISrc.CurrentROIs=[];


            SelectedItemInfo=getSelectedItemInfo(this);
            roiType=SelectedItemInfo.roiItemDataObj.ROI;

            if roiType==labelType.Line
                activateProjectedViewCuboid(this.ProjectedViewDisplay,emptyROISrc,[],[],[],[]);
            else
                activateProjectedViewLine(this.ProjectedViewDisplay,emptyROISrc,[],[],[],[]);
            end
        end
    end

    methods(Access=protected)


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


        function reactToAppClientActivation(this,src,evtData)
            if this.NumSignalsForDisplay>0
                isANewDispSelected=this.DisplayManager.appClientActivated(src,evtData);


                signalList=this.LabelTab.getSignalList();
                updateVisibilityOfSignal(this.AttributesSublabelsDisplay,length(signalList));

                for idx=1:length(signalList)
                    if signalList(idx).signalName==evtData.ClientName
                        if signalList(idx).isVisible==1
                            updatePanelSignal(this.AttributesSublabelsDisplay,evtData.ClientName);
                        else
                            updatePanelSignal(this.AttributesSublabelsDisplay,'');
                        end
                    end
                end



                if isANewDispSelected
                    doROIInstanceIsSelected(this);
                    changeStackOrderOfLidarTab(this);


                    undoRedoQABCallback(this);
                    selectedDisplay=getSelectedDisplay(this);

                    if getProjectedViewDisplayStatus(this)
                        if~isempty(selectedDisplay)&&selectedDisplay.IsCuboidSupported
                            initiateProjectedView(selectedDisplay,this.ProjectedViewDisplay);
                        elseif~isempty(selectedDisplay)&&~selectedDisplay.IsCuboidSupported



                            emptyROISrc=struct;
                            emptyROISrc.CurrentROIs=[];


                            SelectedItemInfo=getSelectedItemInfo(this);
                            roiType=SelectedItemInfo.roiItemDataObj.ROI;

                            if roiType==labelType.Line
                                activateProjectedViewCuboid(this.ProjectedViewDisplay,emptyROISrc,[],[],[],[]);
                            else
                                activateProjectedViewLine(this.ProjectedViewDisplay,emptyROISrc,[],[],[],[]);
                            end

                            this.LidarTab.disableProjectedView();
                        end
                    elseif isempty(selectedDisplay)
                        this.LidarTab.disableProjectedView();
                    end

                    for idx=1:length(signalList)
                        if signalList(idx).signalName==evtData.ClientName...
                            &&(this.ToolType==vision.internal.toolType.GroundTruthLabeler)
                            updateVisualSummaryXAxes(this);
                        end
                    end
                end
            end
        end


        function updateSignalLoadingStatus(this,gtSource,varargin)
            if isVideoLabeler(this)
                sourceType=gtSource.SourceType;
                if sourceType==vision.internal.labeler.DataSourceType.VideoReader

                    [~,fileName,~]=fileparts(gtSource.Source);
                    setStatusText(this,vision.getMessage('vision:labeler:LoadVideoStatus',fileName));
                    setLoadingText(this,true,true);
                elseif sourceType==vision.internal.labeler.DataSourceType.ImageSequence

                elseif sourceType==vision.internal.labeler.DataSourceType.CustomReader

                    setStatusText(this,vision.getMessage('vision:labeler:LoadCustomStatus',gtSource.Source));
                end
            end

            getDisplayIndex(this,true);
        end


        function signalController=createSignalLoadController(this,signalModel)

            signalView=getSignalView(this);

            if nargin<2
                signalModel=getSignalModel(this.Session);
            end

            import vision.internal.videoLabeler.tool.signalLoading.*

            signalController=vision.internal.videoLabeler.tool.signalLoading.SignalLoadController(signalModel,signalView);


            signalController.getContainerObj(this.Tool);
            addlistener(signalController,'SignalModelUpdated',...
            @(src,evt)this.Session.updateSignalModel(src,evt));

            addlistener(this.Session,'AddedSignals',@this.addDisplays);
            addlistener(this.Session,'RemovedSignals',@this.forceCloseDisplays);
            addlistener(signalController,'ReadFrameException',...
            @this.readFrameExceptionListener);
        end


        function signalView=getSignalView(this)

        end


        function createSession(this)

            if this.IsVideoLabeler

                this.SessionManager=vision.internal.videoLabeler.tool.VideoLabelerSessionManager;


                this.Session=vision.internal.videoLabeler.tool.Session;
            else

                this.SessionManager=driving.internal.videoLabeler.tool.VideoLabelerSessionManager;


                this.Session=driving.internal.videoLabeler.tool.Session;
            end
        end


        function forceCloseDisplays(this,~,evtData)
            removedSignals=evtData.RemovedSignals;

            selectedDisplay=getSelectedDisplay(this);
            selectedDisplayID=this.DisplayManager.getDisplayIdFromName(selectedDisplay.Name);

            for idx=1:numel(removedSignals)
                removedSignalName=removedSignals(idx);
                removedDisplayID=this.DisplayManager.getDisplayIdFromName(removedSignalName);
                if removedDisplayID<=selectedDisplayID
                    selectedDisplayID=selectedDisplayID-1;
                end

                displayInfo=getDisplay(this,removedSignalName);

                if isROIClipboardFilled(displayInfo)
                    copiedROIsTypes=getString(message('vision:trainingtool:PastePopup'));
                    setPasteMenuState(this.DisplayManager,displayInfo.SignalType,copiedROIsTypes,0);
                end

                if displayInfo.IsPixelSupported&&isPixelClipboardFilled(displayInfo)
                    setPixPasteMenuState(this.DisplayManager,displayInfo.SignalType,0);
                end

                removeDisplayPlus(this,getDisplayFig(this.DisplayManager,...
                removedSignalName),false);
            end

            drawnow();
            updateDisplaySelection(this,selectedDisplayID);

            numDisplays=this.DisplayManager.NumDisplays;
            updateVisibilityOfSignal(this.AttributesSublabelsDisplay,numDisplays-1);
            selectedDisplay=reassignDisplaySelection(this);
            if isempty(selectedDisplay)
                updatePanelSignal(this.AttributesSublabelsDisplay,'');
            else
                changeDisplayBorderROIColor(this.DisplayManager,selectedDisplay.Name);
                updatePanelSignal(this.AttributesSublabelsDisplay,selectedDisplay.Name);
            end

            if numDisplays==1
                clearAfterLastSignalRemoved(this);

                this.undoRedoQABCallback();
            else
                updateRangeSliderWithRemovedSignals(this.RangeSliderObj,...
                removedSignals,~evtData.SignalsBeingAdded);
            end


            if~isempty(this.ProjectedViewDisplay)
                onProjectedViewClose(this);
                this.ProjectedViewDisplay=[];
            end


            updateToolstrip(this);

        end


        function updateDisplaySelection(~,~)

        end


        function addDisplays(this,~,evtData)

            addedSignals=evtData.AddedSignals;






            grabFocus(this.DisplayManager);

            for idx=1:numel(addedSignals.SignalNames)
                signalName=addedSignals.SignalNames(idx);
                signalType=addedSignals.SignalType(idx);
                dispType=signalType2DisplayType(this,signalType);
                addNewDisplayAsTab(this,dispType,signalName);
            end

            if this.NumSignalsForDisplay>0

                if isNoneSignalDocVisible(this.Container)
                    drawnow()


                    makeNonDisplayInvisible(this.Container);
                end
            end

            isSliderCreation=false;


            if isempty(this.RangeSliderObj)&&(this.NumSignalsForDisplay>0)


                createAndSetRangeSlider(this);
                hideRangeSliderContent(this);
                this.ShowNavControlTab=true;

                if~useAppContainer
                    makeSignalNavVisible(this.Container);drawnow();
                end
                createXMLandGenerateLayout(this,1,1);
                showRangeSliderContent(this);

                isSliderCreation=true;
            end

            changeSelectedDisplayBorderROIColor(this.DisplayManager);

            if~isempty(this.RangeSliderObj)
                currentTime=getRangeSliderCurrentTime(this);
                for idx=1:numel(addedSignals.SignalNames)
                    signalName=addedSignals.SignalNames(idx);

                    frame=this.SignalLoadController.readFrame(currentTime,signalName);

                    if handleException(this)
                        break;
                    end

                    drawFrameWithInteractiveROIs(this,frame);
                end



                labelIDs=queryFrameLevelAnnotationAll(this);
                updateFrameLabelStatus(this.FrameLabelSetDisplay,labelIDs);

                if~isSliderCreation
                    timeVectors=getTimeVectors(this.Session,addedSignals.SignalNames);
                    signalData=struct;
                    signalData.SignalName=addedSignals;
                    signalData.TimeVectors=timeVectors;

                    updateRangeSliderWithAddedSignals(this.RangeSliderObj,signalData);
                end

            end


            if(this.DisplayManager.NumDisplays>1)
                this.AreSignalsLoaded=true;
            else
                this.AreSignalsLoaded=false;
            end


            if~isempty(this.DisplayManager.getSelectedDisplay)&&...
                ~this.DisplayManager.getSelectedDisplay.IsCuboidSupported
                setPixelModeFromToolstrip(this);
            end
            updateROIModeAndAttribs(this);

            grabFocus(this.DisplayManager);

            if this.Session.hasPointCloudSignal&&...
                this.DisplayManager.getSelectedDisplay.IsCuboidSupported
                if numel(this.DisplayManager.Displays)>2
                    clusterViewStatus=this.getColorByCluster;
                else
                    if isempty(this.Session.ClusterViewStatus)

                        this.Session.ClusterViewStatus=0;
                        clusterViewStatus=0;
                    else
                        clusterViewStatus=this.Session.ClusterViewStatus;
                    end
                end

                selectedItem=this.getSelectedItemInfo();
                if selectedItem.isRectOrCubeLabelItemSelected
                    retainClusterVisualizationState(this,clusterViewStatus);
                end
            end


            if~isempty(this.ProjectedViewDisplay)
                onProjectedViewClose(this);
                this.ProjectedViewDisplay=[];
            end


            updateToolstrip(this);


            selectedDisplay=getSelectedDisplay(this);
            signalList=this.LabelTab.getSignalList();
            updateVisibilityOfSignal(this.AttributesSublabelsDisplay,length(signalList)+length(addedSignals));
            if~isempty(selectedDisplay)
                updatePanelSignal(this.AttributesSublabelsDisplay,selectedDisplay.Name);
            end
            if(this.ToolType==vision.internal.toolType.GroundTruthLabeler)
                updateVisualSummaryXAxes(this);
            end


...
...
...
...
...
        end


        function selectedDisplay=reassignDisplaySelection(this)
            numDisplays=this.DisplayManager.NumDisplays;
            selectedDisplay=getSelectedDisplay(this);
            if isempty(selectedDisplay)
                if numDisplays<=1
                    return;
                else

                    selectedDisplay=this.DisplayManager.getDisplayFromIdNoCheck(2);
                    evtData.ClientName=selectedDisplay.Name;
                    reactToAppClientActivation(this,this,evtData);
                end
            end

        end


        function changeStackOrderOfLidarTab(this)
            if isSelectedDisplayLidar(this.DisplayManager)&&...
                isCoboidLabelDefSelected(this)



                showLidarTab(this);

            elseif~isSelectedDisplayLidar(this.DisplayManager)&&isInAlgoMode(this)
                this.ActiveTab=this.AlgorithmTab;
                this.TabGroup.SelectedTab=getTab(this.AlgorithmTab);
                drawnow();
            else
                bringNonLidarTabFront(this);
            end
        end


        function[startTime,endTime]=getSignalStartEndTime(this)
            timeVector=getTimeVectors(this.Session,this.SignalNamesForAutomation);
            startTime=timeVector{1}(1);
            if numel(timeVector{1})>1
                frameRate=timeVector{1}(2)-timeVector{1}(1);
            else
                frameRate=seconds(1);
            end
            endTime=timeVector{1}(end)+frameRate;

            startTime=seconds(startTime);
            endTime=seconds(endTime)-1e-10;

        end


        function[startTime,endTime]=getMasterSignalStartEndTime(this)
            timeVector=this.SignalTimeVector;
            startTime=(timeVector(1));
            if numel(timeVector)>1
                frameRate=(timeVector(2)-timeVector(1));
            else
                frameRate=1;
            end
            endTime=timeVector(end)+frameRate;
            endTime=endTime-1e-10;
        end


        function[startEndTimeOfSignals,startTimeOfSignals,endTimeOfSignals]=...
            getAutomationSelectedSignalStartEndTime(this)
            timeVector=this.SignalTimeVector;
            timeVectors=getTimeVectors(this.Session,this.SignalNamesForAutomation);

            if(isempty(timeVector))
                timeVector=seconds(timeVectors{1});
            end

            if numel(timeVector)>1
                frameRate=(timeVector(2)-timeVector(1));
            else
                frameRate=1;
            end
            startEndTimeOfSignals=cell(this.NumSignalsForAutomation,1);
            startTimeOfSignals=cell(this.NumSignalsForAutomation,1);
            endTimeOfSignals=cell(this.NumSignalsForAutomation,1);
            for i=1:this.NumSignalsForAutomation
                startTime=seconds(timeVectors{i}(1));
                endTime=seconds(timeVectors{i}(end))+frameRate;
                endTime=endTime-1e-10;
                startTimeOfSignals{i}=startTime;
                endTimeOfSignals{i}=endTime;
                startEndTimeOfSignals{i}=strjoin({num2str(startTime),num2str(endTime)},' to ');
            end
        end


        function saveLayoutToSession(this,xmlString)
            if nargin==2

                layout=this.deserializeLayout(xmlString);
            else
                layout=getTilingLayout(this);
            end
            saveLabelModeLayout(this.Session,layout);
        end


        function loadLayoutFromSessionIfPossible(this)
            layout=getLabelModeLayout(this.Session,this.Tool);
            if isLayoutCompatible(this,layout)
                setAppLayout(this,layout);
            else






            end
        end



        function closeAllFigures(this)
            this.IsAppClosing=true;


            if hasCustomDisplay(this)
                closeConnectorTarget(this);
            end


            closeAllFigures@vision.internal.labeler.tool.LabelerTool(this);


            closeExceptionDialogs(this);
        end


        function doLoad=warnBeforeLoading(this)
            if this.AreSignalsLoaded

                dialogName=vision.getMessage('vision:labeler:LoadVideoWarningDlg');
                displayMessage=vision.getMessage('vision:labeler:LoadVideoWarningDisplay');
                yes=vision.getMessage('MATLAB:uistring:popupdialogs:Yes');
                no=vision.getMessage('MATLAB:uistring:popupdialogs:No');
                hFig=this.Container.getDefaultFig;

                selection=vision.internal.labeler.handleAlert(hFig,'questionWithWaitDlg',displayMessage,dialogName,...
                this.Tool,yes,no,yes);

                if strcmpi(selection,yes)
                    doLoad=true;
                else
                    doLoad=false;
                end
            else
                doLoad=true;
            end
        end


        function readFrameExceptionListener(this,varargin)


            this.CaughtReadException=true;
            this.RangeSliderObj.exceptionDuringPlayListener(varargin{:});
            if~isempty(this.VisualSummaryDisplay)
                this.VisualSummaryDisplay.exceptionDuringPlayListener(varargin{:});
            end
        end


        function resetReadException(this)
            this.CaughtReadException=false;
        end


        function idx=getCurrentIndex(this,varargin)
            if isempty(varargin)
                idx=getLastReadIdx(this.SignalLoadController);
            else
                signalName=varargin{1};
                idx=getLastReadIdx(this.SignalLoadController,signalName);
            end
        end


        function hideRangeSliderContent(this)
            hideContent(this.RangeSliderObj);
        end


        function showRangeSliderContent(this)
            showContent(this.RangeSliderObj);
        end


        function setGroundRemoval(this,pcDisplay,evt)
            wait(this.Container);
            if strcmp(evt.Mode,'segmentGroundSMRF')
                setGroundRemoval(pcDisplay,evt.HideGround,evt.Mode,...
                evt.ElevationAngleDelta,evt.InitialElevationAngle,...
                evt.MaxDistance,evt.ReferenceVector,evt.MaxAngularDistance,...
                evt.GridResolution,evt.ElevationThreshold,...
                evt.SlopeThreshold,evt.MaxWindowRadius);
            else
                setGroundRemoval(pcDisplay,evt.HideGround,evt.Mode,...
                evt.ElevationAngleDelta,evt.InitialElevationAngle,...
                evt.MaxDistance,evt.ReferenceVector,evt.MaxAngularDistance);
            end
            resume(this.Container);
            if getProjectedViewDisplayStatus(this)&&(numel(this.DisplayManager.Displays)>2)
                selectedDisplay=this.DisplayManager.getSelectedDisplay;
                if selectedDisplay.SignalType==vision.labeler.loading.SignalType.PointCloud



                    if strcmp(evt.Mode,'segmentGroundSMRF')
                        setGroundRemoval(selectedDisplay,evt.HideGround,evt.Mode,...
                        evt.ElevationAngleDelta,evt.InitialElevationAngle,...
                        evt.MaxDistance,evt.ReferenceVector,evt.MaxAngularDistance,...
                        evt.GridResolution,evt.ElevationThreshold,...
                        evt.SlopeThreshold,evt.MaxWindowRadius);
                    else
                        setGroundRemoval(selectedDisplay,evt.HideGround,evt.Mode,...
                        evt.ElevationAngleDelta,evt.InitialElevationAngle,...
                        evt.MaxDistance,evt.ReferenceVector,evt.MaxAngularDistance);
                        resume(this.Container);
                    end
                end
            end

        end


        function setClusterData(this,pcDisplay,evt)
            wait(this.Container);
            setClusterData(pcDisplay,evt.ClusterData,evt.Mode,evt.DistanceThreshold,evt.AngleThreshold,evt.MinDistance,evt.NumClusters);
            display=this.DisplayManager.getSelectedDisplay;
            if display.SignalType==vision.labeler.loading.SignalType.PointCloud
                if~isempty(display.KMeansClusters)
                    KMeansNumClusters=display.KMeansClusters;
                else
                    KMeansNumClusters=0;
                end
                this.LidarTab.updateNumClustersInClusterSettingsDialog(KMeansNumClusters);
            end
            resume(this.Container);
        end


        function bringLidarTabFront(this)
            if this.ActiveTab~=this.LidarTab
                this.ActiveTab=this.LidarTab;
                this.TabGroup.SelectedTab=getTab(this.LidarTab);
                drawnow();
            end
        end


        function bringNonLidarTabFront(this)

            if this.ActiveTab==this.LidarTab

                labelTab=getTab(this.LabelTab);
                lidarTab=getTab(this.LidarTab);
                semanticTab=getTab(this.SemanticTab);
                selectedTab=getSelectedTab(this);

                if isempty(selectedTab)||strcmp(labelTab.Tag,selectedTab.Tag)||...
                    strcmp(lidarTab.Tag,selectedTab.Tag)||strcmp(semanticTab.Tag,selectedTab.Tag)
                    this.ActiveTab=this.LabelTab;
                    this.TabGroup.SelectedTab=labelTab;
                    drawnow();
                else
                    this.ActiveTab=this.AlgorithmTab;
                    this.TabGroup.SelectedTab=getTab(this.AlgorithmTab);
                    drawnow();
                end
            end
        end


        function showLidarTab(this)

            show(this.LidarTab);
            drawnow();
            bringLidarTabFront(this);
        end


        function hideLidarTab(this)


            lidarTab=getTab(this.LidarTab);
            if hasTab(this,lidarTab)
                hide(this.LidarTab);
                drawnow();
            end


            labelTab=getTab(this.LabelTab);
            lidarTab=getTab(this.LidarTab);
            semanticTab=getTab(this.SemanticTab);
            selectedTab=getSelectedTab(this);



            if isempty(selectedTab)||strcmp(labelTab.Tag,selectedTab)||...
                strcmp(lidarTab.Tag,selectedTab)||strcmp(semanticTab.Tag,selectedTab)
                this.ActiveTab=this.LabelTab;
            else
                this.ActiveTab=this.AlgorithmTab;
            end
        end


        function labelIDs=queryFrameLevelAnnotationAll(this)


            signalNames=getSignalNames(this.Session);
            signalNames=cellstr(signalNames);
            labelIDs=[];

            for i=1:numel(signalNames)

                signalName=signalNames{i};
                currentReadIndex=getCurrentFrameIndex(this,signalName);


                [~,~,labelIDs]=this.Session.queryFrameLabelAnnotationBySignalName(signalName,currentReadIndex);
                if~isempty(labelIDs)
                    return;
                end
            end

        end


        function freezeRangeSlider(this,~,~)
            disableRangeSlider(this.RangeSliderObj);
            if~this.IsVideoLabeler
                disableEditBoxes(this.RangeSliderObj);
            end
        end


        function unfreezeRangeSlider(this,~,~)
            if isInAlgoMode(this)
                unfreezeScrubberInteraction(this);
            else
                enableRangeSlider(this.RangeSliderObj);
                if~this.IsVideoLabeler
                    enableEditBoxes(this.RangeSliderObj);
                end
            end
        end


        function updateRangeSlider(this,settings,interval)
            updateRangeSlider(this.RangeSliderObj,settings,interval);
        end


        function updateSnapButtonStatus(this,snapButtonStatus)
            updateSnapButtonStatus(this.RangeSliderObj,snapButtonStatus);
        end


        function saveProjectedViewStatus(this)
            selectedDisplay=getSelectedDisplay(this);
            if~isempty(selectedDisplay)&&selectedDisplay.IsCuboidSupported
                saveProjectedView(this.Session,selectedDisplay.ProjectedView);
            end

        end


        function loadProjectedViewFromSession(this,status)
            selectedDisplay=getSelectedDisplay(this);
            if status
                this.LidarTab.switchOnProjectedView();
            else
                this.LidarTab.switchOffProjectedView();
            end
            displays=this.DisplayManager.Displays;
            if numel(displays)>2
                for i=2:numel(displays)
                    if displays{i}.SignalType==vision.labeler.loading.SignalType.PointCloud
                        selectedDisplay=displays{i};
                    end
                end
            end

            if~isempty(selectedDisplay)&&selectedDisplay.IsCuboidSupported
                setUpProjectedView(this,selectedDisplay,status);
            end
        end
    end




    methods(Access=protected)

        function createAndSetRangeSlider(this)
            import vision.internal.videoLabeler.*;

            signalNames=getSignalNames(this.Session);
            timeVectors=getTimeVectors(this.Session,signalNames);

            signalData=struct;
            signalData.SignalName=signalNames;
            signalData.TimeVectors=timeVectors;

            this.RangeSliderObj=getRangeSlider(this,signalData);

            attachRangeSliderListeners(this);
            videoLabelUIContainer=this.SignalNavigationDisplay.getLabeledVideoContainer();
            videoLabelUIContainer.setRangeSlider(this.RangeSliderObj);

            if useAppContainer
                makeSignalNavVisible(this.Container);


                this.Tool.WindowBounds=this.Tool.WindowBounds+1;
                drawnow();
            end

            this.SignalNavigationDisplay.resizeFigure();
        end


        function rangeSliderObj=getRangeSlider(this,signalData)
            rangeSliderObj=vision.internal.labeler.tool.RangeSlider(...
            this.SignalNavigationDisplay.getLabeledVideoContainer(),...
            signalData,this.IsVideoLabeler);
        end


        function attachRangeSliderListeners(this)



            addlistener(this.RangeSliderObj,'LastFrameRequested',@this.lastFrameRequestedListener);
            addlistener(this.RangeSliderObj,'FirstFrameRequested',@this.firstFrameRequestedListener);
            addlistener(this.RangeSliderObj,'PrevFrameRequested',@this.prevFrameRequestedListener);
            addlistener(this.RangeSliderObj,'NextFrameRequested',@this.nextFrameRequestedListener);

            addlistener(this.RangeSliderObj,'PlayInit',@this.playInitListener);
            addlistener(this.RangeSliderObj,'PlayLoop',@this.playLoopListener);
            addlistener(this.RangeSliderObj,'PlayEnd',@this.playEndListener);

            addlistener(this.RangeSliderObj,'ScrubberPressed',@this.scrubberPressedListener);
            addlistener(this.RangeSliderObj,'ScrubberMoved',@this.scrubberMovedListener);
            addlistener(this.RangeSliderObj,'ScrubberReleased',@this.scrubberReleasedListener);




            addlistener(this.RangeSliderObj,'CurrentTimeChanged',@this.currentTimeChangedListener);

            addlistener(this.RangeSliderObj,'UpdateValue',@this.updateValueListener);








        end

        function handleConnectorForNewSession(~)

        end


    end

    methods

        function freezeSignalNavInteractions(this)
            freezeRangeSlider(this,[],[]);
        end


        function unfreezeSignalNavInteractions(this)
            unfreezeRangeSlider(this,[],[]);
        end




        function freezeScrubberInterval(this)

            freezeInterval(this.RangeSliderObj);
        end




        function unfreezeScrubberInterval(this)
            if~isempty(this.RangeSliderObj)
                unfreezeInterval(this.RangeSliderObj);
            end
        end




        function freezeScrubberInteraction(this)

            playbackControlState=false;
            freezeInteraction(this.RangeSliderObj,playbackControlState);
        end




        function unfreezeScrubberInteraction(this)

            playbackControlState=true;
            unfreezeInteraction(this.RangeSliderObj,playbackControlState);
        end





        function moveLeftIntervalToCurrentTime(this)

            moveLeftIntervalToCurrentTime(this.RangeSliderObj);
        end





        function moveRightIntervalToCurrentTime(this)

            moveRightIntervalToCurrentTime(this.RangeSliderObj);
        end





        function moveLeftInterval(this,time)

            updateLeftIntervalToTime(this.RangeSliderObj,time);
        end


        function moveRightInterval(this,time)

            updateRightIntervalToTime(this.RangeSliderObj,time);
        end


        function disableTabControlsOnPlayback(this)
            disableControlsForPlayback(this.LabelTab);
        end


        function enableTabControlsOnPlayback(this)

            if this.ActiveTab==this.LabelTab
                updateToolstrip(this);
            else
                updateToolstrip(this);
                enableControlsForPlayback(this.AlgorithmTab);
                if~this.IsVideoLabeler
                    enableControlsForPlayback(this.LidarTab);
                end
            end
        end
    end




    methods

        function addSessionCustomDisplay(~,~,~)

        end
    end


    methods

        function pcListeners=wireUpLidarListeners(this,pcDisplay)

            pcListeners{1}=event.listener(this.LidarTab,'ColormapChanged',@(src,evt)setColormap(pcDisplay,evt.Colormap,evt.ColormapValue));
            pcListeners{2}=event.listener(this.LidarTab,'ViewChanged',@(src,evt)setCameraView(pcDisplay,evt.CameraPosition,evt.CameraTarget,evt.CameraUpVector,evt.CameraViewAngle,evt.AzimuthElevation));
            pcListeners{3}=event.listener(this.LidarTab,'CuboidSnappingChanged',@(src,evt)set(pcDisplay,'SnapToFit',evt.ShrinkCuboid));
            pcListeners{4}=event.listener(this.LidarTab,'HideGroundChanged',@(src,evt)setGroundRemoval(this,pcDisplay,evt));
            pcListeners{5}=event.listener(this.LidarTab,'ClusterDataChanged',@(src,evt)setClusterData(this,pcDisplay,evt));
            pcListeners{6}=event.listener(this.LidarTab,'StartColoringByClusters',@(~,~)set(pcDisplay,'ColorByCluster',true));
            pcListeners{7}=event.listener(this.LidarTab,'StopColoringByClusters',@(~,~)set(pcDisplay,'ColorByCluster',false));
            pcListeners{8}=event.listener(this.LidarTab,'ProjectedViewPressed',@(src,evt)setUpProjectedView(this,pcDisplay,evt.Status));
            pcListeners{9}=event.listener(this.LidarTab,'Line3DSnapChanged',@(src,evt)set(pcDisplay,'SnapToPoint',evt.SnapToPoint));
            pcListeners{10}=event.listener(this.LidarTab,'BackgroundColorChanged',@(src,evt)setBackgroundColor(pcDisplay,evt.Color));
            pcListeners{11}=event.listener(this.LidarTab,'PlanarViewChanged',@(src,evt)setPlanarView(pcDisplay,evt.View));

            addListenersToDisplayObject(pcDisplay,pcListeners);


            refresh(this.LidarTab)

        end
    end




    methods(Access=public)

        function saveLayoutToFile(this)

            dlg=vision.internal.videoLabeler.tool.SaveLayoutDlg(this.Tool);
            wait(dlg);

            if~dlg.IsCanceled

                if useAppContainer()
                    fileExt='json';
                else
                    fileExt='xml';
                end
                fileName=[dlg.FileName,'.',fileExt];
                if this.IsVideoLabeler
                    writeDirectory=fullfile(prefdir,'vl','layouts');
                else
                    writeDirectory=fullfile(prefdir,'gtl','layouts');
                end

                success=true;
                if~isfolder(writeDirectory)
                    success=mkdir(writeDirectory);
                end

                if success
                    layout=getTilingLayout(this);
                    fullFileName=string(fullfile(writeDirectory,fileName));
                    serializeLayoutToFile(this,layout,fullFileName);
                end
            end
        end


        function loaded=loadLayoutFromFile(this,fullFileName)

            if exist(fullFileName{:},'file')
                layout=deserializeLayoutFromFile(this,fullFileName);
                serializedLayout=serializeLayout(this,layout);
                wasVisualSummaryDocked=contains(string(serializedLayout),this.NameVisualSummaryDisplay);

                if wasVisualSummaryDocked
                    visualSummaryOpen=openVisualSummary(this);
                    if visualSummaryOpen
                        dockVisualSummary(this.VisualSummaryDisplay);
                    end
                end

                setAppLayout(this,layout);
                saveLayoutToSession(this);
                loaded=true;
            else
                hFig=this.Container.getDefaultFig;
                errorMessage=vision.getMessage('vision:labeler:LayoutOpenError');
                dialogName=getString(message('vision:labeler:LayoutOpenErrorTitle'));
                vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,...
                this.Tool);
                loaded=false;
            end
        end
    end




    methods(Access=public)
        function restoreLayoutAfterPVClosed(this)
            for idx=1:size(this.ProjectedViewListenerHandles,2)
                delete(this.ProjectedViewListenerHandles{idx});
            end
            this.LidarTab.switchOffProjectedView();

            selectedDisplay=getSelectedDisplay(this);
            if~isempty(selectedDisplay)&&selectedDisplay.IsCuboidSupported
                selectedDisplay.ProjectedView=0;
            end
            prevSelectedDisplay=getSelectedDisplay(this);
            if~isempty(this.DisplayManager.Displays)&&~isInAlgoMode(this)


                createXMLandGenerateLayout(this,this.NumRowsInLayout,this.NumColsInLayout);
            elseif~isempty(this.DisplayManager.Displays)&&isInAlgoMode(this)
                this.NumColsInLayout=this.NumColsInLayout-1;
                createXMLandGenerateLayout(this,this.NumRowsInLayout,this.NumColsInLayout);
            end
            if~isempty(prevSelectedDisplay)
                grabFocus(prevSelectedDisplay)
            end
        end

        function restoreDefaultLayout(this,showInstructionTab)
            restoreDefaultLayout@vision.internal.labeler.tool.Layout(this,showInstructionTab);

            if getProjectedViewDisplayStatus(this)
                if isDocked(this.ProjectedViewDisplay)
                    createProjectedViewLayout(this)
                    setTabName(this,this.ProjectedViewDisplay,'Projected view');
                end
            end
        end

        function createProjectedViewLayout(this)
            createProjectedViewLayout@vision.internal.labeler.tool.Layout(this)
        end

        function createProjectedViewLayoutInAlgoMode(this)
            createProjectedViewLayoutInAlgoMode@vision.internal.labeler.tool.Layout(this);
        end
    end

    methods

        function configureNewDisplayHelper(this,newDisplay)
            addlistener(newDisplay,'FreezeSignalNav',@this.freezeSignalNav);
            addlistener(newDisplay,'UnfreezeSignalNav',@this.unfreezeSignalNav);
        end



        function dockVisualSummary(this,dock)
            if dock
                dockVisualSummary(this.VisualSummaryDisplay);
            else
                undockVisualSummary(this.VisualSummaryDisplay);
            end
            saveLayoutToSession(this);
        end
    end




    methods(Access=public,Hidden)


        function addSignals(this)
            onProjectedViewClose(this);

            this.ProjectedViewDisplay=[];

            wait(this.Container);

            viewInfo=[];

            openDialog(this.SignalLoadController,viewInfo);

            resume(this.Container);

        end


        function loadSource(this,source)
            wait(this.Container);
            updateSignalLoadingStatus(this,source);





            if~this.IsAppClosing
                loadFromSourceObj(this.SignalLoadController,source);
                this.setStatusText('');
                resume(this.Container);
            end
        end

    end


    methods

        function updateLabelerCurrentTime(this,newTime,drawInteractiveFlag)

            this.RangeSliderObj.updateLabelerCurrentTime(newTime,drawInteractiveFlag);
        end


        function t=getRangeSliderStartTime(this)
            t=this.RangeSliderObj.IntervalStartTime;
        end


        function t=getRangeSliderEndTime(this)
            t=this.RangeSliderObj.IntervalEndTime;
        end


        function t=getRangeSliderCurrentTime(this)
            t=this.RangeSliderObj.ScrubberCurrentTime;
        end


        function tf=isSignalRangeValid(this,selectedSignalName)

            rsStartTime=getRangeSliderStartTime(this);
            rsStartTime=seconds(rsStartTime);
            rsEndTime=getRangeSliderEndTime(this);
            rsEndTime=seconds(rsEndTime);
            selectedSignalTimeVector=getTimeVectors(this.Session,selectedSignalName);
            selectedSignalTimeVector=selectedSignalTimeVector{1};
            lastFrame=selectedSignalTimeVector(2)-selectedSignalTimeVector(1);
            ssStartTime=selectedSignalTimeVector(1);
            ssEndTime=selectedSignalTimeVector(end)+lastFrame;

            tf=checkSignalValid(this,rsStartTime,rsEndTime,ssStartTime,ssEndTime);

        end


        function tf=checkSignalValid(~,rsStartTime,rsEndTime,ssStartTime,ssEndTime)
            tf=true;
            if(rsStartTime>ssEndTime||rsEndTime<ssStartTime)
                tf=false;
            end
        end


        function frameIdx=getLastReadFrameIdx(this,signalName)
            frameIdx=getLastReadIdx(this.SignalLoadController,signalName);
        end
    end

    methods

        function viewClustersState=getClusterVisualizationState(this)
            display=this.DisplayManager.Displays;
            if numel(display)<2

                return;
            end
            for i=2:numel(display)
                if display{i}.SignalType==vision.labeler.loading.SignalType.PointCloud
                    viewClustersState=display{i}.ColorByCluster;
                end
            end
        end

        function retainClusterVisualizationState(this,viewClustersState)
            display=this.DisplayManager.Displays;
            if numel(display)<2
                return;
            end
            for i=2:numel(display)
                if display{i}.SignalType==vision.labeler.loading.SignalType.PointCloud
                    display{i}.ColorByCluster=viewClustersState;
                    changeClusterSettingsState(this,false)
                end
            end
            updateColormapSection(this);
        end
    end

    methods(Access=protected)


        function freezeSignalNav(this,~,~)
            disableRangeSlider(this.RangeSliderObj);
        end


        function unfreezeSignalNav(this,~,~)
            if isInAlgoMode(this)
                unfreezeScrubberInteraction(this);
            else
                enableRangeSlider(this.RangeSliderObj);
            end
        end


        function value=getSnapButtonStatus(this)
            value=this.RangeSliderObj.IsDoingSnap;
        end


        function updateRangeSliderAtCurrentTime(this,t)
            this.RangeSliderObj.updateRangeSliderAtCurrentTime(t);
        end


        function moveScrubberFamilyAtTime(this,t)
            this.RangeSliderObj.moveScrubberFamilyAtTime(t);
        end


        function moveScrubberFamilyToStart(this)
            this.RangeSliderObj.moveScrubberFamilyToStart;
        end


        function moveScrubberFamilyToEnd(this)
            moveScrubberFamilyToEnd(this.RangeSliderObj);
        end


    end



    methods(Access=public,Hidden)

        function handleCloseProjectedView(this,~,~)
            delete(this.ProjectedViewDisplay);
            restoreLayoutAfterPVClosed(this);
        end

        function setUpProjectedView(this,pcDisplay,status)

            selectedDisplay=this.DisplayManager.getSelectedDisplay;
            if~strcmp(selectedDisplay.Name,pcDisplay.Name)
                if~selectedDisplay.IsCuboidSupported
                    selectedDisplay=pcDisplay;
                end
            end
            if status
                if strcmp(selectedDisplay.Name,pcDisplay.Name)
                    if~useAppContainer
                        if isempty(this.ProjectedViewDisplay)
                            [this.NumRowsInLayout,this.NumColsInLayout]=getGridLayout(this);
                        elseif~isvalid(this.ProjectedViewDisplay)
                            [this.NumRowsInLayout,this.NumColsInLayout]=getGridLayout(this);
                        end
                    end

                    display=this.DisplayManager.Displays;
                    this.ProjectedViewDisplay=driving.internal.groundTruthLabeler.tool.ProjectedViewDisplay(status);

                    configure(this.ProjectedViewDisplay,@this.doFigKeyPress,...
                    @this.handleCloseProjectedView);
                    addFigureToApp(this.ProjectedViewDisplay,this.Container);

                    configureProjectedViewListeners(this);

                    CreateProjectedViews(this.ProjectedViewDisplay);

                    if numel(display)>2
                        for i=1:numel(display)




                            if display{i}.SignalType==vision.labeler.loading.SignalType.PointCloud



                                addListenersProjectedViewLines(display{i},this.ProjectedViewDisplay);
                                addListenersProjectedViewCuboids(display{i},this.ProjectedViewDisplay);
                                setProjectedView(this.ProjectedViewDisplay,status);
                                initiateProjectedView(selectedDisplay,this.ProjectedViewDisplay);





                                display{i}.ProjectedView=true;
                            end

                        end

                    else
                        addListenersProjectedViewLines(pcDisplay,this.ProjectedViewDisplay);
                        addListenersProjectedViewCuboids(pcDisplay,this.ProjectedViewDisplay);
                        setProjectedView(this.ProjectedViewDisplay,status);
                        initiateProjectedView(pcDisplay,this.ProjectedViewDisplay);
                    end



                    disableMultisignalButton(this.LabelTab);
                    enableSignalViewDropDownMenu(this.LabelTab,false);

                    dockProjectedViewDisplay(this.ProjectedViewDisplay);
                    show(this.ProjectedViewDisplay);
                    bringIconFront(this.ProjectedViewDisplay);
                end
            else
                onProjectedViewClose(this);
            end

        end

        function configureProjectedViewListeners(this)
            this.ProjectedViewListenerHandles{1}=addlistener(this.ProjectedViewDisplay,...
            'FigureDocked',@(varargin)this.protectOnDelete(@this.onProjectedViewDock,varargin{:}));
            this.ProjectedViewListenerHandles{end+1}=addlistener(this.ProjectedViewDisplay,...
            'FigureUndocked',@(varargin)this.protectOnDelete(@this.onProjectedViewUndock,varargin{:}));
            this.ProjectedViewListenerHandles{end+1}=addlistener(this.ProjectedViewDisplay,...
            'FigureClosed',@(varargin)this.protectOnDelete(@this.onProjectedViewClose,varargin{:}));

        end


        function onProjectedViewDock(this,~,~)



            selectedDisplay=this.DisplayManager.getSelectedDisplay;

            grabFocus(selectedDisplay);
            if~isInAlgoMode(this)
                createProjectedViewLayout(this);
                setDisplayTileLocation(this,this.ProjectedViewDisplay,2);
                setTabName(this,this.ProjectedViewDisplay,'Projected view');
            else
                createProjectedViewLayoutInAlgoMode(this);
            end

        end


        function onProjectedViewUndock(this,~,~)
            prevSelectedDisplay=getSelectedDisplay(this);
            restoreDefaultLayout(this,false);
            if~isempty(prevSelectedDisplay)
                grabFocus(prevSelectedDisplay);
            end
        end


        function onProjectedViewClose(this,~,~)
            prevSelectedDisplay=getSelectedDisplay(this);
            close(this.ProjectedViewDisplay);


            enableMultisignalButton(this.LabelTab);
            enableSignalViewDropDownMenu(this.LabelTab,true);
            if~isempty(prevSelectedDisplay)
                grabFocus(prevSelectedDisplay);
            end
        end


        function doROIPanelItemDeletionCallback(this,src,data)
            doROIPanelItemDeletionCallback@vision.internal.labeler.tool.LabelerTool(this,src,data);

            selectedDisplay=getSelectedDisplay(this);
            if~this.Session.HasROILabels&&~isempty(selectedDisplay)&&...
                selectedDisplay.IsCuboidSupported&&selectedDisplay.ProjectedView
                onProjectedViewClose(this);
            end

            this.updateToolstrip();
        end

    end



    methods

        function firstFrameRequestedListener(this,varargin)

            finalize(this);
            tStart=getRangeSliderStartTime(this);
            readAndDrawFramesWithInteractiveROI(this,tStart);
            moveScrubberFamilyAtTime(this,tStart);

            updateROIModeAndAttribs(this);
        end


        function lastFrameRequestedListener(this,varargin)

            finalize(this);

            tEnd=getRangeSliderEndTimeWithCheck(this.RangeSliderObj);

            readAndDrawFramesWithInteractiveROI(this,tEnd);
            moveScrubberFamilyAtTime(this,tEnd);

            updateROIModeAndAttribs(this);
        end


        function prevFrameRequestedListener(this,varargin)


            finalize(this);

            tStart=getRangeSliderStartTimeWithCheck(this.RangeSliderObj);
            tPrev=getPrevFrameTime(this.RangeSliderObj);
            tRead=max(tPrev,tStart);
            readAndDrawFramesWithInteractiveROI(this,tRead)


            if tPrev>tStart
                moveScrubberFamilyAtTime(this,tRead);
            else
                moveScrubberFamilyToStart(this);
            end

            updateROIModeAndAttribs(this);
        end


        function nextFrameRequestedListener(this,varargin)


            finalize(this);

            tEnd=getRangeSliderEndTimeWithCheck(this.RangeSliderObj);
            tNext=getNextFrameTime(this.RangeSliderObj);
            tSignalEnd=getSignalEndTime(this.RangeSliderObj);

            tRead=min(tNext,tEnd);

            readAndDrawFramesWithInteractiveROI(this,seconds(tRead))

            moveScrubberFamilyAtTime(this,tRead);

            updateROIModeAndAttribs(this);
            if tNext>=tEnd||tNext>=tSignalEnd
                lastFrameReached(this.RangeSliderObj);
            else

            end

        end


        function playInitListener(this,varargin)
            if this.Session.hasPointCloudSignal


                this.LidarTab.disableProjectedView();
                onProjectedViewClose(this);

                changeClusterSettingsState(this,true);
            end

            this.disableTabControlsOnPlayback();



            this.RangeSliderObj.IsSelectiveFreeze=this.isInAlgoMode();
            disableClusterVisualization(this);
            disableUndoRedo(this);
        end


        function playLoopListener(this,varargin)

            finalize(this);


            validTimeVector=getPlayTimeVector(this.RangeSliderObj);

            this.playVideo(validTimeVector);

            if this.StopRunning
                closeApp(this);
            end
        end


        function playEndListener(this,varargin)
            this.enableTabControlsOnPlayback();

            if this.SavedStateOfClusterVisuals
                tCur=getRangeSliderCurrentTimeWithCheck(this.RangeSliderObj);
                readAndDrawFramesWithInteractiveROI(this,tCur);
            end



            this.enableClusterVisualization();

            if this.Session.hasPointCloudSignal
                selectedItemInfo=getSelectedItemInfo(this);
                roiItemDataObj=selectedItemInfo.roiItemDataObj;
                disableCuboidSection=true;
                if~isempty(roiItemDataObj)&&(roiItemDataObj.ROI==labelType.Rectangle||...
                    roiItemDataObj.ROI==labelType.Cuboid)
                    disableCuboidSection=false;
                end

                changeClusterSettingsState(this,disableCuboidSection);
                show(this.LidarTab);
                updateProjectedViewStatus(this);
            end
        end


        function scrubberPressedListener(this,varargin)



            disableClusterVisualization(this);
            finalize(this);

            this.ClustersWhenScrubberDragged=this.SavedStateOfClusterVisuals;
            this.replaceStaticROIs();
        end


        function scrubberMovedListener(this,varargin)

            finalize(this);

            tCur=getRangeSliderCurrentTimeWithCheck(this.RangeSliderObj);

            if this.getColorByCluster
                readAndDrawFramesWithInteractiveROI(this,tCur);
            else
                readAndDrawFramesWithStaticROI(this,tCur);
            end

            updateLastQueryTime(this.RangeSliderObj,tCur);


            if(~this.isVideoPaused)
                this.IsScrubberMoved=true;
                if(this.Session.hasPointCloudSignal&&...
                    this.DisplayManager.getSelectedDisplay.IsCuboidSupported)
                    if~this.ClustersWhenScrubberDragged


                        this.SavedStateOfClusterVisuals=this.ClustersWhenScrubberDragged;
                    else
                        this.SavedStateOfClusterVisuals=true;
                    end
                end
            end
        end

        function scrubberReleasedListener(this,varargin)
            tCur=getRangeSliderCurrentTimeWithCheck(this.RangeSliderObj);
            readAndDrawFramesWithInteractiveROI(this,tCur);
            updateLastQueryTime(this.RangeSliderObj,tCur);
            enableClusterVisualization(this)
        end

        function disableClusterVisualizationDuringAutomation(this)
            display=getSelectedDisplay(this);
            if display.SignalType==vision.labeler.loading.SignalType.PointCloud
                if(display.ColorByCluster)
                    display.ColorByCluster=false;
                    updateSavedStateOfClustersDuringAutomation(this,true);
                    updateSavedStateOfClusterVis(this,true)
                    changeClusterSettingsState(this,true);
                else
                    updateSavedStateOfClustersDuringAutomation(this,false);
                end
                updateColormapSection(this);
            end
        end

        function updateSavedStateOfClustersDuringAutomation(this,clustersStateDuringAutomation)
            this.ClustersStateDuringAutomation=clustersStateDuringAutomation;
        end

        function enableClusterVisualizationDuringAutomation(this)
            display=getSelectedDisplay(this);

            if display.SignalType==vision.labeler.loading.SignalType.PointCloud
                if this.ClustersStateDuringAutomation
                    display.ColorByCluster=true;
                    changeClusterSettingsState(this,false);
                else
                    display.ColorByCluster=false;
                end
                updateColormapSection(this);
            end
        end

        function disableClusterVisualization(this)
            display=this.DisplayManager.Displays;
            for i=1:numel(display)
                if display{i}.SignalType==vision.labeler.loading.SignalType.PointCloud

                    if(display{i}.ColorByCluster)
                        display{i}.ColorByCluster=false;
                        savedState=true;
                        updateSavedStateOfClusterVis(this,savedState);
                    else
                        savedState=false;
                        updateSavedStateOfClusterVis(this,savedState);
                    end
                    updateColormapSection(this);
                end
            end
        end

        function updateSavedStateOfClusterVis(this,savedState)
            this.SavedStateOfClusterVisuals=savedState;
        end

        function enableClusterVisualization(this)
            display=this.DisplayManager.Displays;

            for i=1:numel(display)
                if display{i}.SignalType==vision.labeler.loading.SignalType.PointCloud

                    if this.SavedStateOfClusterVisuals
                        display{i}.ColorByCluster=true;
                    else
                        display{i}.ColorByCluster=false;
                    end
                    updateColormapSection(this);
                end
            end
        end


        function currentTimeChangedListener(this,varargin)



            finalize(this);

            tCur=getRangeSliderCurrentTimeWithCheck(this.RangeSliderObj);

            readAndDrawFramesWithInteractiveROI(this,tCur);
        end


        function updateValueListener(this,varargin)
            tCur=getRangeSliderCurrentTime(this);
            if this.RangeSliderObj.DrawInteractive
                if~(this.RangeSliderObj.CaughtExceptionDuringPlay)

                    this.finalize();
                    readAndDrawFramesWithInteractiveROI(this,tCur);
                else


                    resetExceptionDuringPlay(this.RangeSliderObj);
                    return;
                end
            else
                this.readAndDrawFramesWithStaticROI(tCur);
                if(this.RangeSliderObj.CaughtExceptionDuringPlay)


                    resetExceptionDuringPlay(this.RangeSliderObj);
                    return;
                end
            end
        end


        function ts=getLastReadFrameTime(this)
            ts=getLastReadFrameTime(this.RangeSliderObj);
        end


        function[currentFrame,currentFrameIndex]=getCurrentFrameAndFrameidx(this,signalId)
            ts=getLastReadFrameTime(this.RangeSliderObj);
            currentFrame=readFrame(this.SignalLoadController,ts);
            currentFrameIndex=getLastReadIdxFromIdNoCheck(this.SignalLoadController,signalId);
        end


        function resetNavigationControls(this)
            reset(this.RangeSliderObj);
            this.RangeSliderObj=[];
        end
    end




    methods


        function playVideo(this,timeVector)

            this.IsStillRunning=true;

            thisIsMac=ismac;




            for idx=1:numel(timeVector)
                if~this.isVideoPaused
                    frameArray=readFrame(this.SignalLoadController,...
                    timeVector(idx));

                    emptyInFrameArray=cellfun(@isempty,frameArray);
                    findEmptyInFrameArray=find(emptyInFrameArray==1);

                    if(findEmptyInFrameArray>=1)
                        break;
                    end

                    if handleException(this)
                        break;
                    end

                    drawFrameWithStaticROIs(this,frameArray);

                    if this.IsScrubberMoved
                        break;
                    end

                    moveScrubberFamilyAtTime(this,timeVector(idx));

                    notifyFrameChangeEvent(this.RangeSliderObj);

                    [readerException,connectorException]=handleException(this);

                    if readerException||connectorException
                        break;
                    end


                    if thisIsMac



drawnow
                    end
                end
            end



            if this.IsScrubberMoved
                this.IsScrubberMoved=false;
                timeVector=getPlayTimeVector(this.RangeSliderObj);
                this.playVideo(timeVector);
            end



            if this.IsStillRunning
                replaceStaticROIs(this);
            end

            this.IsStillRunning=false;
        end


        function playbackKeyPress(this,src)
            modifierKeys={'shift'};

            keyPressed=src.Key;
            modPressed=src.Modifier;

            playbackKeys={'rightarrow','leftarrow','home','end','space','P'};
            keyIndex=find(strcmpi(keyPressed,playbackKeys),1);

            if strcmp(modPressed,modifierKeys(1))
                if isequal(keyPressed,'leftarrow')||isequal(keyPressed,'rghtarrow')
                    return;
                end
            else


                selectedDisplay=getSelectedDisplay(this);
                hManager=uigetmodemanager(selectedDisplay.Fig);
                hMode=hManager.CurrentMode;
                TF=isobject(hMode)&&isvalid(hMode)&&~isempty(hMode);

                if TF
                    return;
                end




                if keyIndex==1
                    nextFrameCallback(this.RangeSliderObj,[],[]);
                elseif keyIndex==2
                    previousFrameCallback(this.RangeSliderObj,[],[]);
                elseif keyIndex==3
                    firstFrameCallback(this.RangeSliderObj,[],[]);
                elseif keyIndex==4
                    lastFrameCallback(this.RangeSliderObj,[],[]);
                end
            end
        end


        function signalNavigationKeyPress(this,src)

            playbackKeyPress(this,src);
        end


        function flag=isVideoPaused(this)
            flag=this.RangeSliderObj.IsVideoPaused;
        end


        function firstValidFrameIndex=getFirstValidFrameIdx(this,signalName)
            tStart=getRangeSliderStartTime(this);
            firstValidFrameIndex=getFrameIndexFromTime(this.SignalLoadController,...
            tStart,signalName);
        end


        function lastValidFrameIndex=getLastValidFrameIdx(this,signalName)
            tEnd=getRangeSliderEndTimeWithCheck(this.RangeSliderObj);
            lastValidFrameIndex=getFrameIndexFromTime(this.SignalLoadController,...
            tEnd,signalName);
        end


        function replaceStaticROIs(this)


            numSignals=getNumberOfSignals(this.Session);

            for idx=1:numSignals
                displayIdx=idx+1;
                display=getDisplayFromIdNoCheck(this.DisplayManager,displayIdx);
                sz=display.sizeofImage();
                currentFrameId=getLastReadIdx(this.SignalLoadController,idx);
                [data,exceptions]=readDataBySignalId(this.Session,idx,...
                currentFrameId,sz);

                if isempty(exceptions)
                    data.hasPixelLabelInfo=true;
                    display.replaceStaticROIs(data);
                end

                currentROIs=display.getCurrentROIs();
                display.updateUndoOnLabelChange(currentFrameId,currentROIs);
            end
        end




        function readAndDrawFramesWithInteractiveROI(this,timestamp)
            frameArray=readFrame(this.SignalLoadController,timestamp);

            if handleException(this)
                return;
            end

            drawFrameWithInteractiveROIs(this,frameArray);


            updateROIModeAndAttribs(this);



            numSignals=numel(frameArray);
            for idx=1:numSignals

                signalName=frameArray{idx}.SignalName;
                frameIndex=frameArray{idx}.FrameIndex;

                display=getDisplay(this,signalName);
                currentROIs=display.getCurrentROIs();
                display.updateUndoOnLabelChange(frameIndex,currentROIs);
            end
        end


        function drawFrameWithInteractiveROIs(this,frameArray)




            numSignals=numel(frameArray);

            noException=true(numSignals,1);
            sceneLabelIds=[];

            for idx=1:numSignals
                im=frameArray{idx}.Data;
                frameIndex=frameArray{idx}.FrameIndex;
                signalId=frameArray{idx}.SignalId;

                [data,exceptions]=this.Session.readDataBySignalId(signalId,...
                frameIndex,size(im));

                noException(idx)=isempty(exceptions);
                if noException

                    data.Image=im;
                    data.ImageFilename=[];


                    displayId=signalId+1;
                    display=this.DisplayManager.getDisplayFromIdNoCheck(displayId);

                    updateDisplayIndex(display,frameIndex);



                    display.drawImageWithInteractiveROIs(data);

                    display.installContextMenu(this.isInAlgoMode(),this.Session.getNumPixelLabels);

                    sceneLabelIds=[sceneLabelIds(:);data.SceneLabelIds(:)];
                end
            end
            if this.Session.getNumPixelLabels>0
                updatePastePixelContextMenu(this);
            end

            if all(noException)
                sceneLabelIds=unique(sceneLabelIds);
                updateFrameLabelStatus(this.FrameLabelSetDisplay,sceneLabelIds);
            end

            if this.Session.hasPointCloudSignal
                updateProjectedViewStatus(this);
            end
        end




        function readAndDrawFramesWithStaticROI(this,timestamp)
            frameArray=readFrame(this.SignalLoadController,timestamp);

            if handleException(this)
                return;
            end

            drawFrameWithStaticROIs(this,frameArray);


            updateROIModeAndAttribs(this);
        end


        function drawFrameWithStaticROIs(this,frameArray)

            numSignals=numel(frameArray);

            for idx=1:numSignals


                signalId=frameArray{idx}.SignalId;
                frameIndex=frameArray{idx}.FrameIndex;
                image=frameArray{idx}.Data;
                imageSize=size(image);

                [data,exceptions]=readDataBySignalId(this.Session,signalId,...
                frameIndex,imageSize);

                if isempty(exceptions)
                    data.Image=image;
                    data.ImageFilename=[];


                    displayIdx=signalId+1;
                    display=getDisplayFromIdNoCheck(this.DisplayManager,...
                    displayIdx);

                    updateDisplayIndex(display,frameIndex);

                    display.drawImageWithStaticROIs(data);


                    updateFrameLabelStatus(this.FrameLabelSetDisplay,data.SceneLabelIds);
                end
            end
        end
    end

    methods

        function[hasReaderException,hasConnectorException]=handleException(this)


            hasReaderException=false;
            hasConnectorException=false;

            if this.CaughtReadException
                resetReadException(this);
                this.IsStillRunning=false;
                this.replaceStaticROIs();
                hasReaderException=true;
                return;
            end
        end
    end




    methods

        function undo(this,~,~)

            selectedDisplay=getSelectedDisplay(this);
            signalName=selectedDisplay.Name;
            currentIndex=getLastReadIdx(this.SignalLoadController,signalName);
            undoHelper(this,signalName,selectedDisplay,currentIndex);
            updateProjectedViewStatus(this);
        end


        function redo(this,~,~)

            selectedDisplay=getSelectedDisplay(this);
            signalName=selectedDisplay.Name;
            currentIndex=getLastReadIdx(this.SignalLoadController,signalName);
            redoHelper(this,signalName,selectedDisplay,currentIndex);
            updateProjectedViewStatus(this);
        end

        function currentIndex=getCurrentFrameIndex(this,readerIdOrsignalName)
            if isnumeric(readerIdOrsignalName)
                currentIndex=getLastReadIdxFromIdNoCheck(this.SignalLoadController,readerIdOrsignalName);
            else
                currentIndex=getLastReadIdx(this.SignalLoadController,readerIdOrsignalName);
            end
        end
    end

    methods(Access=protected)

        function saveLayoutToSessionInLabelMode(this)






            if isequal(this.ActiveTab,this.LabelTab)
                saveLayoutToSession(this);
            end
        end
    end




    methods(Access=public)


        function controlLidarTabVisibility(this)

            selectedDisplay=getSelectedDisplay(this);

            if~isempty(selectedDisplay)&&this.Session.hasPointCloudSignal
                enableControls(this.LidarTab);

                if~(selectedDisplay.SignalType==vision.labeler.loading.SignalType.PointCloud)...
                    ||~isProjectedViewSupported(selectedDisplay)
                    disableProjectedView(this.LidarTab);
                end



                [roiLabeldefs,~]=getLabelDefinitions(this.Session);
                if~numel(roiLabeldefs)
                    disableCuboidSection(this.LidarTab);
                    disableLineSection(this.LidarTab);
                end

                if~this.isInAlgoMode
                    showLidarTab(this);
                    if isSelectedDisplayLidar(this.DisplayManager)
                        bringLidarTabFront(this)
                    else
                        bringNonLidarTabFront(this);
                    end
                else
                    if isSelectedDisplayLidar(this.DisplayManager)
                        bringLidarTabFront(this)
                        showLidarTab(this);
                    else
                        hideLidarTab(this);
                    end
                end
            else
                hideLidarTab(this);
            end
        end


        function disableLidarControls(this)
            disableControls(this.LidarTab);
            disableLineSection(this.LidarTab);
        end


        function enableLidarControls(this)
            enableControls(this.LidarTab);
            enableLineSection(this.LidarTab);
        end


        function disableCuboidSection(this)
            disableCuboidSection(this.LidarTab);
            changeClusterSettingsState(this.LidarTab,true);
        end


        function enableCuboidSection(this)
            enableCuboidSection(this.LidarTab);
            changeClusterSettingsState(this.LidarTab,false);
        end


        function disableLineSection(this)
            disableLineSection(this.LidarTab);
        end


        function enableLineSection(this)
            enableLineSection(this.LidarTab);
        end
    end




    methods

        function val=get.IsAutomationForward(this)
            val=IsAutomateForward(this.LabelTab);
        end


        function updateFrameLabelData(this,data,AddOrDelete)
            if~this.AreSignalsLoaded
                return
            end

            signalNames=getSignalNames(this.Session);
            signalNames=cellstr(signalNames);

            for i=1:numel(signalNames)
                signalName=signalNames{i};

                if data.ApplyToInterval

                    first=getStartIndex(this,signalName);
                    last=getEndIndex(this,signalName);
                    timeIndex=[first,last];
                    indices=first:last;
                else

                    timeIndex=getCurrentIndex(this,signalName);
                    indices=timeIndex;
                end


                switch AddOrDelete
                case 'add'
                    addFrameLabelAnnotation(this.Session,signalName,timeIndex,data.LabelName);
                    this.FrameLabelSetDisplay.checkFrameLabel(data.ItemId);
                case 'delete'
                    deleteFrameLabelAnnotation(this.Session,signalName,timeIndex,data.LabelName);
                    this.FrameLabelSetDisplay.uncheckFrameLabel(data.ItemId);
                end







                value=strcmpi(AddOrDelete,'add');
                updateVisualSummarySceneCount(this,signalName,data.LabelName,indices,value);
            end
        end

    end

    methods

        function exportLabelDefinitions(this)

            labelDefs=combineCustomLabelDefinitions(this);

            exportLabelDefinitions@vision.internal.labeler.tool.LabelerTool(this,labelDefs);
        end


        function customLabelData=getCustomLabelData(this)
            customLabels=getLabelsFromCustomDisplay(this);
            if isempty(customLabels)
                customLabelData=[];
            else
                customLabelData=customLabels.customLabelData;
            end
        end


        function outTable=appendTableRow(~,inTable,inRowCell)
            tableHeading=inTable.Properties.VariableNames;
            newTableRow=cell2table(inRowCell);
            newTableRow.Properties.VariableNames=tableHeading;

            outTable=[inTable;newTableRow];
        end
    end




    methods

        function importLabelAnnotations(this,source)

            this.setStatusText(vision.getMessage('vision:labeler:ImportLabelAnnotationsStatus'));

            setWaitingToFalseAtExit=onCleanup(@()resume(this.Container));

            if isa(source,'groundTruth')||isa(source,'groundTruthMultisignal')

                gTruth=source;



                pathName=pwd;
                fullName=pwd;
                fileName='gTruth';
            else



                proceed=this.issueImportWarning('Ground Truth');

                if~proceed
                    this.setStatusText('');
                    return;
                end

                [success,gTruth,pathName,fullName,fileName]=importLabelAnnotationsPreWork(this,source);

                if~success||isempty(gTruth)
                    this.setStatusText('');
                    return;
                else




                    if isa(gTruth,'groundTruth')&&~isVideoLabeler(this)
                        displayMessage=vision.getMessage('vision:labeler:ImportGroundTruthInGroundTruthLabelerWarning');
                        dialogName=vision.getMessage('vision:labeler:ImportDialog');
                        yes=vision.getMessage('MATLAB:uistring:popupdialogs:Yes');
                        no=vision.getMessage('MATLAB:uistring:popupdialogs:No');
                        hFig=this.Container.getDefaultFig;

                        selection=vision.internal.labeler.handleAlert(hFig,'questionWithWaitDlg',displayMessage,dialogName,...
                        this.Tool,yes,no,yes);

                        if strcmpi(selection,no)
                            return;
                        end
                    end
                end
            end

            wait(this.Container);


            if isVideoLabeler(this)&&...
                ~validateGroundTruthDataSource(this,gTruth,pathName,fullName,fileName)
                return
            end

            if isa(gTruth,'groundTruth')
                polyOrder=getPolygonOrder(gTruth);
                [gTruthReg,gTruthCustom]=splitGroundTruth(this,gTruth);
                setPolygonOrder(gTruthReg,polyOrder);
            else
                [gTruthReg,gTruthCustom]=splitGroundTruth(this,gTruth);
            end

            hasCustomDisp=hasCustomDisplay(this);
            if~hasCustomDisp&&(~isempty(gTruthCustom))
                hFig=this.Container.getDefaultFig;
                errorMessage=getString(message('vision:labeler:UnableToLoadAnnotationsMsg'));
                dialogName=getString(message('vision:labeler:UnableToLoadAnnotationsDlgName'));
                vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,...
                this.Tool);
                return;
            end


            saveLayoutToSession(this);
            prevLayout=getLabelModeLayout(this.Session,this.Tool);
            [prevGridRow,prevGridCols]=getGridLayout(this);



            reopenVisualSummary=getReopenVisualSummaryFlag(this);

            isCanceled=newSession(this);

            if isCanceled
                return;
            end

            if hasCustomDisp
                addCustomDisplay(this,this.ConnectorHandle);
                this.IsConnectorConfigured=false;
            end

            try

                loadSource(this,gTruthReg.DataSource);
            catch exception
                errorMessage=exception.message;
                dialogName=getString(message('vision:labeler:UnableToLoadAnnotationsDlgName'));
                vision.internal.labeler.handleAlert(this.Container.getDefaultFig,'errorWithWaitDlg',errorMessage,dialogName,this.Tool);
                drawnow;
                return
            end



            if~isempty(gTruthReg)
                this.Session.loadLabelAnnotations(gTruthReg);
                if hasPixelLabels(this.Session)

                    this.updatePixelColorLookup();
                end
            end

            reconfigureUI(this);

            visualSummaryDocked=checkVSDockedFromLayout(this,prevLayout);
            doReopenVisualSummary(this,reopenVisualSummary,visualSummaryDocked);


drawnow

            if~isempty(prevLayout)

                hasPrevLayoutAttribPanel=hasLayoutAttributePanel(this,prevLayout);

                currentLayout=getTilingLayout(this);
                hasCurrentLayoutAttribPanel=hasLayoutAttributePanel(this,currentLayout);

                if(hasCurrentLayoutAttribPanel==hasPrevLayoutAttribPanel)
                    saveLabelModeLayout(this.Session,prevLayout);
                else
                    saveLabelModeLayout(this.Session,currentLayout);
                end
                if~useAppContainer()
                    loadLayoutFromSessionIfPossible(this);
                end




                if prevGridRow>0
                    createAndPopulateDisplayGrid(this,prevGridRow,prevGridCols);
                end

            end

            if hasCustomDisp&&(~isempty(gTruthCustom))
                setCustomLabels(this,gTruthCustom);
            end

            this.setStatusText('');

            onProjectedViewClose(this);
            updateProjectedViewStatus(this);
        end


        function[gTruthReg,gTruthCustom]=splitGroundTruth(~,gTruth)
            [gTruthReg,gTruthCustom]=vision.internal.labeler.splitCustomGroundTruth(gTruth);
        end


        function reconfigureUI(this)



            if this.AreSignalsLoaded
                reconfigureVideoDisplay(this);
            end


            reconfigureROILabelSetDisplay(this);

            reconfigureFrameLabelSetDisplay(this);

            updateToolstrip(this);
        end
    end

    methods(Access=protected)
        function applyRangeSliderInfoFromSession(this)
            rangeSliderStatus=getRangeSliderStatus(this.Session);

            if~isempty(this.RangeSliderObj)&&~isempty(rangeSliderStatus)...
                &&isfield(rangeSliderStatus,'SliderStartTime')&&~isempty(rangeSliderStatus.SliderStartTime)
                interval=[rangeSliderStatus.SliderStartTime,rangeSliderStatus.SliderEndTime];
                currentTime=rangeSliderStatus.SliderCurrentTime;
                snapButtonStatus=rangeSliderStatus.SnapButtonStatus;
                settings=rangeSliderStatus.TimeSettings;

                updateRangeSlider(this,settings,interval);
                updateSnapButtonStatus(this,snapButtonStatus);




                readAndDrawFramesWithInteractiveROI(this,currentTime);
                updateLabelerCurrentTime(this,currentTime,true);
            end
        end
    end

    methods

        function success=validateGroundTruthDataSource(this,gTruth,pathName,fullFilePath,errorDisplayName)






            hFig=this.Container.getDefaultFig;
            try
                if isequal(gTruth.DataSource.SourceType,vision.internal.labeler.DataSourceType.ImageSequence)

                    [~]=cellfun(@(x)vision.internal.uitools.tryToAdjustPath(x,pathName,fullFilePath),gTruth.DataSource.Source,'UniformOutput',false);

                elseif isequal(gTruth.DataSource.SourceType,vision.internal.labeler.DataSourceType.VideoReader)

                    [~]=vision.internal.uitools.tryToAdjustPath(gTruth.DataSource.Source,pathName,fullFilePath);

                elseif isequal(gTruth.DataSource.SourceType,vision.internal.labeler.DataSourceType.ImageDatastore)

                    errorMessage=getString(message('vision:labeler:UnableToLoadAnnotationsDlgMessageImageCollection',errorDisplayName));
                    dialogName=getString(message('vision:labeler:UnableToLoadAnnotationsDlgName'));
                    vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,...
                    this.Tool);

                    resume(this.Container);
                    drawnow();

                    success=false;
                    return
                else


                end

                success=true;

            catch
                errorMessage=getString(message('vision:groundTruth:badSource'));
                dialogName=getString(message('vision:labeler:UnableToLoadAnnotationsDlgName'));
                vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,...
                this.Tool);

                success=false;
            end
        end
    end




    methods

        function success=saveSession(this,fileName)


            if~isempty(this.RangeSliderObj)
                rangeSliderStatus=struct;
                rangeSliderStatus.SliderStartTime=getRangeSliderStartTime(this);
                rangeSliderStatus.SliderCurrentTime=getRangeSliderCurrentTime(this);
                rangeSliderStatus.SliderEndTime=getRangeSliderEndTime(this);
                rangeSliderStatus.SnapButtonStatus=getSnapButtonStatus(this);
                rangeSliderStatus.TimeSettings=getRangeSliderTimeSettings(this.RangeSliderObj);

                setRangeSliderStaus(this.Session,rangeSliderStatus);
            end

            if hasCustomDisplay(this)
                this.Session.ConnectorHandle=this.ConnectorHandle;
                this.Session.CustomLabels=getLabelsFromCustomDisplay(this);
            end

            if hasPointCloudSignal(this.Session)
                this.ViewClustersPreviousState=this.getClusterVisualizationState();
                this.Session.setClusterViewStatus(this.ViewClustersPreviousState);
            end


            if this.isSignalHidden()


                if~useAppContainer()
                    [numRows,numCols]=this.getGridLayout();
                    if~(numRows<1||numRows>3||numCols<1||numCols>3)
                        xmlString=this.createXMLandGenerateLayout(numRows,numCols);
                    else


                        xmlString=this.createXMLandGenerateLayout(1,1);
                    end
                    saveLayoutToSession(this,xmlString);
                else

                    saveLayoutToSession(this);
                end
            else
                saveLayoutToSession(this);
            end
            saveProjectedViewStatus(this);
            if nargin==2
                success=saveSession@vision.internal.labeler.tool.LabelerTool(this,fileName);
            else
                success=saveSession@vision.internal.labeler.tool.LabelerTool(this);
            end
        end


        function cleanSession(this)

            onProjectedViewClose(this);
            this.ProjectedViewDisplay=[];

            if hasPointCloudSignal(this.Session)
                resetGroundSettingsOnNewSession(this.LidarTab);
            end
            cleanSession@vision.internal.labeler.tool.LabelerTool(this);


            this.refreshSignalViewList();

            createSession(this);
            this.SignalLoadController=createSignalLoadController(this);
        end
    end




    methods



        function startAutomation(this)
            if hasPointCloudSignal(this.Session)
                close(this.ProjectedViewDisplay);
            end
            if~useAppContainer
                [this.NumRowsInLayout,this.NumColsInLayout]=getGridLayout(this);
            end

            saveLayoutToSession(this);

            startAutomation@vision.internal.labeler.tool.LabelerTool(this);



            if hasPointCloudSignal(this.Session)&&~any(this.IsValidPtCloudType)
                hide(this.LidarTab);
            end

            updateAttributesSublabelsPanel(this);

            updateVisualSummary(this);

            if~useAppContainer()
                setLayoutAtStartAutomation(this);
            end

        end




        function success=tryToSetupAlgorithm(this)










            closeExceptionDialogs(this);




            moveSelectionFromSublabelTo1stLabelDef(this);
            disableSublabelDefItems(this);


            wait(this.Container);

            oCU=onCleanup(@()resume(this.Container));

            this.AlgorithmConfiguration=getAlgorithmConfigurationSettings(this.LabelTab);



            [signalsSelected,signalTypeInfo]=getSelectedSignalsFromSignalDialog(this);





            selectedDisplay=getSelectedDisplay(this);
            hFig=this.Container.getDefaultFig;

            if(isempty(signalsSelected)&&isMultiSignal(this.LabelTab))


                this.SignalNamesForAutomation=[];
                dialogName=vision.getMessage('vision:labeler:EmptyInSignalSelectionDlg');
                errorMessage=vision.getMessage('vision:labeler:EmptyInSignalSelectionMessage');
                vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,...
                this.Tool);
                success=false;
                return;
            elseif(isempty(signalsSelected))




                this.SignalNamesForAutomation=selectedDisplay.Name;
                signalTypeInfo=selectedDisplay.SignalType;
            else

                this.SignalNamesForAutomation=signalsSelected;
            end


            if(strcmp(selectedDisplay.Fig.Visible,'off'))
                makeFigureVisible(selectedDisplay);
            end


            saveLayoutToSession(this);
            algoDisplay=selectedDisplay;
            this.SelectedDisplayName=algoDisplay.Name;


            [maxEndTimeSignal,timeVector,~]=calAllTimeStamps(this);


            this.MasterSignalBeforeAutomation=this.RangeSliderObj.MasterSignal;


            calNumSignalsForAutomation(this);



            success=false;


            if~this.LabelTab.isAlgorithmSelected
                errorMessage=vision.getMessage('vision:labeler:SelectAlgorithmFirst');
                dialogName=vision.getMessage('vision:labeler:SelectAlgorithmFirstTitle');

                vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,...
                this.Tool);
                return;
            end


            displaysForAutomation=cell(1,this.NumSignalsForAutomation);
            for j=2:numel(this.DisplayManager.Displays)
                isDisplayExists=logical(find(ismember(this.DisplayManager.Displays{j}.Name,...
                this.SignalNamesForAutomation)));
                if(isDisplayExists)
                    displaysForAutomation(j-1)=this.DisplayManager.Displays(j);
                end
            end
            displaysForAutomation=displaysForAutomation(~cellfun('isempty',displaysForAutomation));
            this.DisplaysForAutomation=displaysForAutomation;




            try




                timeInterval=[getRangeSliderStartTime(this),getRangeSliderEndTimeWithCheck(this.RangeSliderObj)];
                this.CachedInterval=[timeInterval,getRangeSliderCurrentTime(this)];




                if~isAlgorithmOnPath(this.AlgorithmSetupHelper,hFig)
                    return;
                end


                if~isAlgorithmValid(this.AlgorithmSetupHelper,hFig)
                    return;
                end



                if~algorithmInstanceFromSession(this.AlgorithmSetupHelper,this.Session)
                    return;
                end

            catch ME

                dlgTitle=vision.getMessage('vision:labeler:CantSetupAlgorithmTitle');
                showExceptionDialog(this,ME,dlgTitle);

                return;
            end

            algorithm=this.AlgorithmSetupHelper.AlgorithmInstance;
            if hasTemporalContext(algorithm)
                if~this.IsAutomationForward&&~supportsReverseAutomation(algorithm)


                    errorMessage=vision.getMessage('vision:labeler:ReverseAlgoUnsuportedMessage');
                    dialogName=vision.getMessage('vision:labeler:ReverseAlgoUnsuportedTitle');
                    vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,...
                    this.Tool);

                    return;
                end
            end


            if this.AlgorithmConfiguration.StartAtCurrentTime
                if this.AlgorithmConfiguration.AutomateForward


                    timeInterval(1)=this.CachedInterval(3);
                else


                    timeInterval(2)=this.CachedInterval(3);
                end
            end



            setFrameIdxIntervalFromTimeInterval(this.Session,timeInterval);
            algoFrameIndexInterval=getFrameIndexInterval(this.Session,this.SignalNamesForAutomation);

            intervalIndices=[1,1];

            tempTimeInterval=timeInterval;

            if(this.NumSignalsForAutomation>1)
                [intervalIndices(1),timeInterval(1)]=getFrameIndexFromTime(this.SignalLoadController,...
                timeInterval(1),maxEndTimeSignal);
                [intervalIndices(2),timeInterval(2)]=getFrameIndexFromTime(this.SignalLoadController,...
                timeInterval(2),maxEndTimeSignal);
            else
                [intervalIndices(1),timeInterval(1)]=getFrameIndexFromTime(this.SignalLoadController,...
                timeInterval(1),this.SignalNamesForAutomation);
                [intervalIndices(2),timeInterval(2)]=getFrameIndexFromTime(this.SignalLoadController,...
                timeInterval(2),this.SignalNamesForAutomation);
            end





            if isnan(timeInterval(1))
                timeInterval(1)=tempTimeInterval(1);
            end

            if isnan(timeInterval(2))
                timeInterval(2)=tempTimeInterval(2);
            end

            fixAlgorithmTimeInterval(this.AlgorithmSetupHelper,timeInterval,...
            algoFrameIndexInterval,this.IsAutomationForward);


            finalize(this);
            signalNames4Automation=this.SignalNamesForAutomation;
            algorithm.SignalName=signalNames4Automation;
            algorithm.SignalType=signalTypeInfo;
            gTruth=exportLabelAnnotations(this.Session);
            setAlgorithmLabelData(this.AlgorithmSetupHelper,gTruth);



            [roiLabelDefs,frameLabelDefs]=getLabelDefinitions(this.Session);

            if this.IsVideoLabeler
                if~checkValidLabels(this.AlgorithmSetupHelper,roiLabelDefs,frameLabelDefs,selectedDisplay.SignalType,hFig)
                    return;
                end



                success=true;
            end

            this.IsValidPtCloudType=logical(find(ismember(signalTypeInfo,...
            vision.labeler.loading.SignalType.PointCloud)));
            if~this.IsVideoLabeler
                for i=1:numel(roiLabelDefs)


                    if(any(this.IsValidPtCloudType)...
                        &&isequal(roiLabelDefs(i).ROI,labelType.Rectangle))
                        roiLabelDefs(i).ROI=labelType.Cuboid;
                    end
                end

                if~checkValidLabels(this.AlgorithmSetupHelper,roiLabelDefs,frameLabelDefs,signalTypeInfo,hFig)
                    return;
                end
            end


            if hasPixelLabels(this.Session)
                newdir=fullfile(this.Session.TempDirectory,'Automation');
                status=mkdir(newdir);
                if status
                    setTempDirectory(this.Session,newdir)
                else
                    return;
                end
            end

            if~this.IsVideoLabeler

                if this.NumSignalsForAutomation>1
                    if~supportsMultisignalAutomation(this.AlgorithmSetupHelper,hFig)
                        return;
                    end
                end
                this.FlagStartTime=this.RangeSliderObj.IntervalStartTime;
                this.FlagEndTime=this.RangeSliderObj.IntervalEndTime;
                if(this.NumSignalsForAutomation>1)
                    this.SignalTimeVector=timeVector;
                else
                    this.SignalTimeVector=this.RangeSliderObj.TimeVector;
                end

                ScrubberCurrenTime=this.RangeSliderObj.ScrubberCurrentTime;
                if numel(this.DisplayManager.Displays)>2
                    if~checkValidIntervals(this,ScrubberCurrenTime)
                        return;
                    else


                        success=true;
                    end
                else


                    success=true;
                end




                selectedSignalId=zeros(size(this.SignalNamesForAutomation));
                for j=1:this.NumSignalsForAutomation
                    selectedSignalId(j,:)=this.DisplayManager.getDisplayIdFromName(this.SignalNamesForAutomation(j));
                end


                signalList=this.LabelTab.getSignalList();
                for i=2:numel(this.DisplayManager.Displays)

                    if~ismember(i,selectedSignalId)&&signalList(i-1).isVisible
                        makeFigureInvisible(this.DisplayManager.Displays{i});
                    end
                end


                saveLayoutToSession(this);
                this.createXMLandGenerateLayout(1,1);
            end

            if this.AlgorithmConfiguration.ImportROIs
                roisImported=cell(1,numel(this.DisplaysForAutomation));
                roisNotImported=cell(1,numel(this.DisplaysForAutomation));

                selectedLabelRois=cell(1,numel(this.DisplaysForAutomation));
                unselectedAllRois=cell(1,numel(this.DisplaysForAutomation));
                for i=1:numel(this.DisplaysForAutomation)
                    [selectedLabelRois{i},unselectedAllRois{i}]=getSelectedLabelROIs(this.DisplaysForAutomation{i});
                end

                if(numel(this.DisplaysForAutomation)==1)
                    idx=importCurrentLabelROIsInAlgoMode(this.AlgorithmSetupHelper,selectedLabelRois{1});
                    roisImported_i=selectedLabelRois{1}(idx);
                    roisImported{1}=roisImported_i;



                    invalidROIs=selectedLabelRois{1}(~idx);
                    roisNotImported_i=vertcat(unselectedAllRois{1}(:),invalidROIs(:));
                    roisNotImported{1}=roisNotImported_i;
                else
                    idx=importCurrentLabelROIsInAlgoMode(this.AlgorithmSetupHelper,selectedLabelRois);
                    for i=1:numel(this.DisplaysForAutomation)
                        roisImported_i=selectedLabelRois{i}(idx{i});
                        roisImported{i}=roisImported_i;



                        invalidROIs=selectedLabelRois{i}(~idx{i});
                        roisNotImported_i=vertcat(unselectedAllRois{i}(:),invalidROIs(:));
                        roisNotImported{i}=roisNotImported_i;
                    end
                end
            else
                roisImported=cell(1,numel(this.DisplaysForAutomation));
                roisNotImported=cell(1,numel(this.DisplaysForAutomation));
                for i=1:numel(this.DisplaysForAutomation)
                    roisNotImported_i=getCurrentROIs(this.DisplaysForAutomation{i});
                    roisNotImported{i}=roisNotImported_i;



                    roisImported_i=repmat(roisNotImported_i,0,0);
                    roisImported{i}=roisImported_i;
                end
            end



            freezeLabelPanelsWhenStartingAutomation(this);
            disableSublabelDefItems(this);


            setVideoDisplayBeforeAutomation(this,roisImported);


            readjustDrawingModeInAutomation(this);


            this.Session.cacheAnnotations(signalNames4Automation);



            validFrameLabelNames=this.AlgorithmSetupHelper.ValidFrameLabelNames;
            for i=1:this.NumSignalsForAutomation
                currentIndex=getLastReadIdx(this.SignalLoadController,this.DisplaysForAutomation{i}.Name);
                algoFrameIndexInterval_i=getFrameIndexInterval(this.Session,this.DisplaysForAutomation{i}.Name);
                replaceROIAnnotations(this.Session,this.DisplaysForAutomation{i}.Name,algoFrameIndexInterval_i,...
                roisImported{i},currentIndex,roisNotImported);
            end
            replaceFrameAnnotationsAllSignals(this.Session,validFrameLabelNames);












            for i=1:this.NumSignalsForAutomation
                currentIndex=getLastReadIdx(this.SignalLoadController,this.SignalNamesForAutomation(i));
                [~,~,labelIDs]=this.Session.queryFrameLabelAnnotationBySignalName(this.SignalNamesForAutomation(i),currentIndex);
                updateFrameLabelStatus(this.FrameLabelSetDisplay,labelIDs);
            end



        end




        function[signalsSelected,signalTypeInfo]=getSelectedSignalsFromSignalDialog(this)
            signalsSelected={};
            signalTypeInfo={};
            prevSelectedDisplay=getSelectedDisplay(this);
            if(isMultiSignal(this.LabelTab))
                this.SignalsSelected=getSelectedSignals(this.LabelTab);
                numSignals=size(this.SignalsSelected.SelectedSignals,1);
                for index=1:numSignals
                    if(this.SignalsSelected.SelectedSignals{index})
                        signalName=this.SignalsSelected.SelectedSignals(index,2);
                        for j=2:numel(this.DisplayManager.Displays)
                            if(strcmp(signalName,this.DisplayManager.Displays{j}.Name))
                                signalTypeInfo=[signalTypeInfo;this.DisplayManager.Displays{j}.SignalType];%#ok<AGROW>
                                if strcmp(this.DisplayManager.Displays{j}.Fig.Visible,'off')
                                    makeFigureVisible(this.DisplayManager.Displays{j});
                                end
                            end
                        end
                        signalsSelected=[signalsSelected;signalName];%#ok<AGROW>
                    end
                end
            end
            if~isempty(prevSelectedDisplay)
                grabFocus(prevSelectedDisplay);
            end
        end




        function[maxEndTimeSignal,timeVector,frameRate]=calAllTimeStamps(this)

            signalNames=this.SignalNamesForAutomation;
            timeVectors=getTimeVectors(this.Session,signalNames);

            allTimeVectors=timeVectors;
            allTimeStamps=[];

            for i=1:numel(allTimeVectors)
                allTimeStamps=[allTimeStamps;allTimeVectors{i}];%#ok<AGROW>
            end
            timeVector=unique(seconds(allTimeStamps));

            numSignals=numel(signalNames);
            if numSignals>0

                endTimeVectors=zeros(numSignals,1);
                frameRates=zeros(numSignals,1);

                for sigId=1:numSignals
                    if(length(timeVectors{sigId})>1)
                        frameRates(sigId)=seconds(timeVectors{sigId}(2))-seconds(timeVectors{sigId}(1));
                        endTimeVectors(sigId)=seconds(timeVectors{sigId}(end));
                    else
                        endTimeVectors(sigId)=seconds(timeVectors{sigId}(1));
                        frameRates(sigId)=seconds(timeVectors{sigId}(1));
                    end
                end
            end

            [frameRate,~]=min(frameRates);
            [~,maxEndTimeVectorIdx]=max(endTimeVectors);
            maxEndTimeSignal=signalNames{maxEndTimeVectorIdx};
        end


        function calNumSignalsForAutomation(this)
            this.NumSignalsForAutomation=numel(this.SignalNamesForAutomation);
        end




        function setVideoDisplayBeforeAutomation(this,selectedROILabels)

            algConfig=this.AlgorithmConfiguration;
            freezeROIDraw=isempty(this.AlgorithmSetupHelper.ValidROILabelNames);


            if algConfig.StartAtCurrentTime
                if algConfig.AutomateForward

                    moveLeftIntervalToCurrentTime(this);
                else

                    moveRightIntervalToCurrentTime(this);
                end
            end

            currentTime=getRangeSliderCurrentTime(this);
            for i=1:size(this.DisplaysForAutomation,2)
                signalName=this.DisplaysForAutomation{i}.Name;
                [data,imageData,currentIndex]=getCurrentIdxSignalData(this,...
                this.DisplaysForAutomation{i},signalName,currentTime);
                data.Image=imageData;
                data.ImageFilename=[];
                onAutomationMode(this.DisplaysForAutomation{i},data,currentIndex,selectedROILabels{i},...
                algConfig,freezeROIDraw);
            end
            this.freezeScrubberInterval();
        end


        function[data,imageData,currentIndex]=getCurrentIdxSignalData(this,algoDisplay,signalName,currentTime)
            currentIndex=getLastReadIdx(this.SignalLoadController,signalName);
            updateDisplayIndex(algoDisplay,currentIndex);
            imageInfo=this.SignalLoadController.readFrame(currentTime,signalName);
            imageData=imageInfo{1}.Data;
            signalId=imageInfo{1}.SignalId;
            [data,~]=this.Session.readDataBySignalId(signalId,currentIndex,size(imageData));
        end


        function resetVideoDisplayAfterAutomation(this)

            algConfig=this.AlgorithmConfiguration;
            cachedInterval=this.CachedInterval;
            unfreezeROIDraw=~isempty(this.AlgorithmSetupHelper)...
            &&isempty(this.AlgorithmSetupHelper.ValidROILabelNames);
            currentIndex=cell(1,this.NumSignalsForAutomation);

            for i=1:this.NumSignalsForAutomation
                currentIndex{i}=getLastReadIdx(this.SignalLoadController,...
                this.SignalNamesForAutomation(i));
                updateDisplayIndex(this.DisplaysForAutomation{i},currentIndex{i});
            end

            if algConfig.StartAtCurrentTime
                if algConfig.AutomateForward


                    cachedStartTime=cachedInterval(1);
                    moveLeftInterval(this,cachedStartTime);
                else


                    cachedEndTime=cachedInterval(2);
                    moveRightInterval(this,cachedEndTime);
                end
            end

            this.unfreezeScrubberInterval();
            for i=1:this.NumSignalsForAutomation
                onAutomationModeExit(this.DisplaysForAutomation{i},currentIndex{1,i},unfreezeROIDraw);
            end


            cachedCurrentTime=cachedInterval(3);
            updateRangeSliderAtCurrentTime(this.RangeSliderObj,cachedCurrentTime);
            frame=readFrame(this.SignalLoadController,cachedCurrentTime);

            this.drawFrameWithInteractiveROIs(frame);
        end


        function restoreSignalAfterAutomation(this)
            resetVideoDisplayAfterAutomation(this);
        end







        function setupSucceeded=setupAlgorithm(this)

            wait(this.Container);

            cleanupObj=onCleanup(@()cleanPostSetupAlg(this));

            try
                algorithm=this.AlgorithmSetupHelper.AlgorithmInstance;


                selections=getSelectedLabelDefinitions(this);
                setSelectedLabelDefinitions(algorithm,selections);



                automationROIs=cell(1,this.NumSignalsForAutomation);
                for i=1:this.NumSignalsForAutomation
                    automationROIs_i=getROIsInTimeInterval(this.Session,this.DisplaysForAutomation{i}.Name);
                    automationROIs{i}=automationROIs_i;
                end

                if(this.NumSignalsForAutomation==1)
                    automationROIs_noID=rmfield(automationROIs{1},'ID');
                    importLabels(algorithm,automationROIs_noID);
                else
                    automationROIs_noID=cell(1,this.NumSignalsForAutomation);
                    for i=1:this.NumSignalsForAutomation
                        automationROIs_noID{i}=rmfield(automationROIs{i},'ID');
                    end
                    importLabels(algorithm,automationROIs_noID);
                end

                this.Session.CachedAutomationROIs=automationROIs;


                setupSucceeded=verifyAlgorithmSetup(algorithm);
            catch ME



                dlgTitle=vision.getMessage('vision:labeler:CantVerifyAlgorithmTitle');
                showExceptionDialog(this,ME,dlgTitle);

                setupSucceeded=false;
                return;
            end



            if~setupSucceeded

                hFig=this.Container.getDefaultFig;
                errorMessage=vision.getMessage('vision:labeler:IncompleteAlgorithmSetupMessage');
                dialogName=vision.getMessage('vision:labeler:IncompleteAlgorithmSetupTitle');
                vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,...
                this.Tool);

                return;
            end
        end




        function[frames,success]=initializeAlgorithm(this,algorithm)

            success=true;

            wait(this.Container);

            try
                if this.IsAutomationForward
                    startTime=getRangeSliderStartTime(this);
                else
                    if(this.NumSignalsForAutomation>1)
                        startTime=getRangeSliderEndTimeWithCheck(this.RangeSliderObj);
                    else
                        startTime=getRangeSliderEndTimeWithCheck(this.RangeSliderObj,this.SignalNamesForAutomation);
                    end
                end

                I=cell(this.NumSignalsForAutomation,1);
                frames=cell(this.NumSignalsForAutomation,1);
                for i=1:this.NumSignalsForAutomation
                    frame=readFrame(this.SignalLoadController,startTime,...
                    this.SignalNamesForAutomation(i));


                    if handleException(this)
                        return;
                    end
                    frames{i,1}=frame;

                    I{i,1}=frame{1}.Data;
                end

                if(this.NumSignalsForAutomation>1)
                    doInitialize(algorithm,I);
                else
                    doInitialize(algorithm,I{1,1});
                end

            catch ME
                success=false;

                dlgTitle=vision.getMessage('vision:labeler:CantInitializeAlgorithmTitle');
                showExceptionDialog(this,ME,dlgTitle);

                return;
            end

            resume(this.Container);
        end

        function setLayoutAtStartAutomation(this)

            if~isempty(this.NumSignalsForAutomation)
                if this.NumSignalsForAutomation<=3
                    rows=1;
                    cols=this.NumSignalsForAutomation;
                elseif this.NumSignalsForAutomation>3&&this.NumSignalsForAutomation<=6
                    rows=ceil(this.NumSignalsForAutomation/3);
                    cols=round(this.NumSignalsForAutomation/rows);
                elseif this.NumSignalsForAutomation>6
                    rows=3;
                    cols=3;
                end
                createXMLandGenerateLayout(this,rows,cols);
            end
        end


        function runAlgorithm(this)

            if~this.IsVideoLabeler&&this.Session.hasPointCloudSignal
                this.LidarTab.disableProjectedView();
                onProjectedViewClose(this);
            end




            finalize(this);

            closeExceptionDialogs(this);

            algorithm=this.AlgorithmSetupHelper.AlgorithmInstance;



            deselectROIInstances(this);
            freezePanelsWhileRunningAlgorithm(this);


            freezeSliderLine(this.RangeSliderObj);



            onDone=onCleanup(@this.cleanupPostAlgorithmRun);


            if handleException(this)

                return;
            end

            this.StopAlgRun=false;
            freezeScrubberInteraction(this);

            for i=1:this.NumSignalsForAutomation
                onAlgorithmRun(this.DisplayManager,this.SignalNamesForAutomation(i));
            end


            [frames,success]=initializeAlgorithm(this,algorithm);


            if~success
                return;
            end


            tStart=getRangeSliderStartTime(this);
            tEnd=getRangeSliderEndTimeWithCheck(this.RangeSliderObj);



            radioBtnSelectionInAutomation=this.RangeSliderObj.PrevSetupSelectionInAutomation;
            if(this.NumSignalsForAutomation>1&&radioBtnSelectionInAutomation(2))
                timeVector=this.SignalTimeVector;
                isValid=r4(timeVector)>=r4(tStart)&r4(timeVector)<=r4(tEnd);
                validTimeVector=timeVector(isValid)';

            elseif(this.NumSignalsForAutomation>1&&radioBtnSelectionInAutomation(1))
                signalIdx=find(this.RangeSliderObj.MasterSignal==this.SignalNamesForAutomation);
                validTimeVector=getValidTimeVector(this.Session,tStart,tEnd,...
                this.SignalNamesForAutomation(signalIdx));
            else


                validTimeVector=getValidTimeVector(this.Session,tStart,tEnd,...
                this.SignalNamesForAutomation);
            end
            isAutomationFwd=this.IsAutomationForward;

            if~isAutomationFwd
                validTimeVector=flip(validTimeVector);
            end

            this.IsStillRunning=true;
            enableSliderCallback(this,false);
            isTemporal=hasTemporalContext(algorithm);
            if isempty(validTimeVector)
                validTimeVector=getRangeSliderStartTime(this);
            end

            [~,~,endTimeofSignals]=getAutomationSelectedSignalStartEndTime(this);

            for idx=1:numel(validTimeVector)

                tNow=validTimeVector(idx);
                if this.StopAlgRun
                    break;
                end

                if isTemporal
                    updateCurrentTime(algorithm,tNow);
                end

                I=cell(this.NumSignalsForAutomation,1);
                imSize=cell(this.NumSignalsForAutomation,1);

                for i=1:this.NumSignalsForAutomation
                    if(~isempty(frames{i,1}))
                        I{i,1}=frames{i,1}{1,1}.Data;
                        imSize{i,1}=[size(I{i,1},1),size(I{i,1},2)];
                    else
                        I{i,1}=[];
                        imSize{i,1}=[0,0];
                    end
                end


                try
                    if(this.NumSignalsForAutomation>1)
                        [videoLabels,isValid]=doRun(algorithm,I);
                    else

                        [videoLabels,isValid]=doRun(algorithm,I{1,1});
                    end
                catch ME
                    dlgTitle=vision.getMessage('vision:labeler:CantRunAlgorithmTitle');
                    showExceptionDialog(this,ME,dlgTitle);
                    updateVisualSummary(this);
                    enableSliderCallback(this,true);
                    return;
                end


                for i=1:this.NumSignalsForAutomation
                    if(~isempty(frames{i,1}))
                        idxNow=frames{i,1}{1,1}.FrameIndex;
                        signalName=this.SignalNamesForAutomation(i);
                        frameTimeStamp=seconds(frames{i,1}{1,1}.FrameTimeStamp);
                    else
                        frameTimeStamp=0;
                    end


                    if(r4(tNow)==r4(frameTimeStamp)||isnan(frameTimeStamp))
                        if(imSize{i,1}(1)>0&&imSize{i,1}(2)>0&&isValid(i))
                            try

                                videoLabels_i=checkUserLabels(this,videoLabels{i,1},isValid(i),imSize{i,1});
                                videoLabels_i=restructPositionAndAddUID(this,videoLabels_i);
                            catch ME
                                dlgTitle=vision.getMessage('vision:labeler:CantRunAlgorithmTitle');
                                showExceptionDialog(this,ME,dlgTitle);
                                updateVisualSummary(this);
                                enableSliderCallback(this,true);
                                return;
                            end
                        else
                            videoLabels_i=[];
                        end
                        if(imSize{i,1}(1)>0&&imSize{i,1}(2)>0)
                            addAlgorithmLabels(this.Session,signalName{1,1},tNow,idxNow,videoLabels_i);
                        end

                        moveScrubberFamilyAtTime(this,tNow);

                        display=getDisplay(this.DisplayManager,signalName);
                        if(imSize{i,1}(1)>0&&imSize{i,1}(2)>0)
                            updateDisplayIndex(display,idxNow);
                        end




                        if(imSize{i,1}(1)>0&&imSize{i,1}(2)>0)
                            drawFrameWithStaticROIs(this,frames{i,1});
                        end
                    end
                end


                if(idx+1)>numel(validTimeVector)
                    break;
                end

                tRead=validTimeVector(idx+1);

                frames=cell(this.NumSignalsForAutomation,1);
                for i=1:this.NumSignalsForAutomation

                    if(r4(tNow)<=r4(endTimeofSignals{i}))
                        frames{i,1}=readFrame(this.SignalLoadController,tRead,...
                        this.SignalNamesForAutomation(i));
                    else
                        frames{i,1}=[];
                    end
                end

                if handleException(this)
                    return;
                end

                if this.StopRunning
                    break;
                end
            end




            tNow=getLastReadFrameTime(this.RangeSliderObj);
            for j=1:this.NumSignalsForAutomation
                if(r4(tNow)<=r4(endTimeofSignals{j}))
                    readFrame(this.SignalLoadController,tNow,...
                    this.SignalNamesForAutomation(j));
                end
            end
            if tNow<validTimeVector(end)
                if isAutomationFwd&&~this.StopAlgRun
                    moveScrubberFamilyToEnd(this.RangeSliderObj);
                end
            elseif tNow>validTimeVector(end)
                if~isAutomationFwd&&~this.StopAlgRun
                    moveScrubberFamilyToStart(this.RangeSliderObj);
                else
                    moveScrubberFamilyAtTime(this,tNow);
                end
            end
            replaceStaticROIs(this);


            unfreezePanelsAfterRunningAlgorithm(this);
            this.RangeSliderObj.disableLeftRightFlags();

            if handleException(this)
                return;
            end

            if this.StopRunning
                updateVisualSummary(this);
                enableSliderCallback(this,true);
                unfreezeSliderLine(this.RangeSliderObj);
                return;
            end




            if isAutomationFwd
                if tNow==validTimeVector(end)
                    moveScrubberFamilyToEnd(this.RangeSliderObj);
                end
            else
                if tNow==validTimeVector(1)
                    moveScrubberFamilyToStart(this.RangeSliderObj);
                end
            end

            updateVisualSummary(this);
            enableSliderCallback(this,true);

            unfreezeSliderLine(this.RangeSliderObj);




            try
                terminate(algorithm);
            catch ME
                dlgTitle=vision.getMessage('vision:labeler:CantTerminateAlgorithmTitle');
                showExceptionDialog(this,ME,dlgTitle);

                return;
            end
            if~this.IsVideoLabeler&&this.Session.hasPointCloudSignal

                this.LidarTab.enableProjectedView();
            end
        end



        function cleanupPostAlgorithmRun(this)


            this.IsStillRunning=false;
            this.StopAlgRun=true;


            for i=1:this.NumSignalsForAutomation
                onAlgorithmStop(this.DisplayManager,this.SignalNamesForAutomation(i));
            end
            unfreezeScrubberInteraction(this);
            unfreezePanelsAfterRunningAlgorithm(this);
            this.RangeSliderObj.disableLeftRightFlags();


            resume(this.Container);
        end


        function userCanceled=undorunAlgorithm(this)

            userCanceled=showUndoRunDialog(this);

            if~userCanceled

                closeExceptionDialogs(this);
                finalize(this);

                wait(this.Container);


                automationROIs=this.Session.CachedAutomationROIs;


                algorithm=this.AlgorithmSetupHelper.AlgorithmInstance;

                if this.AlgorithmConfiguration.StartAtCurrentTime


                    tStartOrEnd=this.CachedInterval(3);
                else


                    if this.IsAutomationForward
                        tStartOrEnd=this.CachedInterval(1);
                    else
                        tStartOrEnd=this.CachedInterval(2);
                    end
                end



                try
                    if hasTemporalContext(algorithm)
                        updateCurrentTime(algorithm,tStartOrEnd);
                    end

                catch ME
                    resume(this.Container);

                    dlgTitle=vision.getMessage('vision:labeler:CantUndoRunAlgorithmTitle');
                    showExceptionDialog(this,ME,dlgTitle);



                    userCanceled=true;

                    return;
                end


                for i=1:this.NumSignalsForAutomation

                    automationROIs_i=automationROIs{i};
                    [automationROIs_i.Label]=deal(automationROIs_i.Name);
                    automationROIs_i=rmfield(automationROIs_i,'Name');
                    automationROIs_i=rmfield(automationROIs_i,'Type');
                    replaceROIAnnotationsForUndo(this.Session,this.DisplaysForAutomation{i}.Name,automationROIs_i);
                end
                replaceFrameAnnotationsForUndoAllSignals(this.Session);

                if hasPixelLabels(this.Session)
                    replacePixelLabels(this.Session);
                end

                if this.IsAutomationForward
                    moveScrubberFamilyToStart(this);
                else
                    moveScrubberFamilyToEnd(this);
                end

                if(this.NumSignalsForAutomation>1)
                    enableRangeSliderSetting(this.RangeSliderObj);
                    updateSliderCurrentTime(this.RangeSliderObj);
                end


                readAndDrawFramesWithInteractiveROI(this,tStartOrEnd);


                handleException(this);

                updateVisualSummary(this);
                resume(this.Container);
            end
        end


        function userCanceled=showUndoRunDialog(this)


            s=settings;

            showUndoRun=getShowUndoRun(this,s);

            if~showUndoRun
                userCanceled=false;
                return;
            end

            userCanceled=vision.internal.labeler.tool.undoRunDialog(this.Tool,this.InstanceName);
        end


        function showUndoRun=getShowUndoRun(this,settings)
            if strcmp(this.InstanceName,'videoLabeler')
                showUndoRun=settings.vision.videoLabeler.ShowUndoRunDialog.ActiveValue;
            else
                showUndoRun=settings.driving.groundTruthLabeler.ShowUndoRunDialog.ActiveValue;
            end
        end


        function acceptAlgorithm(this)

            wait(this.Container);

            closeExceptionDialogs(this);

            finalize(this);


            mergeAnnotations(this.Session,this.SignalNamesForAutomation,this.IsAutomationForward);



            if isPixelLabelingAlgorithm(this.AlgorithmSetupHelper)
                for i=1:this.NumSignalsForAutomation
                    mergePixelLabels(this.Session,this.SignalNamesForAutomation(i));
                end
            end

            removeInstructionsPanel(this);


            endAutomation(this);

            updateVisualSummary(this);
            updateAttributesSublabelsPanelIfNeeded(this);

            if~this.IsVideoLabeler
                controlLidarTabVisibility(this);
                updateColormapSection(this);
            end
            if~useAppContainer
                loadLayoutFromSessionIfPossible(this);
            end
            resume(this.Container);
        end


        function cancelAlgorithm(this)

            wait(this.Container);


            cancelAlgorithm@vision.internal.labeler.tool.LabelerTool(this,this.SignalNamesForAutomation);

            if~useAppContainer
                loadLayoutFromSessionIfPossible(this);
            end

            resume(this.Container);
        end


        function endAutomation(this)
            if this.Session.hasPointCloudSignal&&~this.IsVideoLabeler
                onProjectedViewClose(this);
            end
            endAutomation@vision.internal.labeler.tool.LabelerTool(this);
            updateAttributesSublabelsPanel(this);

            if~isempty(this.AlgorithmConfiguration)
                resetVideoDisplayAfterAutomation(this);
            end

            if~this.IsVideoLabeler



                selectedSignalId=zeros(size(this.SignalNamesForAutomation));
                for j=1:this.NumSignalsForAutomation
                    selectedSignalId(j,:)=this.DisplayManager.getDisplayIdFromName(this.SignalNamesForAutomation(j));
                end

                signalList=this.LabelTab.getSignalList();
                if~useAppContainer()




                    loadLayoutFromSessionIfPossible(this);
                end


                toUpdateShowHideDropdown=false;
                for i=2:numel(this.DisplayManager.Displays)


                    if~ismember(i,selectedSignalId)&&signalList(i-1).isVisible
                        makeFigureVisible(this.DisplayManager.Displays{i});
                    end




                    if ismember(i,selectedSignalId)&&~signalList(i-1).isVisible
                        toUpdateShowHideDropdown=true;
                    end
                end
                if toUpdateShowHideDropdown
                    this.LabelTab.updateSignalsAfterAutomation();
                end

                selectedDisplay=getDisplay(this.DisplayManager,this.SelectedDisplayName);
                drawnow;
                grabFocus(selectedDisplay);

                if(this.NumSignalsForAutomation>1&&any(this.IsValidPtCloudType)&&...
                    ~any(isSelectedDisplayLidar(this.DisplayManager)))
                    controlLidarTabVisibility(this);
                    changeStackOrderOfLidarTab(this);
                end
                enableRangeSliderSettingButton(this);

                if(this.NumSignalsForAutomation>1)
                    signalNames=getSignalNames(this.Session);
                    timeVectors=getTimeVectors(this.Session,signalNames);
                    signalData=struct;
                    signalData.SignalName=signalNames;
                    signalData.TimeVectors=timeVectors;
                    resetSignalPopupOutsideAutomation(this.RangeSliderObj,signalData,...
                    this.MasterSignalBeforeAutomation,this.SignalTimeVector);
                end
                updateLeftIntervalToTime(this.RangeSliderObj,this.FlagStartTime);
                updateRightIntervalToTime(this.RangeSliderObj,this.FlagEndTime);
            end

            setSemanticTabForAutomation(this);



            doROIInstanceIsSelected(this);

        end


        function enableRangeSliderSettingButton(this)
            enableRangeSliderSetting(this.RangeSliderObj);
        end
    end

    methods(Access=protected)

        function updateTileLayoutForAutomation(this,showInstructionTab,isAttributeDisplayOn)
            numberOfSignalInAutomation=this.NumSignalsForAutomation;

            switch numberOfSignalInAutomation
            case{1,2,3}
                grids=[1,numberOfSignalInAutomation];
            case 4
                grids=[2,2];
            case{5,6}
                grids=[2,3];
            otherwise
                grids=[3,3];
            end
            updateTileLayout4AttribInstruct(this,showInstructionTab,...
            isAttributeDisplayOn,grids,this.isInAlgoMode);
        end

        function updateTileLayout4AttribInstruct(this,showInstructionTab,showAttributeTab,varargin)
            updateTileLayout4AttribInstruct@vision.internal.labeler.tool.Layout(this,showInstructionTab,showAttributeTab);

            selectedDisplay=getSelectedDisplay(this);
            if~isempty(selectedDisplay)&&selectedDisplay.IsCuboidSupported...
                &&selectedDisplay.ProjectedView&&showAttributeTab
                createProjectedViewLayout(this);
            end
        end
    end

    methods(Access=public,Hidden)

        function createLidarTutorialDialog(this)



            if hasPointCloudSignal(this.Session)&&hasRectangularLabels(this.Session)





                this.ShowLidarTutorial=false;

                s=settings;

                messageStrings={getString(message('vision:labeler:LidarTutorialStepOne')),...
                getString(message('vision:labeler:LidarTutorialStepTwo')),...
                getString(message('vision:labeler:LidarTutorialStepThree'))};

                titleString=getString(message('vision:labeler:LidarTutorialTitle'));

                basePath=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+images');
                imagePaths={fullfile(basePath,'LidarTutorial1.png'),...
                fullfile(basePath,'LidarTutorial2.png'),...
                fullfile(basePath,'LidarTutorial3.png')};
                flag=s.vision.labeler.OpenWithAppContainer.ActiveValue;
                getLidarTutorialDialog(this,imagePaths,messageStrings,titleString,s,flag);
            end

        end

        function getLidarTutorialDialog(this,imagePaths,messageStrings,titleString,settings,flag)
            images.internal.app.TutorialDialog(imagePaths,...
            messageStrings,titleString,...
            settings.driving.groundTruthLabeler.ShowLidarTutorialDialog,...
            flag);
        end
    end




    methods

        function configureVisualSummaryListeners(this)


            configureVisualSummaryListeners@vision.internal.labeler.tool.LabelerTool(this);

            this.ListenerHandles{end+1}=addlistener(this.RangeSliderObj,'StartOrEndTimeUpdated',@this.updateVisualSummaryXAxes);
            this.ListenerHandles{end+1}=addlistener(this.RangeSliderObj,'FrameChangeEvent',@this.updateVisualSummarySlider);
        end




        function updateOnSliderMove(this,~,data)



            finalize(this);

            updateLabelerCurrentTime(this.RangeSliderObj,seconds(data.Data),data.SliderButtonUpStatus);
        end


        function updateOnSliderRelease(this,~,~)
            redrawInteractiveROIs(this);
        end


        function updateFrameAndSlider(this,signalName,jumpIndex)
            timeVector=getTimeVectors(this.Session,signalName);
            timeVector=seconds(timeVector{1});
            jumpTime=timeVector(jumpIndex);
            updateLabelerCurrentTime(this.RangeSliderObj,jumpTime,1);
        end
    end

    methods(Hidden)



        function currentVal=getCurrentValueForSlider(this)

            currentVal=seconds(getRangeSliderCurrentTime(this));
        end


        function startIndex=getStartIndex(this,signalName)

            if nargin<2
                signalNames=getSignalNames(this.Session);
                signalName=signalNames(1);
            end

            tStart=getRangeSliderStartTime(this);
            startIndex=getFrameIndexFromTime(this.SignalLoadController,tStart,signalName);
        end


        function endIndex=getEndIndex(this,signalName)

            if nargin<2
                signalNames=getSignalNames(this.Session);
                signalName=signalNames(1);
            end

            tEnd=getRangeSliderEndTimeWithCheck(this.RangeSliderObj);
            tSignal=getTimeVectors(this.Session,signalName);
            tSignal=seconds(tSignal{1});

            if tSignal(end)<tEnd
                tEnd=tSignal(end);
            end

            endIndex=getFrameIndexFromTime(this.SignalLoadController,tEnd,signalName);
        end


        function[timeVectorInRange,validInRangeIndices]=getXAxisForSummary(this,signalName)






            timeVectorFull=getTimeVectors(this.Session,signalName);
            timeVectorFull=seconds(timeVectorFull{1});

            tStart=timeVectorFull(1);
            tEnd=timeVectorFull(end);
            validInRangeIndices=this.getIndices(tStart,tEnd,signalName);

            timeVectorInRange=timeVectorFull(validInRangeIndices);

            timeVectorInRange(1)=getRangeSliderStartTime(this);
            timeVectorInRange(end)=getRangeSliderEndTime(this);




            if isscalar(timeVectorInRange)
                if getRangeSliderStartTime(this)==getRangeSliderEndTime(this)
                    timeVectorInRange=[timeVectorInRange,timeVectorInRange+1e-8];
                else

                    timeVectorInRange=[timeVectorInRange-1e-8,timeVectorInRange];
                end
            end

            timeVectorInRange=seconds(timeVectorInRange);
        end


        function timeIndices=getIndices(this,tStart,tEnd,signalName)


            interval=[getRangeSliderStartTime(this),getRangeSliderEndTimeWithCheck(this.RangeSliderObj)];







            interval(1)=max(interval(1),tStart);
            interval(2)=min(interval(2),tEnd);

            intervalIndices=zeros(1,2);
            intervalIndices(1)=getFrameIndexFromTime(this.SignalLoadController,interval(1),signalName);
            intervalIndices(2)=getFrameIndexFromTime(this.SignalLoadController,interval(2),signalName);
            timeIndices=intervalIndices(1):intervalIndices(2);
        end


        function annotationInfo=getAnnotationInfoForSummary(this,signalName,signalType)

            [timeVector,timeIndices]=getXAxisForSummary(this,signalName);


            roiLabelDefs.Names={this.Session.ROILabelSet.DefinitionStruct.Name};
            roiLabelDefs.Colors={this.Session.ROILabelSet.DefinitionStruct.Color};
            roiLabelDefs.Type={this.Session.ROILabelSet.DefinitionStruct.Type};
            roiLabelDefs=getSupportedLabelDefs(this,roiLabelDefs,signalType);

            sceneLabelDefs.Names={this.Session.FrameLabelSet.DefinitionStruct.Name};
            sceneLabelDefs.Colors={this.Session.FrameLabelSet.DefinitionStruct.Color};




            numROIAnnotations=queryROISummary(this.Session,signalName,roiLabelDefs.Names,timeIndices);

            numSceneAnnotations=querySceneSummary(this.Session,signalName,sceneLabelDefs.Names,timeIndices);





            if isscalar(timeIndices)
                if~isempty(roiLabelDefs.Names)
                    for idx=1:numel(roiLabelDefs.Names)
                        numROIAnnotations.(roiLabelDefs.Names{idx})(end+1)=numROIAnnotations.(roiLabelDefs.Names{idx})(end);
                    end
                end
                if~isempty(sceneLabelDefs.Names)
                    for idx=1:numel(sceneLabelDefs.Names)
                        numSceneAnnotations.(sceneLabelDefs.Names{1})(end+1)=numSceneAnnotations.(sceneLabelDefs.Names{1})(end);
                    end
                end
            end


            annotationInfo.ROILabelDefs=roiLabelDefs;
            annotationInfo.SceneLabelDefs=sceneLabelDefs;
            annotationInfo.TimeVector=timeVector;
            annotationInfo.NumROIAnnotations=numROIAnnotations;
            annotationInfo.NumSceneAnnotations=numSceneAnnotations;
        end


        function updateDone=sliderUpdateDone(this)
            updateDone=this.RangeSliderObj.CurrentTimeUpdateDone;
        end


        function supportedROILabelDefs=getSupportedLabelDefs(this,roiLabelDefs,signalType)
            if signalType==vision.labeler.loading.SignalType.PointCloud
                validIdx=([roiLabelDefs.Type{:}]==labelType.Rectangle)...
                |([roiLabelDefs.Type{:}]==labelType.Line);
                supportedROILabelDefs.Names=roiLabelDefs.Names(validIdx);
                supportedROILabelDefs.Colors=roiLabelDefs.Colors(validIdx);
                supportedROILabelDefs.Type=roiLabelDefs.Type(validIdx);
            else
                supportedROILabelDefs=roiLabelDefs;
            end
        end
    end

    methods(Access=protected)
        function visualSummaryDocked=checkVSDockedFromLayout(this,layout)
            if~isempty(layout)
                serializedLayout=serializeLayout(this,layout);
                visualSummaryDocked=contains(string(serializedLayout),this.NameVisualSummaryDisplay);
            else
                visualSummaryDocked=false;
                saveLayoutToSession(this);
            end
        end
    end




    methods(Access=protected)


        function setLoadingText(this,flag,isVideo)
            selectedDisplay=getSelectedDisplay(this);
            if~isempty(selectedDisplay)
                selectedDisplay.setLoadingText(flag,isVideo);
            end
        end






        function getDisplayIndex(this,flag)
            selectedDisplay=getSelectedDisplay(this);
            if~isempty(selectedDisplay)
                selectedDisplay.getDisplayIndex(flag);
            end
        end


        function reconfigureVideoDisplay(this)


            if this.Session.HasROILabels
                selectedItemInfo.roiItemDataObj=queryROILabelData(this.Session,1);
                setModeROIorNone(this,selectedItemInfo);
            end


            tCur=getRangeSliderCurrentTime(this);

            frameArray=readFrame(this.SignalLoadController,tCur);

            if handleException(this)
                return;
            end

            drawFrameWithInteractiveROIs(this,frameArray);


            currentDisplay=this.getSelectedDisplay();
            idx=currentDisplay.getCurrentDisplayIndex();
            currentROIs=currentDisplay.getCurrentROIs();
            currentDisplay.updateUndoOnLabelChange(idx,currentROIs);
        end


        function success=checkValidIntervals(~,~,~)

        end


        function dispType=signalType2DisplayType(this,sigType)


            switch(sigType)
            case vision.labeler.loading.SignalType.Image
                dispType=displayType.Image;
            case vision.labeler.loading.SignalType.PointCloud
                dispType=displayType.PointCloud;



            otherwise
                dispType=displayType.None;
            end

        end


        function TF=isSignalHidden(this)

            if(this.IsVideoLabeler)


                TF=false;
                return;
            end

            signalList=this.LabelTab.getSignalList();
            TF=any(~[signalList(:).isVisible]);
        end
    end

    methods

        function status=getProjectedViewDisplayStatus(this)
            if~isempty(this.ProjectedViewDisplay)
                if isvalid(this.ProjectedViewDisplay)
                    status=true;
                else
                    status=false;
                end
            else

                status=false;
            end
        end

        function updateProjectedViewStatus(this)
            selectedDisplay=getSelectedDisplay(this);
            if~isempty(selectedDisplay)&&selectedDisplay.IsCuboidSupported
                if isProjectedViewSupported(selectedDisplay)
                    this.LidarTab.enableProjectedView();
                else
                    this.LidarTab.disableProjectedView();
                    if~this.Session.HasROILabels
                        onProjectedViewClose(this);
                    end
                    if selectedDisplay.ProjectedView&&~isempty(this.ProjectedViewDisplay)
                        if~isvalid(this.ProjectedViewDisplay)
                            disableProjectedView(selectedDisplay);
                        end
                    end
                end
            end
        end
    end

end

function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('useAppContainer');
end



function r=r4(v)
    r=round(v,04);
end
