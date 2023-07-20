classdef PointCloudDisplay<lidar.internal.labeler.tool.display.Display&matlab.mixin.SetGet




    properties(Dependent)

LabelVisible

SnapToFit
SnapToPoint

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

ClusterData
ClusterMode
DistanceThreshold
AngleThreshold
MinDistance
NumClusters

ColorByCluster

ProjectedView
    end

    properties(SetAccess=protected)
        CLim=[0,1];
    end

    properties(Access=protected)


ColormapInternal
        ColormapValueInternal='z';
BackgroundColorInternal


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
        ShowClusterForRectROI=true;

        PreviousLine=[];
        PreviousROI=[];
    end

    properties(Access=protected)

        PointCloud=pointCloud.empty;
        GroundRemovedPointCloud=pointCloud.empty;
HighlightScatter
ProjectedViewDisplay
        Listeners={};

    end

    properties
        IsCuboidSupported=true;
        IsPixelSupported=false;
        IsVoxelSupported=true;
    end

    properties(Dependent,Access=protected)
ShapeLabelers
SupprtedLabelers
    end

    properties(Access=private)

        XLim=[];
        YLim=[];
        ZLim=[];


        FramesTraversed=[];
    end

    properties(Access=public)
KMeansClusters
    end

    properties(Access=private)
        ProjectedViewInternal=false;
        PCFitGroundInfo=[];
    end


    events
ProjectedViewStatus
    end

    methods

        function this=PointCloudDisplay(hFig,nameDisplayedInTab)

            this=this@lidar.internal.labeler.tool.display.Display(hFig,nameDisplayedInTab);

            this.SignalType=vision.labeler.loading.SignalType.PointCloud;


            this.ColormapInternal=this.getRedToBlueColormap;


            this.BackgroundColorInternal=[0,0,40/255];

            addlistener(this.CuboidLabeler,'LabelIsChanged',@this.activateProjectedView);
            addlistener(this.CuboidLabeler,'LabelIsSelectedPre',@this.activateProjectedView);
            addlistener(this.CuboidLabeler,'LabelIsDeleted',@this.activateProjectedView);

            addlistener(this.Line3DLabeler,'LabelIsChanged',@this.activateProjectedView);
            addlistener(this.Line3DLabeler,'LabelIsSelectedPre',@this.activateProjectedView);
            addlistener(this.Line3DLabeler,'LabelIsDeleted',@this.activateProjectedView);




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


        function setClusterData(this,TF,mode,dist,ang,mindist,k)

            this.ClusterMode=mode;


            this.DistanceThreshold=dist;
            this.AngleThreshold=ang;


            this.MinDistance=mindist;


            this.NumClusters=k;

            this.ClusterData=TF;
        end


        function setColormap(this,cmap,val)



            if isempty(cmap)
                this.ColormapInternal=this.getRedToBlueColormap;
            else
                this.ColormapInternal=cmap;
            end
            this.ColormapValueInternal=validatestring(val,{'z','radial'});
            updateCLim(this,this.ImageHandle.XData,this.ImageHandle.YData,this.ImageHandle.ZData,true);

            if~isempty(this.PointCloud)&&~isempty(this.PointCloud.Color)&&...
                isempty(cmap)
                this.ColormapInternal=[];
                [X,Y,Z,CData]=this.getDataToDisplay(this.PointCloud);
                set(this.ImageHandle,'XData',X,'YData',Y,'ZData',Z,'CData',CData);
            end

            if this.ProjectedView
                src.CurrentROIs=this.selectCurrentROIs;
                this.activateProjectedView(src);
            end
        end


        function setBackgroundColor(this,backgroundColor)


            if~(all(size(backgroundColor)==[1,3])&&...
                all(backgroundColor>=0)&&...
                all(backgroundColor<=1))

                return;
            end

            this.BackgroundColorInternal=backgroundColor;
            this.AxesHandle.Color=backgroundColor;
            this.AxesHandle.Parent.BackgroundColor=backgroundColor;

            if this.ProjectedView
                src.CurrentROIs=this.selectCurrentROIs;
                this.activateProjectedView(src);
            end
        end


        function setCameraView(this,pos,target,up,ang,azel)


            if isempty(azel)
                set(this.AxesHandle,'CameraPosition',pos,'CameraTarget',target,...
                'CameraUpVector',up,'CameraViewAngle',ang);
            else
                set(this.AxesHandle,'CameraUpVector',up,'CameraViewAngleMode',...
                'auto','View',azel);

                if this.axisLimitsValid(this.XLim,this.YLim,this.ZLim)
                    this.AxesHandle.XLim=this.XLim;
                    this.AxesHandle.YLim=this.YLim;
                    this.AxesHandle.ZLim=this.ZLim;
                end
                drawnow;
            end
        end


        function setPlanarView(this,viewVal)

            switch viewVal
            case 1
                view(this.AxesHandle,0,90);
            case 2
                view(this.AxesHandle,90,0);
            case 3
                view(this.AxesHandle,0,0);
            end
        end



        function configure(this,...
            keyPressCallback,...
            labelChangedCallback,...
            roiInstanceSelectionCallback,...
            ~,...
            ~,...
            drawingStartedCallback,...
            drawingFinishedCallback,...
            ~,...
            ~,...
            multipleROIMovingCallback,...
            toolbarButtonChangedCallback,...
            pasteROIMenuCallback,...
            ~,...
            ~,...
            ~,...
            ~,...
            ~)

            this.Fig.KeyPressFcn=keyPressCallback;
            addlistener(this,'ROIsChanged',labelChangedCallback);
            addlistener(this,'ROISelected',roiInstanceSelectionCallback);


            for idx=1:numel(this.ShapeLabelers)
                this.ShapeLabelers(idx).wipeROIs();
                addlistener(this.ShapeLabelers(idx),'DrawingStarted',drawingStartedCallback);
                addlistener(this.ShapeLabelers(idx),'DrawingFinished',drawingFinishedCallback);
                addlistener(this.ShapeLabelers(idx),'MultiROIMoving',multipleROIMovingCallback);
            end
            this.ToolbarButtonChangedCallback=toolbarButtonChangedCallback;
            this.PasteROIMenuCallback=pasteROIMenuCallback;
        end


        function installContextMenu(this,~,~)
            if isempty(this.Fig.CurrentAxes.UIContextMenu)
                hCMenu=uicontextmenu('Parent',this.Fig,...
                'Tag','DisplayContextMenu');


                pasteUIMenu=uimenu(hCMenu,'Label',...
                getString(message('vision:trainingtool:PastePopup')),...
                'Callback',@this.PasteROIMenuCallback,'Accelerator','V',...
                'Tag','PasteContextMenu');

                if isempty(this.Clipboard)
                    set(pasteUIMenu,'Enable','off');
                end


                set(this.Fig.CurrentAxes,'UIContextMenu',hCMenu);
                this.ContextMenuCache=hCMenu;
            end
        end


        function setPasteMenuState(this,~,enableState)

            foundPaste=findall(get(this.Fig.CurrentAxes,'UIContextMenu'),...
            'Label',getString(message('vision:trainingtool:PastePopup')));
            set(foundPaste,'Enable',enableState);
        end


        function setPasteVisibility(this,visibleState)

            foundPaste=findall(get(this.Fig.CurrentAxes,'UIContextMenu'),...
            'Label',getString(message('vision:trainingtool:PastePopup')));
            set(foundPaste,'Visible',visibleState);
        end


        function setPasteContextMenuVisibility(this)
            if this.LabelingMode==lidarLabelType.Voxel
                setPasteVisibility(this,'off');
            else
                setPasteVisibility(this,'on');
            end

        end


        function addListenersToDisplayObject(this,pcListeners)

            this.Listeners=pcListeners;

        end


        function doMoveMultipleROI(this,varargin)
            limits=vertcat(this.XLim,this.YLim,this.ZLim);
            this.MultiShapeLabelers.doMoveMultipleCuboidROIs(this.ShapeLabelers,...
            limits,varargin{:});
        end


        function delete(this)



            cellfun(@(src)delete(src),this.Listeners);

        end


        function data=getEventDataFouVisualSummaryUpdate(~)

            data=[];
        end
    end

    methods
        function LabelerGroup=get.ShapeLabelers(this)
            LabelerGroup=[this.CuboidLabeler;this.Line3DLabeler];
        end

        function LabelerGroup=get.SupprtedLabelers(this)
            LabelerGroup=[this.CuboidLabeler;this.Line3DLabeler];
        end
    end

    methods(Hidden)

        function drawVoxelLabels(this,locations)
            drawVoxelROI(this.VoxelLabeler,locations);
        end


        function removeVoxelLabels(this,locations)
            clearVoxelROI(this.VoxelLabeler,locations);
        end
    end



    methods


        function finalize(this)
            this.VoxelLabeler.finalize();
        end


        function resetUndoRedoPixelOnLabDefDel(this)

        end

        function initializePixelLabeler(this)

        end


        function initializeVoxelLabeler(this)

            if this.isInvalidAxes()
                this.createAxes();
            end
            setHandles(this.VoxelLabeler,this.Fig,this.AxesHandle,this.ImageHandle);
        end


        function resetPixelLabeler(~,~)

        end

    end



























    methods


        function copiedROIsInGroup=getCopiedROIsInGroup(this)

            if isempty(this.Clipboard)
                copiedROIsInGroup=[];
                return;
            end

            rois=contents(this.Clipboard);


            CopiedCuboidROIs={};
            CopiedLine3DROIs={};

            for inx=1:numel(rois)

                if isempty(rois{inx})

                    continue
                end

                roiData=rois{inx}.UserData;




                shapeSpec=roiData{1};
                switch shapeSpec
                case 'cuboid'
                    CopiedCuboidROIs{end+1}=rois{inx};%#ok<AGROW>
                case 'line'
                    CopiedLine3DROIs{end+1}=rois{inx};%#ok<AGROW>
                otherwise
                    error('Undefined action for shape %s',roiData);
                end
            end

            copiedROIsInGroup.CopiedCuboidROIs=CopiedCuboidROIs;
            copiedROIsInGroup.CopiedLine3DROIs=CopiedLine3DROIs;
        end


        function pasteROIsInGroup(this,copiedROIsInGroup)
            if isempty(copiedROIsInGroup)
                return;
            end


            pasteSelectedROIs(this.CuboidLabeler,copiedROIsInGroup.CopiedCuboidROIs);

            pasteSelectedROIs(this.Line3DLabeler,copiedROIsInGroup.CopiedLine3DROIs);



            drawnow('limitrate');
        end


        function enablePasteFlag=copySelectedROIs(this,varargin)


            allrois=[];


            for lIdx=1:numel(this.ShapeLabelers)
                theserois=this.ShapeLabelers(lIdx).getSelectedROIsForCopy();
                allrois=[allrois,theserois];%#ok<AGROW>
            end


            parentrois=[];
            for idx=1:numel(allrois)
                thisparent=[];
                if~isempty(allrois{idx}.parentName)

                    parentID=allrois{idx}.UserData{3};
                    thisparent=this.CuboidLabeler.copyROIByID(parentID);
                end

                if~any(cellfun(@(x)isequal(x,thisparent),allrois))
                    parentrois=[parentrois,thisparent];%#ok<AGROW>
                end
            end


            for idx=1:numel(parentrois)
                allrois=[allrois,parentrois(idx)];%#ok<AGROW>
            end

            if~isempty(allrois)
                this.Clipboard.add(allrois);
            end

            enablePasteFlag=~isempty(this.Clipboard);
        end


        function pasteSelectedROIs(this,varargin)

            copiedROIsInGroup=getCopiedROIsInGroup(this);
            pasteROIsInGroup(this,copiedROIsInGroup);
        end


        function setSingleSelectedROIInstanceInfo(this,selectedROIinfo)
            if this.CuboidLabeler.hasSelectedROI
                selectedROIinfo.Type=labelType.Rectangle;
                this.CuboidLabeler.setSingleSelectedROIInstanceInfo(selectedROIinfo);
            elseif this.Line3DLabeler.hasSelectedROI
                selectedROIinfo.Type=labelType.Line;
                this.Line3DLabeler.setSingleSelectedROIInstanceInfo(selectedROIinfo);
            end

        end

    end




    methods(Access=protected)


        function data=overrideShape(~,data)


            if~isempty(data.Shapes)
                data.Shapes(data.Shapes==labelType.Rectangle)=labelType.Cuboid;
            end
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
                    end

                    displayPointCloud(this,this.GroundRemovedPointCloud);

                else

                    this.GroundRemovedPointCloud=pointCloud.empty;
                    displayPointCloud(this,this.PointCloud);

                end

            catch




                displayEmptyPointCloudOnError(this);
            end

            if this.ClusterData
                clusterLidarData(this);
            end

            if this.ProjectedView
                src.CurrentROIs=this.selectCurrentROIs();
                this.activateProjectedView(src);
            end
        end


        function clusterLidarData(this)





            try

                if this.HideGroundDataInternal&&~isempty(this.GroundRemovedPointCloud)
                    pc=this.GroundRemovedPointCloud;
                else
                    pc=this.PointCloud;
                end

                switch this.ClusterModeInternal
                case 'segmentLidarData'

                    if~ismatrix(this.PointCloud.Location)
                        labels=segmentLidarData(pc,this.DistanceThresholdInternal,this.AngleThresholdInternal);
                    else

                        labels=pcsegdist(pc,this.MinDistanceInternal);
                    end

                case 'pcsegdist'

                    if(this.MinDistanceInternal==0)
                        warndlg(vision.getMessage('vision:labeler:pcsegdistMinDistance'),'Warning','modal')
                    end
                    labels=pcsegdist(pc,this.MinDistanceInternal);

                case 'imsegkmeans'

                    labels=zeros(size(this.ImageHandle.XData))';
                    nanPoints=isnan(this.ImageHandle.XData);

                    pcdata(:,:,1)=this.ImageHandle.XData(~nanPoints)';
                    pcdata(:,:,2)=this.ImageHandle.YData(~nanPoints)';
                    pcdata(:,:,3)=this.ImageHandle.ZData(~nanPoints)';

                    maxk=round(size(pcdata,1)/10);
                    k=max(1,ceil(this.NumClustersInternal*maxk));
                    this.KMeansClusters=k;
                    seg=imsegkmeans(pcdata,k,'NormalizeInput',false);
                    labels(~nanPoints)=seg;

                end

                this.ImageHandle.ClusterData=labels(:);

                if this.HideGroundDataInternal&&~isempty(this.GroundRemovedPointCloud)
                    displayPointCloud(this,this.GroundRemovedPointCloud);
                else
                    displayPointCloud(this,this.PointCloud);
                end
            catch



                displayEmptyPointCloudOnError(this);
            end

        end


        function initialize(this)
            this.OrigFigUnit=this.Fig.Units;

            this.LabeledVideoUIObj=vision.internal.videoLabeler.tool.LabeledVideoUIContainer(this.Fig);
            this.ImagePanel=this.LabeledVideoUIObj.ImagePanel;


            this.Fig.Resize='on';


            this.Fig.BusyAction='cancel';
            this.Fig.Interruptible='off';


            this.Fig.Tag='Video';

            this.UndoRedoManagerShape=lidar.internal.labeler.tool.UndoRedoManagerShape();

            this.MultiShapeLabelers=vision.internal.labeler.tool.MultiShapeLabelers();
            this.CuboidLabeler=getCuboidLabeler(this);

            addlistener(this.CuboidLabeler,'LabelIsChanged',@this.doLabelIsChanged);
            addlistener(this.CuboidLabeler,'LabelIsSelected',@this.doLabelIsSelected);
            addlistener(this.CuboidLabeler,'LabelIsSelectedPre',@this.doLabelIsSelectedPre);
            addlistener(this.CuboidLabeler,'LabelIsDeleted',@this.doLabelIsDeleted);


            this.Line3DLabeler=getLine3DLabeler(this);

            addlistener(this.Line3DLabeler,'LabelIsChanged',@this.doLabelIsChanged);
            addlistener(this.Line3DLabeler,'LabelIsSelected',@this.doLabelIsSelected);
            addlistener(this.Line3DLabeler,'LabelIsSelectedPre',@this.doLabelIsSelectedPre);
            addlistener(this.Line3DLabeler,'LabelIsDeleted',@this.doLabelIsDeleted);


            this.VoxelLabeler=this.getVoxelLabeler;

            addlistener(this.VoxelLabeler,'LabelIsChanged',@(~,evt)this.drawImage(evt.Data));
            addlistener(this.VoxelLabeler,'LabelIsChanged',@(~,evt)this.doVoxelLabelChanged(evt.Data));
            addlistener(this.VoxelLabeler,'LabelIsSelected',@this.doLabelIsSelected);
            addlistener(this.VoxelLabeler,'LabelIsSelectedPre',@this.doLabelIsSelectedPre);
            addlistener(this.VoxelLabeler,'LabelIsDeleted',@this.doLabelIsDeleted);

            createAxes(this);


            wipeROIs(this);

            showHelperText(this,vision.getMessage('vision:labeler:VideoHelperText'));

            images.roi.internal.IPTROIPointerManager(this.Fig,[]);
            addlistener(this.Fig,'WindowMouseMotion',@(src,evt)this.mouseMotionCallback(src,evt));
        end


        function cuboidLabeler=getCuboidLabeler(~)
            cuboidLabeler=driving.internal.groundTruthLabeler.tool.CuboidLabeler();
        end


        function line3DLabeler=getLine3DLabeler(~)
            line3DLabeler=driving.internal.groundTruthLabeler.tool.Line3DLabeler();
        end


        function voxelLabeler=getVoxelLabeler(~)
            voxelLabeler=lidar.internal.lidarLabeler.tool.VoxelLabeler();
        end


        function doLabelIsSelectedPre(this,varargin)
            this.MultiShapeLabelers.doLabelIsSelectedPre(this.ShapeLabelers,varargin{:});
        end



        function adjustAxisLimits(this,data)
            if~isfield(data,'Image')||isempty(data.Image)
                return;
            end

            if~ismember(data.ImageIndex,this.FramesTraversed)



                I=data.Image.Location;



                if ismatrix(I)
                    X=I(:,1);
                    Y=I(:,2);
                    Z=I(:,3);
                else
                    X=reshape(I(:,:,1),[],1);
                    Y=reshape(I(:,:,2),[],1);
                    Z=reshape(I(:,:,3),[],1);
                end



                this.XLim=[min([X(:);this.XLim(:)],[],'omitnan'),max([X(:);this.XLim(:)],[],'omitnan')];
                this.YLim=[min([Y(:);this.YLim(:)],[],'omitnan'),max([Y(:);this.YLim(:)],[],'omitnan')];
                this.ZLim=[min([Z(:);this.ZLim(:)],[],'omitnan'),max([Z(:);this.ZLim(:)],[],'omitnan')];


                if this.axisLimitsValid(this.XLim,this.YLim,this.ZLim)
                    set(this.AxesHandle,'XLim',this.XLim,'YLim',this.YLim,'ZLim',this.ZLim);
                end



                this.FramesTraversed(end+1)=data.ImageIndex;






            end
        end


        function displayPointCloud(this,pc)

            I=pc.Location;


            pointclouds.internal.pcui.utils.setAppData(this.ImageHandle,'PointCloud',pc);


            originalTag=this.AxesHandle.Tag;


            if isempty(this.ImageHandle)

                createImage(this);


                attachToImage(this.CuboidLabeler,this.Fig,this.AxesHandle,this.ImageHandle);
                attachToImage(this.Line3DLabeler,this.Fig,this.AxesHandle,this.ImageHandle);



                if~isempty(this.CurrentLabeler)&&strcmp(this.Mode,'ROI')
                    activate(this.CurrentLabeler,this.Fig,this.AxesHandle,this.ImageHandle);
                end
            else


                if isempty(this.GroundRemovedPointCloud)
                    updateLimits=all(isnan(this.ImageHandle.XData));
                else
                    updateLimits=~all(isnan(this.ImageHandle.XData));
                end

                if ismatrix(I)
                    X=I(:,1);
                    Y=I(:,2);
                    Z=I(:,3);
                else
                    X=reshape(I(:,:,1),[],1);
                    Y=reshape(I(:,:,2),[],1);
                    Z=reshape(I(:,:,3),[],1);
                end

                updateCLim(this,X,Y,Z,updateLimits);

            end

            this.AxesHandle.Tag=originalTag;

        end


        function updateCLim(this,X,Y,Z,updateLimits)

            if this.ColorByClusterInternal&&~isempty(this.ImageHandle.ClusterData)&&this.ShowClusterForRectROI
                cdata=single(this.ImageHandle.ClusterData)/single(max(this.ImageHandle.ClusterData(:)));
            else

                switch this.ColormapValueInternal
                case 'z'
                    pts=Z;
                case 'radial'
                    pts=sqrt((X.^2)+(Y.^2));
                otherwise
                    assert(false,'Not a valid colormap value');
                end

                if updateLimits

                    xLim=[min([X(:);this.XLim(:)],[],'omitnan'),max([X(:);this.XLim(:)],[],'omitnan')];
                    yLim=[min([Y(:);this.YLim(:)],[],'omitnan'),max([Y(:);this.YLim(:)],[],'omitnan')];
                    zLim=[min([Z(:);this.ZLim(:)],[],'omitnan'),max([Z(:);this.ZLim(:)],[],'omitnan')];

                    if any(isnan([xLim,yLim,zLim]))
                        return;
                    end


                    if this.axisLimitsValid(xLim,yLim,zLim)

                        udata=pointclouds.internal.pcui.utils.getAppData(this.AxesHandle,'PCUserData');
                        udata.dataLimits=[xLim,yLim,zLim];
                        pointclouds.internal.pcui.utils.setAppData(this.AxesHandle,'PCUserData',udata);
                        set(this.AxesHandle,'XLim',xLim,'YLim',yLim,'ZLim',zLim);
                    end

                    set(this.AxesHandle,'Colormap',this.ColormapInternal);
                    set(this.AxesHandle,'Color',this.BackgroundColorInternal);
                    set(this.AxesHandle.Parent,'BackgroundColor',this.BackgroundColorInternal);
                end

                sortedPts=sort(pts(~isnan(pts)));
                n=numel(sortedPts);
                if n>100
                    this.CLim=[sortedPts(floor(0.02*n)),sortedPts(ceil(0.98*n))];
                else
                    this.CLim=[min(sortedPts),max(sortedPts)];
                end


                if~isempty(this.CLim)

                    cdata=(pts-this.CLim(1))/(this.CLim(2)-this.CLim(1));
                    cdata(cdata>1)=1;
                    cdata(cdata<0)=0;
                end
            end

            if isempty(this.ColormapInternal)
                [X,Y,Z,CData]=this.getDataToDisplay(this.PointCloud);
                set(this.ImageHandle,'XData',X,'YData',Y,'ZData',Z,'CData',CData);
            end

            if~isempty(this.CLim)&&~isempty(this.ColormapInternal)
                set(this.ImageHandle,'XData',X,'YData',Y,'ZData',Z,'CData',cdata');
            end


        end


        function drawInteractiveROIs(this,roiPositions,labelNames,sublabelNames,selfUIDs,parentUIDs,colors,shapes,roiVisibility)

            enableClusteringState(this);

            if~isempty(roiPositions)&&...
                ~isempty(labelNames)&&...
                ~isempty(colors)&&...
                ~isempty(colors)

                data.Positions=roiPositions;
                [roiNames,parentNames]=convertToParentNames(this,labelNames,sublabelNames);
                data.Names=roiNames;
                data.ParentNames=parentNames;
                data.ParentUIDs=parentUIDs;
                data.SelfUIDs=selfUIDs;
                data.Colors=colors;
                data.Shapes=shapes;
                data.ROIVisibility=roiVisibility;
                this.CuboidLabeler.drawLabels(data);
                this.Line3DLabeler.drawLabels(data);
                enableProjectedView(this);
            end
        end


        function drawStaticROIs(this,roiPositions,labelNames,sublabelNames,selfUIDs,parentUIDs,colors,shapes,roiVisibility)



            disableClusteringState(this);

            for roiPosIdx=1:numel(roiPositions)

                switch shapes(roiPosIdx)
                case labelType.Cuboid
                    staticRoi=driving.internal.groundTruthLabeler.tool.StaticCuboid(...
                    roiPositions{roiPosIdx},this.AxesHandle,...
                    colors{roiPosIdx},labelNames{roiPosIdx},...
                    sublabelNames{roiPosIdx},selfUIDs{roiPosIdx},...
                    parentUIDs{roiPosIdx},this.ShowLabel,roiVisibility{roiPosIdx});
                    this.StaticROIs{end+1}=staticRoi;

                case labelType.Line
                    if~iscell(roiPositions)
                        roiPositions={roiPositions};
                    end

                    staticRoi=driving.internal.groundTruthLabeler.tool.StaticLine3D(...
                    roiPositions{roiPosIdx},this.AxesHandle,...
                    colors{roiPosIdx},labelNames{roiPosIdx},...
                    sublabelNames{roiPosIdx},selfUIDs{roiPosIdx},...
                    parentUIDs{roiPosIdx},this.ShowLabel,roiVisibility{roiPosIdx});
                    this.StaticROIs{end+1}=staticRoi;

                otherwise
                    assert(false,'drawStaticROIs: Unknown shape: %s',shapes(roiPosIdx));
                end
            end
        end


        function mouseMotionCallback(this,~,evt)

            if~this.Fig.IPTROIPointerManager.Enabled||isempty(this.ImageHandle)||~isvalid(this.ImageHandle)
                currentAxes=this.Fig.CurrentAxes;
                udata=pointclouds.internal.pcui.utils.getAppData(currentAxes,'PCUserData');

                rotateToolbarItem=findall(currentAxes.Toolbar,'Tag','rotate');
                if~udata.rotateFromCenter&&isempty(udata.pcshowMouseData)...
                    &&strcmp(rotateToolbarItem.Value,'on')

                    x=this.ImageHandle.XData(isfinite(this.ImageHandle.XData));
                    y=this.ImageHandle.YData(isfinite(this.ImageHandle.YData));
                    z=this.ImageHandle.ZData(isfinite(this.ImageHandle.ZData));

                    if isempty(this.HighlightScatter)

                        hold(currentAxes,'on');
                        this.HighlightScatter=scatter3(NaN,NaN,NaN,10,[1,1,0],'.',...
                        'HitTest','off',...
                        'PickableParts','none',...
                        'Parent',currentAxes,...
                        'HandleVisibility','off',...
                        'LineWidth',5,...
                        'Marker','*');

                        hold(currentAxes,'off');
                    end

                    if any(x(:)==evt.IntersectionPoint(1))&&any(y(:)==evt.IntersectionPoint(2))&&any(z(:)==evt.IntersectionPoint(3))
                        set(this.HighlightScatter,'XData',evt.IntersectionPoint(1),'YData',evt.IntersectionPoint(2),'ZData',evt.IntersectionPoint(3),'Visible','on')
                    else
                        set(this.HighlightScatter,'Visible','off')
                    end
                elseif~isempty(this.HighlightScatter)&&udata.rotateFromCenter
                    set(this.HighlightScatter,'Visible','off')
                end

                return;
            elseif~isempty(this.HighlightScatter)
                set(this.HighlightScatter,'Visible','off')
            end

            if evt.HitObject==this.ImageHandle||evt.HitObject==this.AxesHandle
                this.WasImageLastHitObject=true;
                setPointer(this);
            elseif isa(evt.HitObject,'matlab.ui.container.Panel')&&any(strcmp(evt.HitObject.Tag,{'RightFlagPanel','LeftFlagPanel','ScrubberPanel'}))
                this.WasScrubberLastHitObject=true;
                images.roi.internal.setROIPointer(this.Fig,'east');
            else
                if this.LabelingMode==lidarLabelType.Voxel
                    setPointer(this.VoxelLabeler)
                elseif this.WasImageLastHitObject||this.WasScrubberLastHitObject

                    this.WasImageLastHitObject=false;
                    this.WasScrubberLastHitObject=false;
                    if~any(strcmp(class(evt.HitObject.Parent),...
                        {'images.roi.Cuboid','images.roi.Polyline'}))
                        set(this.Fig,'Pointer','arrow');
                    end

                end
            end

        end


        function setPointer(this)

            if strcmpi(this.Mode,'ROI')
                if this.LabelingMode==lidarLabelType.Voxel
                    setPointer(this.VoxelLabeler)
                else
                    images.roi.internal.setROIPointer(this.Fig,'crosshair');
                end
            elseif strcmpi(this.Mode,'none')

                images.roi.internal.setROIPointer(this.Fig,'restricted');
            else
                set(this.Fig,'Pointer','arrow');
            end
        end


        function disableClusteringState(this)

            if isempty(this.CachedClusterState)

                this.CachedClusterState=this.ClusterData;
                this.ClusterData=false;

            end

        end


        function enableClusteringState(this)

            if~isempty(this.CachedClusterState)

                this.ClusterData=this.CachedClusterState;
                this.CachedClusterState=logical.empty;

                if this.ClusterData
                    clusterLidarData(this);
                end

            end

        end


        function pcfitGroundPlaneRemoval(this)
            if(this.MaxDistanceInternal<0.05)||(this.MaxAngularDistanceInternal<0.05)
                warning('off','vision:ransac:maxTrialsReached')
                warning('off',"vision:pointcloud:notEnoughInliers")
            end
            warning('off',"vision:pointcloud:notEnoughInliers")
            if isempty(this.PCFitGroundInfo)||~compairPCFitInfo(this)
                [~,~,outlierPointsIdx]=pcfitplane(this.PointCloud,this.MaxDistanceInternal,this.ReferenceVectorInternal,this.MaxAngularDistanceInternal);
                this.PCFitGroundInfo.outlierPointsIdx=outlierPointsIdx;
                this.PCFitGroundInfo.PointCloud=this.PointCloud;
                this.PCFitGroundInfo.MaxDistanceInternal=this.MaxDistanceInternal;
                this.PCFitGroundInfo.ReferenceVectorInternal=this.ReferenceVectorInternal;
                this.PCFitGroundInfo.MaxAngularDistanceInternal=this.MaxAngularDistanceInternal;
            else
                outlierPointsIdx=this.PCFitGroundInfo.outlierPointsIdx;
            end
            warning('on','vision:ransac:maxTrialsReached')
            warning('on',"vision:pointcloud:notEnoughInliers")
            this.GroundRemovedPointCloud=select(this.PointCloud,outlierPointsIdx,'OutputSize','full');
        end


        function tf=compairPCFitInfo(this)
            tf1=this.PCFitGroundInfo.PointCloud==this.PointCloud;
            tf2=this.PCFitGroundInfo.MaxDistanceInternal==this.MaxDistanceInternal;
            tf3=this.PCFitGroundInfo.ReferenceVectorInternal==this.ReferenceVectorInternal;
            tf4=this.PCFitGroundInfo.MaxAngularDistanceInternal==this.MaxAngularDistanceInternal;

            tf=tf1&tf2&all(tf3)&tf4;
        end




        function createAxes(this)
            this.AxesHandle=axes('Parent',this.ImagePanel,...
            'Units','Normalized',...
            'position',[0,0,1,1],...
            'Visible','off',...
            'Color',[0,0,40/255]);

            resizeFigure(this);





            drawnow;
        end


        function createImage(this,varargin)
            pcshow([NaN,NaN,NaN],'Parent',this.AxesHandle,MarkerSize=10,...
            AxesVisibility='on',Projection="orthographic");



            this.makeChangesToPcshow();

            set(this.AxesHandle,'Color',[0,0,40/255]);
            set(this.ImagePanel,'BackgroundColor',[0,0,40/255]);
            this.ImageHandle=findobj(this.AxesHandle,'Tag','pcviewer');
            set(this.ImageHandle,'HitTest','on','PickableParts','visible');



            this.makeChangesToPcshow();


            p=this.ImageHandle.addprop('ClusterData');
            p.Hidden=true;
            p.Transient=true;

            this.Toolbar=axtoolbar(this.AxesHandle,{'rotate','pan','zoomin','zoomout','restoreview'},'Visible','on');
            this.AxesHandle.Interactions=[zoomInteraction;rotateInteraction];

            this.AxesHandle.Toolbar.SelectionChangedFcn=@(src,evt)this.axToolbarSelectionChangedCallback(src,evt);

            rotate3d(this.AxesHandle,'off');

            addlistener(this.Fig,'WindowScrollWheel',@(o,e)this.doScrollWheelCallBack(o,e));
            addlistener(this.Fig,'WindowKeyPress',@(o,e)keyPressCallback(this.CuboidLabeler,e));
            addlistener(this.Fig,'WindowKeyRelease',@(o,e)keyPressCallback(this.CuboidLabeler,e));

        end


        function doScrollWheelCallBack(this,o,e)
            if isCuboidResizeButtonPressed(this)
                return;
            end
            pointclouds.internal.pcui.localScrollWheelCallback(o,e,this.Fig);
        end


        function TF=isCuboidResizeButtonPressed(this)
            TF=isCuboidLabelerValid(this)&&isCuboidResizeButtonPressed(this.CuboidLabeler);
        end


        function TF=isCuboidLabelerValid(this)
            TF=~isempty(this.CuboidLabeler)&&isvalid(this.CuboidLabeler);
        end


        function displayEmptyPointCloudOnError(this)



            set(this.ImageHandle,'XData',NaN,'YData',NaN,'ZData',NaN,'CData',0);
        end

    end

    methods

        function set.ColorByCluster(this,TF)
            this.ColorByClusterInternal=TF;
            if TF&&this.ColorByClusterInternal



                cmap=hsv(256)';
                cmap=[cmap(:,1:128);cmap(:,129:256)];
                cmap=reshape(cmap(:),[3,256]);
                set(this.AxesHandle,'Colormap',cmap');
            else
                set(this.AxesHandle,'Colormap',this.ColormapInternal);
            end
            if~all(isnan(this.ImageHandle.XData))
                updateCLim(this,this.ImageHandle.XData,this.ImageHandle.YData,this.ImageHandle.ZData,false);
            else
                this.displayEmptyPointCloudOnError
            end
        end


        function setClusterVisibility(this,TF)
            this.ShowClusterForRectROI=TF;
            if TF&&this.ColorByClusterInternal



                cmap=hsv(256)';
                cmap=[cmap(:,1:128);cmap(:,129:256)];
                cmap=reshape(cmap(:),[3,256]);
                set(this.AxesHandle,'Colormap',cmap');
            else
                set(this.AxesHandle,'Colormap',this.ColormapInternal);
            end
            if~all(isnan(this.ImageHandle.XData))
                updateCLim(this,this.ImageHandle.XData,this.ImageHandle.YData,this.ImageHandle.ZData,false);
            else
                this.displayEmptyPointCloudOnError
            end

        end

        function TF=get.ColorByCluster(this)
            TF=this.ColorByClusterInternal;
        end

        function set.ClusterData(this,TF)
            if TF
                clusterLidarData(this);
            end
            this.CuboidLabeler.ClusterData=TF;
        end

        function TF=get.ClusterData(this)
            TF=this.CuboidLabeler.ClusterData;
        end

        function set.HideGroundData(this,TF)
            this.HideGroundDataInternal=TF;
            displayGroundData(this);
        end

        function TF=get.HideGroundData(this)
            TF=this.HideGroundDataInternal;
        end

        function set.SnapToFit(this,TF)
            this.CuboidLabeler.SnapToFit=TF;
        end

        function TF=get.SnapToFit(this)
            TF=this.CuboidLabeler.SnapToFit;
        end

        function set.SnapToPoint(this,TF)
            this.Line3DLabeler.SnapToPoint=TF;
        end

        function TF=get.SnapToPoint(this)
            TF=this.Line3DLabeler.SnapToPoint;
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

        function clipboardState=isROIClipboardFilled(this)
            clipboardState=~isempty(this.Clipboard);
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
    end




    methods

        function initializeUndoBuffer(this,currentIndex)
            this.UndoRedoManagerShape.initializeUndoBuffer(currentIndex);
        end


        function toUpdate=undoROI(this,currentIndex)
            if(this.UndoRedoManagerShape.isUndoAvailable())
                this.UndoRedoManagerShape.undo();
                toUpdate=this.updateInteractiveROIsForUndoRedo(currentIndex);
            else
                toUpdate=false;
            end
        end


        function toUpdate=redoROI(this,currentIndex)
            if(this.UndoRedoManagerShape.isRedoAvailable())
                this.UndoRedoManagerShape.redo();
                toUpdate=this.updateInteractiveROIsForUndoRedo(currentIndex);
            else
                toUpdate=false;
            end
        end


        function updateUndoOnLabelChange(this,currentIdx,roiAnnotations,~)




            if this.UndoRedoManagerShape.shouldResetUndoRedo(currentIdx)
                this.initializeUndoBuffer(currentIdx);
            end
            this.addAllCurrentROILabelsToUndoStack(currentIdx,roiAnnotations);
        end


        function addAllCurrentROILabelsToUndoStack(this,currentIndex,roiAnnotations)



            roiNames={roiAnnotations.Label};
            parentNames={roiAnnotations.ParentName};

            selfUIDs={roiAnnotations.ID};
            parentUIDs={roiAnnotations.ParentUID};

            roiPositions={roiAnnotations.Position};
            roiColors={roiAnnotations.Color};
            roiShapes=[roiAnnotations.Shape];
            roiVisibility={roiAnnotations.ROIVisibility};


            this.UndoRedoManagerShape.executeCommand(...
            lidar.internal.labeler.tool.ROIUndoRedoParams(...
            currentIndex,roiNames,parentNames,...
            selfUIDs,parentUIDs,...
            roiPositions,roiColors,roiShapes,roiVisibility));
        end


        function addlistenerForUpdateUndoRedoQAB(this,callback)

            addlistener(this.UndoRedoManagerShape,'UpdateUndoRedoQAB',callback);
        end


        function TF=isUndoAvailable(this,~)
            TF=this.UndoRedoManagerShape.isUndoAvailable(this.CurrentDisplayIndex);
        end


        function TF=isRedoAvailable(this,~)
            TF=this.UndoRedoManagerShape.isRedoAvailable(this.CurrentDisplayIndex);
        end


        function resetUndoRedoBuffer(this)
            this.UndoRedoManagerShape.resetUndoRedoBuffer();
        end


        function updateLabelInUndoRedoBuffer(this,newItemInfo,oldItemInfo,toUpdate)
            this.UndoRedoManagerShape.updateLabelInUndoRedoBuffer(newItemInfo,oldItemInfo,toUpdate);
        end


        function updateLabelVisibilityInUndoRedoBuffer(this,newItemInfo)
            this.UndoRedoManagerShape.updateLabelVisibilityInUndoRedoBuffer(newItemInfo);
        end
    end

    methods(Static)

        function cmap=getRedToBlueColormap(~)
            cmap=zeros([256,3]);
            cmap(1:128,1)=1;
            cmap(1:128,2)=linspace(0,1,128);
            cmap(1:128,3)=linspace(0,1,128);
            cmap(128:256,1)=linspace(1,0,129);
            cmap(128:256,2)=linspace(1,0,129);
            cmap(128:256,3)=1;
        end



        function TF=axisLimitsValid(xLim,yLim,zLim)


            TF=(xLim(1)<xLim(2))&&(yLim(1)<yLim(2))&&(zLim(1)<zLim(2));
        end
    end

    methods(Access=private)

        function makeChangesToPcshow(this)



            cMenuColorMapOption=findall(this.Fig.Children,'Tag','contextPCChangeColor');
            cMenuColorMapOption.Visible='off';
        end


        function changeBackground(this,src)


            switch src.Position
            case 2

                color=uisetcolor;
            otherwise

                color=[0,0,0];
            end


            tickColor=[0.8,0.8,0.8];

            if~isscalar(color)

                this.ImagePanel.Parent.Color=color;
                this.AxesHandle.Color=color;
                this.AxesHandle.XColor=tickColor;
                this.AxesHandle.YColor=tickColor;
                this.AxesHandle.ZColor=tickColor;
                this.AxesHandle.Title.Color=tickColor;
            end
        end


        function[XData,YData,ZData,CData]=getDataToDisplay(this,pointCloud)


            if ismatrix(pointCloud.Location)

                XData=pointCloud.Location(:,1);
                YData=pointCloud.Location(:,2);
                ZData=pointCloud.Location(:,3);
            else

                XData=reshape(pointCloud.Location(:,:,1),[],1);
                YData=reshape(pointCloud.Location(:,:,2),[],1);
                ZData=reshape(pointCloud.Location(:,:,3),[],1);
            end


            if this.ColorByClusterInternal&&~isempty(this.ImageHandle(end).ClusterData)
                CData=single(this.ImageHandle(end).ClusterData)/single(max(this.ImageHandle(end).ClusterData(:)));
            else


                CData=getCDataColor(this);
            end
        end


        function cData=getCDataColor(this)
            if isempty(this.PointCloud.Color)
                cData=this.setDefaultCMapVal();
                return;
            end

            if ismatrix(this.PointCloud.Color)
                cData=this.PointCloud.Color;
            else
                cData=reshape(this.PointCloud.Color,[],3);
            end
        end
    end



    methods

        function addListenersProjectedViewCuboids(this,ProjectedViewDisplay)
            this.ProjectedViewDisplay=ProjectedViewDisplay;
            addlistener(this.ProjectedViewDisplay.RectX,'ROIMoved',@this.projectedViewRectMovedCallback);
            addlistener(this.ProjectedViewDisplay.RectY,'ROIMoved',@this.projectedViewRectMovedCallback);
            addlistener(this.ProjectedViewDisplay.RectZ,'ROIMoved',@this.projectedViewRectMovedCallback);
            addlistener(this.ProjectedViewDisplay.RectX,'MovingROI',@(src,evnt)this.projectedViewRectRotatingCallback(src,evnt,'X'));
            addlistener(this.ProjectedViewDisplay.RectY,'MovingROI',@(src,evnt)this.projectedViewRectRotatingCallback(src,evnt,'Y'));
            addlistener(this.ProjectedViewDisplay.RectZ,'MovingROI',@(src,evnt)this.projectedViewRectRotatingCallback(src,evnt,'Z'));
            addlistener(this.ProjectedViewDisplay.PointIconX,'MovingROI',@(src,evnt)this.pointMovingCallback(src,evnt,...
            this.ProjectedViewDisplay.RectX,'X'));
            addlistener(this.ProjectedViewDisplay.PointIconX,'ROIMoved',@(src,evnt)this.pointMovedCallback(src,evnt,...
            this.ProjectedViewDisplay.RectX,'X'));
            addlistener(this.ProjectedViewDisplay.PointIconY,'MovingROI',@(src,evnt)this.pointMovingCallback(src,evnt,...
            this.ProjectedViewDisplay.RectY,'Y'));
            addlistener(this.ProjectedViewDisplay.PointIconY,'ROIMoved',@(src,evnt)this.pointMovedCallback(src,evnt,...
            this.ProjectedViewDisplay.RectY,'Y'));
            addlistener(this.ProjectedViewDisplay.PointIconZ,'MovingROI',@(src,evnt)this.pointMovingCallback(src,evnt,...
            this.ProjectedViewDisplay.RectZ,'Z'));
            addlistener(this.ProjectedViewDisplay.PointIconZ,'ROIMoved',@(src,evnt)this.pointMovedCallback(src,evnt,...
            this.ProjectedViewDisplay.RectZ,'Z'));
        end

        function addListenersProjectedViewLines(this,ProjectedViewDisplay)
            this.ProjectedViewDisplay=ProjectedViewDisplay;

            addlistener(this.ProjectedViewDisplay.Line2Dx,'ROIMoved',@this.projectedViewLineROIMovedCallback);
            addlistener(this.ProjectedViewDisplay.Line2Dy,'ROIMoved',@this.projectedViewLineROIMovedCallback);
            addlistener(this.ProjectedViewDisplay.Line2Dz,'ROIMoved',@this.projectedViewLineROIMovedCallback);


            addlistener(this.ProjectedViewDisplay.Line2Dx,'VertexDeleted',@this.projectedViewLineROIVertexDeletedCallback);
            addlistener(this.ProjectedViewDisplay.Line2Dy,'VertexDeleted',@this.projectedViewLineROIVertexDeletedCallback);
            addlistener(this.ProjectedViewDisplay.Line2Dz,'VertexDeleted',@this.projectedViewLineROIVertexDeletedCallback);



            addlistener(this.ProjectedViewDisplay.Line2Dx,'AddingVertex',@this.projectedViewLineROIAddVertexCallback);
            addlistener(this.ProjectedViewDisplay.Line2Dy,'AddingVertex',@this.projectedViewLineROIAddVertexCallback);
            addlistener(this.ProjectedViewDisplay.Line2Dz,'AddingVertex',@this.projectedViewLineROIAddVertexCallback);


            addlistener(this.ProjectedViewDisplay.Line2Dx,'VertexAdded',@this.projectedViewLineROIVertexAddedCallback);
            addlistener(this.ProjectedViewDisplay.Line2Dy,'VertexAdded',@this.projectedViewLineROIVertexAddedCallback);
            addlistener(this.ProjectedViewDisplay.Line2Dz,'VertexAdded',@this.projectedViewLineROIVertexAddedCallback);


            addlistener(this.ProjectedViewDisplay.Line2Dx,'DeletingROI',@this.projectedViewLineDeletingCallback);
            addlistener(this.ProjectedViewDisplay.Line2Dy,'DeletingROI',@this.projectedViewLineDeletingCallback);
            addlistener(this.ProjectedViewDisplay.Line2Dz,'DeletingROI',@this.projectedViewLineDeletingCallback);


            addlistener(this.ProjectedViewDisplay,'ROIDeleted',@this.projectedViewLineDeletedCallback);
        end

        function status=isProjectedViewSupported(this)
            status=false;
            if~isempty(this.CuboidLabeler)&&~isempty(this.CuboidLabeler.CurrentROIs)||...
                ~isempty(this.Line3DLabeler)&&~isempty(this.Line3DLabeler.CurrentROIs)
                status=true;
            end
        end

        function projectedViewRectRotatingCallback(this,src,evt,varargin)

            this.ProjectedViewDisplay.rectRotatingCallback(src,evt,varargin{:});
        end

        function pointMovingCallback(this,src,evt,varargin)


            newPoint=src;
            this.ProjectedViewDisplay.pointMovingCallback(newPoint,evt,varargin{1},varargin{2});
        end

        function projectedViewRectMovedCallback(this,~,evt)


            rectChange=evt;
            currentrois=this.CuboidLabeler.CurrentROIs;
            [data,selectedIdx]=this.ProjectedViewDisplay.rectMovedCallback(rectChange,currentrois);

            updateAllCuboidInProjectedView(this,data,selectedIdx);
        end

        function projectedViewLineROIMovedCallback(this,src,evt)


            line2DChange=evt;
            currentrois=this.Line3DLabeler.CurrentROIs;
            [data,selectedIdx]=this.ProjectedViewDisplay.lineROIMovedCallback(line2DChange,currentrois);

            updateAllLineROIInProjectedView(this,data,selectedIdx);
        end

        function projectedViewLineROIVertexDeletedCallback(this,src,evt)


            line2DChange=evt;
            currentrois=this.Line3DLabeler.CurrentROIs;
            [data,selectedIdx]=this.ProjectedViewDisplay.lineROIVertexDeletedCallback(line2DChange,currentrois);
            updateAllLineROIInProjectedView(this,data,selectedIdx);
        end

        function projectedViewLineROIAddVertexCallback(this,src,evt)

            this.PreviousLine=src.Position;
        end

        function projectedViewLineROIVertexAddedCallback(this,src,evt)

            if isempty(this.PreviousLine)
                return;
            end

            src.Position=this.PreviousLine;
        end

        function projectedViewLineDeletingCallback(this,src,evt)

            copyObj.Position=src.Position;
            copyObj.Parent=src.Parent;
            copyObj.UserData=src.UserData;
            this.PreviousROI=copyObj;

            errordlg(getString(message('vision:labeler:DeleteProjectedPolylineErrorDialog')),...
            getString(message('vision:labeler:DeleteProjectedPolylineErrorDialogTitle')));

            delete(src);
            notify(this.ProjectedViewDisplay,'ROIDeleted');
        end

        function projectedViewLineDeletedCallback(this,src,evt)
            if~isempty(this.PreviousROI)
                copyObj=images.roi.Polyline(this.PreviousROI.Parent,...
                'Label','',...
                'Tag','',...
                'Selected',true,...
                'SelectedColor',[1,1,0],...
                'LabelVisible','off');

                if~isvalid(this.ProjectedViewDisplay.Line2Dx)||...
                    ~isvalid(this.ProjectedViewDisplay.Line2Dy)
                    if~isvalid(this.ProjectedViewDisplay.Line2Dx)
                        this.ProjectedViewDisplay.Line2Dx=copyObj;
                        this.ProjectedViewDisplay.Line2Dx.Position=this.PreviousROI.Position;
                        this.ProjectedViewDisplay.Line2Dx.Tag='Line2Dx';
                        this.ProjectedViewDisplay.Line2Dx.UserData=this.PreviousROI.UserData;
                        this.ProjectedViewDisplay.Line2Dx.Layer='front';
                    else
                        this.ProjectedViewDisplay.Line2Dy=copyObj;
                        this.ProjectedViewDisplay.Line2Dy.Position=this.PreviousROI.Position;
                        this.ProjectedViewDisplay.Line2Dy.UserData=this.PreviousROI.UserData;
                        this.ProjectedViewDisplay.Line2Dy.Tag='Line2Dy';
                        this.ProjectedViewDisplay.Line2Dy.Layer='front';
                    end
                elseif~isvalid(this.ProjectedViewDisplay.Line2Dz)
                    this.ProjectedViewDisplay.Line2Dz=copyObj;
                    this.ProjectedViewDisplay.Line2Dz.Position=this.PreviousROI.Position;
                    this.ProjectedViewDisplay.Line2Dz.UserData=this.PreviousROI.UserData;
                    this.ProjectedViewDisplay.Line2Dz.Tag='Line2Dz';
                    this.ProjectedViewDisplay.Line2Dz.Layer='front';
                end
                addListenersProjectedViewLines(this,this.ProjectedViewDisplay);
            end
        end

        function pointMovedCallback(this,src,~,varargin)


            newPoint=src;
            currentrois=this.CuboidLabeler.CurrentROIs;
            [data,selectedIdx]=this.ProjectedViewDisplay.pointMovedCallback(newPoint,currentrois,varargin{1},varargin{2});

            updateAllCuboidInProjectedView(this,data,selectedIdx);
        end

        function updateAllCuboidInProjectedView(this,position,selectedIdx)

            if~isempty(position)
                this.CuboidLabeler.CurrentROIs{selectedIdx}.Selected=true;
                this.CuboidLabeler.CurrentROIs{selectedIdx}.Position=position(1:6);
                this.CuboidLabeler.CurrentROIs{selectedIdx}.RotationAngle=position(7:9);
                updateProjectedView(this.CuboidLabeler);
            end
        end

        function updateAllLineROIInProjectedView(this,position,selectedIdx)

            if~isempty(position)
                this.Line3DLabeler.CurrentROIs{selectedIdx}.Selected=true;
                this.Line3DLabeler.CurrentROIs{selectedIdx}.Position=position;
                updateProjectedView(this.Line3DLabeler);
            end
        end


        function initiateProjectedView(this,projectedViewDisplay)
            this.ProjectedViewDisplay=projectedViewDisplay;
            this.ProjectedView=true;

            src.CurrentROIs=this.selectCurrentROIs();
            this.activateProjectedView(src);
        end
    end

    methods









        function enableProjectedView(this)
            if this.ProjectedView&&isvalid(this.ProjectedViewDisplay)
                this.ProjectedViewDisplay.AxesX.Parent=this.ProjectedViewDisplay.Panelx;
                this.ProjectedViewDisplay.AxesY.Parent=this.ProjectedViewDisplay.Panely;
                this.ProjectedViewDisplay.AxesZ.Parent=this.ProjectedViewDisplay.Panelz;

                src.CurrentROIs=this.selectCurrentROIs();
                this.activateProjectedView(src);
            end
        end



        function currentROIs=selectCurrentROIs(this)
            if~isempty(this.getSelectedLabelROIs)
                ROIType=this.getSelectedLabelROIs.Shape;
            else
                ROIType=[];
            end

            if ROIType==labelType.Line
                currentROIs=this.Line3DLabeler.CurrentROIs;
            else
                currentROIs=this.CuboidLabeler.CurrentROIs;
            end
        end
    end
    methods(Access=protected)

        function activateProjectedView(this,src,~)



            if~isempty(this.ProjectedViewDisplay)
                if this.ProjectedView&&isvalid(this.ProjectedViewDisplay)

                    if~isempty(this.getSelectedLabelROIs)
                        ROIType=this.getSelectedLabelROIs.Shape;
                    else
                        ROIType=[];
                    end

                    if this.HideGroundData
                        if ROIType==labelType.Line
                            this.ProjectedViewDisplay.activateProjectedViewLine(src,this.GroundRemovedPointCloud,...
                            this.ColormapValueInternal,this.ColormapInternal,this.BackgroundColorInternal);
                        else
                            this.ProjectedViewDisplay.activateProjectedViewCuboid(src,this.GroundRemovedPointCloud,...
                            this.ColormapValueInternal,this.ColormapInternal,this.BackgroundColorInternal);
                        end
                    else
                        if ROIType==labelType.Line
                            this.ProjectedViewDisplay.activateProjectedViewLine(src,this.PointCloud,...
                            this.ColormapValueInternal,this.ColormapInternal,this.BackgroundColorInternal);
                        else
                            this.ProjectedViewDisplay.activateProjectedViewCuboid(src,this.PointCloud,...
                            this.ColormapValueInternal,this.ColormapInternal,this.BackgroundColorInternal);
                        end
                    end

                end
            end
        end
    end
    methods
        function set.ProjectedView(this,TF)
            this.ProjectedViewInternal=TF;
        end

        function TF=get.ProjectedView(this)
            TF=this.ProjectedViewInternal;
        end
    end



end

