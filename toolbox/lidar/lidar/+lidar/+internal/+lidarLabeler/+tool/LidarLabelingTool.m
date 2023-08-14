








classdef LidarLabelingTool<lidar.internal.lidarLabeler.tool.TemporalLabelingTool

    properties(Hidden)

        FrameChangeFromSyncImageViewer=false;



SyncImageViewerHandle

        IsSyncImageViewerConfigured=false;
    end

    properties(Access=private)




        CaughtSyncImageViewerException=false;



SyncImageViewerSignalName



FrameChangeListener
    end

    properties



SyncImageViewerInstance
    end

    properties(Access=public)
        pixelLabelSupported=false;
    end




    methods(Access=public)

        function this=LidarLabelingTool(varargin)

            import lidar.internal.lidarLabeler.tool.*;
            import vision.internal.videoLabeler.tool.*;
            import vision.internal.labeler.tool.*;

            [title,instanceName]=getAppInfo(varargin{:});


            this=this@lidar.internal.lidarLabeler.tool.TemporalLabelingTool(title,instanceName);

            setSupportedLabelTypes(this);
            createTabsSetActive(this);





            createSession(this);

            this.SignalLoadController=createSignalLoadController(this);


            this.AlgorithmSetupHelper=lidar.internal.labeler.tool.LidarAlgorithmSetupHelper(this.InstanceName);





            addlistener(this.AlgorithmSetupHelper,'CaughtExceptionEvent',@(src,evt)this.showExceptionDialog(evt.ME,evt.DlgTitle));


            this.AreSignalsLoaded=false;


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

















            this.addToolInstance();


            if~isdeployed()
                this.setPublishSnapBehavior();
            end

        end

        function setupDocContainedObjs(this)

            import lidar.internal.lidarLabeler.tool.*;
            import vision.internal.videoLabeler.tool.*;
            import vision.internal.labeler.tool.*;
            import lidar.internal.labeler.tool.display.*;



            thisFig=this.Container.NoneSignalFigure;
            this.DisplayManager=lidar.internal.labeler.tool.display.DisplayManager(thisFig,this.ToolType,this.NameNoneDisplay);




            thisFig=this.Container.ROILabelFigure;
            this.ROILabelSetDisplay=lidar.internal.labeler.tool.ROILabelSetDisplay(thisFig,this.InstanceName);

            thisFig=this.Container.SignalNavFigure;
            this.SignalNavigationDisplay=RangeSliderDisplay(thisFig);

            thisFig=this.Container.FrameLabelFigure;
            this.FrameLabelSetDisplay=FrameLabelSetDisplay(thisFig,this.InstanceName);

            thisFig=this.Container.InstructionFigure;
            this.InstructionsSetDisplay=InstructionsSetDisplay(thisFig);

            thisFig=this.Container.AttribSublabelFigure;
            this.AttributesSublabelsDisplay=lidar.internal.labeler.tool.AttributesSublabelsDisplay(thisFig);


            this.updateFigureCloseListener();

        end

        function refreshSignalViewList(~)

        end


        function TF=isVideoLabeler(this)


            TF=this.IsVideoLabeler;
        end
    end

    methods(Hidden)


        function createLidarTutorialDialog(this)



            if hasPointCloudSignal(this.Session)&&hasRectangularLabels(this.Session)





                this.ShowLidarTutorial=false;

                s=settings;

                messageStrings={getString(message('vision:labeler:LidarTutorialStepOne')),...
                getString(message('vision:labeler:LidarTutorialStepTwo')),...
                getString(message('vision:labeler:LidarTutorialStepThree'))};

                titleString=getString(message('vision:labeler:LidarTutorialTitle'));

                imagePaths={fullfile(matlabroot,'toolbox','vision','vision','+vision','+internal','+labeler','+tool','+images','LidarTutorial1.png'),...
                fullfile(matlabroot,'toolbox','vision','vision','+vision','+internal','+labeler','+tool','+images','LidarTutorial2.png'),...
                fullfile(matlabroot,'toolbox','vision','vision','+vision','+internal','+labeler','+tool','+images','LidarTutorial3.png')};

                images.internal.app.TutorialDialog(imagePaths,...
                messageStrings,titleString,...
                s.lidar.lidarLabeler.ShowLidarTutorialDialog,...
                s.vision.labeler.OpenWithAppContainer.ActiveValue);

            end

        end
    end

    methods(Access=private)

        function createTabsSetActive(this)

            this.LabelTab=lidar.internal.lidarLabeler.tool.LabelTab(this);
            this.AlgorithmTab=lidar.internal.lidarLabeler.tool.AlgorithmTab(this);
            this.SemanticTab=vision.internal.labeler.tool.SemanticTab(this);
            this.LidarTab=lidar.internal.lidarLabeler.tool.LidarTab(this);


            this.ActiveTab=this.LabelTab;
        end


        function setSupportedLabelTypes(this)




            this.SupportedROILabelTypes={labelType.Rectangle,labelType.Line...
            ,lidarLabelType.Voxel,labelType.Cuboid};
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
                this.Session.SyncImageViewerHandle=this.SyncImageViewerHandle;
            end

            if hasPointCloudSignal(this.Session)
                this.ViewClustersPreviousState=this.getClusterVisualizationState();
                this.Session.setClusterViewStatus(this.ViewClustersPreviousState);
            end

            saveLayoutToSession(this);

            saveProjectedViewStatus(this);


            saveCameraViewToSession(this)

            if nargin==2
                success=saveSession@lidar.internal.labeler.tool.LabelerTool(this,fileName);
            else
                success=saveSession@lidar.internal.labeler.tool.LabelerTool(this);
            end
        end


        function doLoadSession(this,pathName,fileName,varargin)

            close(this.ProjectedViewDisplay);

            wait(this.Container);

            hFig=getDefaultFig(this.Container);
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

            handleSyncImageViewerForNewSession(this);
            addSessionCustomDisplay(this,...
            loadedSession.SyncImageViewerHandle,varargin{:});

            progressDlgTitle=vision.getMessage('vision:labeler:LoadProgressTitle');
            pleaseWaitMsg=vision.getMessage('vision:labeler:PleaseWait');
            hFig=getDefaultFig(this.Container);
            waitBarObj=vision.internal.labeler.tool.ProgressDialog(hFig,...
            progressDlgTitle,pleaseWaitMsg);


            signalModel=getSignalModel(loadedSession);
            signalLoadController=createSignalLoadController(this,signalModel);
            handleSourceLoadFailures(signalLoadController,...
            getAlternateFilePath(loadedSession),isVideoLabeler(this));
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
                hFig=this.Container.getDefaultFig;
                vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,this.Tool);
                return;
            end

            loadingSessionMsg=vision.getMessage('vision:labeler:LoadingSession');
            waitBarObj.setParams(0.8,loadingSessionMsg);






            deleteAllItemsLabelSetDisplay(this);

            if signalModel.getNumberOfSignals()==0
                resetNavigationControls(this);
                removeSignalNav(this);
                createDefaultLayoutForNewSession(this);
            end

            this.Session=loadedSession;
            if strcmp(class(loadedSession.ROILabelSet),'vision.internal.labeler.ROILabelSet')
                this.Session.modifyROILabelSet(loadedSession);
            end



            this.LabelVisibleInternal=loadedSession.ShowROILabelMode;
            this.LabelTab.changeLabelDisplayOption(loadedSession.ShowROILabelMode);

            this.SignalLoadController=createSignalLoadController(this);

            updatingSessionMsg=vision.getMessage('vision:labeler:UpdatingSession');
            waitBarObj.setParams(0.67,updatingSessionMsg);

            close(waitBarObj);


            if hasVoxelLabel(this.Session)
                setTempDirectory(this);
            end

            TF=true;

            if hasVoxelLabel(this.Session)
                TF=importVoxelLabelData(this.Session);
            end



            if~TF
                oldDirectory=this.Session.TempDirectory;
                [~,name]=fileparts(tempname);
                foldername=vision.internal.labeler.tool.selectDirectoryDialog(name);
                setTempDirectory(this.Session,foldername);
                importVoxelLabelData(this.Session);
                if isfolder(oldDirectory)
                    rmdir(oldDirectory,'s');
                end
            end

            if hasVoxelLabel(this.Session)

                this.updateVoxelColorLookup();
            end

            updateSignalModel(this.Session,[]);
            this.Session.IsChanged=false;

            if hasVoxelLabel(this.Session)

                this.updateVoxelColorLookup();
            end


            applyRangeSliderInfoFromSession(this);


            reconfigureROILabelSetDisplay(this);
            reconfigureFrameLabelSetDisplay(this);

            [~,fileName]=fileparts(fileName);

            titleStr=getString(message(...
            'vision:labeler:ToolTitleWithSession',this.ToolName,fileName));
            setTitleBar(this.Container,titleStr);

            layout=getLabelModeLayout(this.Session,this.Tool);
            visualSummaryDocked=checkVSDockedFromLayout(this,layout);
            doReopenVisualSummary(this,reopenVisualSummary,visualSummaryDocked);
            drawnow;
            if~useAppContainer()
                loadLayoutFromSessionIfPossible(this);
            end







            resume(this.Container);


            if this.Session.hasPointCloudSignal
                this.loadProjectedViewFromSession(this.Session.ProjectedViewStatus);
            end


            this.loadCameraViewFromSession(this.Session.SavedCameraViewParameters);

            resetROIViewOnNewSession(this.LidarTab);
        end


        function cleanSession(this)
            cleanSession@lidar.internal.lidarLabeler.tool.TemporalLabelingTool(this);
            handleSyncImageViewerForNewSession(this);
            resetROIViewOnNewSession(this.LidarTab);
            resetGroundSettingsOnNewSession(this.LidarTab);
        end
    end




    methods(Hidden=true,Access=public)


        function addSignals(this)

            load=true;
            if this.AreSignalsLoaded
                doLoad=warnBeforeLoading(this);
                if doLoad
                    load=true;
                else
                    load=false;
                end

            end

            if load
                this.deleteComponenDestroyListener();
                addSignals@lidar.internal.lidarLabeler.tool.TemporalLabelingTool(this);

                this.updateFigureCloseListener();
            end

        end

        function handleSyncImageViewerForNewSession(this)

            if hasCustomDisplay(this)
                closeSyncImageViewerTarget(this);

                msg=vision.getMessage('lidar:labeler:SyncImageViewerNewSessionWarning');
                dlgTitle=vision.getMessage('lidar:labeler:SyncImageViewerWarnDlg');
                figHandle=this.Container.getDefaultFig;
                vision.internal.labeler.handleAlert(figHandle,'warndlg',msg,dlgTitle);
            end
        end



        function updateSignalLoadingStatus(this,~,varargin)
            getDisplayIndex(this,true);
        end
    end

    methods

        function attachListenerForRangeSlider(this)
            if~isempty(this.SyncImageViewerInstance)
                addlistener(this.SyncImageViewerInstance,'CaughtExceptionEvent',...
                @this.syncImageViewerExceptionListener);
            end
        end
    end

    methods(Access=protected)


        function signalController=createSignalLoadController(this,signalModel)

            if nargin<2
                signalController=createSignalLoadController@lidar.internal.lidarLabeler.tool.TemporalLabelingTool(this);
            else
                signalController=createSignalLoadController@lidar.internal.lidarLabeler.tool.TemporalLabelingTool(this,signalModel);
            end
        end


        function signalView=getSignalView(~)

            import lidar.internal.lidarLabeler.tool.signalLoading.view.*

            signalView=LidarLoadView();
        end


        function createSession(this)

            this.SessionManager=lidar.internal.lidarLabeler.tool.LidarLabelerSessionManager;


            this.Session=lidar.internal.lidarLabeler.tool.Session;

        end



        function addDisplays(this,src,evtData)

            addDisplays@lidar.internal.lidarLabeler.tool.TemporalLabelingTool(this,src,evtData);

            if numel(this.DisplayManager.Displays)>1
                lidarDisplay=this.DisplayManager.Displays{2};
                addlistener(lidarDisplay,...
                'VoxelROIsChanged',@this.doVoxelLabelIsChanged);
            end




            this.refreshSaveCamera();

            configureSyncImageViewerClass(this);
            updateFigureCloseListener(this);

            resetROIViewOnNewSession(this.LidarTab);
        end

    end




    methods(Access=protected)


        function rangeSliderObj=getRangeSlider(this,signalData)
            rangeSliderObj=vision.internal.labeler.tool.RangeSlider(...
            this.SignalNavigationDisplay.getLabeledVideoContainer(),...
            signalData,true);
        end


        function freezeRangeSlider(this,~,~)
            disableRangeSlider(this.RangeSliderObj);
            disableStartCurrentEndEditBoxes(this.RangeSliderObj);
        end


        function unfreezeRangeSlider(this,~,~)
            if isInAlgoMode(this)
                unfreezeScrubberInteraction(this);
            else
                enableRangeSlider(this.RangeSliderObj);
                enableStartCurrentEndEditBoxes(this.RangeSliderObj);
            end
        end
    end

    methods

        function wireUpLidarListeners(this,pcDisplay)

            pcListeners=wireUpLidarListeners@lidar.internal.lidarLabeler.tool.TemporalLabelingTool(this,pcDisplay);
            pcListeners{end+1}=addlistener(this.LidarTab,'UsePCFitCuboid',@(src,evt)set(pcDisplay,'UsePCFit',evt.ShrinkCuboid));
            pcListeners{end+1}=event.listener(this.LidarTab,'SaveCameraViewEvent',@(src,evt)cameraViewCallback(pcDisplay,evt.Index,evt.Operation));
            pcListeners{end+1}=event.listener(this.LidarTab,'LimitsDataChanged',@(src,evt)setLimitsData(this,pcDisplay,evt));
            pcListeners{end+1}=event.listener(this.LidarTab,'ChangedView',@(src,~)setFullView(pcDisplay));
            addListenersToDisplayObject(pcDisplay,pcListeners);


            refresh(this.LidarTab)

        end
    end




    methods

        function importLabelAnnotations(this,source)

            this.setStatusText(vision.getMessage('vision:labeler:ImportLabelAnnotationsStatus'));

            setWaitingToFalseAtExit=onCleanup(@()resume(this.Container));

            if isa(source,'groundTruthLidar')

                gTruth=source;
            else

                proceed=this.issueImportWarning(vision.getMessage('vision:labeler:GroundTruth'));

                if~proceed
                    this.setStatusText('');
                    return;
                end

                [success,gTruth,~,~,~]=importLabelAnnotationsPreWork(this,source);

                if~success||isempty(gTruth)
                    this.setStatusText('');
                    return;
                end
            end

            wait(this.Container);

            [gTruthReg,gTruthCustom]=splitGroundTruth(this,gTruth);

            hasCustomDisp=hasCustomDisplay(this);
            if~hasCustomDisp&&(~isempty(gTruthCustom))

            end






            currentDefinitions=exportLabelDefinitions(this.Session);

            canImportLabels=importVoxelLabelHelper(this,gTruth,currentDefinitions);

            if~canImportLabels
                return
            end


            saveLayoutToSession(this);
            prevLayout=getLabelModeLayout(this.Session,this.Tool);



            reopenVisualSummary=getReopenVisualSummaryFlag(this);

            if~isVideoLabeler(this)
                isCanceled=newSession(this);

                if isCanceled
                    return;
                end

                if hasCustomDisp
                    addCustomDisplay(this,this.SyncImageViewerHandle);
                    this.IsSyncImageViewerConfigured=false;
                end

                loadSource(this,gTruthReg.DataSource);
            end


            if~isempty(gTruthReg)
                this.Session.loadLabelAnnotations(gTruthReg);
                if hasVoxelLabel(this.Session)

                    this.updateVoxelColorLookup();
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

                if~useAppContainer
                    loadLayoutFromSessionIfPossible(this);
                end

            end

            this.setStatusText('');

            close(this.ProjectedViewDisplay);
            restoreDefaultLayout(this,false);
            updateProjectedViewStatus(this);
        end
    end





    methods
        function setLimitsData(this,pcDisplay,evt)
            wait(this.Container);
            setLimitsData(pcDisplay,evt.LimitsData,evt.XMinLimits,evt.XMaxLimits,evt.YMinLimits,...
            evt.YMaxLimits,evt.ZMinLimits,evt.ZMaxLimits,...
            evt.PointDimension);
            resume(this.Container);
        end

    end




    methods(Access=protected)

        function updateToolstrip(this)

            anyROIOrFrameLabels=this.Session.HasROILabels||this.Session.HasFrameLabels;

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



                this.LabelTab.enableAlgorithmSection(anyROIOrFrameLabels);
                this.LabelTab.enableExportSection(anyROIOrFrameLabels);

                updateVisualSummaryButton(this);

                if anyROIOrFrameLabels
                    doROIInstanceIsSelected(this);
                end

            else

                visible=false;
                changeToolbarVisibility(this,visible);

                disableControls(this.LabelTab);
                disableControls(this.SemanticTab);
            end

            controlLidarTabVisibility(this);


            if anyROIOrFrameLabels
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


            if~hasVoxelLabel(this.Session)
                hideContextualSemanticTab(this);
            end
            updateProjectedViewStatus(this);

            if this.ShowLidarTutorial
                createLidarTutorialDialog(this);
            end
        end


        function updateTileLayout4AttribInstruct(this,showInstructionTab,showAttributeTab)
            updateTileLayout4AttribInstruct@vision.internal.labeler.tool.Layout(this,showInstructionTab,showAttributeTab);

            selectedDisplay=getSelectedDisplay(this);
            if~isempty(selectedDisplay)&&selectedDisplay.IsCuboidSupported...
                &&selectedDisplay.ProjectedView&&showAttributeTab
                createProjectedViewLayout(this);
            end
        end

    end




    methods(Access=protected)


        function dlg=getROILabelDefinitionDialog(this,labelAddMode,roiLabel,sublabelNames)
            if nargin>2
                dlg=lidar.internal.labeler.tool.ROILabelDefinitionDialog(...
                this.Tool,...
                this.Session.ROILabelSet,...
                this.Session.FrameLabelSet,...
                this.SupportedROILabelTypes,labelAddMode,...
                roiLabel,sublabelNames);
            else
                dlg=lidar.internal.labeler.tool.ROILabelDefinitionDialog(...
                this.Tool,...
                this.Session.ROILabelSet,...
                this.Session.FrameLabelSet,...
                this.SupportedROILabelTypes,...
                labelAddMode);
            end
        end


        function enableSublabelDefCreateButton(this)


        end


        function doROIPanelItemROIVisibilityCallback(this,~,data)

            selectedItemInfo=getSelectedItemInfo(this);
            selectedLabelData=data.Data;

            if~isequal(selectedLabelData.ROI,lidarLabelType.Voxel)
                this.DisplayManager.changeVisibilitySelectedROI(selectedLabelData,selectedItemInfo);

                this.DisplayManager.roiVisibilityChangeInClipboard(selectedLabelData);
            else
                this.DisplayManager.changeVisibilitySelectedVoxelROI(selectedLabelData,selectedItemInfo);
            end

            if isa(selectedLabelData,'lidar.internal.labeler.ROILabel')
                this.Session.modifyLabelROIVisibility(selectedLabelData);
            else
                this.Session.modifySubLabelROIVisibility(selectedLabelData);
            end

            if~isequal(selectedLabelData.ROI,lidarLabelType.Voxel)
                this.DisplayManager.updateLabelVisibilityInUndoRedoBuffer(selectedLabelData);
            end
            this.Session.IsChanged=true;
        end

    end




    methods

        function exportLabelAnnotationsToWS(this)

            wait(this.Container);

            resetWait=onCleanup(@()resume(this.Container));

            finalize(this);

            variableName='gTruth';
            if hasVoxelLabel(this.Session)
                dlgTitle=vision.getMessage('vision:uitools:ExportTitle');
                toFile=false;
                exportDlg=lidar.internal.labeler.tool.ExportVoxelLabelDlg(...
                this.Tool,variableName,dlgTitle,this.Session.getVoxelLabelDataPath,toFile);
                wait(exportDlg);
                if~exportDlg.IsCanceled
                    this.Session.setVoxelLabelDataPath(exportDlg.VarPath);
                    TF=exportVoxelLabelData(this.Session,exportDlg.CreatedDirectory);
                    if~TF
                        hFig=this.Container.getDefaultFig;
                        errorMessage=getString(message('vision:labeler:UnableToExportDlgMessage'));
                        dialogName=getString(message('vision:labeler:UnableToExportDlgName'));
                        vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,...
                        this.Tool);
                        return;
                    end
                end
            else
                exportDlg=vision.internal.labeler.tool.ExportDlg(this.Tool,variableName);
                wait(exportDlg);
            end

            if~exportDlg.IsCanceled
                varName=exportDlg.VarName;
                this.setStatusText(vision.getMessage('vision:labeler:ExportToWsStatus',varName));
                labels=exportLabelAnnotations(this.Session);

                saveVariableToWs(this,varName,labels);

                this.setStatusText('');
            end
            drawnow;
        end


        function exportLabelDefinitions(this)

            labelDefs=exportLabelDefinitions(this.Session);

            exportLabelDefinitions@vision.internal.labeler.tool.LabelerTool(this,labelDefs);
        end
    end




    methods

        function[gTruthReg,gTruthCustom]=splitGroundTruth(~,gTruth)
            gTruthReg=gTruth;
            gTruthCustom=[];
        end


        function doLoadLabelDefinitionsFromFile(this,fileName)

            wait(this.Container);

            try

                temp=load(fileName,'-mat');



                fields=fieldnames(temp);
                definitions=temp.(fields{1});

                definitions=lidar.internal.lidarLabeler.validation.checkLabelDefinitions(definitions);

                definitions=convertDefinitions(this.Session,definitions);

                labelDefTable=definitions;


                deleteAllItemsLabelSetDisplay(this);


                this.Session.loadLabelDefinitions(labelDefTable);
            catch
                handleLoadDefinitionError(this,fileName,this.ToolName);
                return;
            end

            reconfigureUI(this);

            resume(this.Container);
        end
    end


    methods(Hidden)
        function fcnName=getGtruthFcnName(~)

            fcnName={'groundTruthLidar'};
        end



        function drawVoxelLabels(this,locations)
            drawVoxelLabels(this.DisplayManager,locations);
        end


        function removeVoxelLabels(this,locations)
            removeVoxelLabels(this.DisplayManager,locations);
        end
    end




    methods

        function showUndoRun=getShowUndoRun(~,settings)
            showUndoRun=settings.lidar.lidarLabeler.ShowUndoRunDialog.ActiveValue;
        end


        function endAutomation(this)


            endAutomation@lidar.internal.labeler.tool.LabelerTool(this);

            updateAttributesSublabelsPanel(this);


            if~isempty(this.AlgorithmConfiguration)
                resetVideoDisplayAfterAutomation(this);
            end

            setSemanticTabForAutomation(this);



            doROIInstanceIsSelected(this);

            close(this.ProjectedViewDisplay);

        end
    end




    methods(Access=private)
        function refreshSaveCamera(this)


            this.LidarTab.resetSavedCameraOnNewSession()
        end


        function saveCameraViewToSession(this)


            if this.DisplayManager.NumDisplays==1
                return;
            end


            lidarDisplay=this.DisplayManager.Displays{2};

            savedCameraViewParameters=...
            lidarDisplay.getSavedCameraParameters();
            savedCameraViewNames=...
            this.LidarTab.getSavedCameraViewNames;

            saveCameraViewToSession(this.Session,savedCameraViewParameters,savedCameraViewNames);
        end


        function loadCameraViewFromSession(this,savedCameraViewParameters)


            if this.DisplayManager.NumDisplays==1
                return;
            end


            lidarDisplay=this.DisplayManager.Displays{2};


            lidarDisplay.loadCameraViewFromSession(savedCameraViewParameters);


            this.LidarTab.appendSaveCameraViewName(savedCameraViewParameters);
        end
    end




    methods
        function addCustomDisplay(this,classHandle)

            this.SyncImageViewerHandle=classHandle;
            instantiateSyncImageViewerClass(this);
            attachListenerForRangeSlider(this);
        end


        function addSessionCustomDisplay(this,classHandleSession,varargin)





            hasCustomDisplayPVPair=false;
            if~isempty(varargin)
                hasCustomDisplayPVPair=varargin{1};
            end
            if hasCustomDisplayPVPair
                syncImageViewerHandle=varargin{2};
                addCustomDisplay(this,syncImageViewerHandle);
                this.IsSyncImageViewerConfigured=false;
            else
                if~isempty(classHandleSession)
                    addCustomDisplay(this,classHandleSession);
                    this.IsSyncImageViewerConfigured=false;
                end
            end
        end


        function syncImageViewerExceptionListener(this,varargin)
            this.CaughtSyncImageViewerException=true;
            this.RangeSliderObj.exceptionDuringPlayListener(varargin{:});
            if~isempty(this.VisualSummaryDisplay)
                this.VisualSummaryDisplay.exceptionDuringPlayListener(varargin{:});
            end
        end
    end

    methods(Hidden)


        function flag=hasCustomDisplay(this)
            flag=~isempty(this.SyncImageViewerInstance);
        end
    end

    methods(Access=protected)

        function closeAllFigures(this)
            this.IsAppClosing=true;


            if hasCustomDisplay(this)
                closeSyncImageViewerTarget(this);
            end


            closeAllFigures@vision.internal.labeler.tool.LabelerTool(this);


            closeExceptionDialogs(this);
        end



        function modifyLabelSelection(this,oldProperty,newProperty)
            selectedItemInfo=getSelectedItemInfo(this);

            isAnyItemSelected=selectedItemInfo.isAnyItemSelected;
            roiItemDataObj=selectedItemInfo.roiItemDataObj;
            if isAnyItemSelected
                assert(isa(roiItemDataObj,'lidar.internal.labeler.ROILabel'))
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


        function modifyItemMenuLabel(this,roi)

            isLabel=isa(roi,'lidar.internal.labeler.ROILabel');
            if isLabel
                labelName=roi.Label;
                sublabelName='';
            end

            itemID=this.ROILabelSetDisplay.getItemID(labelName,sublabelName);
            this.ROILabelSetDisplay.modifyItemMenuLabel(itemID,isLabel);
        end

    end


    methods(Access=public,Hidden)


        function closeSyncImageViewerTarget(this)

            try
                if~this.SyncImageViewerInstance.IsDisconnected
                    close(this.SyncImageViewerInstance);
                    this.SyncImageViewerInstance=[];
                end
            catch ME





                functionName='close()';
                errorReport=vision.internal.getTrimmedReport(ME,{});
                warnMsg=getString(message('lidar:labeler:EncapsulatedSyncImageViewerWarning',functionName,errorReport));



                backtraceState=warning('query','backtrace');
                restoreBacktraceSTate=onCleanup(@()warning(backtraceState));



                warning('off','backtrace');
                warning(warnMsg);
            end
        end
    end

    methods(Access=private)


        function instantiateSyncImageViewerClass(this)

            try
                this.SyncImageViewerInstance=this.SyncImageViewerHandle();

                if~isa(this.SyncImageViewerInstance,'lidar.syncImageViewer.SyncImageViewer')
                    error(message('lidar:labeler:SyncImageViewerInheritance'));
                end

            catch ME
                dlgTitle=getString(message('lidar:labeler:CantInstantiateSyncImageViewer'));
                textStr=getString(message('lidar:labeler:ErrorEncounteredSyncImage'));
                showExceptionDialog(this,ME,dlgTitle,textStr);
            end
        end


        function configureSyncImageViewerClass(this)

            if this.IsSyncImageViewerConfigured
                return;
            end

            if~isempty(this.SyncImageViewerInstance)
                try
                    if~this.SyncImageViewerInstance.IsDisconnected

                        timeVector=getSignalTimeVector(this.RangeSliderObj);


                        timeInfo.VideoStartTime=this.RangeSliderObj.VideoStartTime;
                        timeInfo.VideoEndTime=this.RangeSliderObj.VideoEndTime;
                        timeInfo.ScrubberCurrentTime=getRangeSliderCurrentTime(this);
                        timeInfo.IntervalStartTime=getRangeSliderStartTime(this);
                        timeInfo.IntervalEndTime=getRangeSliderEndTime(this);
                        timeInfo.TimeVector=timeVector;

                        connect(this.SyncImageViewerInstance,this,timeInfo);


                        this.FrameChangeListener=addlistener(this.RangeSliderObj,...
                        'FrameChangeEvent',@this.runSyncImageViewerOnFrameChange);


                        dataSourceChangeListener(this.SyncImageViewerInstance);

                        this.IsSyncImageViewerConfigured=true;

                        signalNames=getSignalNames(this.Session);
                        assert(numel(signalNames)==1);
                        this.SyncImageViewerSignalName=signalNames(1);
                    end
                catch ME
                    dlgTitle=getString(message('lidar:labeler:CantConnectSyncImageViewer'));
                    textStr=getString(message('lidar:labeler:ErrorEncounteredSyncImage'));
                    showExceptionDialog(this,ME,dlgTitle,textStr);
                end
            end
        end


        function runSyncImageViewerOnFrameChange(this,~,~)

            try
                frameChangeListenerWrapper(this.SyncImageViewerInstance);
            catch ME
                closeExceptionDialogs(this);

                dlgTitle=getString(message('lidar:labeler:FrameChangeListenerError'));
                textStr=getString(message('lidar:labeler:ErrorEncounteredSyncImage'));
                showExceptionDialog(this,ME,dlgTitle,textStr);
            end
        end

    end




    methods(Static)
        function deleteAllTools(~)
            imageslib.internal.apputil.manageToolInstances('deleteAll',...
            'lidarLabeler');
        end
    end
end

function[title,instanceName]=getAppInfo(varargin)
    title=vision.getMessage('vision:labeler:ToolTitleLL');
    instanceName='lidarLabeler';
end

function tf=useAppContainer
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end