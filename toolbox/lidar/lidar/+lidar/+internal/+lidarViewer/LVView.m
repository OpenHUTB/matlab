






classdef LVView<handle

    properties(SetAccess=private,GetAccess={?lidartest.apps.lidarViewer.LidarViewerAppTester,...
        ?LidarViewerPerformanceTester})

        Container lidar.internal.lidarViewer.view.LVAppContainer


        Toolstrip lidar.internal.lidarViewer.view.Toolstrip
    end

    properties(Access=private)


        DisplayManager lidar.internal.lidarViewer.view.display.DisplayManager


        Slider lidar.internal.lidarViewer.view.LVSlider


        DataBrowser lidar.internal.lidarViewer.view.LVDataBrowser


        AnalysisPanel lidar.internal.lidarViewer.view.LVAnalysisPanel


        HistoryPanel lidar.internal.lidarViewer.view.LVHistoryPanel

OldPCDisplay
    end

    properties(Access=private)
        MeasurementManager lidar.internal.lidarViewer.measurementTool.MeasurementManager
MeasurementUndoStack
    end

    properties(Access=private)




        DataIdInView(1,1)int32=0;

        EditMode(1,1)int32=false;

        MeasurementMode(1,1)int32=false;
    end

    properties
CamPos
CamTarget
CamUpVector
CamAngle
CamAzel
CameraZoom

PlanarViewType
    end

    methods



        function this=LVView()


            this.wireUpContainer();
            this.wireUpToolStrip();

            this.wait();

            addTabs(this.Container,this.Toolstrip.Tabs);
            open(this.Container);

            this.wireUpDisplay();
            this.wireUpDataBrowser();
            this.wireUpAnalysisPanel();
            this.wireUpHistoryPanel();
            this.wireUpMeasurementManager();

            this.Container.setDefaultLayout();

            this.wireUpSlider();

            this.resume();
        end


        function wait(this)

            wait(this.Container);
        end


        function resume(this)

            resume(this.Container);
        end


        function closeApp(this)

            this.Toolstrip.close();

            this.DisplayManager.closeAllDisplays(true);
            clear(this.DisplayManager);

            this.DataBrowser.reset();
            this.AnalysisPanel.reset();
            this.Slider.reset();
        end
    end




    events

RequestForNewSession
RequestToImportSignals
RequestToEditSignals
EditModeRequest
MeasurementModeRequest
RequestForDefaultLayout
RequestToExportSignals
HideGroundChanged
ClusterSettingsRequest
ClusterDataChanged
StartColoringByClusters
StopColoringByClusters
ViewGroundDataRequest
StopViewGroundDataRequest
ClusteringStatusRequest
HideGroundDataRequest
RequestToAddColor


RequestToExitEditMode
RequestToEditDataWithCustomFunction
RequestToUpdateEdits


CloseMeasurementTab
RequestForMeasurementTools
AddedMeasurementTool
RemoveMeasurementTool
ObjectDeleted
ColorChangeRequest
UpdateUndoRedoStack
DeleteFromUndoRedoStack
UpdateMeasurementUndoStack
DeleteAllMeasurementRequest
UpdateColorData


FrameChangeRequest


RequestToCloseApp
AppResized
RequestUndo
RequestRedo


RequestToToggleData
RequestToDeleteData


RequestToDiscardAllEdits
RequestToGenerateMacro

UpdateClearSection
    end




    methods(Access=private)

        function wireUpContainer(this)

            this.Container=lidar.internal.lidarViewer.view.LVAppContainer();
            addlistener(this.Container,'AppResized',@(~,~)notify(this,'AppResized'));
            addlistener(this.Container,'AppClosed',@(~,~)notify(this,'RequestToCloseApp'));
            addlistener(this.Container,'UndoRequest',@(~,~)notify(this,'RequestUndo'));
            addlistener(this.Container,'RedoRequest',@(~,~)notify(this,'RequestRedo'));
            addlistener(this.Container,'EscPressed',@(~,~)escapePressedFunction(this));

        end


        function wireUpToolStrip(this)
            this.Toolstrip=lidar.internal.lidarViewer.view.Toolstrip();

            addlistener(this.Toolstrip,'RequestToImportSignals',@(~,evt)tryLoadingSignals(this,evt));
            addlistener(this.Toolstrip,'RequestForNewSession',@(~,~)notify(this,'RequestForNewSession'));
            addlistener(this.Toolstrip,'ColorChangeRequest',@(~,evt)colorChangeRequest(this,evt));
            addlistener(this.Toolstrip,'BackgroundColorChangeRequest',@(~,evt)backgroundColorChangeRequest(this,evt));
            addlistener(this.Toolstrip,'PlanarViewChangeRequest',@(~,evt)planarViewChangeRequest(this,evt));
            addlistener(this.Toolstrip,'PointSizeChangeRequest',@(~,evt)pointSizeChangeRequest(this,evt));
            addlistener(this.Toolstrip,'EditModeRequest',@(~,~)requestToEnterEditMode(this));
            addlistener(this.Toolstrip,'MeasurementModeRequest',@(~,~)requestToEnterMeasurementMode(this));
            addlistener(this.Toolstrip,'RequestForDefaultLayout',@(~,~)requestForDefaultLayout(this));
            addlistener(this.Toolstrip,'RequestForCustomCameraOperation',@(~,evt)customCameraOperation(this,evt));
            addlistener(this.Toolstrip,'RequestToExportSignals',@(~,~)notify(this,'RequestToExportSignals'));

            addlistener(this.Toolstrip,'RequestToExitEditMode',@(~,evt)exitEditMode(this,evt));
            addlistener(this.Toolstrip,'CloseMeasurementTab',@(~,evt)exitMeasurementMode(this,evt));
            addlistener(this.Toolstrip,'RequestToEditSignals',@(~,evt)requestToEditSignal(this,evt));
            addlistener(this.Toolstrip,'RequestToEditDataWithCustomFunction',@(~,evt)notify(this,'RequestToEditDataWithCustomFunction',evt));
            addlistener(this.Toolstrip,'RequestToUpdateEdits',@(~,evt)notify(this,'RequestToUpdateEdits',evt));
            addlistener(this.Toolstrip,'CameraViewChangeRequest',@(~,evt)setCameraView(this,evt.Method,evt.EgoDirection));
            addlistener(this.Toolstrip,'DefaultViewChangeRequest',@(~,~)defaultViewChangeRequest(this));
            addlistener(this.Toolstrip,'HideGroundChanged',@(src,evt)setGroundRemoval(this,evt));
            addlistener(this.Toolstrip,'ExternalTrigger',@(~,evt)this.handleExternalTriggers(evt));
            addlistener(this.Toolstrip,'ClusterSettingsRequest',@(~,~)colorByCluster(this));
            addlistener(this.Toolstrip,'ClusterDataChanged',@(~,evt)setClusterData(this,evt));
            addlistener(this.Toolstrip,'StartColoringByClusters',@(~,~)startColoringByClusters(this));
            addlistener(this.Toolstrip,'StopColoringByClusters',@(~,~)stopColoringByClusters(this));
            addlistener(this.Toolstrip,'ViewGroundDataRequest',@(~,~)viewGroundDataRequest(this));
            addlistener(this.Toolstrip,'StopViewGroundDataRequest',@(~,~)stopViewGroundDataRequest(this));
            addlistener(this.Toolstrip,'ClusteringStatusRequest',@(~,~)doClusterData(this));
            addlistener(this.Toolstrip,'HideGroundDataRequest',@(~,~)doHideGround(this));
            addlistener(this.Toolstrip,'CustomColormapRequest',@(~,evt)customColormapRequest(this,evt));

            addlistener(this.Toolstrip,'RequestForMeasurementTools',@(~,evt)handleMeasurementTool(this,evt));
            addlistener(this.Toolstrip,'UpdateClearSection',@(~,~)this.updateClearSection());
            addlistener(this.Toolstrip,'DisableSlider',@(~,~)sliderState(this,false));
            addlistener(this.Toolstrip,'EnableSlider',@(~,~)sliderState(this,true));

        end


        function wireUpDisplay(this)
            dataFig=this.Container.DataFigure{1};

            this.DisplayManager=...
            lidar.internal.lidarViewer.view.display.DisplayManager(...
            dataFig,'Display');
            this.addDefaultTextToEmptyDisplay(dataFig);
            addlistener(this.DisplayManager,'ExternalTrigger',@(~,evt)handleExternalTriggers(this,evt));
            addlistener(this.DisplayManager,'DefaultCMapValSelected',@(~,~)this.Toolstrip.setDefaultCMapValText(this.EditMode));
            addlistener(this.DisplayManager,'DefaultCMapSelected',@(~,~)this.Toolstrip.setDefaultCMapText(this.EditMode));
            addlistener(this.DisplayManager,'UserDrawingFinished',@(~,~)this.Toolstrip.Measurement.measurementToolCompleted(true));
            addlistener(this.DisplayManager,'ObjectDeleted',@(~,~)this.toolsDeleted());
            addlistener(this.DisplayManager,'DisableToolstrip',@(~,~)this.Toolstrip.Measurement.disable());
            addlistener(this.DisplayManager,'UpdateUndoRedoStack',@(~,evt)notify(this,'UpdateUndoRedoStack',evt));
            addlistener(this.DisplayManager,'DeleteFromUndoRedoStack',@(~,evt)notify(this,'DeleteFromUndoRedoStack',evt));
            addlistener(this.DisplayManager,'UpdateColorData',@(~,~)notify(this,'UpdateColorData'));
            addlistener(this.DisplayManager,'UpdateUndoRedo',@(~,~)this.updateUndoRedoQAB(true,true));
            addlistener(this.DisplayManager,'RequestToAddColor',@(~,evt)this.addColorInColormap(evt));

        end


        function wireUpSlider(this)
            sliderFigure=this.Container.SliderFigure;
            this.Slider=lidar.internal.lidarViewer.view.LVSlider(sliderFigure);

            addlistener(this.Slider,'FrameChangeRequest',@(~,evt)notify(this,'FrameChangeRequest',evt));
        end


        function wireUpDataBrowser(this)
            dataBrowserFig=this.Container.DataBrowserFigure;
            this.DataBrowser=lidar.internal.lidarViewer.view.LVDataBrowser(dataBrowserFig);

            addlistener(this.DataBrowser,'RequestToDelete',@(~,evt)notify(this,'RequestToDeleteData',evt));
            addlistener(this.DataBrowser,'RequestToChangeSelection',@(~,evt)notify(this,'RequestToToggleData',evt));
        end


        function wireUpAnalysisPanel(this)
            analysisFigure=this.Container.AnalysisFigure;
            fieldList={getString(message('lidar:lidarViewer:SourceName'));...
            getString(message('lidar:lidarViewer:SourceType'));...
            getString(message('lidar:lidarViewer:PointsCount'));...
            getString(message('lidar:lidarViewer:XLim'));...
            getString(message('lidar:lidarViewer:YLim'));...
            getString(message('lidar:lidarViewer:ZLim'));...
            getString(message('lidar:lidarViewer:CurrentFrameIndex'));...
            getString(message('lidar:lidarViewer:NumberOfFrames'))};
            this.AnalysisPanel=lidar.internal.lidarViewer.view.LVAnalysisPanel(analysisFigure,fieldList);


        end


        function wireUpHistoryPanel(this)
            historyPanel=this.Container.HistoryFigure;
            this.HistoryPanel=lidar.internal.lidarViewer.view.LVHistoryPanel(historyPanel);

            addlistener(this.HistoryPanel,'RequestToDiscardAllEdits',@(~,~)notify(this,'RequestToDiscardAllEdits'));
            addlistener(this.HistoryPanel,'RequestToGenerateMacro',@(~,~)notify(this,'RequestToGenerateMacro'));
        end


        function wireUpMeasurementManager(this)
            this.MeasurementManager=lidar.internal.lidarViewer.measurementTool.MeasurementManager();
            addlistener(this.MeasurementManager,'CreateObject',@(~,evt)this.measurementToolCreateObject(evt));
        end
    end




    methods(Access=private)

        function tryLoadingSignals(this,evt)

            this.wait();
            this.updateUndoRedoQAB(true,true);
            notify(this,'RequestToImportSignals',evt);
            this.resume();
        end
    end




    methods(Hidden,Access=?lidar.internal.lidarViewer.LVController)



        function requestToEnterEditMode(this)



            this.updateUndoRedoQAB(true,true);
            this.wait();
            this.EditMode=true;
            this.DisplayManager.Displays{this.DataIdInView+1}.HideGroundData=false;
            this.DisplayManager.Displays{this.DataIdInView+1}.ColorByCluster=false;
            notify(this,'EditModeRequest');
            this.resume();
        end


        function requestToEnterMeasurementMode(this)


            this.updateUndoRedoQAB(true,true);
            this.wait();
            this.MeasurementMode=true;

            originalDisplay=this.DisplayManager.Displays{this.DataIdInView+1};
            [cmap,cmapValue,pointSize,backGroundColor]=originalDisplay.getColorParams();

            notify(this,'MeasurementModeRequest');

            newDisplay=this.DisplayManager.Displays{this.DataIdInView+1};
            newDisplay.setColorParams(cmap,cmapValue,pointSize,backGroundColor);

            if originalDisplay.ClusterData
                this.startColoringByClusters();
            end

            this.DataBrowser.setVisibility(false);
            this.resume();
        end


        function exitEditMode(this,evt)





            this.wait();
            this.EditMode=false;
            notify(this,'RequestToExitEditMode',evt);
            this.exitFromEditMode();

            this.resume();
        end


        function exitMeasurementMode(this,evt)





            this.wait();
            this.MeasurementMode=false;

            [this.CamPos,this.CamTarget,this.CamUpVector,this.CamAngle,this.CameraZoom]...
            =this.DisplayManager.getCameraProperties(this.DataIdInView);

            notify(this,'CloseMeasurementTab',evt);

            this.setCameraProperties();

            this.exitFromMeasurementMode();

            this.resume();
        end
    end

    methods(Access=private)

        function requestToEditSignal(this,evt)
            this.wait();
            this.Toolstrip.disableAlgorithmAndFinalizeSection();
            notify(this,'RequestToEditSignals',evt);
            this.resume();
        end
    end




    methods(Access=private)


        function selection=checkForMeasurementToolsDialogBox(this,msg)



            axes=this.getDisplayAxes();
            selection=[];
            if~all(isa(axes.Children,'matlab.graphics.chart.primitive.Scatter'))
                selection=uiconfirm(axes.Parent,msg,...
                getString(message('lidar:lidarViewer:ConfirmAction')),...
                'Options',{getString(message('MATLAB:uistring:popupdialogs:Yes')),...
                getString(message('MATLAB:uistring:popupdialogs:No'))});
            end
        end
    end




    methods

        function handleMeasurementTool(this,evt)
            if evt.ToCancel
                this.DisplayManager.stopMeasuringMetric(this.DataIdInView);
                notify(this,'RemoveMeasurementTool',evt);
            else
                this.updateUndoRedoQAB(true,true);
                evt=this.DisplayManager.doMeasureMetric(this.DataIdInView,evt);

                if isempty(evt.ToolObj)||all(~isvalid(evt.ToolObj.AllTools{end}))
                    return;
                end

                notify(this,'AddedMeasurementTool',evt);
            end
        end


        function escapePressedFunction(this)


            this.DisplayManager.stopCurrentTool(this.DataIdInView);
        end


        function disableMeasurementTool(this)


            if this.DataIdInView==0
                return;
            end

            this.DisplayManager.stopMeasuringMetric(this.DataIdInView);


            this.Toolstrip.Measurement.resetMeasurementToolSection();


            this.Toolstrip.Measurement.measurementToolCompleted(...
            this.DisplayManager.toEnableCancel(this.DataIdInView));
        end


        function IsMeasurementTools(this,TF)


            this.DataBrowser.IsMeasurementTools=TF;
        end


        function disappearMeasurementTools(this,~)


            if this.DataIdInView==0
                return;
            end

            axesHandle=this.getDisplayAxes();

            numOfScatter=0;

            for i=1:numel(axesHandle.Children)
                if isa(axesHandle.Children(i),'matlab.graphics.chart.primitive.Scatter')
                    numOfScatter=numOfScatter+1;
                end
            end

            if~isempty(allchild(axesHandle))
                if~isa(allchild(axesHandle),'matlab.graphics.chart.primitive.Scatter')
                    if numOfScatter==2
                        delete(axesHandle.Children(1:end-2));
                    elseif numOfScatter==1
                        delete(axesHandle.Children(1:end-1));
                    end
                end
            end
        end


        function updateMeasurementTools(this)



            this.disappearMeasurementTools();

            if~isempty(this.MeasurementUndoStack)
                totalROIs=this.MeasurementUndoStack{end};
                if~isempty(totalROIs)
                    for i=1:numel(totalROIs)
                        if numel(totalROIs)>1
                            this.MeasurementManager.createTool(totalROIs{i});
                        end
                    end
                end
            end
            this.updateClearSection();
        end


        function updateColorMapValues(this)
            if(this.DataIdInView==0)
                return;
            end

            try
                clusterData=this.DisplayManager.Displays{this.DataIdInView+1}.ClusterData;
            catch
                return;
            end

            if getViewGroundData(this)||this.Toolstrip.Home.ClusterVisualizationState
                this.Toolstrip.Home.resetColorAndColormapValue();
                if getViewGroundData(this)
                    this.Toolstrip.Home.ViewGroundData=true;
                end
                if clusterData
                    this.Toolstrip.Home.ClusterSettings.ClusterData=true;
                end
            else
                this.Toolstrip.Home.setColorAndColormapValue();
                if~getViewGroundData(this)
                    this.Toolstrip.Home.ViewGroundData=false;
                end
                if~clusterData
                    this.Toolstrip.Home.ClusterSettings.ClusterData=false;
                end
            end
        end


        function setToolstripVisualization(this)

            this.Toolstrip.Home.ClusterSettings.ClusterData=false;
            this.Toolstrip.Home.ViewGroundData=false;
        end


        function updateClearSection(this)


            try
                axesHandle=this.getDisplayAxes();
            catch
                return;
            end
            if~all(isa(axesHandle.Children,'matlab.graphics.chart.primitive.Scatter'))
                this.Toolstrip.Measurement.enableClearSection();
            else
                this.Toolstrip.Measurement.disableClearSection();
            end
        end


        function updateMeasurementUndoStack(this,measurementUndoStack)


            this.MeasurementUndoStack=measurementUndoStack;
        end


        function measurementToolCreateObject(this,evt)
            this.DisplayManager.measurementToolCreateObject(evt,this.DataIdInView);
        end


        function viewGroundData(this)
            if this.getViewGroundData
                this.DisplayManager.viewGroundDataRequest(this.DataIdInView);
            end
        end


        function viewClusterData(this)
            if this.Toolstrip.Home.ClusterVisualizationState
                this.startColoringByClusters();
            end
        end


        function sliderState(this,val)
            if val
                this.Slider.enable();
            else
                this.Slider.disable();
            end
        end

    end





    methods(Access=private)

        function colorChangeRequest(this,evt)

            cmap=evt.ColorMap;
            cmapVal=evt.ColorMapVal;
            colorVariation=evt.ColorVariation;
            this.DisplayManager.changeDisplayColor(cmap,cmapVal,colorVariation,this.DataIdInView);

            if colorVariation==2
                [colormapText,colormapValText]=this.Toolstrip.Home.getColormapAndColormapValText();
                [cmap,variation,cmapValData]=this.DisplayManager.getColorVariationInfo(this.DataIdInView);
                this.wait();
                if~this.EditMode
                    this.Toolstrip.Home.CustomColormapSettings.open(cmap,variation,cmapValData,colormapText,colormapValText);
                else
                    this.Toolstrip.Edit.CustomColormapSettings.open(cmap,variation,cmapValData,colormapText,colormapValText);
                end
                this.resume();
            end

            if~this.EditMode
                axesHandle=this.getDisplayAxes();
                this.DisplayManager.changeToolColor(this.DataIdInView,cmap,axesHandle);
                notify(this,'ColorChangeRequest',evt);
            end
        end


        function backgroundColorChangeRequest(this,evt)

            this.DisplayManager.changeBackgroundColor(this.DataIdInView,evt);
        end


        function planarViewChangeRequest(this,evt)

            this.DisplayManager.changePlanarView(this.DataIdInView,evt.View)
            this.PlanarViewType=evt.View;
        end


        function defaultViewChangeRequest(this)
            this.DisplayManager.setDefaultView(this.DataIdInView);
        end


        function pointSizeChangeRequest(this,evt)

            this.DisplayManager.changeDisplayPointSize(this.DataIdInView,...
            evt.PointSize);
        end


        function requestForDefaultLayout(this)


            numDisplays=this.getNumDisplays;
            if numDisplays==1

                this.Container.setDefaultLayout();
            else
                this.Container.setSingleGridLayout();
            end
        end


        function customCameraOperation(this,evt)



            this.wait();
            toUpdate=false;
            switch evt.OperationID
            case 1

                toUpdate=true;
                savedViews=this.saveCameraViewHelper();

            case 2

                toUpdate=true;
                savedViews=this.organizeCameraViewHelper();

            case 3

                if evt.ViewID==0

                    return;
                end
                this.DisplayManager.changeCameraView(this.DataIdInView,...
                evt.ViewID);
            end

            if toUpdate
                this.Toolstrip.updateCustomCameraPopup(savedViews);
            end
            this.resume();
        end


        function setCameraView(this,method,egoDirection)

            this.DisplayManager.setCameraView(this.DataIdInView,method,egoDirection);
            [this.CamPos,this.CamTarget,this.CamUpVector,this.CamAngle,this.CameraZoom]...
            =this.DisplayManager.getCameraProperties(this.DataIdInView);
        end

        function setCameraProperties(this)
            this.DisplayManager.setCameraProperties(this.DataIdInView,this.CamPos,...
            this.CamTarget,this.CamUpVector,this.CamAngle,this.CamAzel,this.CameraZoom);
        end


        function setGroundRemoval(this,evt)

            this.DisplayManager.setGroundRemoval(this.DataIdInView,evt);

            if this.MeasurementMode
                notify(this,'UpdateMeasurementUndoStack');
                this.updateMeasurementTools();
            end
        end


        function doHideGround(this)
            TF=getViewGroundData(this);
            GroundSettings=this.Toolstrip.Home.GroundSettings;
            open(GroundSettings,TF);
        end

        function customColormapRequest(this,evt)
            this.DisplayManager.customColormapRequest(evt,this.DataIdInView);

        end


        function isViewGroundData=getViewGroundData(this)
            dataId=this.DataIdInView;
            isViewGroundData=false;
            try
                isViewGroundData=isViewGroundData||this.DisplayManager.Displays{dataId+1}.ViewHideGround;
                this.DisplayManager.Displays{dataId+1}.ViewHideGround=isViewGroundData;
            catch
            end

            this.Toolstrip.Home.ViewGroundData=isViewGroundData;
        end



        function viewGroundDataRequest(this)
            this.DisplayManager.viewGroundDataRequest(this.DataIdInView);

            if this.MeasurementMode
                notify(this,'UpdateMeasurementUndoStack');
                this.updateMeasurementTools();
            end
        end



        function stopViewGroundDataRequest(this)
            this.DisplayManager.stopViewGroundDataRequest(this.DataIdInView);

            if this.MeasurementMode
                notify(this,'UpdateMeasurementUndoStack');
                this.updateMeasurementTools();
            end
        end



        function colorByCluster(this)
            dataId=this.DataIdInView;
            kMeansNumClusters=this.DisplayManager.Displays{dataId+1}.KMeansClusters;
            ClusterSettings=this.Toolstrip.Home.ClusterSettings;
            open(ClusterSettings,kMeansNumClusters);
        end



        function updateNumClustersInClusterSettingsDialog(this,KMeansClusters)
            if~isempty(this.Toolstrip.Home.ClusterSettings.Dialog)&&...
                isvalid(this.Toolstrip.Home.ClusterSettings.Dialog)
                this.Toolstrip.Home.ClusterSettings.Dialog.updateKMeansClusters(KMeansClusters);
            end
        end



        function stopColoringByClusters(this)
            this.DisplayManager.stopColoringByClusters(this.DataIdInView);

            if this.MeasurementMode
                notify(this,'UpdateMeasurementUndoStack');
                this.updateMeasurementTools();
            end
        end



        function doClusterData(this)
            if this.Toolstrip.Home.ClusterVisualizationState
                startColoringByClusters(this);
            end

            if this.MeasurementMode
                notify(this,'UpdateMeasurementUndoStack');
                this.updateMeasurementTools();
            end
        end



        function addColorInColormap(this,evt)

            this.Toolstrip.addColorInColormap(this.EditMode,evt.ColorPresent);
        end
    end




    methods
        function resizeApp(this)

            if~isempty(this.DataBrowser)
                this.DataBrowser.resize();
            end

            if~isempty(this.Slider)
                this.Slider.resize();
            end

            if~isempty(this.AnalysisPanel)
                this.AnalysisPanel.resize();
            end

            numDisplays=this.getNumDisplays;
            if numDisplays==1
                this.addDefaultTextToEmptyDisplay(this.Container.DataFigure{1});
            end
            drawnow();









        end
    end







    methods(Hidden,Access=?lidar.internal.lidarViewer.LVController)
        function setClusterData(this,evt)
            dataId=this.DataIdInView;
            this.DisplayManager.setClusterData(dataId,evt);
            if this.DisplayManager.Displays{dataId+1}.KMeansClusters
                kMeansNumClusters=this.DisplayManager.Displays{dataId+1}.KMeansClusters;
            else
                kMeansNumClusters=0;
            end
            this.updateNumClustersInClusterSettingsDialog(kMeansNumClusters);

            if this.Toolstrip.Home.ClusterSettings.ClusterData
                notify(this,'UpdateColorData');
            end
        end


        function startColoringByClusters(this)
            this.DisplayManager.startColoringByClusters(this.DataIdInView);

            if this.MeasurementMode
                notify(this,'UpdateMeasurementUndoStack');
                this.updateMeasurementTools();
            end
        end
    end

    methods(Hidden,Access=?matlab.uitest.TestCase)


        function cpoints=getColorFromCustomColormap(this,cmap)
            cpoints=this.DisplayManager.getColorFromCustomColormap(this.DataIdInView,cmap);
        end
    end




    methods
        function updateAnalysisPanel(this,info)

            this.AnalysisPanel.update(info);
        end
    end




    methods(Hidden,Access=?lidar.internal.lidarViewer.LVController)
        function goToNextFrame(this)

            this.Slider.nextFrameButtonPressed();
        end


        function playOrPauseData(this)


            this.Slider.playPauseButtonPressed();
        end
    end




    methods
        function appendEditInHistoryPanel(this,editData,isPlayMode)





            if nargin==2




                isPlayMode=false;
            end

            for i=1:numel(editData)
                if isfield(editData{i}.AlgoParams,'IsClass')
                    editData{i}.AlgoParams=rmfield(editData{i}.AlgoParams,'IsClass');

                    [~,editData{i}.Name,~]=fileparts(editData{i}.Name);
                end
            end
            this.HistoryPanel.append(editData,~isPlayMode);
        end


        function resetHistoryPanel(this)

            this.HistoryPanel.reset();
        end


        function updateHistoryPanelAfterUndo(this)


            this.HistoryPanel.discardLastEntry();
        end


        function updateUndoRedoQAB(this,isUndoEmpty,isRedoEmpty)


            this.Container.setUndoRedo(isUndoEmpty,isRedoEmpty);
        end
    end




    methods
        function createAndAddDisplay(this,dataName,limits)




            dataFig=this.Container.addDocumentFigures(dataName);


            this.DisplayManager.createAndAddDisplay(dataFig,true,dataName,limits);


            this.DataIdInView=this.getNumDisplays-1;


            this.Container.toggleDataDocument(this.DataIdInView+1)
        end


        function editModeUIChange(this)



            this.Container.changeToEditMode()


            this.Toolstrip.changeToEditTab();


            data.ColorMap=0;
            data.ColorMapVal=1;
            data.ColorVariation=0;
            this.colorChangeRequest(data);


            addDefaultTextToEditPanel(this);


            this.Toolstrip.setDefaultCMapValText(this.EditMode);
        end


        function measurementModeUIChange(this)



            this.Toolstrip.changeToMeasurementTab();

        end


        function updateDisplayContent(this,dataId,frameData,limits,measurementUndoStack)



            displayObj=this.DisplayManager.Displays{dataId+1};

            if this.MeasurementMode
                [this.CamPos,this.CamTarget,this.CamUpVector,this.CamAngle,this.CameraZoom]...
                =this.DisplayManager.getCameraProperties(this.DataIdInView);
                displayObj.setPCShowInDisplay(frameData,limits);

                setCameraProperties(this);

                this.disappearMeasurementTools();


                if nargin==5&&~isempty(measurementUndoStack)
                    this.MeasurementUndoStack=measurementUndoStack;

                    totalROIs=measurementUndoStack{end};
                    if~isempty(totalROIs)
                        for i=1:numel(totalROIs)
                            if numel(totalROIs)>1
                                this.MeasurementManager.createTool(totalROIs{i});
                            end
                        end
                    end
                end

                this.updateClearSection();
            else
                displayObj.setPCInDisplay(frameData);
            end
            this.Toolstrip.Home.GroundSettings.OrganizedPC=displayObj.OrganizedPC;

        end

        function storeDefaultCameraProperties(this,dataId)
            displayObj=this.DisplayManager.Displays{dataId+1};
            displayObj.storeDefaultCameraPos();
        end

        function switchPcDisplay(this,dataId,frameData,limits,isPcshow,varargin)

            displayObj=this.DisplayManager.Displays{dataId+1};

            if isPcshow
                if nargin>5
                    [this.CamPos,this.CamTarget,this.CamUpVector,this.CamAngle,this.CameraZoom]=...
                    this.DisplayManager.getCameraProperties(this.DataIdInView);
                end

                displayObj.setPCShowInDisplay(frameData,limits);

                if nargin>5

                    defaultViewChangeRequest(this);


                    setCameraProperties(this);
                end
            else
                [this.CamPos,this.CamTarget,this.CamUpVector,this.CamAngle,this.CameraZoom]...
                =this.DisplayManager.getCameraProperties(this.DataIdInView);

                displayObj.setPCInDisplay(frameData);


                this.setCameraProperties();
            end
            if nargin>5&&~isPcshow
                setCameraProperties(this);
            end
        end


        function panel=getEditPanel(this)

            panel=this.Container.EditFigure;
        end


        function numDisplays=getNumDisplays(this)


            numDisplays=this.DisplayManager.NumDisplays;
        end


        function setUpUIAfterDataManagement(this)





            numVisibleDisplay=this.getNumOfVisibleDisplay();
            TF=numVisibleDisplay>0;

            this.Toolstrip.Home.setNewSessionState(TF);
            this.Toolstrip.Home.setEditSection(TF);
            this.Toolstrip.Home.setMeasurementSection(TF);
            this.Toolstrip.Home.setVisualizeSection(TF);
            this.Toolstrip.Home.setExportSection(TF);

            if numVisibleDisplay==0


                this.Container.setDefaultLayout();
            else


                this.Container.setSingleGridLayout();
            end
        end


        function setSliderTime(this,timeStamps,hasTimingInfo)

            this.Slider.setTimeVector(timeStamps,hasTimingInfo);
        end


        function time=getCurrentTime(this)

            time=this.Slider.getCurrentTime();
        end


        function updateCurrentTimeWithFrameNum(this,frameNum)

            this.Slider.updateCurrentTimeWithFrameNum(frameNum);
        end


        function setEditTabOptions(this,isDataEdited)



            this.Toolstrip.setEditTabOptions(isDataEdited);
        end


        function setSliderState(this,state)

            this.Slider.setSliderState(state);
        end


        function addInDataBrowser(this,signalname)

            this.DataBrowser.insert(signalname);
        end


        function vetoAppClose(this)

            this.Container.vetoAppClose();
        end


        function fig=getVisibleDataFig(this)

            fig=this.Container.getVisibleDataFig;
        end


        function reset(this)

            if this.DataIdInView~=0

                this.Toolstrip.Home.BackGroundColor=[0,0,40/255];
            end

            this.DataIdInView=0;


            this.DisplayManager.closeAllDisplays(false);
            this.Container.resetDataFigures();


            this.DataBrowser.reset();


            this.Container.setDefaultLayout();


            colorPresent=false;
            evt=lidar.internal.lidarViewer.events.ColorOptionRequestEventData(...
            colorPresent);
            notify(this,"RequestToAddColor",evt);


            this.Toolstrip.Home.setNewSessionState(false);
            this.Toolstrip.Home.setDefaultVisualizationSection();
            this.Toolstrip.Home.setVisualizeSection(false);
            this.Toolstrip.Home.setEditSection(false);
            this.Toolstrip.Home.setExportSection(false);
            this.Toolstrip.Home.disableGroundAndClusterSettings();
            this.Toolstrip.Home.CustomColormapSettings.resetSettings();


            this.AnalysisPanel.reset();


            this.updateUndoRedoQAB(true,true);
        end


        function resetThisView(this)

            dataId=this.DataIdInView;
            delete(this.DisplayManager.Displays{dataId+1});
            this.DisplayManager.Displays=this.DisplayManager.Displays(1:end-1);
            this.Container.resetThisView();
        end


        function updateAfterSignalDeletion(this,evt)


            id=this.DisplayManager.getDisplayId(evt.DataName);


            this.DisplayManager.removeDisplay(evt.DataName);
            this.Container.deleteDataFigure(id);


            this.DataBrowser.remove(evt.DataName);

            if this.DataIdInView==(id-1)

                this.DataIdInView=this.getNumDisplays-1;

            elseif this.DataIdInView>=id


                this.DataIdInView=this.DataIdInView-1;
            end


            this.viewGroundData();


            this.setUpUIAfterDataManagement();
        end


        function updateAfterDataToggling(this,evt)



            id=this.DisplayManager.getDisplayId(evt.DataName);
            this.Container.toggleDataDocument(id);

            this.DataIdInView=id-1;


            this.setUpUIAfterDataManagement();
        end


        function updateEditTS(this,spatialEditNames,temporalEditNames,...
            customSpatialFuncNames,customTemporalFuncNames)


            this.Toolstrip.Edit.SpatialEditNames=spatialEditNames;
            this.Toolstrip.Edit.TemporalEditNames=temporalEditNames;
            this.Toolstrip.Edit.CustomSpatialFuncNames=customSpatialFuncNames;
            this.Toolstrip.Edit.CustomTemporalFuncNames=customTemporalFuncNames;
            this.Toolstrip.Edit.updateEditsGallery();
        end


        function ptCld=getPtCldInDisplay(this)


            ptCld=this.DisplayManager.getPtCldInDisplay(...
            this.DataIdInView);
        end


        function displayObj=getDisplayAxes(this)



            displayObj=this.DisplayManager.getDisplayAxes(this.DataIdInView);
        end


        function setToolstrip(this,TF,inEditMode)


            this.Toolstrip.setToolstrip(TF,inEditMode);
        end


        function setMeasurementToolstrip(this,TF)
            if TF
                this.Toolstrip.Measurement.enable();
                this.updateClearSection();
            else
                this.Toolstrip.Measurement.disable();
            end
        end


        function setDataBrowser(this,TF)
            this.DataBrowser.set(TF);
        end


        function setHistoryPanelOptions(this,TF)
            this.HistoryPanel.setOptions(TF);
        end


        function resetEditPanelAfterOperation(this)

            panel=this.getEditPanel();

            uga=panel.UserData{1};
            delete(uga.Children);

            ugb=panel.UserData{2};
            delete(ugb.Children);

            this.addDefaultTextToEditPanel();
        end

        function TF=getGroundOrClustersState(this)
            TF=this.Toolstrip.Home.ClusterSettings.ClusterData||...
            this.Toolstrip.Home.ViewGroundData;
        end
    end





    methods














        function setUpTS(this,varargin)




            this.Toolstrip.Home.setDefaultVisualizationSection();




            this.Toolstrip.updateColorOptions(varargin{1});
        end


        function saveTSState(this,signalId)



            this.Toolstrip.saveTSState(signalId);
        end


        function toggleTSState(this,signalId)



            this.Toolstrip.toggleTSState(signalId);
        end


        function deleteTSState(this,signalId)



            this.Toolstrip.deleteTSState(signalId);
        end
    end




    methods

        function status=promptToSaveData(this)

            fig=this.Container.getVisibleDataFig();
            answer=uiconfirm(fig,getString(message('lidar:lidarViewer:SaveDataMessage')),...
            getString(message('lidar:lidarViewer:SaveDataTitle')),...
            'Options',{getString(message('MATLAB:uistring:popupdialogs:Yes')),...
            getString(message('MATLAB:uistring:popupdialogs:No')),...
            getString(message('MATLAB:uistring:popupdialogs:Cancel'))});

            if strcmp(answer,getString(message('MATLAB:uistring:popupdialogs:No')))
                status=2;
            elseif strcmp(answer,getString(message('MATLAB:uistring:popupdialogs:Cancel')))
                status=0;
            else
                status=1;
            end
        end


        function TF=promptToConfirmAction(this,mode)


            switch mode
            case 'newSession'
                title=getString(message('lidar:lidarViewer:NewSessionDialogTitle'));
                question=getString(message('lidar:lidarViewer:NewSessionDialogMessage'));
            case 'deleteSignal'
                title=getString(message('lidar:lidarViewer:DeleteSignalDialogTitle'));
                question=getString(message('lidar:lidarViewer:DeleteSignalDialogMessage'));
            case 'closeApp'
                title=getString(message('lidar:lidarViewer:CloseAppDialogTitle'));
                question=getString(message('lidar:lidarViewer:CloseAppDialogMessage'));
            end

            fig=this.Container.getVisibleDataFig();
            answer=uiconfirm(fig,question,title,...
            'Options',{getString(message('MATLAB:uistring:popupdialogs:Yes')),...
            getString(message('MATLAB:uistring:popupdialogs:No'))});

            if strcmp(answer,getString(message('MATLAB:uistring:popupdialogs:No')))
                TF=false;
            else
                TF=true;
            end
        end


        function handleExternalTriggers(this,evt)


            fig=this.Container.getVisibleDataFig;
            persistent h
            switch evt.ExternalTriggerType
            case 1

                uialert(fig,evt.ExternalTriggerData.Message,...
                evt.ExternalTriggerData.Title);
            case 2


                if evt.ExternalTriggerData.Progress==0

                    h=uiprogressdlg(fig,'Message',evt.ExternalTriggerData.Message,...
                    'Title',evt.ExternalTriggerData.Title);
                    h.Value=0;
                    this.resume();
                elseif evt.ExternalTriggerData.Progress<1&&...
                    evt.ExternalTriggerData.Progress>0

                    if isvalid(h)
                        h.Value=evt.ExternalTriggerData.Progress;
                    end
                elseif evt.ExternalTriggerData.Progress==1

                    if isvalid(h)
                        close(h);
                    end
                    this.wait();
                elseif evt.ExternalTriggerData.Progress==-1

                    if~isvalid(h)
                        h=uiprogressdlg(fig,'Message',evt.ExternalTriggerData.Message,...
                        'Title',evt.ExternalTriggerData.Title,'Indeterminate','on');
                    end
                end
            case 3

                if~isunix
                    this.Container.App.bringToFront();
                end
            otherwise
                return;
            end
        end


        function TF=getUserConfirmation(this,msg,title)


            if nargin==1
                TF=false;
                return;
            end

            if nargin==2
                title='Confirm';
            end
            fig=this.Container.getVisibleDataFig;
            TF=uiconfirm(fig,msg,title,'Options',{getString(message('MATLAB:uistring:popupdialogs:Yes'))...
            ,getString(message('MATLAB:uistring:popupdialogs:No')),...
            getString(message('MATLAB:uistring:popupdialogs:Cancel'))});

            if strcmp(TF,getString(message('MATLAB:uistring:popupdialogs:Yes')))
                TF=1;
            elseif strcmp(TF,getString(message('MATLAB:uistring:popupdialogs:No')))
                TF=2;
            else
                TF=0;
            end
        end


        function showMessageToUser(this,msg)


            fig=this.Container.getVisibleDataFig;
            uialert(fig,msg,...
            getString(message('lidar:lidarViewer:Message')));
        end


        function addDefaultTextToEditPanel(this)



            ug=this.Container.EditFigure.UserData{1};


            ug.RowHeight={"fit"};
            ug.ColumnWidth={'1x'};

            defaultText=uilabel(ug,...
            'Text',getString(message('lidar:lidarViewer:EditPanelDefaultText')),...
            'WordWrap','on',...
            'FontColor',[0.45,0.45,0.45]);

            defaultText.Layout.Row=1;
            defaultText.Layout.Column=1;
        end


        function addTextForCustomFunctionInEditPanel(this,visiblility)



            ug=this.Container.EditFigure.UserData{1};

            delete(ug.Children);

            if~visiblility
                return;
            end


            ug.RowHeight={25,'1x',25};
            ug.ColumnWidth={25,'1x',25};

            defaultText=uilabel(ug,'WordWrap','on',...
            'Text',getString(message('lidar:lidarViewer:EditPanelDefaultTextCustomFunctions')),...
            'FontColor',[0.45,0.45,0.45]);

            defaultText.Layout.Row=2;
            defaultText.Layout.Column=2;
        end
    end




    methods(Access=private)

        function exitFromEditMode(this)



            this.Container.revertFromEditMode();


            this.Toolstrip.resetTSAfterEditMode();


            drawnow();
            this.Container.setDefaultLayout();


            this.Toolstrip.changeToHomeTab('Edit');
        end


        function exitFromMeasurementMode(this)



            this.Toolstrip.changeToHomeTab('Measurement');
            this.Toolstrip.toggleTSState(this.DataIdInView);
            this.DataBrowser.setVisibility(true);
        end


        function numDisp=getNumOfVisibleDisplay(this)


            numDisp=this.Container.getNumOfVisibleDisplay();
        end




        function savedViews=saveCameraViewHelper(this)



            savedViews=this.DisplayManager.getSavedViewNames(...
            this.DataIdInView);


            saveCameraDlg=lidar.internal.lidarViewer.view.dialog.SaveCameraDialog(...
            getString(message('lidar:lidarViewer:SaveCameraView')),...
            getString(message('lidar:lidarViewer:SaveCameraViewDlgText')),savedViews);


            open(saveCameraDlg);
            wait(saveCameraDlg);

            if~saveCameraDlg.IsSuccess
                return;
            end


            cameraViewName=saveCameraDlg.CamViewName;

            this.DisplayManager.saveCameraView(...
            this.DataIdInView,cameraViewName);

            savedViews=this.DisplayManager.getSavedViewNames(...
            this.DataIdInView);
        end


        function savedViews=organizeCameraViewHelper(this)



            savedViews=this.DisplayManager.getSavedViewNames(...
            this.DataIdInView);


            dlg=lidar.internal.lidarViewer.view.dialog.OrganizeDialog(...
            getString(message('lidar:lidarViewer:OrgCameraView')),...
            getString(message('lidar:lidarViewer:SavedCameraViews')),...
            savedViews);


            open(dlg);
            wait(dlg);
            dlgInfo=dlg.getUserAction();

            for i=1:numel(dlgInfo)

                if(strcmp(dlgInfo{i}.Operation,'delete'))
                    index=find(strcmp(savedViews,dlgInfo{i}.Data),1);
                    savedViews(index)=[];

                elseif(strcmp(dlgInfo{i}.Operation,'rename'))
                    index=find(strcmp(savedViews,dlgInfo{i}.Data{1}),1);
                    savedViews{index}=dlgInfo{i}.Data{2};

                end
            end

            this.DisplayManager.organizeCameraView(...
            this.DataIdInView,dlgInfo);
        end

        function addDefaultTextToEmptyDisplay(this,dataFig)


            delete(dataFig.Children);
            uilabel('Parent',dataFig,'Position',...
            [25,dataFig.Position(4)*0.9,dataFig.Position(3)*.75,25],...
            'Text',getString(message('lidar:lidarViewer:EmptyDisplayText')),...
            'FontColor',[0.45,0.45,0.45]);

        end


        function toolsDeleted(this)


            axes=this.getDisplayAxes();
            if all(isa(axes.Children,'matlab.graphics.chart.primitive.Scatter'))
                this.Toolstrip.Measurement.resetMeasurementToolSection();
                this.Toolstrip.Measurement.disableClearSection();
            end
            notify(this,'ObjectDeleted');
        end


        function TF=isMeasurementTools(this)


            TF=false;
            if this.DataIdInView==0
                return;
            end
            axesHandle=this.getDisplayAxes();
            if~all(isa(axesHandle.Children,'matlab.graphics.chart.primitive.Scatter'))
                TF=true;
            end
        end
    end
end


