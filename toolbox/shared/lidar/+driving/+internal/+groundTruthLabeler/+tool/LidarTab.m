classdef LidarTab<vision.internal.uitools.NewAbstractTab2




    properties(Access=protected)

ColormapSection
CameraViewSection
CuboidSection
GroundSection
GroundSettings
ClusterSettings
LineSection
        WasEgoLastUsed=true;
    end

    properties(Access=private)
        ClusterVisualizationState=false;
BackgroundColor
    end

    properties
Container
    end
    events
ProjectedViewPressed
ColormapChanged
ViewChanged
LabelVisibilityChanged
CuboidSnappingChanged
HideGroundChanged
ClusterDataChanged
StartColoringByClusters
StopColoringByClusters
Line3DSnapChanged
BackgroundColorChanged
PlanarViewChanged
    end

    methods(Access=public)
        function this=LidarTab(tool)

            tabName=getString(message('vision:labeler:Lidar'));
            this@vision.internal.uitools.NewAbstractTab2(tool,tabName);

            this.Container=tool;
            this.createWidgets(getGroupName(tool));
            this.installListeners();


            this.BackgroundColor=[0,0,40/255];
        end

        function delete(this)
            delete(this.ClusterSettings);
            delete(this.GroundSettings);
            delete(this);
        end

        function testers=getTesters(this)%#ok<STOUT,MANU>

        end

        function enableControls(this)
            this.ColormapSection.Section.enableAll();
            this.CameraViewSection.Section.enableAll();
            this.GroundSection.enable();
        end

        function enableControlsForPlayback(this)
            enableControls(this);
        end

        function disableControls(this)
            this.ColormapSection.Section.disableAll();
            this.CameraViewSection.Section.disableAll();
            this.GroundSection.Section.disableAll();
        end

        function disableProjectedView(this)
            this.CameraViewSection.disable();
        end

        function switchOffProjectedView(this)
            this.CameraViewSection.switchOff();
        end

        function switchOnProjectedView(this)
            this.CameraViewSection.switchOn();
        end

        function enableProjectedView(this)
            this.CameraViewSection.enable();
        end

        function disableControlsForPlayback(this)
            disableControls(this);
        end

        function enableGroundSettings(this)
            enableGroundSettings(this.GroundSection);
        end

        function enableClusterSettings(this)
            enableClusterSettings(this.CuboidSection);
        end

        function disableColormapSection(this)
            this.ColormapSection.disable();
        end

        function enableColormapSection(this)
            this.ColormapSection.enable();
        end

        function enableCuboidSection(this)
            this.CuboidSection.enable();
        end

        function disableCuboidSection(this)
            this.CuboidSection.disable();
        end

        function enableLineSection(this)
            this.LineSection.enable();
        end

        function disableLineSection(this)
            this.LineSection.disable();
        end

        function changeClusterSettingsState(this,disableCuboidSection)
            if disableCuboidSection
                this.CuboidSection.ClusterData.Value=false;
                this.CuboidSection.disable;
            else
                if getClusteringStatus(this)
                    this.CuboidSection.ClusterData.Value=true;
                    this.CuboidSection.ShrinkCuboid.Value=false;
                else
                    this.CuboidSection.ClusterData.Value=false;
                end
                this.CuboidSection.enable;
                updateCuboidSectionControls(this);
                this.ClusterVisualizationState=getClusteringStatus(this);
            end

        end

        function refresh(this)


            doColormap(this);
            setBackGroundColor(this);
            doHideGround(this);
            doClusterData(this);
            doShrinkCuboid(this);

        end

        function updateNumClustersInClusterSettingsDialog(this,KMeansClusters)
            if~isempty(this.ClusterSettings.Dialog)&&isvalid(this.ClusterSettings.Dialog)
                this.ClusterSettings.Dialog.updateKMeansClusters(KMeansClusters);
            end
        end

    end


    methods
        function set.BackgroundColor(this,color)
            this.BackgroundColor=color;
            this.setBackGroundColor();
        end
    end

    methods(Access=protected)

        function doColormap(this)

            switch this.ColormapSection.Colormap.SelectedIndex
            case 1

                cmap=zeros([256,3]);
                cmap(1:128,1)=1;
                cmap(1:128,2)=linspace(0,1,128);
                cmap(1:128,3)=linspace(0,1,128);
                cmap(128:256,1)=linspace(1,0,129);
                cmap(128:256,2)=linspace(1,0,129);
                cmap(128:256,3)=1;
            case 2

                cmap=parula(256);
            case 3

                cmap=jet(256);
            case 4

                cmap=hot(256);
            case 5

                cmap=spring(256);
            otherwise
                assert(false,'Invalid colormap entry')
            end

            switch this.ColormapSection.ColormapValue.SelectedIndex
            case 1

                val='z';
            case 2

                val='radial';
            end

            evtData=driving.internal.groundTruthLabeler.tool.LidarColormapEventData(cmap,val);
            notify(this,'ColormapChanged',evtData);

        end

        function changeBackgroundColor(this)

            backgroundColor=uisetcolor(this.BackgroundColor,...
            getString(message('lidar:lidarViewer:SelectBackgroundColor')));


            this.BackgroundColor=backgroundColor;
        end

        function setBackGroundColor(this)



            this.ColormapSection.BackgroundColor.Icon=constructColorIconFromRGBTriplet(this.BackgroundColor,[24,24]);


            evt=driving.internal.groundTruthLabeler.tool.BackgroundColorChangeEventData(this.BackgroundColor);
            notify(this,'BackgroundColorChanged',evt);
        end

        function doProjectedView(this)
            evtData=driving.internal.groundTruthLabeler.tool.LidarProjectedViewEventData(logical(this.CameraViewSection.ProjectedView.Value));
            notify(this,'ProjectedViewPressed',evtData);
        end

        function doHomeView(this)
            cameraPosition=[];
            cameraTarget=[0,0,0];
            cameraUpVector=[0,0,1];
            cameraViewAngle=[];
            cameraAzimuthElevation=[-37.5,30];

            evtData=driving.internal.groundTruthLabeler.tool.LidarCameraViewEventData(cameraPosition,cameraTarget,cameraUpVector,cameraViewAngle,cameraAzimuthElevation);
            notify(this,'ViewChanged',evtData);
        end

        function doPlanarView(this,viewVal)

            evt=driving.internal.groundTruthLabeler.tool.StandardViewChangedEventData(viewVal);
            notify(this,'PlanarViewChanged',evt);
        end

        function doBirdsEyeView(this)
            cameraPosition=[20,0,50];
            cameraTarget=[0,0,0];
            cameraUpVector=[0,0,1];
            cameraViewAngle=90;
            cameraAzimuthElevation=[];

            evtData=driving.internal.groundTruthLabeler.tool.LidarCameraViewEventData(cameraPosition,cameraTarget,cameraUpVector,cameraViewAngle,cameraAzimuthElevation);
            notify(this,'ViewChanged',evtData);
        end

        function doChaseView(this)

            this.WasEgoLastUsed=false;

            switch this.CameraViewSection.EgoDirection.SelectedIndex
            case 1
                cameraPosition=[5,0,2];
            case 2
                cameraPosition=[-5,0,2];
            case 3
                cameraPosition=[0,5,2];
            case 4
                cameraPosition=[0,-5,2];
            end
            cameraTarget=[0,0,0];
            cameraUpVector=[0,0,1];
            cameraViewAngle=90;
            cameraAzimuthElevation=[];

            evtData=driving.internal.groundTruthLabeler.tool.LidarCameraViewEventData(cameraPosition,cameraTarget,cameraUpVector,cameraViewAngle,cameraAzimuthElevation);
            notify(this,'ViewChanged',evtData);
        end

        function doEgoView(this)

            this.WasEgoLastUsed=true;

            switch this.CameraViewSection.EgoDirection.SelectedIndex
            case 1
                cameraTarget=[1,0,0];
            case 2
                cameraTarget=[-1,0,0];
            case 3
                cameraTarget=[0,1,0];
            case 4
                cameraTarget=[0,-1,0];
            end
            cameraPosition=[0,0,0];
            cameraUpVector=[0,0,1];
            cameraViewAngle=150;
            cameraAzimuthElevation=[];

            evtData=driving.internal.groundTruthLabeler.tool.LidarCameraViewEventData(cameraPosition,cameraTarget,cameraUpVector,cameraViewAngle,cameraAzimuthElevation);
            notify(this,'ViewChanged',evtData);
        end

        function doEgoDirection(this)





            if this.WasEgoLastUsed
                doEgoView(this);
            else
                doChaseView(this);
            end

        end

        function doShrinkCuboid(this)
            if this.CuboidSection.ShrinkCuboid.Value
                if this.CuboidSection.ClusterData.Value
                    this.ClusterVisualizationState=getClusteringStatus(this);
                else
                    this.ClusterVisualizationState=this.ClusterVisualizationState||getClusteringStatus(this);
                end
                this.CuboidSection.ClusterData.Value=false;
                this.ClusterSettings.ClusterData=this.CuboidSection.ClusterData.Value;
                enableClusterSettings(this);
                enableColormapSection(this);
                hideClusterVisualization(this);
            end
            evtData=driving.internal.groundTruthLabeler.tool.CuboidSettingsEventData(logical(this.CuboidSection.ShrinkCuboid.Value));
            notify(this,'CuboidSnappingChanged',evtData);
        end

        function doSnapToPoint(this)
            evtData=driving.internal.groundTruthLabeler.tool.Line3DSettingsEventData(logical(this.LineSection.SnapToPoint.Value));
            notify(this,'Line3DSnapChanged',evtData);
        end

        function updateCuboidSectionControls(this)
            if this.CuboidSection.ShrinkCuboid.Value
                this.CuboidSection.ClusterData.Value=false;
                this.ClusterSettings.ClusterData=this.CuboidSection.ClusterData.Value;
                enableClusterSettings(this);
                enableColormapSection(this);
                hideClusterVisualization(this);
            end
            evtData=driving.internal.groundTruthLabeler.tool.CuboidSettingsEventData(logical(this.CuboidSection.ShrinkCuboid.Value));
            notify(this,'CuboidSnappingChanged',evtData);
        end

        function clusterStatus=getClusteringStatus(this)
            vlt=getParent(this);
            clusterStatus=vlt.getColorByCluster();
        end


        function hideClusterVisualization(this)
            vlt=getParent(this);
            isPCDataClustered=vlt.getColorByCluster();
            if isPCDataClustered
                notify(this,'StopColoringByClusters');
            end
        end

        function doHideGround(this)
            this.GroundSettings.ToolName=this.getParent.ToolType;
            this.GroundSettings.HideGround=this.GroundSection.HideGround.Value;
            enableGroundSettings(this);
        end

        function doHideGroundSettings(this)
            this.GroundSettings.ToolName=this.getParent.ToolType;
            open(this.GroundSettings);
        end

        function doHideGroundChanged(this,~,evt)
            notify(this,'HideGroundChanged',evt);
        end

        function doClusterData(this)
            this.ClusterSettings.ClusterData=this.CuboidSection.ClusterData.Value;
            if this.CuboidSection.ClusterData.Value
                this.CuboidSection.ShrinkCuboid.Value=false;
                if this.ClusterVisualizationState
                    startColoringByClusters(this)
                end

            else
                this.ClusterVisualizationState=getClusteringStatus(this);
                hideClusterVisualization(this);
                enableColormapSection(this);
            end
            enableClusterSettings(this);
        end

        function doClusterSettings(this)
            vlt=getParent(this);
            TF=vlt.getColorByCluster();
            display=vlt.DisplayManager.getSelectedDisplay;
            if display.SignalType==vision.labeler.loading.SignalType.PointCloud
                kMeansNumClusters=display.KMeansClusters;
            else
                kMeansNumClusters=0;
            end

            open(this.ClusterSettings,TF,kMeansNumClusters);
        end

        function doClusterChanged(this,~,evt)
            notify(this,'ClusterDataChanged',evt);
        end

        function startColoringByClusters(this)
            notify(this,'StartColoringByClusters');
            disableColormapSection(this);
        end

        function stopColoringByClusters(this)
            notify(this,'StopColoringByClusters');
            enableColormapSection(this);
        end

    end

    methods(Access=protected)

        function createWidgets(this,name)
            this.createColormapSection();
            this.createCameraViewSection();
            this.createGroundSection();
            this.createCuboidSection();
            this.createLineSection();
        end

        function createColormapSection(this)
            this.ColormapSection=driving.internal.groundTruthLabeler.tool.sections.LidarColormapSection;
            this.addSectionToTab(this.ColormapSection);
        end

        function createCameraViewSection(this)
            this.CameraViewSection=driving.internal.groundTruthLabeler.tool.sections.LidarCameraViewSection;
            this.addSectionToTab(this.CameraViewSection);
        end

        function createCuboidSection(this)
            this.CuboidSection=driving.internal.groundTruthLabeler.tool.sections.CuboidSection;
            this.addSectionToTab(this.CuboidSection);
            this.ClusterSettings=driving.internal.groundTruthLabeler.tool.ClusterSettings(this.Container);
        end

        function createLineSection(this)
            this.LineSection=driving.internal.groundTruthLabeler.tool.sections.LineSection;
            this.addSectionToTab(this.LineSection);
        end

        function createGroundSection(this)
            this.GroundSection=driving.internal.groundTruthLabeler.tool.sections.GroundSection;
            this.addSectionToTab(this.GroundSection);
            this.GroundSettings=driving.internal.groundTruthLabeler.tool.GroundSettings(this.Container);
        end


        function installListeners(this)
            this.installListenersColormapSection();
            this.installListenersProjectedViewSection();
            this.installListenersCameraViewSection();
            this.installListenersCuboidSection();
            this.installListenersGroundSection();
            this.installListenersLineSection();
        end

        function installListenersColormapSection(this)
            addlistener(this.ColormapSection.Colormap,'ValueChanged',@(~,~)this.doColormap);
            addlistener(this.ColormapSection.ColormapValue,'ValueChanged',@(~,~)this.doColormap);
            addlistener(this.ColormapSection.BackgroundColor,'ButtonPushed',@(~,~)this.changeBackgroundColor);
        end

        function installListenersProjectedViewSection(this)
            addlistener(this.CameraViewSection.ProjectedView,'ValueChanged',@(~,~)this.doProjectedView);
        end

        function installListenersCameraViewSection(this)
            addlistener(this.CameraViewSection.HomeView,'ButtonPushed',@(~,~)this.doHomeView);
            addlistener(this.CameraViewSection.XYView,'ButtonPushed',@(~,~)this.doPlanarView(1));
            addlistener(this.CameraViewSection.YZView,'ButtonPushed',@(~,~)this.doPlanarView(2));
            addlistener(this.CameraViewSection.XZView,'ButtonPushed',@(~,~)this.doPlanarView(3));
            addlistener(this.CameraViewSection.BirdsEyeView,'ButtonPushed',@(~,~)this.doBirdsEyeView);
            addlistener(this.CameraViewSection.ChaseView,'ButtonPushed',@(~,~)this.doChaseView);
            addlistener(this.CameraViewSection.EgoView,'ButtonPushed',@(~,~)this.doEgoView);
            addlistener(this.CameraViewSection.EgoDirection,'ValueChanged',@(~,~)this.doEgoDirection);
        end

        function installListenersCuboidSection(this)
            addlistener(this.CuboidSection.ShrinkCuboid,'ValueChanged',@(~,~)this.doShrinkCuboid);
            addlistener(this.CuboidSection.ClusterData,'ValueChanged',@(~,~)this.doClusterData);
            addlistener(this.CuboidSection.ClusterSettings,'ButtonPushed',@(~,~)this.doClusterSettings);
            addlistener(this.ClusterSettings,'ClusterSettingsChanged',@this.doClusterChanged);
            addlistener(this.ClusterSettings,'StartColoringByClusters',@(~,~)startColoringByClusters(this));
            addlistener(this.ClusterSettings,'StopColoringByClusters',@(~,~)stopColoringByClusters(this));
        end

        function installListenersGroundSection(this)
            addlistener(this.GroundSection.HideGround,'ValueChanged',@(~,~)this.doHideGround);
            addlistener(this.GroundSection.HideGroundSettings,'ButtonPushed',@(~,~)this.doHideGroundSettings);
            addlistener(this.GroundSettings,'GroundSettingsChanged',@this.doHideGroundChanged);
        end

        function installListenersLineSection(this)
            addlistener(this.LineSection.SnapToPoint,'ValueChanged',@(~,~)this.doSnapToPoint);
        end
    end

    methods



        function resetGroundSettingsOnNewSession(this)

            this.GroundSection.HideGround.Value=false;
        end
    end
end

function icon=constructColorIconFromRGBTriplet(rgbColor,iconSize)

    img=zeros([iconSize,3]);
    img(:,:,1)=rgbColor(1);
    img(:,:,2)=rgbColor(2);
    img(:,:,3)=rgbColor(3);

    icon=matlab.ui.internal.toolstrip.Icon(im2uint8(img));
end
