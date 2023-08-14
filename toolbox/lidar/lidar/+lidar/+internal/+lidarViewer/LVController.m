





classdef LVController<handle

    properties(Access=private)


        Model lidar.internal.lidarViewer.LVModel


        View lidar.internal.lidarViewer.LVView


        DataIOController lidar.internal.lidarViewer.lidarViewerIO.LVIOController

    end

    properties(Access=private)


        EditMode logical


        EditBeingUsed string



        DataIdInView(1,1)int32



EditModeCachedPtCld



EditModeValidity



SelectedFrames
    end

    properties(Access=private)


        MeasurementMode logical


        MeasurementManager lidar.internal.lidarViewer.measurementTool.MeasurementManager


MeasurementUndoStack


MeasurementRedoStack


ColorValue


        CData={}


        CData1={}


        CData2={}
    end

    properties(Access=private)

        InPlayMode(1,1)logical=false;


        ToExport(1,1)logical=false;
    end




    methods
        function this=LVController(viewObj,modelObj)

            this.Model=modelObj;
            this.View=viewObj;


            wireUpDataIOController(this);
            wireUpModel(this);
            wireUpView(this);

            this.EditMode=false;
            this.MeasurementMode=false;
        end
    end





    methods(Access=private)

        function wireUpDataIOController(this)

            dataModel=this.Model.getDataModel();

            this.DataIOController=...
            lidar.internal.lidarViewer.lidarViewerIO.LVIOController(dataModel);


            addlistener(this.DataIOController,'DataAdded',@(~,~)dataAdded(this));
            addlistener(this.DataIOController,'ExternalTrigger',@(~,evt)handleExternalTriggers(this,evt));
        end


        function wireUpView(this)



            addlistener(this.View,'RequestToImportSignals',@(~,evt)loadData(this,evt));
            addlistener(this.View,'RequestForNewSession',@(~,~)requestForNewSession(this));

            addlistener(this.View,'EditModeRequest',@(~,~)switchToEditMode(this));
            addlistener(this.View,'MeasurementModeRequest',@(~,~)switchToMeasurementMode(this));
            addlistener(this.View,'CloseMeasurementTab',@(~,~)exitMeasurementMode(this));
            addlistener(this.View,'RequestToEditSignals',@(~,evt)requestToEditData(this,evt));
            addlistener(this.View,'RequestToEditDataWithCustomFunction',@(~,evt)requestToEditDataWithCustomFunction(this,evt));
            addlistener(this.View,'RequestToExitEditMode',@(~,evt)exitEditMode(this,evt));
            addlistener(this.View,'RequestToExportSignals',@(~,~)requestToExportData(this));
            addlistener(this.View,'RequestToUpdateEdits',@(~,evt)updateRequestForEdits(this,evt));


            addlistener(this.View,'FrameChangeRequest',@(~,evt)frameChangeRequest(this,evt));


            addlistener(this.View,'RequestToCloseApp',@(~,~)requestToCloseApp(this));
            addlistener(this.View,'AppResized',@(~,~)resizeApp(this));
            addlistener(this.View,'RequestUndo',@(~,~)undoRequest(this));
            addlistener(this.View,'RequestRedo',@(~,~)redoRequest(this));


            addlistener(this.View,'RequestToDeleteData',@(~,evt)requestToDeleteData(this,evt));
            addlistener(this.View,'RequestToToggleData',@(~,evt)requestToToggleData(this,evt));


            addlistener(this.View,'RequestToGenerateMacro',@(~,~)requestToGenerateScript(this));
            addlistener(this.View,'RequestToDiscardAllEdits',@(~,~)requestToRevertEditsInCurrentFrame(this));


            addlistener(this.View,'AddedMeasurementTool',@(~,evt)addToolsInMeasurementStacks(this,evt));
            addlistener(this.View,'RemoveMeasurementTool',@(~,~)resetMeasurementStacks(this));
            addlistener(this.View,'DeleteAllMeasurementRequest',@(~,~)requestToDeleteMeasurementWhenEditData(this));
            addlistener(this.View,'ColorChangeRequest',@(~,evt)getColor(this,evt));
            addlistener(this.View,'ObjectDeleted',@(~,~)this.toolsDeleted());
            addlistener(this.View,'UpdateUndoRedoStack',@(~,evt)this.updateToolsInMeasurementStack('update',evt));
            addlistener(this.View,'DeleteFromUndoRedoStack',@(~,evt)this.updateToolsInMeasurementStack('delete',evt));
            addlistener(this.View,'UpdateMeasurementUndoStack',@(~,~)this.updateMeasurementUndoStack());
            addlistener(this.View,'UpdateColorData',@(~,~)this.updateColorData());

        end


        function wireUpModel(this)

            addlistener(this.Model,'PointCloudChanging',@(~,evt)pointCloudChanging(this,evt));
            addlistener(this.Model,'PointCloudChanged',@(~,evt)pointCloudChanged(this,evt));
            addlistener(this.Model,'ExternalTrigger',@(~,evt)handleExternalTriggers(this,evt));
        end


        function wireUpMeasurementManager(this)

            addlistener(this.MeasurementManager,'ResetColorData',@(~,~)this.resetColorData());
            addlistener(this.MeasurementManager,'DeleteAllTools',@(~,~)this.deleteAllTools());
            addlistener(this.MeasurementManager,'UpdateClearSection',@(~,~)this.updateClearSection());
            addlistener(this.MeasurementManager,'CreateObject',@(~,evt)this.measurementToolCreateObject(evt));
        end
    end





    methods(Access=private)

        function dataAdded(this)




            dataAdded=this.Model.getDataAdded();






            maxDataId=this.Model.getDataCount();
            this.DataIdInView=maxDataId;

            dataName=dataAdded.DataName{1};



            limits=this.Model.getGlobalLimits(...
            this.DataIdInView);
            this.View.createAndAddDisplay(dataName,limits);


            this.View.setUpUIAfterDataManagement();



            this.manageTimeStamps(this.DataIdInView);



            currentTime=this.View.getCurrentTime();
            data=this.DataIOController.readData(dataName,currentTime);


            if this.View.getNumDisplays~=2




                this.View.saveTSState(this.DataIdInView)
            end



            scalars=this.Model.getScalars(dataName);
            this.View.setUpTS(scalars);


            this.View.updateDisplayContent(this.DataIdInView,data);


            this.View.setUpUIAfterDataManagement();


            this.View.addInDataBrowser(dataAdded.DataName{1});


            this.updateAnalysisPanel();


            dataNew=this.Model.getDataInfo(this.DataIdInView);


            initializeColorData(this,dataNew.NumFrames);


            this.View.storeDefaultCameraProperties(this.DataIdInView);

        end
    end





    methods(Access=private)

        function loadData(this,evt)

            srcType=evt.SourceFileType;
            this.DataIOController.importData(srcType,evt);

        end

        function requestForNewSession(this)


            if this.Model.getDataCount==0

                TF=true;
            else
                TF=this.promptToSaveData('newSession');
            end

            if TF

                this.Model.reset();
                this.wireUpDataIOController();


                this.DataIdInView=0;


                this.View.reset();
            end


            this.ToExport=false;
        end


        function requestToExportData(this)



            this.doExport();
        end


        function requestToGenerateScript(this)

            this.Model.generateScript();
        end
    end




    methods(Access=private)

        function switchToEditMode(this)


            if this.View.getNumDisplays==1


                return;
            end

            this.EditMode=true;

            if this.View.getGroundOrClustersState


                currentTime=this.View.getCurrentTime();
                dataInfo=this.Model.getDataInfo(this.DataIdInView);


                data=this.DataIOController.readData(dataInfo.Name,...
                currentTime);
                this.View.updateDisplayContent(this.DataIdInView,data);
            end


            dataId=this.DataIdInView;


            this.View.editModeUIChange();



            data=this.Model.getDataInfo(dataId);
            dataName=data.Name;
            currentIndex=this.Model.getDataIndex(dataName,this.View.getCurrentTime);


            this.Model.createEditStack(dataName,data.NumFrames,currentIndex);





            evt=lidar.internal.lidarViewer.events.CustomEditOperationEvenData(1);
            updateRequestForEdits(this,evt);
            this.View.updateUndoRedoQAB(true,true);
        end


        function switchToMeasurementMode(this)


            if this.View.getNumDisplays==1


                return;
            end

            this.MeasurementMode=true;

            this.View.saveTSState(this.DataIdInView);
            limits=this.Model.getGlobalLimits(...
            this.DataIdInView);



            currentTime=this.View.getCurrentTime();
            dataInfo=this.Model.getDataInfo(this.DataIdInView);


            data=this.DataIOController.readData(dataInfo.Name,...
            currentTime);


            this.View.measurementModeUIChange();

            this.View.updateDisplayContent(this.DataIdInView,data,limits,[]);

            currentIndex=this.Model.getDataIndex(dataInfo.Name,this.View.getCurrentTime);
            this.MeasurementManager=lidar.internal.lidarViewer.measurementTool.MeasurementManager();

            this.MeasurementManager.createMeasurementStacks(dataInfo.NumFrames,currentIndex);
            this.wireUpMeasurementManager();

            this.MeasurementUndoStack=this.MeasurementManager.MeasurementUndoStack{currentIndex};
            this.MeasurementRedoStack=this.MeasurementManager.MeasurementRedoStack{currentIndex};

            try
                updateColorData(this);
                updateColorMapValues(this);
            catch
            end

            this.View.updateUndoRedoQAB(true,true);
        end

        function exitMeasurementMode(this)
            this.MeasurementMode=false;



            currentTime=this.View.getCurrentTime();
            dataInfo=this.Model.getDataInfo(this.DataIdInView);


            data=this.DataIOController.readData(dataInfo.Name,...
            currentTime);

            this.MeasurementManager.resetStacks();

            this.View.updateDisplayContent(this.DataIdInView,data);

            this.View.updateUndoRedoQAB(true,true);
        end


        function requestToDeleteMeasurementWhenEditData(this)




            count=cellfun(@(x)numel(x),this.MeasurementManager.MeasurementUndoStack);
            count=sum(count);

            dataInfo=this.Model.getDataInfo(this.DataIdInView);


            if count~=dataInfo.NumFrames
                this.View.IsMeasurementTools(true);
            else
                this.View.IsMeasurementTools(false);
            end
        end


        function requestToEditData(this,evt)




            editPanel=this.View.getEditPanel();
            editName=evt.EditName;
            isTemporal=evt.IsTemporal;

            if strcmp(editName,getString(message('lidar:lidarViewer:Crop')))
                limits=this.Model.getGlobalLimits(...
                this.DataIdInView);currentTime=this.View.getCurrentTime();
                dataInfo=this.Model.getDataInfo(this.DataIdInView);
                data=this.DataIOController.readData(dataInfo.Name,...
                currentTime);
                this.View.switchPcDisplay(this.DataIdInView,data,limits,true,true);
            end


            displayObjAxes=this.View.getDisplayAxes();


            figToDisplayDialogs=this.View.getVisibleDataFig();
            this.Model.setUpEditOperation(editName,editPanel,isTemporal,displayObjAxes,figToDisplayDialogs)


            this.View.setSliderState(false);


            this.View.setHistoryPanelOptions(false);


            this.View.updateUndoRedoQAB(true,true);


            this.EditBeingUsed=editName;
        end


        function exitEditMode(this,evt)





            this.EditMode=false;

            if~evt.ToSave


                currentTime=this.View.getCurrentTime();
                dataInfo=this.Model.getDataInfo(this.DataIdInView);


                data=this.DataIOController.readData(dataInfo.Name,...
                currentTime);
                this.View.updateDisplayContent(this.DataIdInView,data);
            end

            if evt.ToSave


                this.Model.markDataAsEdited(this.DataIdInView);
                try

                    this.updateColorMapValues();


                    this.updateColorData();
                catch
                end
            end


            this.updateAnalysisPanel();


            this.View.updateUndoRedoQAB(true,true);


            this.Model.deleteEditStack(evt.ToSave,this.DataIdInView);


            this.View.setSliderState(true);


            this.View.resetHistoryPanel();


            this.ToExport=evt.ToSave;


            this.View.setToolstripVisualization();

        end


        function pointCloudChanging(this,evt)




            algoParams=evt.algoParam;
            isTemporal=evt.IsTemporal;
            pointCloudIn=evt.PointCloudIn;

            [isValid,pointCloudOut,selectedFrames]=this.Model.applyEdits...
            (evt.EditName,algoParams,pointCloudIn);


            if~isValid


                this.restoreDisplay();
            else
                if isTemporal


                    this.View.updateCurrentTimeWithFrameNum(selectedFrames(end));
                    pointCloudOut=pointCloudOut(selectedFrames(end));
                end
                data=lidar.internal.lidarViewer.lidarViewerIO.createFrameDataStruct(...
                pointCloudOut);

                if strcmp(evt.EditName,getString(message('lidar:lidarViewer:Crop')))
                    limits=this.Model.getGlobalLimits(this.DataIdInView);
                    this.View.switchPcDisplay(this.DataIdInView,data,limits,true);
                else
                    if~isempty(data)
                        this.View.updateDisplayContent(this.DataIdInView,data);
                    end
                end
            end


            this.EditModeCachedPtCld=pointCloudOut;
            this.SelectedFrames=selectedFrames;
            this.EditModeValidity=isValid;

            drawnow();
        end


        function pointCloudChanged(this,evt)



            this.View.wait();

            if evt.IsOKButton



                isValid=this.doUpdateAfterEditOperation(evt.EditName,evt.algoParam,...
                evt.IsTemporal,evt.PointCloudIn,evt.ToApplyOnAllFrames);
            else

                this.restoreDisplay(evt.EditName);


                this.View.resetEditPanelAfterOperation();


                this.View.setEditTabOptions(this.Model.isAnyFrameEdited());


                this.View.updateUndoRedoQAB(this.Model.isEditUndoStackEmpty,...
                this.Model.isEditRedoStackEmpty);


                this.View.setSliderState(true);


                this.View.setHistoryPanelOptions(~this.Model.isEditUndoStackEmpty());


                this.EditBeingUsed=string.empty;
                isValid=true;
            end


            this.EditModeCachedPtCld=pointCloud.empty;
            this.EditModeValidity=logical.empty;

            this.View.resume();

            if~isValid
                this.restoreDisplay();

                editPanel=this.View.getEditPanel();
                editName=evt.EditName;
                isTemporal=evt.IsTemporal;


                this.Model.setUpAlgorithmConfigurePanel(editName,editPanel,isTemporal);
            end
        end


        function requestToRevertEditsInCurrentFrame(this)





            data=this.Model.revertAllEditsOnCurrentFrame();


            this.View.updateDisplayContent(this.DataIdInView,data);


            this.View.setEditTabOptions(this.Model.isAnyFrameEdited());


            this.View.resetHistoryPanel();


            this.View.updateUndoRedoQAB(true,false);
        end


        function updateRequestForEdits(this,evt)




            fig=this.View.getVisibleDataFig();
            [toUpdate,spatialEditNames,temporalEditNames,customSpatialFuncNames,...
            customTemporalFuncNames]=this.Model.updateEdits(evt,fig);

            if toUpdate
                updateEditTS(this.View,spatialEditNames,temporalEditNames,...
                customSpatialFuncNames,customTemporalFuncNames);
            end
        end


        function requestToEditDataWithCustomFunction(this,evt)


            this.View.addTextForCustomFunctionInEditPanel(true);

            editName=char(evt.EditName);
            algoParams=struct();
            algoParams.IsClass=false;
            isTemporal=evt.IsTemporal;

            TF=0;
            if~isTemporal


                TF=this.View.getUserConfirmation(getString(message('lidar:lidarViewer:ApplyAllFramesMacro')));
                if~TF

                    this.View.addDefaultTextToEditPanel();
                    return;
                end
            end


            pointCloudIn=this.Model.getCurrentPointCloudInEditMode(isTemporal);


            [isValid,pointCloudOut,selectedFrames]=this.Model.applyEdits...
            (editName,algoParams,pointCloudIn);

            if~isValid
                return;
            end


            if isTemporal&&~isempty(selectedFrames)
                this.View.updateCurrentTimeWithFrameNum(selectedFrames(end));
                pointCloudOut=pointCloudOut(selectedFrames(end));
            end


            this.Model.updateCurrentPointCloudInEditMode(pointCloudOut);

            editData=lidar.internal.lidarViewer.edits.helper.createEditOpStruct(...
            editName,algoParams,isTemporal,selectedFrames,pointCloudIn);


            this.Model.saveEditParams(editData);


            [~,editData.Name,~]=fileparts(editData.Name);
            this.View.appendEditInHistoryPanel({editData});


            if TF==1&&~isTemporal
                this.Model.applyEditsOnAllFrames();
            end

            data=lidar.internal.lidarViewer.lidarViewerIO.createFrameDataStruct(...
            pointCloudOut);
            this.View.updateDisplayContent(this.DataIdInView,data);


            this.View.setEditTabOptions(true);


            this.View.updateUndoRedoQAB(this.Model.isEditUndoStackEmpty,...
            this.Model.isEditRedoStackEmpty);


            this.View.setSliderState(true);


            this.View.setHistoryPanelOptions(~this.Model.isEditUndoStackEmpty());

            this.View.addTextForCustomFunctionInEditPanel(false);
            this.View.addDefaultTextToEditPanel();
        end
    end




    methods(Access=private)
        function manageTimeStamps(this,dataId)


            timeStamps=this.Model.getTimeVectors(dataId);
            hasTimeInfo=this.Model.getHasTimingInfoFlag(dataId);
            this.View.setSliderTime(timeStamps,hasTimeInfo);
        end


        function frameChangeRequest(this,evt)


            currentTime=evt.CurrentTime;
            limits=this.Model.getGlobalLimits(...
            this.DataIdInView);


            if evt.IsPlayMode&&~this.InPlayMode



                this.disableAppOnPlay();
                this.InPlayMode=evt.IsPlayMode;

            elseif~evt.IsPlayMode&&this.InPlayMode



                this.enableAppOnPause();
                this.InPlayMode=evt.IsPlayMode;
                return;
            end


            dataInfo=this.Model.getDataInfo(this.DataIdInView);
            currentIndex=getCurrentIndex(this,currentTime);

            if this.MeasurementMode
                this.MeasurementManager.changeCurrentFrame(currentIndex);
            end


            if~this.EditMode




                data=this.DataIOController.readData(dataInfo.Name,...
                currentTime);

                if this.MeasurementMode
                    this.MeasurementUndoStack=this.MeasurementManager.MeasurementUndoStack{currentIndex};
                    this.MeasurementRedoStack=this.MeasurementManager.MeasurementRedoStack{currentIndex};
                end

                if~this.InPlayMode


                    if this.MeasurementMode

                        this.View.updateUndoRedoQAB(this.MeasurementManager.isMeasurementUndoStackEmpty(currentIndex),...
                        this.MeasurementManager.isMeasurementRedoStackEmpty(currentIndex));
                    end
                elseif this.InPlayMode
                    this.View.updateUndoRedoQAB(true,true);
                end
            else



                [isValid,pointCloudOut]=this.Model.readFrameFromEditStack(currentTime,true);

                data=lidar.internal.lidarViewer.lidarViewerIO.createFrameDataStruct(pointCloudOut);


                this.updateHistoryPanelAfterFrameChange();

                if~this.InPlayMode



                    this.View.updateUndoRedoQAB(this.Model.isEditUndoStackEmpty,...
                    this.Model.isEditRedoStackEmpty);
                end

                if~isValid


                    this.View.showMessageToUser(getString(message('lidar:lidarViewer:ErrorOnFrameChange')))
                end
            end

            if~isempty(data.PointCloud)


                this.View.updateDisplayContent(this.DataIdInView,data,limits,...
                this.MeasurementUndoStack);

                drawnow();
                if this.MeasurementMode
                    try
                        if isempty(this.CData{currentIndex})
                            this.updateColorData();
                        end
                    catch
                    end

                    if~this.InPlayMode

                        this.updateColorMapValues();
                    end
                end
            end

            if~isempty(data.PointCloud)&&...
                ~this.EditMode

                this.updateAnalysisPanel();

                if this.MeasurementMode

                    this.View.updateUndoRedoQAB(this.MeasurementManager.isMeasurementUndoStackEmpty(currentIndex),...
                    this.MeasurementManager.isMeasurementRedoStackEmpty(currentIndex));
                end

            end
        end
    end




    methods(Access=private)

        function requestToCloseApp(this)



            TF=confirmAppClosure(this);


            if~TF
                this.View.vetoAppClose();
            end
        end


        function resizeApp(this)

            this.View.resizeApp();
        end


        function undoRequest(this)


            currentTime=this.View.getCurrentTime();
            currentIndex=getCurrentIndex(this,currentTime);

            if this.EditMode
                if this.Model.isEditUndoStackEmpty()
                    return;
                end

                this.View.wait();


                ptCldOut=this.Model.doUndo(currentTime);


                data=lidar.internal.lidarViewer.lidarViewerIO.createFrameDataStruct(ptCldOut);
                this.View.updateDisplayContent(this.DataIdInView,data);


                this.View.updateHistoryPanelAfterUndo();


                this.View.updateUndoRedoQAB(this.Model.isEditUndoStackEmpty,...
                this.Model.isEditRedoStackEmpty);


                this.View.setEditTabOptions(this.Model.isAnyFrameEdited());

                this.View.resume();
            elseif this.MeasurementMode
                if this.MeasurementManager.isMeasurementUndoStackEmpty(currentIndex)
                    return;
                end


                this.MeasurementManager.doUndo();

                this.View.updateUndoRedoQAB(this.MeasurementManager.isMeasurementUndoStackEmpty(currentIndex),...
                this.MeasurementManager.isMeasurementRedoStackEmpty(currentIndex));
            end
        end


        function redoRequest(this)

            currentTime=this.View.getCurrentTime();
            currentIndex=getCurrentIndex(this,currentTime);

            if this.EditMode
                if this.Model.isEditRedoStackEmpty
                    return;
                end

                this.View.wait();


                [editOp,ptCld]=this.Model.doRedo(currentTime);


                data=lidar.internal.lidarViewer.lidarViewerIO.createFrameDataStruct(ptCld);
                this.View.updateDisplayContent(this.DataIdInView,data);


                this.View.appendEditInHistoryPanel({editOp});


                this.View.updateUndoRedoQAB(this.Model.isEditUndoStackEmpty,...
                this.Model.isEditRedoStackEmpty);


                this.View.setEditTabOptions(true);

                this.View.resume();
            elseif this.MeasurementMode
                if this.MeasurementManager.isMeasurementRedoStackEmpty(currentIndex)
                    return;
                end


                this.MeasurementManager.doRedo();


                this.View.updateUndoRedoQAB(this.MeasurementManager.isMeasurementUndoStackEmpty(currentIndex),...
                this.MeasurementManager.isMeasurementRedoStackEmpty(currentIndex));
            end
        end
    end




    methods(Access=private)
        function requestToDeleteData(this,evt)




            TF=this.promptToSaveData('deleteSignal');

            if TF



                dataId=this.Model.getDataIdFromName(evt.DataName);
                this.DataIOController.deleteData(evt.DataName);


                this.View.deleteTSState(dataId)

                if dataId==this.DataIdInView



                    this.DataIdInView=this.Model.getDataCount();

                    if this.DataIdInView



                        this.manageTimeStamps(this.DataIdInView);



                        this.View.toggleTSState(this.DataIdInView);
                        this.View.updateAfterSignalDeletion(evt);



                        currentTime=this.View.getCurrentTime();
                        dataInfo=this.Model.getDataInfo(this.DataIdInView);
                        data=this.DataIOController.readData(dataInfo.Name,...
                        currentTime);
                        this.View.updateDisplayContent(this.DataIdInView,data);


                        this.updateAnalysisPanel();
                    else

                        this.View.reset();
                    end

                    if this.MeasurementMode

                        this.updateColorMapValues();


                        this.updateColorData();
                    end



                    this.View.updateUndoRedoQAB(true,true);

                    if this.DataIdInView&&this.MeasurementMode
                        dataNew=this.Model.getDataInfo(this.DataIdInView);
                        currentTime=this.View.getCurrentTime();
                        currentIndex=getCurrentIndex(this,currentTime);
                        this.MeasurementManager.createMeasurementStacks(dataNew.NumFrames,currentIndex);
                    end

                else
                    if this.DataIdInView>dataId
                        this.DataIdInView=this.DataIdInView-1;
                    end

                    this.View.updateAfterSignalDeletion(evt);


                    this.updateColorMapValues();
                end
            end


        end


        function requestToToggleData(this,evt)



            saveTSState(this.View,this.DataIdInView);

            this.DataIdInView=...
            this.Model.getDataIdFromName(evt.DataName);



            this.manageTimeStamps(this.DataIdInView);


            this.View.updateAfterDataToggling(evt);


            timeStamps=this.Model.getTimeVectors(this.DataIdInView);
            currentTime=timeStamps(1);
            dataInfo=this.Model.getDataInfo(this.DataIdInView);
            data=this.DataIOController.readData(dataInfo.Name,...
            currentTime);
            this.View.updateDisplayContent(this.DataIdInView,data);


            this.View.toggleTSState(this.DataIdInView);


            updateAnalysisPanel(this);

            if this.MeasurementMode

                this.updateColorMapValues();


                this.updateColorData();
            end

            drawnow();
        end


        function updateAnalysisPanel(this)







            info=cell(7,1);

            dataInfo=this.Model.getDataInfo(this.DataIdInView);
            ptCldInDisp=this.View.getPtCldInDisplay();

            info{1}=dataInfo.Name;

            info{2}=dataInfo.SourceName;

            info{3}=ptCldInDisp.Count;

            info{4}=ptCldInDisp.XLimits;

            info{5}=ptCldInDisp.YLimits;

            info{6}=ptCldInDisp.ZLimits;

            info{7}=this.Model.getDataIndex(dataInfo.Name,this.View.getCurrentTime());

            info{8}=dataInfo.NumFrames;
            this.View.updateAnalysisPanel(info);
        end
    end





    methods(Hidden,Access=?lidar.internal.lidarViewer.LidarViewer)
        function loadSource(this,srcObj,info)

            this.DataIOController.addDataInModel(srcObj,info);
            this.View.resume();
        end

        function goToNextFrame(this)
            this.View.goToNextFrame();
        end

        function playOrPauseData(this)
            this.View.playOrPauseData();
        end

        function viewClusters(this,evt)

            this.View.setClusterData(evt)
            this.View.startColoringByClusters();
        end

        function enterEditTab(this)

            this.View.requestToEnterEditMode();
        end

        function exitEditTab(this,TF)

            evt=lidar.internal.lidarViewer.events.ExitEditModeEventData(TF);
            this.View.exitEditMode(evt);
        end

        function exportData(this,destinationFolder,toExport)

            this.DataIOController.exportDataInModel(destinationFolder,toExport);
        end

        function createAngleTool(this,pos,axesHandle)

            obj=lidar.internal.lidarViewer.measurementTool.tools.AngleTool();
            obj.createToolObj(pos,axesHandle);

            evt=lidar.internal.lidarViewer.events.MeasurementToolEventData(obj.ToolName,obj);
            this.addToolsInMeasurementStacks(evt);
        end
    end




    methods(Access=private)
        function TF=confirmAppClosure(this)


            if this.Model.getDataCount==0


                this.View.closeApp();
                TF=true;
                return;
            end


            TF=this.promptToSaveData('closeApp');

            if TF
                this.Model.clear();


                this.View.closeApp();
            end
        end


        function TF=isAnyDataEdited(this,dataName)


            TF=this.Model.isAnyDataEdited(dataName);
        end


        function TF=promptToSaveData(this,mode)







            if this.ToExport

                status=this.View.promptToSaveData();

                if status==1
                    this.doExport();
                end


                TF=(status>0);
            else

                TF=this.View.promptToConfirmAction(mode);
            end
        end


        function doExport(this)



            this.View.wait();
            anyFiletoBeExported=this.DataIOController.exportData();



            if~isempty(anyFiletoBeExported)
                this.ToExport=anyFiletoBeExported;
            end

            this.View.resume();
        end


        function isValid=doUpdateAfterEditOperation(this,editName,algoParams,...
            isTemporal,pointCloudIn,toApplyOnAllFrames)



            isValid=this.EditModeValidity;

            if~isValid


                return;
            end






            this.Model.updateCurrentPointCloudInEditMode(this.EditModeCachedPtCld(end));

            editData=lidar.internal.lidarViewer.edits.helper.createEditOpStruct(...
            editName,algoParams,isTemporal,this.SelectedFrames,pointCloudIn);


            this.Model.saveEditParams(editData);


            this.View.appendEditInHistoryPanel({editData});


            if toApplyOnAllFrames
                this.Model.applyEditsOnAllFrames();
            end


            this.View.setHistoryPanelOptions(false);
        end


        function handleExternalTriggers(this,evt)


            this.View.handleExternalTriggers(evt);
        end


        function updateHistoryPanelAfterFrameChange(this)


            this.View.resetHistoryPanel();
            editStack=this.Model.getEditsOnCurrentFrame();
            this.View.appendEditInHistoryPanel(editStack,this.InPlayMode);
        end


        function disableAppOnPlay(this)



            this.View.setToolstrip(false,this.EditMode);

            if this.EditMode



                this.View.updateUndoRedoQAB(true,true);


                this.View.setHistoryPanelOptions(false);
            else



                this.View.setDataBrowser(false);

                if this.MeasurementMode
                    this.View.setMeasurementToolstrip(false);
                end
            end
        end


        function enableAppOnPause(this)



            this.View.setToolstrip(true,this.EditMode);

            if this.EditMode

                this.View.updateUndoRedoQAB(this.Model.isEditUndoStackEmpty,...
                this.Model.isEditRedoStackEmpty);


                this.View.setEditTabOptions(this.Model.isAnyFrameEdited());


                this.View.setHistoryPanelOptions(~this.Model.isEditUndoStackEmpty());
            else
                if~this.MeasurementMode

                    this.View.setDataBrowser(true);
                else
                    this.View.setMeasurementToolstrip(true);
                end
            end
        end


        function restoreDisplay(this,varargin)



            pointCloudOut=this.Model.getCurrentPointCloudInEditMode();


            frame=lidar.internal.lidarViewer.lidarViewerIO.createFrameDataStruct(pointCloudOut);
            if nargin>1&&strcmp(varargin{1},getString(message('lidar:lidarViewer:Crop')))
                limits=this.Model.getGlobalLimits(...
                this.DataIdInView);
                this.View.switchPcDisplay(this.DataIdInView,frame,limits,false,true);
            else
                this.View.updateDisplayContent(this.DataIdInView,frame);
            end
        end


        function addToolsInMeasurementStacks(this,evt)


            currentTime=this.View.getCurrentTime();
            currentIndex=getCurrentIndex(this,currentTime);

            this.MeasurementManager.addToolsInStacks(currentIndex,evt);
            this.View.updateMeasurementUndoStack(this.MeasurementManager.MeasurementUndoStack{currentIndex});

            this.View.IsMeasurementTools(true);


            this.View.updateUndoRedoQAB(this.MeasurementManager.isMeasurementUndoStackEmpty(currentIndex),...
            this.MeasurementManager.isMeasurementRedoStackEmpty(currentIndex));

        end


        function resetMeasurementStacks(this)


            this.resetColorData();

            currentTime=this.View.getCurrentTime();
            currentIndex=getCurrentIndex(this,currentTime);


            this.View.viewGroundData();


            this.View.viewClusterData();

            this.View.IsMeasurementTools(false);

            axes=this.View.getDisplayAxes();
            if~isa(allchild(axes),'matlab.graphics.chart.primitive.Scatter')
                this.View.disableMeasurementTool();
            end


            this.updateClearSection();



            if numel(this.MeasurementManager.MeasurementUndoStack{currentIndex})==1
                this.MeasurementManager.resetStacks();
            else
                this.MeasurementManager.resetStacks(this.MeasurementManager.MeasurementUndoStack{currentIndex}{end});
            end


            this.View.updateUndoRedoQAB(this.MeasurementManager.isMeasurementUndoStackEmpty(currentIndex),...
            this.MeasurementManager.isMeasurementRedoStackEmpty(currentIndex));
        end


        function disableCancelMeasurement(this)


            this.View.disableMeasurementTool();
        end


        function getColor(this,evt)

            switch evt.ColorMap
            case 1
                this.ColorValue=[1,0,0];
            case 2
                this.ColorValue=[0,0,1];
            case 3
                this.ColorValue=[1,0,1];
            case 4
                this.ColorValue=[0,1,1];
            case 5
                this.ColorValue=[0,1,0];
            otherwise
                this.ColorValue=[1,1,0];
            end
            this.updateColorData();
        end


        function currentIndex=getCurrentIndex(this,currentTime)


            dataId=this.DataIdInView;
            data=this.Model.getDataInfo(dataId);
            dataName=data.Name;
            currentIndex=this.Model.getDataIndex(dataName,currentTime);
        end


        function resetColorData(this)


            axesHandle=this.View.getDisplayAxes();
            scatterPlot=findall(axesHandle.Children,'Tag','pcviewer');

            currentTime=this.View.getCurrentTime();
            currentIndex=getCurrentIndex(this,currentTime);

            if numel(scatterPlot)>1
                scatterPlot(1).CData=this.CData1{currentIndex};
                scatterPlot(2).CData=this.CData2{currentIndex};
            else
                scatterPlot.CData=this.CData{currentIndex};
            end

        end


        function deleteAllTools(this)


            this.View.disappearMeasurementTools();
        end


        function updateClearSection(this)

            this.View.updateClearSection();
        end


        function measurementToolCreateObject(this,evt)
            this.View.measurementToolCreateObject(evt);
        end


        function toolsDeleted(this)


            currentTime=this.View.getCurrentTime();
            currentIndex=getCurrentIndex(this,currentTime);

            ax=this.View.getDisplayAxes();

            if all(isa(ax.Children,'matlab.graphics.chart.primitive.Scatter'))
                this.View.IsMeasurementTools(false);
            end

            this.View.updateUndoRedoQAB(...
            this.MeasurementManager.isMeasurementUndoStackEmpty(currentIndex),...
            this.MeasurementManager.isMeasurementRedoStackEmpty(currentIndex));
        end


        function updateToolsInMeasurementStack(this,value,evt)
            if strcmp(value,'update')
                this.MeasurementManager.updateToolsInMeasurementStack(evt);
            elseif strcmp(value,'delete')
                this.MeasurementManager.deleteToolsInMeasurementStack(evt);
            end
        end


        function updateMeasurementUndoStack(this)
            currentTime=this.View.getCurrentTime();
            currentIndex=getCurrentIndex(this,currentTime);
            this.View.updateMeasurementUndoStack(this.MeasurementManager.MeasurementUndoStack{currentIndex});
            this.updateColorData();
        end


        function initializeColorData(this,numFrames)
            this.CData=cell(numFrames,1);
            this.CData1=cell(numFrames,1);
            this.CData2=cell(numFrames,1);
        end


        function updateColorMapValues(this)
            this.View.updateColorMapValues();
        end


        function updateColorData(this)
            if~this.MeasurementMode
                return;
            end

            try
                axesHandle=this.View.getDisplayAxes();
            catch
                return;
            end

            scatterPlot=findall(axesHandle.Children,'Tag','pcviewer');

            currentTime=this.View.getCurrentTime();
            currentIndex=getCurrentIndex(this,currentTime);

            if numel(scatterPlot)>1
                this.CData1{currentIndex}=scatterPlot(1).CData;
                this.CData2{currentIndex}=scatterPlot(2).CData;
            else
                this.CData{currentIndex}=scatterPlot(end).CData;
            end
        end
    end
end

