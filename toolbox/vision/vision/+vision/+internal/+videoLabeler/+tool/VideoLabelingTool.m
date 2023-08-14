









classdef VideoLabelingTool<vision.internal.videoLabeler.tool.TemporalLabelingTool



    properties(Hidden)

        FrameChangeFromConnector=false;



ConnectorHandle

        IsConnectorConfigured=false;
    end


    properties(Access=private)




        CaughtConnectorException=false;





ConnectorDrivingSignalName



FrameChangeListener
    end

    properties



ConnectorInstance
    end





    methods(Access=public)


        function this=VideoLabelingTool(varargin)

            import vision.internal.videoLabeler.tool.*;
            import vision.internal.labeler.tool.*;
            import vision.internal.videoLabeler.*;
            import vision.internal.labeler.tool.display.*;

            [isVideoLabeler,title,instanceName]=getAppInfo(varargin{:});


            this=this@vision.internal.videoLabeler.tool.TemporalLabelingTool(title,instanceName);
            this.IsVideoLabeler=isVideoLabeler;

            setSupportedLabelTypes(this);
            createTabsSetActive(this);





            createSession(this);

            this.SignalLoadController=createSignalLoadController(this);


            this.AlgorithmSetupHelper=AlgorithmSetupHelper(this.InstanceName);





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
            import vision.internal.videoLabeler.tool.*;
            import vision.internal.labeler.tool.*;
            import vision.internal.videoLabeler.*;
            import vision.internal.labeler.tool.display.*;

            thisFig=this.Container.NoneSignalFigure;
            this.DisplayManager=DisplayManager(thisFig,this.ToolType,this.NameNoneDisplay);






            thisFig=this.Container.ROILabelFigure;
            this.ROILabelSetDisplay=ROILabelSetDisplay(thisFig,this.InstanceName);

            thisFig=this.Container.SignalNavFigure;
            this.SignalNavigationDisplay=RangeSliderDisplay(thisFig);

            thisFig=this.Container.FrameLabelFigure;
            this.FrameLabelSetDisplay=FrameLabelSetDisplay(thisFig,this.InstanceName);

            thisFig=this.Container.InstructionFigure;
            this.InstructionsSetDisplay=InstructionsSetDisplay(thisFig);

            thisFig=this.Container.AttribSublabelFigure;
            this.AttributesSublabelsDisplay=AttributesSublabelsDisplay(thisFig);


            this.updateFigureCloseListener();
        end


        function TF=isVideoLabeler(this)
            TF=this.IsVideoLabeler;
        end


        function refreshSignalViewList(this)


            this.LabelTab.refreshSignalViewList();
        end
    end




    methods(Access=private)

        function createTabsSetActive(this)


            this.LabelTab=vision.internal.videoLabeler.tool.LabelTab(this);
            this.AlgorithmTab=vision.internal.videoLabeler.tool.AlgorithmTab(this);
            this.SemanticTab=vision.internal.labeler.tool.SemanticTab(this);

            if~this.IsVideoLabeler
                this.LidarTab=driving.internal.groundTruthLabeler.tool.LidarTab(this);
                hide(this.LidarTab);
            end


            this.ActiveTab=this.LabelTab;
        end


        function setSupportedLabelTypes(this)

            this.SupportedROILabelTypes=[labelType.Rectangle...
            ,labelType.Line,labelType.PixelLabel,labelType.Polygon,labelType.ProjectedCuboid];
            if isMultiSignal()
                if~this.IsVideoLabeler
                    this.SupportedROILabelTypes=[this.SupportedROILabelTypes,labelType.Cuboid];
                end
            end
        end


        function[imgDatastore,timestamps,caughtLoadSessionExceptionFlag]=...
            validateAndProcessLoadedSessionWithImageSequence(this,loadedSession)





            caughtLoadSessionExceptionFlag=false;
            timestamps=[];
            imgDatastore=[];

            imgSeqDirName=loadedSession.VideoFileName;



            currentFolder=pwd;
            hFig=this.Container.getDefaultFig;
            if endsWith(currentFolder,fullfile(filesep,imgSeqDirName))
                imgSeqDirName=currentFolder;
            end

            try
                imgDatastore=imageDatastore(imgSeqDirName);
            catch
                caughtLoadSessionExceptionFlag=true;
                errorMessage=vision.getMessage('vision:groundTruthDataSource:InvalidFolderContent');
                dialogName=vision.getMessage('vision:labeler:InvalidFolderTitle');
                vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,...
                this.Tool);
                return;
            end

            timestamps=loadedSession.Timestamps;
            try
                vision.internal.videoLabeler.validation.validateImageSequenceAndTimestamps(imgDatastore,timestamps);
            catch ME
                caughtLoadSessionExceptionFlag=true;
                errorMessage=ME.message;
                dialogName=vision.getMessage('vision:labeler:InvalidTimestampsTitle');
                vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,...
                this.Tool);
                return;
            end
        end


        function[customReaderFunctionHandle,sourceName,timestamps,caughtLoadSessionExceptionFlag,dlg]=...
            validateAndProcessLoadedSessionWithCustomReader(this,loadedSession)





            caughtLoadSessionExceptionFlag=false;
            timestamps=[];
            customReaderFunctionHandle=[];





            sourceName=loadedSession.VideoFileName;

            hFig=this.Container.getDefaultFig;


            try
                timestamps=loadedSession.Timestamps;
                vision.internal.labeler.validation.validateTimestamps(timestamps);
            catch ME
                caughtLoadSessionExceptionFlag=true;
                errorMessage=ME.message;
                dialogName=vision.getMessage('vision:labeler:InvalidTimestampsTitle');
                vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,...
                this.Tool);
                return;
            end


            try
                customReaderFunctionHandle=loadedSession.CustomReaderFunction;
                vision.internal.labeler.validation.validateCustomReaderFunction(customReaderFunctionHandle,sourceName,timestamps)
            catch ME
                caughtLoadSessionExceptionFlag=true;
                errorMessage=ME.message;
                dialogName=vision.getMessage('vision:labeler:InvalidCustomReaderTitle');
                vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,...
                this.Tool);
                return;
            end
        end


        function throwErrorDlg(this,userGivenStartT,userGivenEndT,...
            signalStartTime,signalEndTime)
            if(this.NumSignalsForAutomation>1)
                [startEndTimeOfSignals,~,~]=getAutomationSelectedSignalStartEndTime(this);
                signals=sprintf('%s',strjoin(this.SignalNamesForAutomation(1:end-1),', '),' and ',this.SignalNamesForAutomation{end});
                signalsStartEndTime=[sprintf('%s',strjoin(startEndTimeOfSignals(1:end-1),',')),' and ',startEndTimeOfSignals{end}];
                errorMsg=getString(message('vision:labeler:ErrorForMultipleSignalsAutomation',...
                num2str(userGivenStartT),num2str(userGivenEndT),...
                signals,...
                signalsStartEndTime));
            else
                errorMsg=getString(message('vision:labeler:ErrorForAutomation',...
                num2str(userGivenStartT),num2str(userGivenEndT),...
                num2str(this.SignalNamesForAutomation{1}),...
                num2str(signalStartTime),num2str(signalEndTime)));
            end
            hFig=this.Container.getDefaultFig;
            dlgTitle=getString(message('vision:labeler:ErrorMessage'));
            vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMsg,dlgTitle,...
            this.Tool);
        end


        function dlg=throwYesNoDlg(this,userGivenStartT,userGivenEndT,...
            signalStartTime,signalEndTime,...
            automationStatT,automationEndT)








            [startEndTimeOfSignals,~,~]=getAutomationSelectedSignalStartEndTime(this);
            signals=sprintf('%s',strjoin(this.SignalNamesForAutomation(1:end-1),', '),' and ',this.SignalNamesForAutomation{end});
            signalsStartEndTime=[sprintf('%s',strjoin(startEndTimeOfSignals(1:end-1),', ')),' and ',startEndTimeOfSignals{end}];
            if(this.NumSignalsForAutomation>1)
                yesNoMsg=getString(message('vision:labeler:AcceptForMultiSignalAutomation',...
                num2str(userGivenStartT),num2str(userGivenEndT),...
                signals,...
                signalsStartEndTime,...
                num2str(automationStatT),num2str(automationEndT)));
            else
                yesNoMsg=getString(message('vision:labeler:AcceptForAutomation',...
                num2str(userGivenStartT),num2str(userGivenEndT),...
                num2str(this.SignalNamesForAutomation{1}),...
                num2str(signalStartTime),num2str(signalEndTime),...
                num2str(automationStatT),num2str(automationEndT)));
            end
            dlgTitle=getString(message('vision:labeler:UserWarning'));
            hFig=this.Container.getDefaultFig;
            yes=vision.getMessage('MATLAB:uistring:popupdialogs:Yes');
            no=vision.getMessage('MATLAB:uistring:popupdialogs:No');
            dlg=vision.internal.labeler.handleAlert(hFig,'questionWithWaitDlg',yesNoMsg,dlgTitle,...
            this.Tool,yes,no,yes);
        end


        function success=updateRangeSliderIfYes(this,dlg,automationStatT,automationEndT,newScrubberTime)

            if strcmpi(dlg,vision.getMessage('MATLAB:uistring:popupdialogs:Yes'))









                newRSLeftFlagTime=min_r2(automationStatT,automationEndT);
                newRSRightFlagTime=max_r2(automationStatT,automationEndT);
                updateRangeSliderForAutomation(this.RangeSliderObj,newRSLeftFlagTime,newRSRightFlagTime)
                moveScrubberFamilyAtTime(this,newScrubberTime)


                success=true;
            else
                success=false;
            end

        end
    end




    methods

        function doLoadSession(this,pathName,fileName,varargin)

            if~isVideoLabeler(this)
                this.LabelTab.clearSelectedSignals();
            end

            doLoadSession@vision.internal.videoLabeler.tool.TemporalLabelingTool(this,pathName,fileName,varargin{:});


            if~isVideoLabeler(this)
                signalInfo=this.Session.loadSelectedSignalInfo();
                this.LabelTab.updateSelectedSignals(signalInfo);
            end
        end


        function success=saveSession(this,filename)


            if~isVideoLabeler(this)
                signalInfo=this.LabelTab.getSelectedSignalsForAutomation();
                this.Session.saveSelectedSignalInfo(signalInfo);
            end
            if nargin==2
                success=saveSession@vision.internal.videoLabeler.tool.TemporalLabelingTool(this,filename);
            else
                success=saveSession@vision.internal.videoLabeler.tool.TemporalLabelingTool(this);
            end
        end
    end


    methods
        function configureNewDisplayHelper(this,newDisplay)
            addlistener(newDisplay,'FreezeSignalNav',@this.freezeSignalNav);
            addlistener(newDisplay,'UnfreezeSignalNav',@this.unfreezeSignalNav);
        end
    end





    methods(Static)
        function deleteAllTools(isVL)
            if isVL
                imageslib.internal.apputil.manageToolInstances('deleteAll',...
                'videoLabeler');
            else
                imageslib.internal.apputil.manageToolInstances('deleteAll',...
                'groundTruthLabeler');
            end
        end
    end




    methods(Access=public)

        function createAndPopulateDisplayGrid(this,numRows,numCols)

            createXMLandGenerateLayout(this,numRows,numCols);
            grabFocus(this.DisplayManager);

        end
    end

    methods(Access=protected)


        function forceCloseDisplays(this,src,evtData)

            deleteComponenDestroyListener(this);
            forceCloseDisplays@vision.internal.videoLabeler.tool.TemporalLabelingTool(this,src,evtData);
            removedSignals=evtData.RemovedSignals;
            handleConnectorForDeletedSignal(this,removedSignals);

            if numel(this.DisplayManager.Displays)>2&&...
                evtData.Source.HasROILabels>0
                this.LabelTab.enableSignalSelection();
            else
                this.LabelTab.disableSignalSelection();
            end
        end


        function throwLoadErrorDialog(this,sourceType)
            if sourceType==vision.internal.labeler.DataSourceType.VideoReader

                errorMessage=getString(message('vision:labeler:UnableToReadDlgMessage'));
                dialogName=getString(message('vision:labeler:UnableToReadDlgName'));
            elseif sourceType==vision.internal.labeler.DataSourceType.ImageSequence

                errorMessage=getString(message('vision:labeler:ImageSequenceLoadErrorGeneral'));
                dialogName=getString(message('vision:labeler:ImageSequenceLoadErrorTitle'));
            elseif sourceType==vision.internal.labeler.DataSourceType.CustomReader

                errorMessage=getString(message('vision:labeler:CustomSourceLoadErrorGeneral'));
                dialogName=getString(message('vision:labeler:CustomSourceLoadErrorTitle'));
            end
            hFig=this.Container.getDefaultFig;
            vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,...
            this.Tool);
            drawnow;
        end


        function addDisplays(this,src,evtData)

            addDisplays@vision.internal.videoLabeler.tool.TemporalLabelingTool(this,src,evtData);

            configureConnectorClass(this);

            updateFigureCloseListener(this);
            if~isVideoLabeler(this)
                if numel(this.DisplayManager.Displays)>2&&...
                    evtData.Source.HasROILabels>0
                    this.LabelTab.enableSignalSelection();
                else
                    this.LabelTab.disableSignalSelection();
                end
            end
        end


        function updateDisplaySelection(this,selectedDisplayID)
            if selectedDisplayID<=1
                selectedDisplayID=this.DisplayManager.NumDisplays;
            end
            dislayObj=this.DisplayManager.getDisplayFromId(selectedDisplayID);
            grabFocus(dislayObj);
            drawnow();
            selectedDisplay=getSelectedDisplay(this);
            if isempty(selectedDisplay)&&selectedDisplayID~=1
                updateDisplaySelection(this,selectedDisplayID-1);
            end
        end


        function modifySignalViewList(this,~,evtData)
            this.LabelTab.updateSignalList(evtData)
            if isequal(this.ToolType,vision.internal.toolType.GroundTruthLabeler)
                this.LabelTab.updateSignalSelectionList(evtData)
            end
        end
    end




    methods(Access=public,Hidden)


        function addSignals(this)

            wait(this.Container);

            viewInfo=[];

            openDialog(this.SignalLoadController,viewInfo);

            resume(this.Container);

        end


        function loadVideo(this)


            doLoad=warnBeforeLoading(this);

            wait(this.Container);
            resetWait=onCleanup(@()resume(this.Container));

            if doLoad

                viewInfo=struct();
                viewInfo.ViewType="video";
                openDialog(this.SignalLoadController,viewInfo);
            end
        end


        function loadImageSequence(this)


            doLoad=warnBeforeLoading(this);

            wait(this.Container);
            resetWait=onCleanup(@()resume(this.Container));

            if doLoad

                viewInfo=struct();
                viewInfo.ViewType="imagesequnce";

                openDialog(this.SignalLoadController,viewInfo);
            end
        end


        function loadCustomReader(this)


            doLoad=warnBeforeLoading(this);

            wait(this.Container);
            resetWait=onCleanup(@()resume(this.Container));

            if doLoad
                viewInfo=struct();
                viewInfo.ViewType="customimage";

                openDialog(this.SignalLoadController,viewInfo);
            end
        end

    end

    methods(Access=protected)

        function signalController=createSignalLoadController(this,signalModel)

            if nargin<2
                signalController=createSignalLoadController@vision.internal.videoLabeler.tool.TemporalLabelingTool(this);
            else
                signalController=createSignalLoadController@vision.internal.videoLabeler.tool.TemporalLabelingTool(this,signalModel);
            end

            addlistener(this.Session,'AddedSignals',@this.modifySignalViewList);
            addlistener(this.Session,'RemovedSignals',@this.modifySignalViewList);

        end


        function signalView=getSignalView(this)

            import vision.internal.videoLabeler.tool.signalLoading.view.*


            if this.IsVideoLabeler
                signalView=SignalLoadViewSingle();
            else
                if isMultiSignal()
                    signalView=SignalLoadViewMulti();
                else
                    signalView=SignalLoadViewSingle();
                end
            end
        end


        function updateAfterSignalLoad(this)
            addVideoToSession(this);

            updateOnNewVideo(this,this.Reader.Name);

            setLoadingText(this,false,false);

            this.setStatusText('');
        end
    end




    methods(Access=protected)


        function attachRangeSliderListeners(this)
            attachRangeSliderListeners@vision.internal.videoLabeler.tool.TemporalLabelingTool(this);

            addlistener(this.RangeSliderObj,'MasterSignalChanged',@this.masterSignalChangeListener);
        end


        function handleConnectorForDeletedSignal(this,removedSignals)

            if hasCustomDisplay(this)
                drivingSignalDeleted=~isempty(find(contains(removedSignals,this.ConnectorDrivingSignalName),1));
                if drivingSignalDeleted
                    closeConnectorTarget(this);

                    msg=vision.getMessage('vision:labeler:DrivingSignalDeletedWarning');
                    dlgTitle=vision.getMessage('vision:labeler:ConnectorWarnDlg');
                    figHandle=this.Container.getDefaultFig;
                    vision.internal.labeler.handleAlert(figHandle,'warndlg',msg,dlgTitle);
                end
            end
        end

        function handleConnectorForMasterSignalChange(this)

            if hasCustomDisplay(this)
                closeConnectorTarget(this);

                msg=vision.getMessage('vision:labeler:DrivingSignalNonMainWarning');
                dlgTitle=vision.getMessage('vision:labeler:ConnectorWarnDlg');
                figHandle=this.Container.getDefaultFig;
                vision.internal.labeler.handleAlert(figHandle,'warndlg',msg,dlgTitle);
            end
        end

        function handleConnectorForNewSession(this)

            if hasCustomDisplay(this)
                closeConnectorTarget(this);

                msg=vision.getMessage('vision:labeler:ConnectorNewSessionWarning');
                dlgTitle=vision.getMessage('vision:labeler:ConnectorWarnDlg');
                figHandle=this.Container.getDefaultFig;
                vision.internal.labeler.handleAlert(figHandle,'warndlg',msg,dlgTitle);
            end
        end
    end


    methods


        function attachListenerForRangeSlider(this)
            if~isempty(this.ConnectorInstance)
                addlistener(this.ConnectorInstance,'CaughtExceptionEvent',...
                @this.connectorExceptionListener);
            end
        end


        function removeRangeSlider(this)
        end


        function wireUpLidarListeners(this,pcDisplay)

            pcListeners=wireUpLidarListeners@vision.internal.videoLabeler.tool.TemporalLabelingTool(this,pcDisplay);
            addListenersToDisplayObject(pcDisplay,pcListeners);


            refresh(this.LidarTab)

        end
    end




    methods


        function playVideo(this,timeVector)
            if~this.IsVideoLabeler&&~this.isInAlgoMode
                disableRangeSliderSetting(this.RangeSliderObj);
            end

            playVideo@vision.internal.videoLabeler.tool.TemporalLabelingTool(this,timeVector);

            if~this.IsVideoLabeler&&~this.isInAlgoMode
                enableRangeSliderSetting(this.RangeSliderObj);
            end
        end
    end

    methods(Access=protected)


        function success=checkValidIntervals(this,scrubberCurrentTime)

            success=false;
            if(this.NumSignalsForAutomation>1)
                [signalStartTime,signalEndTime]=getMasterSignalStartEndTime(this);
            else
                [signalStartTime,signalEndTime]=getSignalStartEndTime(this);
            end

            flagStartTime=this.CachedInterval(1);
            flagEndTime=this.CachedInterval(2);

            isAlgoForward=this.AlgorithmConfiguration.AutomateForward;
            isAlgoStartAtCurrentTime=this.AlgorithmConfiguration.StartAtCurrentTime;

            [isSigOutsideRange,userGivenStartT,userGivenEndT]=...
            isSignalOutsideRange(...
            isAlgoForward,isAlgoStartAtCurrentTime,...
            signalStartTime,signalEndTime,...
            flagStartTime,flagEndTime,...
            scrubberCurrentTime);

            if isSigOutsideRange


                throwErrorDlg(this,userGivenStartT,userGivenEndT,...
                signalStartTime,signalEndTime);
                return;
            end

            [isSigRangeTruncated,automationStatT,automationEndT,newScrubberTime]=...
            isSignalRangeTruncated(...
            isSigOutsideRange,isAlgoForward,isAlgoStartAtCurrentTime,...
            signalStartTime,signalEndTime,...
            flagStartTime,flagEndTime,...
            scrubberCurrentTime);

            if isSigRangeTruncated
                dlg=throwYesNoDlg(this,userGivenStartT,userGivenEndT,...
                signalStartTime,signalEndTime,...
                automationStatT,automationEndT);
                success=updateRangeSliderIfYes(this,dlg,...
                automationStatT,automationEndT,newScrubberTime);
            else
                success=true;
            end

        end

    end
    methods

        function[hasReaderException,hasConnectorException]=handleException(this)


            [hasReaderException,hasConnectorException]=handleException@vision.internal.videoLabeler.tool.TemporalLabelingTool(this);

            if this.CaughtConnectorException
                this.IsStillRunning=false;
                this.replaceStaticROIs();
                this.CaughtConnectorException=false;
                hasConnectorException=true;
                return;
            end
        end
    end




    methods(Access=protected)


        function displayObj=getDisplay(this,name)
            displayObj=getDisplay(this.DisplayManager,name);
        end

    end




    methods







        function requestModeChange(this,mode)

            this.ActiveTab.reactToModeChange(mode);


            if~this.Session.HasROILabels&&strcmpi(mode,'ROI')
                mode='none';
            end

            setMode(this,mode);
        end
    end




    methods

        function exportLabelAnnotationsToWS(this)

            wait(this.Container);

            resetWait=onCleanup(@()resume(this.Container));

            finalize(this);

            variableName='gTruth';

            if hasPixelLabels(this.Session)
                dlgTitle=vision.getMessage('vision:uitools:ExportTitle');
                toFile=false;
                exportDlg=vision.internal.labeler.tool.ExportPixelLabelDlg(...
                this.Tool,variableName,dlgTitle,this.Session.getPixelLabelDataPath,toFile);
                wait(exportDlg);
                if~exportDlg.IsCanceled
                    this.Session.setPixelLabelDataPath(exportDlg.VarPath);
                    TF=exportPixelLabelData(this.Session,exportDlg.CreatedDirectory);
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
                labels=exportLabelAnnotations(this.Session,getSignalNames(this.Session));
                labels=appendCustomLabels(this,labels);
                if hasPixelLabels(this.Session)
                    refreshPixelLabelAnnotation(this.Session);
                end

                saveVariableToWs(this,varName,labels);

                this.setStatusText('');
            end
            drawnow;


        end


        function labelsOut=appendCustomLabels(this,labels)
            customLabels=getLabelsFromCustomDisplay(this);



            if isempty(labels)

                dataSources=getDataSourceForExport(this.Session,getSignalNames(this.Session));
                definitions=combineCustomLabelDefinitions(this);
                [roiData,sceneData]=getAnnotationsForExport(this.Session,[dataSources.SignalName]);
                labels=groundTruthMultisignal(dataSources,definitions,...
                roiData,sceneData);
            end

            labelsOut=vision.internal.labeler.mergeCustomGroundTruth(labels,customLabels,this.ConnectorDrivingSignalName);
        end


        function labelDefs=combineCustomLabelDefinitions(this)

            labelDefs=exportLabelDefinitions(this.Session);

            customLabelDefs=getCustomLabelDefinitions(this,labelDefs);

            if~isempty(customLabelDefs)
                labelDefs=appendTableRow(this,labelDefs,customLabelDefs);
            end
        end

    end

    methods(Access=private)


        function customLabelDefs=getCustomLabelDefinitions(this,labelDefs)
            customLabels=getLabelsFromCustomDisplay(this);
            if isempty(customLabels)
                customLabelDefs={};
            else

                numCustomLabels=numel(string(customLabels.CustomLabelName));

                labelDefHeading=string(labelDefs.Properties.VariableNames);
                customLabelDefs=cell(numCustomLabels,numel(labelDefHeading));

                if numCustomLabels==1
                    try
                        if iscell(customLabels.CustomLabelDesc)&&...
                            isempty(customLabels.CustomLabelDesc)
                            customLabels.CustomLabelDesc='';
                        end
                    catch
                        customLabels.CustomLabelDesc='';
                    end
                    customLabels.CustomLabelName={customLabels.CustomLabelName};
                end

                for idx=1:numCustomLabels
                    customLabelDefs{idx,1}=customLabels.CustomLabelName{idx};
                    customLabelDefs{idx,2}=vision.labeler.loading.SignalType.Custom;
                    customLabelDefs{idx,3}=labelType.Custom;
                    customLabelDefs{idx,4}=customLabels.CustomLabelGroup;
                    try
                        customLabelDefs{idx,5}=customLabels.CustomLabelDesc{idx};
                    catch
                        customLabelDefs{idx,5}='';
                    end
                end
            end
        end
    end

    methods(Hidden)
        function fcnName=getGtruthFcnName(this)
            if isVideoLabeler(this)
                fcnName={'groundTruth'};
            else
                fcnName={'groundTruthMultisignal','groundTruth'};
            end
        end
    end




    methods

        function cleanSession(this)

            cleanSession@vision.internal.videoLabeler.tool.TemporalLabelingTool(this);

            handleConnectorForNewSession(this);

            if~isVideoLabeler(this)
                this.LabelTab.clearSelectedSignals();
            end
        end
    end




    methods




        function startAutomation(this)

            startAutomation@vision.internal.videoLabeler.tool.TemporalLabelingTool(this);
        end




        function success=tryToSetupAlgorithm(this)
            success=tryToSetupAlgorithm@vision.internal.videoLabeler.tool.TemporalLabelingTool(this);
        end




        function setVideoDisplayBeforeAutomation(this,selectedROILabels)

            setVideoDisplayBeforeAutomation@vision.internal.videoLabeler.tool.TemporalLabelingTool(this,selectedROILabels);

            if~this.IsVideoLabeler
                if(this.NumSignalsForAutomation>1)
                    setSignalNamesPopupInAutomation(this.RangeSliderObj,...
                    this.SignalNamesForAutomation,this.SignalTimeVector,this.AlgorithmConfiguration);
                else
                    disableRangeSliderSetting(this.RangeSliderObj);
                end
            end
        end

    end




    methods
        function addCustomDisplay(this,classHandle)

            this.ConnectorHandle=classHandle;
            instantiateConnectorClass(this);
            attachListenerForRangeSlider(this);
        end


        function addSessionCustomDisplay(this,classHandleSession,varargin)





            hasCustomDisplayPVPair=false;
            if~isempty(varargin)
                hasCustomDisplayPVPair=varargin{1};
            end
            if hasCustomDisplayPVPair
                connectorHandle=varargin{2};
                addCustomDisplay(this,connectorHandle);
                this.IsConnectorConfigured=false;
            else
                if~isempty(classHandleSession)
                    addCustomDisplay(this,classHandleSession);
                    this.IsConnectorConfigured=false;
                end
            end
        end


        function connectorExceptionListener(this,varargin)
            this.CaughtConnectorException=true;
            this.RangeSliderObj.exceptionDuringPlayListener(varargin{:});
            if~isempty(this.VisualSummaryDisplay)
                this.VisualSummaryDisplay.exceptionDuringPlayListener(varargin{:});
            end
        end


        function masterSignalChangeListener(this,varargin)
            handleConnectorForMasterSignalChange(this);
        end
    end

    methods(Hidden)


        function flag=hasCustomDisplay(this)
            flag=~isempty(this.ConnectorInstance);
        end



        function setCustomLabelDefinition(this,customLabelDef)

            try
                setCustomLabelDefinition(this.ConnectorInstance,customLabelDef);
            catch ME
                closeExceptionDialogs(this);

                dlgTitle=getString(message('vision:labeler:LabelDefinitionLoadListenerError'));
                textStr=getString(message('vision:labeler:ErrorEncounteredConn'));
                showExceptionDialog(this,ME,dlgTitle,textStr);
            end
        end
    end

    methods(Access=public,Hidden)

        function setCustomLabels(this,customLabels)

            try
                setCustomLabels(this.ConnectorInstance,customLabels);
            catch ME
                closeExceptionDialogs(this);

                dlgTitle=getString(message('vision:labeler:LabelLoadListenerError'));
                textStr=getString(message('vision:labeler:ErrorEncounteredConn'));
                showExceptionDialog(this,ME,dlgTitle,textStr);
            end
        end



        function labels=getLabelsFromCustomDisplay(this)
            if hasCustomDisplay(this)
                labels.CustomLabelName=this.ConnectorInstance.LabelName;
                labels.CustomLabelGroup='None';
                labels.CustomLabelDesc=this.ConnectorInstance.LabelDescription;
                labels.CustomLabelData=this.ConnectorInstance.LabelData;
            else
                labels=[];
            end
        end


        function closeConnectorTarget(this)

            try
                if~this.ConnectorInstance.IsDisconnected
                    close(this.ConnectorInstance);
                    this.ConnectorInstance=[];
                end
            catch ME





                functionName='close()';
                errorReport=vision.internal.getTrimmedReport(ME,{});
                warnMsg=getString(message('vision:labeler:EncapsulatedConnectorWarning',functionName,errorReport));



                backtraceState=warning('query','backtrace');
                restoreBacktraceSTate=onCleanup(@()warning(backtraceState));



                warning('off','backtrace');
                warning(warnMsg);
            end
        end
    end

    methods(Access=private)


        function instantiateConnectorClass(this)

            try
                this.ConnectorInstance=this.ConnectorHandle();

                if~isa(this.ConnectorInstance,'driving.connector.Connector')
                    error(message('vision:labeler:ConnectorInheritance'));
                end

            catch ME
                dlgTitle=getString(message('vision:labeler:CantInstantiateConnector'));
                textStr=getString(message('vision:labeler:ErrorEncounteredConn'));
                showExceptionDialog(this,ME,dlgTitle,textStr);
            end
        end


        function configureConnectorClass(this)

            if this.IsConnectorConfigured
                return;
            end

            if~isempty(this.ConnectorInstance)
                try
                    if~this.ConnectorInstance.IsDisconnected

                        timeVector=getSignalTimeVector(this.RangeSliderObj);


                        timeInfo.VideoStartTime=this.RangeSliderObj.VideoStartTime;
                        timeInfo.VideoEndTime=this.RangeSliderObj.VideoEndTime;
                        timeInfo.ScrubberCurrentTime=getRangeSliderCurrentTime(this);
                        timeInfo.IntervalStartTime=getRangeSliderStartTime(this);
                        timeInfo.IntervalEndTime=getRangeSliderEndTime(this);
                        timeInfo.TimeVector=timeVector;

                        connect(this.ConnectorInstance,this,timeInfo);


                        this.FrameChangeListener=addlistener(this.RangeSliderObj,...
                        'FrameChangeEvent',@this.runConnectorOnFrameChange);


                        dataSourceChangeListener(this.ConnectorInstance);

                        if~isempty(this.ConnectorInstance.LabelName)

                            connectorLabelNames=convertCharsToStrings(this.ConnectorInstance.LabelName);

                            for idx=1:numel(connectorLabelNames)
                                isValid=isValidName(this.Session,connectorLabelNames(idx));
                                if~isValid
                                    errorMessage=vision.getMessage('vision:labeler:LabelNameExistsDlgMsg',connectorLabelNames(idx));
                                    error(errorMessage);
                                end
                            end

                            setConnectorLabelNames(this.Session,this.ConnectorInstance.LabelName);
                        end

                        this.IsConnectorConfigured=true;

                        signalNames=getSignalNames(this.Session);
                        assert(numel(signalNames)==1);
                        this.ConnectorDrivingSignalName=signalNames(1);
                    end
                catch ME
                    dlgTitle=getString(message('vision:labeler:CantConnectConnector'));
                    textStr=getString(message('vision:labeler:ErrorEncounteredConn'));
                    showExceptionDialog(this,ME,dlgTitle,textStr);
                end
            end
        end


        function runConnectorOnFrameChange(this,~,~)

            try
                frameChangeListenerWrapper(this.ConnectorInstance);
            catch ME
                closeExceptionDialogs(this);

                dlgTitle=getString(message('vision:labeler:FrameChangeListenerError'));
                textStr=getString(message('vision:labeler:ErrorEncounteredConn'));
                showExceptionDialog(this,ME,dlgTitle,textStr);
            end
        end

        function signalId=convertSignalNameToSignalId(this,signalName)
            signalId=getDisplayIdFromName(this.DisplayManager,signalName)-1;
        end

    end

    methods(Access=public,Hidden)







        function status=updateCurrentDisplay(this,data)

            try
                for i=1:this.NumSignalsForDisplay
                    dispIdx=i+1;
                    thisDisplay=this.DisplayManager.getDisplayFromIdNoCheck(dispIdx);

                    thisDisplay.drawFrameWithInteractiveROIs(data);

                    notifyExternal=false;
                    currentROIs=thisDisplay.getCurrentROIs();
                    updateSessionWithROIsAnnotations(this,thisDisplay,currentROIs,notifyExternal);
                end
                status=true;
            catch
                status=false;
            end
        end

    end

    methods


        function fig=getSignalFig(this)
            fig=getDisplayFig(this.DisplayManager,this.NameNoneDisplay);
        end


        function name=getConvertedSignalName(~,signalName)
            name=signalName;
        end
    end

end

function[isVideoLabeler,title,instanceName]=getAppInfo(varargin)
    if nargin==1
        isVideoLabeler=varargin{1};
    else

        isVideoLabeler=false;
    end

    if isVideoLabeler
        title=vision.getMessage('vision:labeler:ToolTitleVL');
        instanceName='videoLabeler';
    else
        title=vision.getMessage('vision:labeler:ToolTitleGTL');
        instanceName='groundTruthLabeler';
    end
end


function r=r2(v)
    r=round(v,02);
end


function v=max_r2(x,y)
    if r2(x)>r2(y)
        v=x;
    else
        v=y;
    end
end


function v=min_r2(x,y)
    if r2(x)<r2(y)
        v=x;
    else
        v=y;
    end
end


function[tf,automationStatT,automationEndT,newScrubberTime]=...
    isSignalRangeTruncated(isSigOutsideRange,...
    isAlgoForward,isAlgoStartAtCurrentTime,...
    signalStartTime,signalEndTime,...
    flagStartTime,flagEndTime,...
    scrubberCurrentTime)







    automationStatT=-1;
    automationEndT=-1;

    newScrubberTime=scrubberCurrentTime;

    if isAlgoForward
        if isAlgoStartAtCurrentTime


            if~isSigOutsideRange
                tf=(r2(signalStartTime)>r2(scrubberCurrentTime))||...
                (r2(signalEndTime)<r2(flagEndTime));
                automationStatT=max_r2(signalStartTime,scrubberCurrentTime);
                automationEndT=min_r2(signalEndTime,flagEndTime);
                newScrubberTime=automationStatT;
            end
        else

            if~isSigOutsideRange
                tf=(r2(signalStartTime)>r2(flagStartTime))||...
                (r2(signalEndTime)<r2(flagEndTime));
                automationStatT=max_r2(signalStartTime,flagStartTime);
                automationEndT=min_r2(signalEndTime,flagEndTime);
                newScrubberTime=min_r2(...
                max_r2(automationStatT,scrubberCurrentTime),...
                automationEndT);
            end
        end
    else
        if isAlgoStartAtCurrentTime

            if~isSigOutsideRange

                tf=(r2(signalEndTime)<r2(scrubberCurrentTime))||...
                (r2(signalStartTime)>r2(flagStartTime));
                automationStatT=min_r2(signalEndTime,scrubberCurrentTime);
                automationEndT=max_r2(signalStartTime,flagStartTime);



                newScrubberTime=automationStatT;
            end
        else

            if~isSigOutsideRange
                tf=(r2(signalEndTime)<r2(flagEndTime))||...
                (r2(signalStartTime)>r2(flagStartTime));
                automationStatT=min_r2(signalEndTime,flagEndTime);
                automationEndT=max_r2(signalStartTime,flagStartTime);



                newScrubberTime=max_r2(...
                min_r2(automationStatT,scrubberCurrentTime),...
                automationEndT);
            end
        end
    end
end


function[tf,userGivenStartT,userGivenEndT]...
    =isSignalOutsideRange(isAlgoForward,isAlgoStartAtCurrentTime,...
    signalStartTime,signalEndTime,...
    flagStartTime,flagEndTime,...
    scrubberCurrentTime)







    if isAlgoForward
        if isAlgoStartAtCurrentTime

            tf=(r2(signalEndTime)<r2(scrubberCurrentTime))||...
            (r2(signalStartTime)>r2(flagEndTime));
            userGivenStartT=scrubberCurrentTime;
            userGivenEndT=flagEndTime;
        else

            tf=(r2(signalEndTime)<r2(flagStartTime))||...
            (r2(signalStartTime)>r2(flagEndTime));
            userGivenStartT=flagStartTime;
            userGivenEndT=flagEndTime;
        end
    else
        if isAlgoStartAtCurrentTime

            tf=(r2(signalEndTime)<r2(flagStartTime))||...
            (r2(signalStartTime)>r2(scrubberCurrentTime));
            userGivenStartT=flagEndTime;
            userGivenEndT=scrubberCurrentTime;
        else

            tf=(r2(signalEndTime)<r2(flagStartTime))||...
            (r2(signalStartTime)>r2(flagEndTime));
            userGivenStartT=flagEndTime;
            userGivenEndT=flagStartTime;
        end
    end

end

function tf=isMultiSignal()
    tf=strcmpi(vision.internal.videoLabeler.gtlfeature('multiSignalSupport'),'on');
end
