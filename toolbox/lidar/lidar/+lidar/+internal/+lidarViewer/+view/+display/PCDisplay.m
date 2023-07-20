






classdef PCDisplay<handle

    properties

Name

        OrganizedPC=false;

KMeansClusters
        ClusterData=false;
        ViewGroundData=false;
ViewHideGround
    end

    properties(Access=private)


        ParentFigure matlab.ui.Figure


Axes
Viewer
PreviousViewer
AxesToolbar



        MeasurementTool lidar.internal.lidarViewer.measurementTool.MeasurementTool
    end

    properties(Access=private)

        PointCloud pointCloud

Surface


Scalars


        PointSize=1;



        ColorMap=1;










        ColorMapVal=1;





        ColorVariation=1;

ColormapInternal

CustomVariationMap


PlanarView






SavedCameraViewNames



SavedCameraView


LimitsInternal


        GroundRemovedPointCloud=pointCloud.empty;

        GroundPointCloud=pointCloud.empty;

CustomColorVariationDialog

CustomVariationMapPrev

ColormapPrev

ClusterLabels

DefaultCameraPos

        MeasurementMode=false;

        ZoomInternal=1;
    end

    properties(Dependent)

ScatterPlot
CData


HideGroundData
GroundMode
ElevationAngleDelta
InitialElevationAngle
MaxDistance
ReferenceVector
MaxAngularDistance
GridResolution
ElevationThreshold
SlopeThreshold
MaxWindowRadius

DistanceThreshold
AngleThreshold
MinDistance

ColorByCluster
SnapToFit

ClusterMode
NumClusters
ToEnableCancel
    end

    properties(Access=protected)

        HideGroundDataInternal=false;
        GroundModeInternal='segmentGroundFromLidarData';

        ElevationAngleDeltaInternal=5;
        InitialElevationAngleInternal=30;

        MaxDistanceInternal=0.5;
        ReferenceVectorInternal=[0,0,1];
        MaxAngularDistanceInternal=5;

        GridResolutionInternal=1;
        ElevationThresholdInternal=0.5;
        SlopeThresholdInternal=0.15;
        MaxWindowRadiusInternal=18;


        ClusterModeInternal='segmentLidarData';
        DistanceThresholdInternal=5;
        AngleThresholdInternal=5;
        MinDistanceInternal=0.5;

        NumClustersInternal=0.1;
        CachedClusterState=logical.empty;

        ColorByClusterInternal=false;
        ViewHideGroundInternal=false;

        ColorPresent=false;
    end

    events
ExternalTrigger

DefaultCMapValSelected

DefaultCMapSelected

UserDrawingFinished

ObjectDeleted

DisableToolstrip

UpdateUndoRedoStack

DeleteFromUndoRedoStack

UpdateColorData

CustomColormapRequest

RequestToAddColor
    end

    methods



        function this=PCDisplay(parentFig,name,limits)

            this.ParentFigure=parentFig;

            this.Name=name;

            limits=this.validateLimits(limits);
            this.LimitsInternal=limits;
        end
    end




    methods

        function scatterPlot=get.ScatterPlot(this)

            scatterPlot=findall(this.Axes.Children,'Tag','pcviewer');
        end


        function TF=get.ToEnableCancel(this)


            if this.MeasurementTool.IsUserMeasuring

                TF=false;
            else

                TF=this.MeasurementTool.IsToolActive;
            end
        end


        function cData=get.CData(this)


            if this.ColorMap==6
                cData=this.getCDataColor;
                return;
            end

            switch this.ColorMapVal
            case 1
                cData=this.getCDataZHeight();
            case 2
                cData=this.getCDataRadial();
            case 3
                cData=this.getCDataIntensity();
            otherwise





                if isempty(this.Scalars)
                    cData=this.setDefaultCMapVal();
                    return;
                end


                [isValid,cData]=this.validateAndGetCDataFromScalars(...
                this.ColorMapVal-3);
                if~isValid
                    cData=this.setDefaultCMapVal();
                end

                cData=rescale(cData,1,256);
            end
        end


        function viewer=getViewer(this)
            if this.MeasurementMode
                viewer=this.Axes;
            else
                viewer=this.Viewer;
            end
        end


        function setColorParams(this,cmap,cmapValue,pointSize,backGroundColor)
            if(cmap~=this.ColorMap||cmapValue~=this.ColorMapVal)
                this.setColorData(cmap,cmapValue);
            end

            if this.PointSize~=pointSize
                this.setPointSize(pointSize);
            end

            if this.ParentFigure.Color~=backGroundColor
                this.changeBackgroundColor(backGroundColor);
            end
        end


        function[cmap,cmapValue,pointSize,backGroundColor]=getColorParams(this)
            cmap=this.ColorMap;
            cmapValue=this.ColorMapVal;
            pointSize=this.PointSize;
            backGroundColor=this.ParentFigure.Color;
        end


        function setPCInDisplay(this,frameData)



            this.MeasurementMode=false;
            this.PointCloud=frameData.PointCloud;

            pcdata=reshape(this.PointCloud.Location,[],3);

            this.attachPCDispalay(double(pcdata));
            if~(this.HideGroundDataInternal||this.ClusterData)
                this.setColorMap;
            end

            this.Surface.Parent.Position=this.ParentFigure.Position;

            if~isfield(frameData,'ScalarData')
                frameData.ScalarData=[];
            end
            this.Scalars=frameData.ScalarData;
            if this.HideGroundDataInternal||this.ClusterData
                displayGroundData(this);
            elseif~this.ViewHideGround
                this.GroundRemovedPointCloud=pointCloud.empty;
            end

            if isempty(this.GroundRemovedPointCloud)
                this.update(this.PointCloud);
            end
            if~ismatrix(this.PointCloud.Location)
                this.OrganizedPC=true;
            else
                this.OrganizedPC=false;
            end

            colorPresent=~isempty(this.PointCloud.Color);
            if~colorPresent&&this.ColorMap==6


                this.setDefaultCMap();

            elseif(this.ColorPresent&&~colorPresent)


                evt=lidar.internal.lidarViewer.events.ColorOptionRequestEventData(...
                colorPresent);
                notify(this,"RequestToAddColor",evt)
                this.ColorPresent=false;

            elseif(~this.ColorPresent&&colorPresent)


                evt=lidar.internal.lidarViewer.events.ColorOptionRequestEventData(...
                colorPresent);
                notify(this,"RequestToAddColor",evt)
                this.ColorPresent=true;
            end
        end




        function setPCShowInDisplay(this,frameData,limits)

            bgColor=this.ParentFigure.Color;
            if~isempty(this.Viewer)&&isvalid(this.Viewer)
                delete(this.Viewer);
                this.Viewer=[];
            end

            this.MeasurementMode=true;
            if isempty(this.Axes)||~isvalid(this.Axes)
                this.setUpPCShow();
                this.setAxisLimits(limits);
                this.Axes.Color=bgColor;
                this.ParentFigure.Color=bgColor;
            end

            this.MeasurementTool=lidar.internal.lidarViewer.measurementTool.MeasurementTool();
            addlistener(this.MeasurementTool,'UserDrawingFinished',@(~,~)notify(this,'UserDrawingFinished'));
            addlistener(this.MeasurementTool,'ObjectDeleted',@(~,~)notify(this,'ObjectDeleted'));
            addlistener(this.MeasurementTool,'DisableToolstrip',@(~,~)notify(this,'DisableToolstrip'));
            addlistener(this.MeasurementTool,'UpdateUndoRedoStack',@(~,evt)notify(this,'UpdateUndoRedoStack',evt));
            addlistener(this.MeasurementTool,'DeleteFromUndoRedoStack',@(~,evt)notify(this,'DeleteFromUndoRedoStack',evt));



            this.PointCloud=frameData.PointCloud;


            pointclouds.internal.pcui.utils.setAppData(this.ScatterPlot(end),'PointCloud',this.PointCloud);


            udata=pointclouds.internal.pcui.utils.getAppData(this.Axes,'PCUserData');
            udata.dataLimits=[this.PointCloud.XLimits,this.PointCloud.YLimits,this.PointCloud.ZLimits];
            pointclouds.internal.pcui.utils.setAppData(this.Axes,'PCUserData',udata);

            if~isfield(frameData,'ScalarData')
                frameData.ScalarData=[];
            end
            this.Scalars=frameData.ScalarData;
            if this.HideGroundDataInternal||this.ClusterData
                displayGroundData(this);
            elseif~this.ViewHideGround
                this.GroundRemovedPointCloud=pointCloud.empty;
            end

            if isempty(this.GroundRemovedPointCloud)
                this.update(this.PointCloud);
            end
            if~ismatrix(this.PointCloud.Location)
                this.OrganizedPC=true;
            else
                this.OrganizedPC=false;
            end
        end

        function storeDefaultCameraPos(this)




            pause(1);
            this.DefaultCameraPos=struct();
            this.DefaultCameraPos.CameraPosition=this.Viewer.CameraPosition;
            this.DefaultCameraPos.CameraTarget=this.Viewer.CameraTarget;
            this.DefaultCameraPos.CameraUpVector=this.Viewer.CameraUpVector;
            this.DefaultCameraPos.CameraZoom=this.Viewer.CameraZoom;
        end

        function displayGroundData(this)



            try
                if this.HideGroundDataInternal
                    switch this.GroundModeInternal
                    case 'segmentGroundFromLidarData'
                        if~ismatrix(this.PointCloud.Location)

                            groundPtsIdx=segmentGroundFromLidarData(this.PointCloud,...
                            'ElevationAngleDelta',this.ElevationAngleDeltaInternal,...
                            'InitialElevationAngle',this.InitialElevationAngleInternal);

                            this.GroundRemovedPointCloud=select(this.PointCloud,~groundPtsIdx,'OutputSize','full');
                            this.GroundPointCloud=select(this.PointCloud,groundPtsIdx,'OutputSize','full');
                        else
                            pcfitGroundPlaneRemoval(this);
                        end
                    case 'pcfitplane'

                        pcfitGroundPlaneRemoval(this);
                    otherwise
                        groundPtsIdx=segmentGroundSMRF(this.PointCloud,this.GridResolutionInternal,...
                        'MaxWindowRadius',this.MaxWindowRadiusInternal,...
                        'ElevationThreshold',this.ElevationThresholdInternal,...
                        'SlopeThreshold',this.SlopeThresholdInternal);
                        this.GroundRemovedPointCloud=select(this.PointCloud,~groundPtsIdx,'OutputSize','full');
                        this.GroundPointCloud=select(this.PointCloud,groundPtsIdx,'OutputSize','full');
                    end

                    if this.ClusterData
                        clusterLidarData(this);
                    end
                    if this.ViewHideGround
                        viewGroundDataRequest(this);
                    else
                        this.update(this.GroundRemovedPointCloud);
                    end
                else
                    if this.ClusterData
                        clusterLidarData(this);
                    else
                        this.ColorByClusterInternal=false;
                    end
                    if~this.ViewHideGround
                        this.GroundRemovedPointCloud=pointCloud.empty;
                        this.update(this.PointCloud);
                    else

                        if this.MeasurementMode
                            this.attachPCShowDispalay();
                            this.setColorMap();
                            this.setColorVariation();
                            this.update(this.PointCloud);
                        else
                            cameraPos=this.Viewer.CameraPosition;
                            cameraTar=this.Viewer.CameraTarget;
                            cameraUp=this.Viewer.CameraUpVector;
                            cameraZoom=this.Viewer.CameraZoom;

                            delete(this.Viewer);
                            data=double(reshape(this.PointCloud.Location,[],3));
                            this.attachPCDispalay(data);
                            this.setColorMap;
                            this.setColorVariation();

                            this.setCameraProperties(cameraPos,cameraTar,cameraUp,[],[],[])
                            this.Viewer.CameraZoom=cameraZoom;

                            this.ViewHideGround=true;
                        end
                        this.ViewHideGround=true;
                    end
                end
            catch
                if this.MeasurementMode
                    set(this.ScatterPlot(end),'XData',NaN,'YData',NaN,'ZData',NaN,'CData',0);
                end
            end
        end


        function clusterLidarData(this)





            try
                if this.HideGroundDataInternal&&this.ViewHideGroundInternal
                    this.stopViewGroundDataRequest();
                end

                if this.HideGroundDataInternal&&~isempty(this.GroundRemovedPointCloud)
                    pc=pointCloud(reshape(this.GroundRemovedPointCloud.Location,[],3));
                else
                    if this.MeasurementMode
                        pc=pointCloud(reshape(this.PointCloud.Location,[],3));
                    else
                        pc=pointCloud(this.Surface.Data);
                    end
                end

                switch this.ClusterModeInternal
                case 'segmentLidarData'

                    if~ismatrix(pc.Location)
                        labels=segmentLidarData(pc,this.DistanceThresholdInternal,this.AngleThresholdInternal);
                    else

                        labels=pcsegdist(pc,this.MinDistanceInternal);
                    end

                case 'pcsegdist'

                    labels=pcsegdist(pc,this.MinDistanceInternal);

                case 'imsegkmeans'

                    ptCloudLoc=this.Surface.Data;

                    labels=zeros(size(ptCloudLoc(:,1)));
                    nanPoints=isnan(ptCloudLoc(:,1))';

                    pcdata(:,:,1)=ptCloudLoc(~nanPoints,1);
                    pcdata(:,:,2)=ptCloudLoc(~nanPoints,2);
                    pcdata(:,:,3)=ptCloudLoc(~nanPoints,3);
                    pcdata=single(pcdata);

                    maxk=round(size(pcdata,1)/10);
                    k=max(1,ceil(this.NumClustersInternal*maxk));
                    this.KMeansClusters=k;
                    seg=imsegkmeans(pcdata,k,'NormalizeInput',false);
                    labels(~nanPoints)=seg;

                end

                if this.MeasurementMode
                    this.ScatterPlot(end).ClusterData=reshape(labels(:),[],1);
                else
                    this.ClusterLabels=reshape(labels(:),[],1);
                end

                if this.HideGroundDataInternal&&~isempty(this.GroundRemovedPointCloud)
                    update(this,this.GroundRemovedPointCloud);
                else
                    update(this,this.PointCloud);
                end
            catch
            end
        end


        function pcfitGroundPlaneRemoval(this)
            if(this.MaxDistanceInternal<0.05)||(this.MaxAngularDistanceInternal<0.05)
                warning('off','vision:ransac:maxTrialsReached')
                warning('off',"vision:pointcloud:notEnoughInliers")
            end
            warning('off',"vision:pointcloud:notEnoughInliers")
            [~,inlierPointsIdx,outlierPointsIdx]=pcfitplane(this.PointCloud,this.MaxDistanceInternal,this.ReferenceVectorInternal,this.MaxAngularDistanceInternal);
            warning('on','vision:ransac:maxTrialsReached')
            warning('on',"vision:pointcloud:notEnoughInliers")
            this.GroundRemovedPointCloud=select(this.PointCloud,outlierPointsIdx,'OutputSize','full');
            this.GroundPointCloud=select(this.PointCloud,inlierPointsIdx,'OutputSize','full');
        end


        function viewGroundDataRequest(this)




            if this.ClusterData
                this.ClusterData=false;
            end
            this.ViewHideGroundInternal=true;

            if this.MeasurementMode
                ptCloudA=this.GroundRemovedPointCloud;
                ptCloudB=this.GroundPointCloud;
                pos=this.Axes.CameraPosition;
                target=this.Axes.CameraTarget;
                up=this.Axes.CameraUpVector;
                ang=this.Axes.CameraViewAngle;
                azel=this.Axes.View;
                hObj=updatePointCloud(this,this.Axes,ptCloudA,this.PointSize,0.7,'first');
                hold(this.Axes,'on');
                this.updatePointCloud(this.Axes,ptCloudB,this.PointSize,0.7,'second');
                hold(this.Axes,'off');

                notify(this,'UpdateColorData');


                axis(this.Axes,'equal');


                initializePointCloudViewer(this,hObj);

                axtoolbar(this.Axes,...
                {'rotate','pan','zoomin','zoomout'},'Visible','on');
                this.setAxisLimits(this.LimitsInternal);
                p=this.ScatterPlot.addprop('ClusterData');

                rotate3d(this.Axes,'off');
                setCameraProperties(this,pos,target,up,ang,azel,[]);
            else
                ptCloudA=this.GroundRemovedPointCloud.Location;
                ptCloudB=this.GroundPointCloud.Location;
                ptCloudA=reshape(ptCloudA,[],3);
                ptCloudB=reshape(ptCloudB,[],3);

                cameraPos=this.Viewer.CameraPosition;
                cameraTar=this.Viewer.CameraTarget;
                cameraUp=this.Viewer.CameraUpVector;
                cameraZoom=this.Viewer.CameraZoom;

                delete(this.Viewer);


                this.attachPCDispalay(double(ptCloudA));
                indices=size(ptCloudA,1);
                C=repmat([0.4940,0.1840,0.5560],indices,1);
                this.Surface.Color=C;

                indices=size(ptCloudB,1);
                C=repmat([0,1,0],indices,1);

                images.ui.graphics3d.internal.Points(this.Viewer,'Data',double(ptCloudB),'Alpha',1,'PointSize',this.PointSize,'Color',C);

                this.setCameraProperties(cameraPos,cameraTar,cameraUp,[],[],cameraZoom)
                drawnow();
            end
            pause(1);
        end


        function stopViewGroundDataRequest(this)




            if this.MeasurementMode
                axesColor=this.Axes.Color;
                figureColor=this.ParentFigure.Color;
                pos=this.Axes.CameraPosition;
                target=this.Axes.CameraTarget;
                up=this.Axes.CameraUpVector;
                ang=this.Axes.CameraViewAngle;
                azel=this.Axes.View;
                this.setAxisLimits(this.LimitsInternal);
                this.attachPCShowDispalay();
                setCameraProperties(this,pos,target,up,ang,azel,this.ZoomInternal);
                this.Axes.Color=axesColor;
                this.ParentFigure.Color=figureColor;
                this.setColorMap();
                this.setColorVariation();
                this.update(this.GroundRemovedPointCloud);
            else
                ptCloud=this.GroundRemovedPointCloud.Location;
                ptCloud=reshape(ptCloud,[],3);

                cameraPos=this.Viewer.CameraPosition;
                cameraTar=this.Viewer.CameraTarget;
                cameraUp=this.Viewer.CameraUpVector;
                cameraZoom=this.Viewer.CameraZoom;

                delete(this.Viewer);
                this.attachPCDispalay(double(ptCloud));
                this.setColorMap();
                this.setColorVariation();

                this.setCameraProperties(cameraPos,cameraTar,cameraUp,[],[],cameraZoom)
                drawnow();
            end
            this.ViewHideGroundInternal=false;
        end


        function setGroundRemoval(this,TF,mode,varargin)

            this.GroundMode=mode;


            this.ElevationAngleDelta=varargin{1};
            this.InitialElevationAngle=varargin{2};


            this.MaxDistance=varargin{3};
            this.ReferenceVector=varargin{4};
            this.MaxAngularDistance=varargin{5};


            if nargin>8
                this.GridResolution=varargin{6};
                this.ElevationThreshold=varargin{7};
                this.SlopeThreshold=varargin{8};
                this.MaxWindowRadius=varargin{9};
            end

            this.HideGroundData=TF;

        end


        function setPointSize(this,sz)

            if sz<=0
                sz=1;
            end

            this.PointSize=sz;


            if~this.ViewHideGround
                if this.MeasurementMode
                    this.ScatterPlot.SizeData=sz;
                else
                    this.Surface.PointSize=sz;
                end
            else
                this.Viewer.Children(end).PointSize=sz;
                this.Viewer.Children(end-1).PointSize=sz;
            end
        end


        function setColorData(this,cmap,cmapVal,colorVariation)

            if cmap
                this.ColorMap=cmap;
            end

            if cmapVal
                this.ColorMapVal=cmapVal;
            end

            if colorVariation
                this.ColorVariation=colorVariation;
            end


            update(this,this.PointCloud);
            this.setColorVariation();
        end


        function setClusterData(this,TF,mode,dist,ang,mindist,k)

            this.ClusterMode=mode;


            this.DistanceThreshold=dist;
            this.AngleThreshold=ang;


            this.MinDistance=mindist;


            this.NumClusters=k;

            this.ClusterData=TF;
        end


        function changeBackgroundColor(this,backgroundColor)

            if~(all(size(backgroundColor)==[1,3])&&...
                all(backgroundColor>=0)&&...
                all(backgroundColor<=1))

                return;
            end

            if this.MeasurementMode
                this.Axes.Color=backgroundColor;
            else
                this.Surface.Parent.BackgroundColor=backgroundColor;
            end
            this.ParentFigure.Color=backgroundColor;
        end


        function setPlanarView(this,view)

            this.PlanarView=view;

            this.updatePlanarView();
        end


        function setDefaultView(this)



            if this.MeasurementMode
                resetplotview(this.Axes,'ApplyStoredView');



                this.setAxisLimits(this.LimitsInternal);
                this.Axes.XLimMode='manual';
                this.Axes.YLimMode='manual';
                this.Axes.ZLimMode='manual';

                axtoolbar(this.Axes,...
                {'rotate','pan','zoomin','zoomout'},'Visible','on');
            else
                this.Viewer.CameraUpVector=this.DefaultCameraPos.CameraUpVector;
                this.Viewer.CameraPosition=this.DefaultCameraPos.CameraPosition;
                this.Viewer.CameraTarget=this.DefaultCameraPos.CameraTarget;
                this.Viewer.CameraZoom=this.DefaultCameraPos.CameraZoom;
                drawnow;
            end
        end


        function setCameraProperties(this,pos,target,up,ang,azel,cZoom)


            if this.MeasurementMode
                ax=this.Axes;
                if isempty(azel)
                    set(ax,'CameraPosition',pos,'CameraTarget',target,...
                    'CameraUpVector',up);
                    if~isempty(ang)
                        set(ax,'CameraViewAngle',ang);
                    end

                else
                    set(ax,'CameraUpVector',up,'CameraViewAngleMode',...
                    'auto','View',azel);
                    drawnow;
                end
                if~isempty(cZoom)
                    zoom(ax,cZoom);
                end
            else
                ax=this.Viewer;
                if isempty(azel)
                    set(ax,'CameraPosition',pos,'CameraTarget',target,...
                    'CameraUpVector',up);
                else
                    set(ax,'CameraUpVector',up);
                    drawnow;
                end
                if~isempty(cZoom)
                    ax.CameraZoom=cZoom;
                else
                    ax.CameraZoom=this.ZoomInternal;
                end
            end
        end

        function[pos,target,up,ang,cZoom]=getCameraProperties(this)
            ang=[];
            cZoom=this.ZoomInternal;
            if this.MeasurementMode
                ax=this.Axes;
                ang=ax.CameraViewAngle;

            else
                ax=this.Viewer;
                cZoom=ax.CameraZoom;
                this.ZoomInternal=cZoom;
            end
            pos=ax.CameraPosition;
            target=ax.CameraTarget;
            up=ax.CameraUpVector;
        end


        function setCameraView(this,method,egoDirection)



            up=[0,0,1];
            switch method
            case 'BirdsEyeView'
                pos=[mean(this.PointCloud.XLimits),mean(this.PointCloud.YLimits),max(this.PointCloud.ZLimits)+0.5*(this.PointCloud.ZLimits(2)-this.PointCloud.ZLimits(1))];
                target=[mean(this.PointCloud.XLimits)-0.1,mean(this.PointCloud.YLimits),mean(this.PointCloud.ZLimits)];
                ang=90;
                if mean(this.PointCloud.XLimits)<1e5
                    z=10;
                else
                    z=2;
                end

            case 'ChaseView'
                groundPtsIdx=segmentGroundSMRF(this.PointCloud);
                groundPtCloud=select(this.PointCloud,groundPtsIdx);

                switch egoDirection

                case 1
                    pos=[mean(this.PointCloud.XLimits)+5...
                    ,mean(this.PointCloud.YLimits),mean(groundPtCloud.Location(:,3),"omitnan")+2];
                    target=[pos(1)-5,pos(2),pos(3)-2];

                case 2
                    pos=[sum(this.PointCloud.XLimits)/2-5...
                    ,sum(this.PointCloud.YLimits)/2,mean(groundPtCloud.Location(:,3),"omitnan")+2];
                    target=[pos(1)+5,pos(2),pos(3)-2];

                case 3
                    pos=[mean(this.PointCloud.XLimits)...
                    ,mean(this.PointCloud.YLimits)+5,mean(groundPtCloud.Location(:,3),"omitnan")+2];
                    target=[pos(1),pos(2)-5,pos(3)-2];

                case 4
                    pos=[mean(this.PointCloud.XLimits)...
                    ,mean(this.PointCloud.YLimits)-5,mean(groundPtCloud.Location(:,3),"omitnan")+2];
                    target=[pos(1),pos(2)+5,pos(3)-2];
                end
                ang=90;
                if mean(this.PointCloud.XLimits)<1e5
                    z=30;
                else
                    z=10;
                end


            case 'EgoView'
                groundPtsIdx=segmentGroundSMRF(this.PointCloud);
                groundPtCloud=select(this.PointCloud,groundPtsIdx);

                switch egoDirection
                case 1
                    pos=[mean(this.PointCloud.XLimits)+1...
                    ,mean(this.PointCloud.YLimits),min(groundPtCloud.Location(:,3))+2];
                    target=[pos(1)+1,pos(2),pos(3)];

                case 2
                    pos=[mean(this.PointCloud.XLimits)-1...
                    ,mean(this.PointCloud.YLimits),min(groundPtCloud.Location(:,3))+2];
                    target=[pos(1)-1,pos(2),pos(3)];

                case 3
                    pos=[mean(this.PointCloud.XLimits)...
                    ,mean(this.PointCloud.YLimits)+1,min(groundPtCloud.Location(:,3))+2];
                    target=[pos(1),pos(2)+1,pos(3)];

                case 4
                    pos=[mean(this.PointCloud.XLimits)...
                    ,mean(this.PointCloud.YLimits)-1,min(groundPtCloud.Location(:,3))+2];
                    target=[pos(1),pos(2)-1,pos(3)];
                end
                ang=150;
                if mean(this.PointCloud.XLimits)<1e5
                    z=30;
                else
                    z=10;
                end

            end
            if this.MeasurementMode
                this.Axes.CameraPositionMode="auto";
                this.Axes.CameraTargetMode="auto";

                set(this.Axes,'CameraPosition',pos,'CameraTarget',target,'CameraUpVector',up,'CameraViewAngle',ang);
                zoom(this.Axes,z);
            else
                set(this.Viewer,'CameraPosition',pos,'CameraTarget',target,'CameraUpVector',up,'CameraZoom',z);
            end

        end


        function axes=getAxes(this)

            axes=this.Axes;
        end


        function ptCld=getPtCldInDisplay(this)

            ptCld=this.PointCloud;
        end
    end





    methods

        function saveCameraView(this,viewName)


            this.SavedCameraViewNames{end+1}=viewName;

            cameraView=this.getCurrentView();

            this.SavedCameraView{end+1}=cameraView;
        end


        function savedViews=getSavedViewNames(this)


            savedViews=this.SavedCameraViewNames;
        end


        function deleteSavedView(this,viewName)



            for i=1:numel(this.SavedCameraViewNames)
                if isequal(this.SavedCameraViewNames{i},viewName)
                    break;
                end
            end

            this.SavedCameraView(i)=[];
            this.SavedCameraViewNames(i)=[];
        end


        function renameSavedView(this,oldName,newName)


            for i=1:numel(this.SavedCameraViewNames)
                if isequal(this.SavedCameraViewNames{i},oldName)
                    this.SavedCameraViewNames{i}=newName;
                    break;
                end
            end
        end


        function changeCameraView(this,viewId)

            cameraView=this.SavedCameraView{viewId};
            this.setView(cameraView);
        end


        function organizeCameraView(this,actions)

            for i=1:numel(actions)
                if(strcmp(actions{i}.Operation,'delete'))
                    this.deleteSavedView(actions{i}.Data);
                elseif(strcmp(actions{i}.Operation,'rename'))
                    this.renameSavedView(actions{i}.Data{1},actions{i}.Data{2});
                end
            end
        end

        function[cmap,variation,cmapVal]=getColorVariationInfo(this)
            cmap=this.ColormapInternal;
            variation=this.CustomVariationMap;
            cmapVal=256-rescale(this.CData,1,256);
        end


        function customColormapRequest(this,evt)
            if evt.DialogState==3
                this.CustomVariationMap=this.CustomVariationMapPrev;
                if~isempty(this.ColormapPrev)
                    if this.MeasurementMode
                        this.Axes.Colormap=this.ColormapPrev;
                    else
                        this.setColorFromCmap(this.ColormapPrev);
                    end
                else
                    this.CustomVariationMap=[];
                    this.CustomVariationMapPrev=[];
                    this.setColorMap();
                end
            elseif evt.DialogState==2

                this.CustomVariationMapPrev=evt.VariationMap;
                this.ColormapPrev=evt.Colormap;

                this.CustomVariationMap=evt.VariationMap;
                if this.MeasurementMode
                    this.Axes.Colormap=this.ColormapPrev;
                else
                    this.setColorFromCmap(evt.Colormap);
                end

            else
                this.CustomVariationMap=evt.VariationMap;
                if this.MeasurementMode
                    this.Axes.Colormap=evt.Colormap;
                else
                    this.setColorFromCmap(evt.Colormap);
                end
            end
        end

        function setColorFromCmap(this,cmap)
            index=this.normalizeCData(this.CData);
            nanPoints=isnan(index);
            index(isnan(index))=1;

            cpoints=cmap(index,:);
            cpoints(nanPoints,:)=zeros(nnz(nanPoints),3);
            this.Surface.Color=cpoints;
        end
    end




    methods
        function evt=doMeasureMetric(this,evt)

            evt=this.MeasurementTool.doMeasureMetric(evt,this.ColorMap);
        end


        function stopMeasuringMetric(this)

            this.MeasurementTool.stopMeasuringMetric();
        end


        function changeToolColor(this,cMap,axesHandle)

        end


        function measurementToolCreateObject(this,evt)
            this.MeasurementTool.measurementToolCreateObject(evt);
        end


        function stopCurrentTool(this)

            this.MeasurementTool.stopCurrentTool();
        end
    end




    methods(Access=private)

        function setUpPCShow(this)



            this.Axes=axes('Parent',this.ParentFigure,...
            'Units','normalized','Position',[0,0,1,1],'Color',[0,0,40/255]);



            this.attachPCShowDispalay();
            this.setColorMap();
            this.setColorVariation();
            drawnow();

            this.Axes.CameraTarget=this.DefaultCameraPos.CameraTarget;
            this.Axes.CameraPosition=this.DefaultCameraPos.CameraPosition;
        end


        function setAxisLimits(this,limits)
            if isvalid(this.Axes)

                this.Axes.XLim=1*limits(1:2);
                this.Axes.YLim=1*limits(3:4);
                this.Axes.ZLim=1*limits(5:6);
            end
        end


        function attachPCDispalay(this,varargin)


            if nargin>1
                data=varargin{1};
            else
                data=[NaN,NaN,NaN];
            end

            bgColor=this.ParentFigure.Color;
            if~isempty(this.Axes)&&isvalid(this.Axes)
                delete(this.Axes);
                this.Axes=[];
            end

            if isempty(this.Viewer)||isempty(this.ParentFigure.Children)||...
                (~isempty(this.Viewer)&&~isvalid(this.Viewer))
                this.Viewer=images.ui.graphics3d.Viewer3D(this.ParentFigure,'BackgroundColor',[0.0,0.0,0.0],'Position',this.ParentFigure.Position,'BackgroundGradient',false,'CameraZoom',1,'Tag','PCViewer3D');
                this.Viewer.Interactions={'rotate','zoom','pan','axes'};
                this.Viewer.BackgroundColor=bgColor;
            elseif~isempty(this.Viewer.Children)
                try
                    this.Surface.Data=data;
                catch
                end
                return;
            end
            this.Surface=images.ui.graphics3d.internal.Points(this.Viewer,'Data',data,'Alpha',1,'PointSize',this.PointSize);



            this.ColorPresent=~isempty(this.PointCloud.Color);
            evt=lidar.internal.lidarViewer.events.ColorOptionRequestEventData(...
            this.ColorPresent);
            notify(this,"RequestToAddColor",evt);
        end


        function attachPCShowDispalay(this)


            pcshow([NaN,NaN,NaN],Parent=this.Axes,MarkerSize=this.PointSize,...
            Projection="orthographic");


            initializePointCloudViewer(this,this.ScatterPlot);


            this.AxesToolbar=axtoolbar(this.Axes,...
            {'rotate','pan','zoomin','zoomout'},'Visible','on');
            this.setAxisLimits(this.LimitsInternal);

            set(this.Axes,'Color',[0,0,40/255]);
            set(this.ParentFigure,'Color',[0,0,40/255]);

            p=this.ScatterPlot.addprop('ClusterData');
            p.Hidden=true;
            p.Transient=true;


            rotate3d(this.Axes,'off');


            cMenu=findall(this.ParentFigure,'Tag','contextPCChangeColor');
            delete(cMenu);

            cMenu=findall(this.ParentFigure,'Tag','contextPCChangeBackground');
            delete(cMenu);

            cMenu=findall(this.ParentFigure,'Tag','contextPCChangeView');
            delete(cMenu);

            this.Axes.Toolbar.SelectionChangedFcn=@(src,evt)this.axToolbarSelectionChangedCallback(src,evt);


            addlistener(this.ParentFigure,'WindowScrollWheel',@(o,e)this.doScrollWheelCallBack(o,e));
            addlistener(this.ParentFigure,'WindowKeyPress',@(~,e)this.keyPressCallback(e));
            addlistener(this.ParentFigure,'WindowKeyRelease',@(~,e)this.keyPressCallback(e));
        end


        function doScrollWheelCallBack(this,o,e)

            pointclouds.internal.pcui.localScrollWheelCallback(o,e,this.ParentFigure);

        end

        function axToolbarSelectionChangedCallback(this,~,evt)
            child=this.Axes.Children;
            if evt.Selection.Value==0
                for i=1:numel(child)
                    if isa(child(i),'vision.roi.Polyline3D')||...
                        isa(child(i),'images.roi.Cuboid')||...
                        isa(child(i),'lidar.roi.Point3D')
                        child(i).InteractionsAllowed='all';
                    end
                end
                this.MeasurementTool.ToolbarChanged=false;
            else
                for i=1:numel(child)
                    if isa(child(i),'vision.roi.Polyline3D')||...
                        isa(child(i),'images.roi.Cuboid')||...
                        isa(child(i),'lidar.roi.Point3D')
                        child(i).InteractionsAllowed='none';
                    end
                end
                this.MeasurementTool.ToolbarChanged=true;
            end
        end


        function keyPressCallback(this,evt)
            modifierKeys={'shift'};

            keyPressed=evt.Key;
            modPressed=evt.Modifier;


            if strcmp(modPressed,modifierKeys(1))
                if isequal(keyPressed,'leftarrow')||isequal(keyPressed,'rightarrow')||...
                    isequal(keyPressed,'uparrow')||isequal(keyPressed,'downarrow')
                    pan(this.Axes,'on');
                end
            else
                pan(this.Axes,'off');
            end


            if any(strcmp(evt.Key,{'r'}))
                import matlab.graphics.interaction.internal.setPointer
                switch evt.EventName
                case 'WindowKeyPress'
                    hFigure=evt.Source;
                    newCursor='rotate';
                    setPointer(hFigure,newCursor);
                    rotate3d(this.Axes,'on','-orbit');
                case 'WindowKeyRelease'
                    rotate3d(this.Axes,'off');
                    hFigure=evt.Source;
                    newCursor='arrow';
                    setPointer(hFigure,newCursor);
                end
                return;
            end
        end


        function[XData,YData,ZData,CData]=getDataToDisplay(this,pointCloud)


            if this.MeasurementMode
                if ismatrix(pointCloud.Location)

                    XData=pointCloud.Location(:,1);
                    YData=pointCloud.Location(:,2);
                    ZData=pointCloud.Location(:,3);
                else

                    XData=reshape(pointCloud.Location(:,:,1),[],1);
                    YData=reshape(pointCloud.Location(:,:,2),[],1);
                    ZData=reshape(pointCloud.Location(:,:,3),[],1);
                end
            else
                XData=pointCloud.Location(:,1);
                YData=pointCloud.Location(:,2);
                ZData=pointCloud.Location(:,3);
            end


            if this.ColorByClusterInternal&&~isempty(this.ScatterPlot(end).ClusterData)
                CData=single(this.ScatterPlot(end).ClusterData)/single(max(this.ScatterPlot(end).ClusterData(:)));
            else


                CData=this.normalizeCData(this.CData);
            end
        end


        function update(this,pointCloud)





            if this.MeasurementMode


                [xData,yData,zData,cData]=this.getDataToDisplay(pointCloud);

                set(this.ScatterPlot(end),'XData',xData,'YData',yData,'ZData',...
                zData,'CData',cData);
                drawnow();

                this.MeasurementTool.updateAxes(this.Axes);
            else
                pcdata=reshape(pointCloud.Location,[],3);

                try
                    this.Surface.Data=double(pcdata);
                    this.setColorMap;
                catch
                end
            end
        end


        function setColorMap(this)

            if numel(this.PointCloud.Location)<=1
                return;
            end

            switch this.ColorMap
            case 1

                colorMap=zeros([256,3]);
                colorMap(1:128,1)=1;
                colorMap(1:128,2)=linspace(0,1,128);
                colorMap(1:128,3)=linspace(0,1,128);
                colorMap(128:256,1)=linspace(1,0,129);
                colorMap(128:256,2)=linspace(1,0,129);
                colorMap(128:256,3)=1;
            case 2
                colorMap=parula();
            case 3
                colorMap=jet();
            case 4
                colorMap=spring();
            case 5
                colorMap=hot();
            case 6
                colorMap=this.CData;
                if this.MeasurementMode||this.ColorMap~=6
                    return;
                else
                    if~(this.ColorByClusterInternal&&~isempty(this.ClusterLabels))
                        colorMap=reshape(colorMap,[],3);
                        cpoints=double(rescale(colorMap,0,1));
                        this.Surface.Color=cpoints;
                        return;
                    end
                end
            otherwise
                return;
            end

            this.ColormapInternal=colorMap;
            if~isempty(this.CustomVariationMap)
                colorMap=colorMap(fix(this.CustomVariationMap),:);
            end

            if this.MeasurementMode
                this.Axes.Colormap=colorMap;
            else
                if this.ColorByClusterInternal&&~isempty(this.ClusterLabels)
                    colorMap=hsv(256)';
                    colorMap=[colorMap(:,1:128);colorMap(:,129:256)];
                    colorMap=reshape(colorMap(:),[256,3]);
                    index=fix(rescale(this.ClusterLabels,1,256));
                else
                    index=this.normalizeCData(this.CData);
                end

                nanPoints=isnan(index);
                index(isnan(index))=1;
                cpoints=colorMap(index,:);
                cpoints(nanPoints,:)=zeros(nnz(nanPoints),3);
                this.Surface.Color=cpoints;
            end
        end

        function setColorVariation(this)

            switch this.ColorVariation
            case 1

                this.CustomVariationMap=[];
                this.CustomVariationMapPrev=[];
                this.ColormapPrev=[];
                this.setColorMap();
            case 2

            otherwise
                assert(false,'Not a valid colormap variation')
            end
        end


        function updatePlanarView(this)


            if this.MeasurementMode
                switch this.PlanarView
                case 1

                    view(this.Axes,0,90);
                case 2

                    view(this.Axes,90,0);
                case 3

                    view(this.Axes,0,0);
                end
                axtoolbar(this.Axes,...
                {'rotate','pan','zoomin','zoomout'},'Visible','on');
            else
                switch this.PlanarView
                case 1

                    this.Surface.Parent.CameraUpVector=[0,1,0];
                    this.Surface.Parent.CameraPosition=[mean(this.PointCloud.XLimits),mean(this.PointCloud.YLimits),max(this.PointCloud.ZLimits)+(this.PointCloud.ZLimits(2)-this.PointCloud.ZLimits(1))];
                    this.Surface.Parent.CameraTarget=[mean(this.PointCloud.XLimits),mean(this.PointCloud.YLimits)+0.1,mean(this.PointCloud.ZLimits)];
                case 2

                    this.Surface.Parent.CameraUpVector=[0,0,1];
                    this.Surface.Parent.CameraPosition=[mean(this.PointCloud.XLimits),mean(this.PointCloud.YLimits),min(this.PointCloud.ZLimits)];
                    this.Surface.Parent.CameraTarget=[mean(this.PointCloud.XLimits)-0.1*(this.PointCloud.XLimits(2)-this.PointCloud.XLimits(1)),mean(this.PointCloud.YLimits),min(this.PointCloud.ZLimits)+0.1];

                case 3

                    this.Surface.Parent.CameraUpVector=[0,0,1];
                    this.Surface.Parent.CameraPosition=[mean(this.PointCloud.XLimits),mean(this.PointCloud.YLimits),min(this.PointCloud.ZLimits)];
                    this.Surface.Parent.CameraTarget=[mean(this.PointCloud.XLimits),mean(this.PointCloud.YLimits)-0.1*(this.PointCloud.YLimits(2)-this.PointCloud.YLimits(1)),min(this.PointCloud.ZLimits)+0.1];
                end
                if mean(this.PointCloud.XLimits)<1e5
                    this.Surface.Parent.CameraZoom=3;
                else
                    this.Surface.Parent.CameraZoom=2;
                end
            end
        end


        function cameraView=getCurrentView(this)

            cameraView={this.Viewer.CameraPosition;...
            this.Viewer.CameraTarget;...
            this.Viewer.CameraUpVector;...
            this.Viewer.CameraZoom};
        end


        function setView(this,cameraView)

            this.Viewer.CameraPosition=cameraView{1};
            this.Viewer.CameraTarget=cameraView{2};
            this.Viewer.CameraUpVector=cameraView{3};
            this.Viewer.CameraZoom=cameraView{4};
        end


        function initializePointCloudViewer(this,hObj)

            params=struct();
            params.VerticalAxis='Z';
            params.VerticalAxisDir='Up';
            params.BackgroundColor=this.ParentFigure.Color;
            params.AxesVisibility='on';
            params.Projection='orthographic';
            params.PtCloudThreshold=[1920*1080,1e8];
            params.ColorSource='auto';
            params.ViewPlane='auto';
            pointclouds.internal.pcui.initializePCSceneControl(this.ParentFigure,this.Axes,hObj,params);
        end
    end




    methods(Access=private)
        function cData=getCDataZHeight(this)
            if this.MeasurementMode

                if ismatrix(this.PointCloud.Location)
                    cData=this.PointCloud.Location(:,3);
                else
                    cData=reshape(this.PointCloud.Location(:,:,3),[],1);
                end
            else
                ptCloudLoc=this.Surface.Data;
                cData=rescale(ptCloudLoc(:,3),1,256);
            end
        end


        function cData=getCDataRadial(this)
            if this.MeasurementMode
                if ismatrix(this.PointCloud.Location)
                    cData=vecnorm(this.PointCloud.Location(:,1:2),2,2);
                else
                    cData=reshape(vecnorm(this.PointCloud.Location(:,:,1:2),2,3),[],1);
                end
            else
                ptCloudLoc=this.Surface.Data;

                ptCloudLoc=vecnorm(ptCloudLoc(:,1:2),2,2);
                cData=rescale(ptCloudLoc,1,256);
            end
        end


        function cData=getCDataIntensity(this)
            if isempty(this.PointCloud.Intensity)
                cData=this.setDefaultCMapVal();
                return;
            end

            cData=reshape(this.PointCloud.Intensity,[],1);
            cData=rescale(cData,1,256);
        end


        function cData=getCDataColor(this)



            if isempty(this.PointCloud.Color)
                this.setDefaultCMap();
                cData=this.CData;
                return;
            end

            if ismatrix(this.PointCloud.Color)
                cData=this.PointCloud.Color;
            else
                cData=reshape(this.PointCloud.Color,[],3);
            end
        end


        function[isValid,cData]=validateAndGetCDataFromScalars(this,val)


            cData=[];
            isValid=false;
            if isempty(this.Scalars.Value{val})
                return;
            end


            cDataSize=size(this.Scalars.Value{val});
            ptLocSize=size(this.PointCloud.Location);

            if ismatrix(this.PointCloud.Location)

                ptLocSize=ptLocSize(1);
            else

                ptLocSize=ptLocSize(1)*ptLocSize(2);
            end

            if ismatrix(cDataSize)&&cDataSize(2)==1

                cDataSize=cDataSize(1);
            elseif ismatrix(cDataSize)

                cDataSize=cDataSize(1)*cDataSize(2);
            else

                cDataSize=cDataSize(1)*cDataSize(2);
            end

            if~isequal(ptLocSize,cDataSize)
                return;
            end
            isValid=true;
            cData=reshape(this.Scalars.Value{val},[],1);
        end


        function cData=setDefaultCMapVal(this)



            warningMessage=getString(message('lidar:lidarViewer:ScalarNotPresent'));
            warningTitle=getString(message('lidar:lidarViewer:Warning'));
            lidar.internal.lidarViewer.createAndNotifyExtTrigger(...
            this,'warningDialog',warningMessage,warningTitle);

            this.ColorMapVal=1;
            cData=this.getCDataZHeight();

            notify(this,'DefaultCMapValSelected');
        end


        function setDefaultCMap(this)




            warningMessage=getString(message('lidar:lidarViewer:ColorNotPresent'));
            warningTitle=getString(message('lidar:lidarViewer:Warning'));
            lidar.internal.lidarViewer.createAndNotifyExtTrigger(...
            this,'warningDialog',warningMessage,warningTitle);

            this.ColorMap=1;
            this.setColorMap();

            if this.ClusterData
                clusterLidarData(this);
            end
            if this.ViewHideGround
                viewGroundDataRequest(this);
            end

            notify(this,'DefaultCMapSelected');
        end

        function cData=normalizeCData(this,cData)
            sortedPts=sort(cData(~isnan(cData)));
            n=numel(sortedPts);
            if n>100
                cLim=[sortedPts(floor(0.02*n)),sortedPts(ceil(0.98*n))];
            else
                cLim=[min(sortedPts),max(sortedPts)];
            end

            if~isempty(cLim)&&this.ColorMap~=6

                cData=(cData-cLim(1))/(cLim(2)-cLim(1));
                cData(cData>1)=1;
                cData(cData<0)=0;
                cData=round(rescale(cData,1,256));
            end
        end
    end

    methods(Access=private,Static)

        function limits=validateLimits(limits)




            if~(limits(1)<limits(2))
                limits(2)=1.01*limits(1);
            end

            if~(limits(3)<limits(4))
                limits(4)=1.01*limits(3);
            end

            if~(limits(5)<limits(6))
                limits(6)=1.01*limits(5);
            end
        end
    end




    methods
        function set.ColorByCluster(this,TF)
            this.ColorByClusterInternal=TF;
            if TF&&this.MeasurementMode



                colorMap=hsv(256)';
                colorMap=[colorMap(:,1:128);colorMap(:,129:256)];
                colorMap=reshape(colorMap(:),[256,3]);
                index=fix(rescale(this.ClusterLabels,1,256));

                nanPoints=isnan(index);
                index(isnan(index))=1;
                cpoints=colorMap(index,:);
                cpoints(nanPoints,:)=zeros(nnz(nanPoints),3);
                set(this.Axes,'Colormap',colorMap);
                set(this.Axes.Children,'CData',cpoints);
            else
                this.setColorMap();
                drawnow();
                this.setColorVariation();
            end
            if this.HideGroundDataInternal
                update(this,this.GroundRemovedPointCloud);
            else
                update(this,this.PointCloud);
            end

        end

        function TF=get.ColorByCluster(this)
            TF=this.ColorByClusterInternal;
        end

        function set.ClusterData(this,TF)
            if TF
                clusterLidarData(this);
            end
            this.ClusterData=TF;
        end

        function TF=get.ClusterData(this)
            TF=this.ClusterData;
        end

        function set.ViewHideGround(this,TF)
            this.ViewHideGroundInternal=TF;
        end

        function TF=get.ViewHideGround(this)
            TF=this.ViewHideGroundInternal;
        end

        function set.HideGroundData(this,TF)
            this.HideGroundDataInternal=TF;
            displayGroundData(this);

            if~TF
                this.ViewHideGround=TF;
            end
        end

        function TF=get.HideGroundData(this)
            TF=this.HideGroundDataInternal;
        end

        function set.ElevationAngleDelta(this,val)
            this.ElevationAngleDeltaInternal=val;
        end

        function val=get.ElevationAngleDelta(this)
            val=this.ElevationAngleDeltaInternal;
        end

        function set.InitialElevationAngle(this,val)
            this.InitialElevationAngleInternal=val;
        end

        function val=get.InitialElevationAngle(this)
            val=this.InitialElevationAngleInternal;
        end

        function set.GroundMode(this,val)
            this.GroundModeInternal=val;
        end

        function val=get.GroundMode(this)
            val=this.GroundModeInternal;
        end

        function set.MaxDistance(this,val)
            this.MaxDistanceInternal=val;
        end

        function val=get.MaxDistance(this)
            val=this.MaxDistanceInternal;
        end

        function set.ReferenceVector(this,val)
            this.ReferenceVectorInternal=val;
        end

        function val=get.ReferenceVector(this)
            val=this.ReferenceVectorInternal;
        end

        function set.MaxAngularDistance(this,val)
            this.MaxAngularDistanceInternal=val;
        end

        function val=get.MaxAngularDistance(this)
            val=this.MaxAngularDistanceInternal;
        end

        function set.DistanceThreshold(this,val)
            this.DistanceThresholdInternal=val;
        end

        function val=get.DistanceThreshold(this)
            val=this.DistanceThresholdInternal;
        end

        function set.AngleThreshold(this,val)
            this.AngleThresholdInternal=val;
        end

        function val=get.AngleThreshold(this)
            val=this.AngleThresholdInternal;
        end

        function set.MinDistance(this,val)
            this.MinDistanceInternal=val;
        end

        function val=get.MinDistance(this)
            val=this.MinDistanceInternal;
        end

        function set.GridResolution(this,val)
            this.GridResolutionInternal=val;
        end

        function val=get.GridResolution(this)
            val=this.GridResolutionInternal;
        end

        function set.ElevationThreshold(this,val)
            this.ElevationThresholdInternal=val;
        end

        function val=get.ElevationThreshold(this)
            val=this.ElevationThresholdInternal;
        end

        function set.SlopeThreshold(this,val)
            this.SlopeThresholdInternal=val;
        end

        function val=get.SlopeThreshold(this)
            val=this.SlopeThresholdInternal;
        end

        function set.MaxWindowRadius(this,val)

            this.MaxWindowRadiusInternal=floor(val);
        end

        function val=get.MaxWindowRadius(this)

            val=floor(this.MaxWindowRadiusInternal);
        end

        function set.NumClusters(this,val)
            this.NumClustersInternal=val;
        end

        function val=get.NumClusters(this)
            val=this.NumClustersInternal;
        end

        function set.ClusterMode(this,val)
            this.ClusterModeInternal=val;
        end

        function val=get.ClusterMode(this)
            val=this.ClusterModeInternal;
        end



        function hObj=updatePointCloud(this,currentAxes,ptCloud,markerSize,blendFactor,colorAssignment)
            if ptCloud.Count>0
                C=this.getColorValues(ptCloud,blendFactor,colorAssignment);
                count=ptCloud.Count;
                X=ptCloud.Location(1:count);
                Y=ptCloud.Location(count+1:count*2);
                Z=ptCloud.Location(count*2+1:end);
                hObj=scatter3(currentAxes,X,Y,Z,markerSize,C,'.','Tag','pcviewer');
            end
        end


        function C=getColorValues(~,ptCloud,blendFactor,colorAssignment)


            if isempty(ptCloud.Color)
                if strcmpi(colorAssignment,'first')
                    if ismatrix(ptCloud.Location)
                        indices=size(ptCloud.Location,1);
                        C=repmat([0.4940,0.1840,0.5560],indices,1);
                    else
                        ptCloudReshape=reshape(ptCloud.Location(:,:,3),[],1);
                        indices=size(ptCloudReshape,1);
                        C=repmat([0.4940,0.1840,0.5560],indices,1);
                    end
                else
                    if ismatrix(ptCloud.Location)
                        indices=size(ptCloud.Location,1);
                        C=repmat([0,1,0],indices,1);
                    else
                        ptCloudReshape=reshape(ptCloud.Location(:,:,3),[],1);
                        indices=size(ptCloudReshape,1);
                        C=repmat([0,1,0],indices,1);
                    end
                end
            else
                C=im2double(ptCloud.Color);
                if~ismatrix(C)
                    C=reshape(C,[],3);
                end
                if strcmpi(colorAssignment,'first')
                    C(:,[1,3])=C(:,[1,3])*(1-blendFactor)+blendFactor;
                else
                    C(:,2)=C(:,2)*(1-blendFactor)+blendFactor;
                end
            end
        end
    end

    methods(Hidden,Access=?lidar.internal.lidarViewer.view.display.DisplayManager)


        function cpoints=getColorFromCustomColormap(this,cmap)
            index=this.normalizeCData(this.CData);
            nanPoints=isnan(index);
            index(isnan(index))=1;

            cpoints=cmap(index,:);
            cpoints(nanPoints,:)=zeros(nnz(nanPoints),3);
        end
    end
end
