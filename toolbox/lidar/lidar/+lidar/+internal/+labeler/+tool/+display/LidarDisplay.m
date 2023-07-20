classdef LidarDisplay<lidar.internal.labeler.tool.display.PointCloudDisplay



    properties(Access=private)



CMap
CVal
    end

    properties(Dependent)
UsePCFit
    end

    properties(Access=private)
        CameraViewParameters={};
LabelScatterPlot
    end

    properties

LimitsSettings

        LimitsDataInternal(1,1)logical=false;

    end

    properties(Access=public,Hidden)

        LimitsData=false;
Limits
PointDimension

    end

    properties(Access=protected)

LimitsInternal
PointDimensionInternal

    end

    methods

        function this=LidarDisplay(hFig,nameDisplayedInTab)
            this=this@lidar.internal.labeler.tool.display.PointCloudDisplay(hFig,nameDisplayedInTab);
            this.Clipboard=lidar.internal.labeler.tool.ROILabelerClipBoard;
        end
    end

    methods

        function setColormap(this,cmap,val)
            setColormap@lidar.internal.labeler.tool.display.PointCloudDisplay(this,cmap,val);
            this.CMap=cmap;
            this.CVal=val;
            if this.LimitsDataInternal
                limitsLidarData(this);
            end

        end


        function enableProjectedView(this)
            enableProjectedView@lidar.internal.labeler.tool.display.PointCloudDisplay(this);

            if this.LimitsDataInternal
                limitsLidarData(this);
            end
        end


        function isModeReadyForROI=getModeFromSelectedItem(this,selectedItem)
            isLabel=isLabelDef(this,selectedItem.roiItemDataObj);
            isModeReadyForROI=(~isempty(this.PointCloud)&&~isempty(this.PointCloud.XLimits))...
            &&isLabel&&isfield(selectedItem,'isRectOrCubeLabelItemSelected')&&selectedItem.isRectOrCubeLabelItemSelected||...
            (isfield(selectedItem,'isLineOrLine3DLabelItemSelected')&&selectedItem.isLineOrLine3DLabelItemSelected)||...
            isLabel&&strcmp(selectedItem.roiItemDataObj.ROI,'Voxel');
        end


        function updateVoxelLabelColorInCurrentFrame(this)


            data.dummy=0;
            imageInfo=getLabelAndColorData(this.VoxelLabeler,data);
            updateVoxelLabelPlot(this,imageInfo)
        end
    end

    methods(Access=protected)
        function initialize(this)
            initialize@lidar.internal.labeler.tool.display.PointCloudDisplay(this);
            showHelperText(this,vision.getMessage('vision:labeler:VideoHelperTextLL'));
        end


        function line3DLabeler=getLine3DLabeler(~)
            line3DLabeler=lidar.internal.lidarLabeler.tool.Line3DLabeler();
        end

        function drawImage(this,data)



            if~isfield(data,'PointCloud')&&~isfield(data,'Image')
                return;
            end


            if isfield(data,'LabelMatrix')
                resetVoxelLabeler(this,data);
                delete(this.LabelScatterPlot);
                this.LabelScatterPlot=[];
                this.LabelScatterPlot=repmat(matlab.graphics.chart.primitive.Scatter,255,1);
            end

            imageInfo=getLabelAndColorData(this.VoxelLabeler,data);


            originalTag=this.AxesHandle.Tag;

            if isempty(this.ImageHandle)


                createAxes(this);
            end

            if isfield(data,'PointCloud')
                this.PointCloud=data.PointCloud;
            else
                this.PointCloud=data.Image;
            end
            displayGroundData(this,false);

            if~this.HideGroundDataInternal&&~isempty(imageInfo.label)
                updateVoxelLabelPlot(this,imageInfo);
            end


            this.AxesHandle.Tag=originalTag;

            if~this.LimitsDataInternal
                adjustAxisLimits(this,data);
            end
        end


        function displayGroundData(this,varargin)
            displayGroundData@lidar.internal.labeler.tool.display.PointCloudDisplay(this);
            if this.LimitsDataInternal
                limitsLidarData(this);
            end

            if this.HideGroundDataInternal
                updateVoxelLabelGroundData(this);

                setGroundRemovedData(this.VoxelLabeler,this.GroundRemovedPointCloud);

            elseif nargin==1
                imageInfo=getLabelAndColorData(this.VoxelLabeler);
                updateVoxelLabelPlot(this,imageInfo);

                setGroundRemovedData(this.VoxelLabeler,pointCloud.empty);
            end
        end


        function clusterLidarData(this)
            clusterLidarData@lidar.internal.labeler.tool.display.PointCloudDisplay(this);
            if this.LimitsDataInternal
                limitsLidarData(this);
            end
        end

        function updateVoxelLabelPlot(this,imageInfo)

            if~isempty(imageInfo.label)&&any(~isnan(this.ImageHandle.XData))

                previousPlotProp=this.AxesHandle.NextPlot;
                this.AxesHandle.NextPlot='add';

                for seqID=1:size(imageInfo.cmap,1)
                    idx=find(imageInfo.label(:,4)==seqID);
                    if~isempty(idx)
                        sNew=scatter3(this.AxesHandle,imageInfo.label(idx,1),imageInfo.label(idx,2),imageInfo.label(idx,3),...
                        1,'.','MarkerEdgeColor',imageInfo.cmap(seqID,:));

                        if~isempty(this.LabelScatterPlot)
                            delete(this.LabelScatterPlot(seqID));
                        else
                            this.LabelScatterPlot=repmat(matlab.graphics.chart.primitive.Scatter,255,1);
                        end

                        this.LabelScatterPlot(seqID)=sNew;
                        if~isempty(this.PointDimensionInternal)
                            this.LabelScatterPlot(seqID).SizeData=this.PointDimensionInternal;
                        end
                    elseif~isempty(this.LabelScatterPlot)
                        delete(this.LabelScatterPlot(seqID));
                    end
                end

                this.AxesHandle.NextPlot=previousPlotProp;
            end
        end


        function updateVoxelLabelGroundData(this)


            imageInfo=getLabelAndColorData(this.VoxelLabeler);

            if~isempty(imageInfo.label)
                if size(this.GroundRemovedPointCloud.Location,3)==3
                    removedData=find(isnan(this.GroundRemovedPointCloud.Location(:,:,1)));
                else
                    removedData=find(isnan(this.GroundRemovedPointCloud.Location(:,1)));
                end
                imageInfo.label(removedData,4)=0;

                updateVoxelLabelPlot(this,imageInfo);
            end

        end


        function cuboidLabeler=getCuboidLabeler(~)
            cuboidLabeler=lidar.internal.lidarLabeler.tool.CuboidLabeler();
        end



        function limitsLidarData(this)





            try

                if this.HideGroundDataInternal&&~isempty(this.GroundRemovedPointCloud)
                    pc=this.GroundRemovedPointCloud;
                else
                    pc=this.PointCloud;
                end

                roi=[this.LimitsInternal(1),this.LimitsInternal(2),this.LimitsInternal(3)...
                ,this.LimitsInternal(4),this.LimitsInternal(5),this.LimitsInternal(6)];

                if~isequal(roi,[pc.XLimits,pc.YLimits,pc.ZLimits])

                    indices=findPointsInROI(pc,roi);
                    newPc=select(pc,indices);

                    set(this.AxesHandle,'XLim',newPc.XLimits,'YLim',newPc.YLimits,'ZLim',newPc.ZLimits);
                    this.ImageHandle.SizeData=this.PointDimensionInternal;

                    for seqNo=1:length(this.LabelScatterPlot)
                        if isvalid(this.LabelScatterPlot(seqNo))
                            this.LabelScatterPlot(seqNo).SizeData=this.PointDimensionInternal;
                        end
                    end

                    if ishandle(this.LimitsSettings.Dialog)
                        if~isWebFigure(this)
                            update(this.LimitsSettings.Dialog,...
                            this.LimitsSettings.XMinLimits,...
                            this.LimitsSettings.XMaxLimits,...
                            this.LimitsSettings.YMinLimits,...
                            this.LimitsSettings.YMaxLimits,...
                            this.LimitsSettings.ZMinLimits,...
                            this.LimitsSettings.ZMaxLimits,...
                            this.LimitsSettings.PointDimension);
                            eventData=lidar.internal.lidarLabeler.tool.LidarLimitsEventData(true,...
                            this.LimitsSettings.Dialog.XMinSlider.Value,...
                            this.LimitsSettings.Dialog.XMaxSlider.Value,...
                            this.LimitsSettings.Dialog.YMinSlider.Value,...
                            this.LimitsSettings.Dialog.YMaxSlider.Value,...
                            this.LimitsSettings.Dialog.ZMinSlider.Value,...
                            this.LimitsSettings.Dialog.ZMaxSlider.Value,...
                            this.LimitsSettings.Dialog.PointDimensionSlider.Value);
                        else
                            update(this.LimitsSettings.Dialog,...
                            double(newPc.XLimits(1)),...
                            double(newPc.XLimits(2)),...
                            double(newPc.YLimits(1)),...
                            double(newPc.YLimits(2)),...
                            double(newPc.ZLimits(1)),...
                            double(newPc.ZLimits(2)),...
                            this.ImageHandle.SizeData);
                            eventData=lidar.internal.lidarLabeler.tool.LidarLimitsEventData(true,...
                            this.LimitsSettings.Dialog.XMinSlider.Value,...
                            this.LimitsSettings.Dialog.XMaxSlider.Value,...
                            this.LimitsSettings.Dialog.YMinSlider.Value,...
                            this.LimitsSettings.Dialog.YMaxSlider.Value,...
                            this.LimitsSettings.Dialog.ZMinSlider.Value,...
                            this.LimitsSettings.Dialog.ZMaxSlider.Value,...
                            this.LimitsSettings.Dialog.PointDimensionSlider.Value);
                        end
                        updateSliderDisplay(this.LimitsSettings.Dialog,eventData);
                    end
                    this.LimitsSettings.XMinInternal=double(newPc.XLimits(1));
                    this.LimitsSettings.XMaxInternal=double(newPc.XLimits(2));
                    this.LimitsSettings.YMinInternal=double(newPc.YLimits(1));
                    this.LimitsSettings.YMaxInternal=double(newPc.YLimits(2));
                    this.LimitsSettings.ZMinInternal=double(newPc.ZLimits(1));
                    this.LimitsSettings.ZMaxInternal=double(newPc.ZLimits(2));
                end
            catch



                displayEmptyPointCloudOnError(this);


                delete(this.LabelScatterPlot);
                this.LabelScatterPlot=[];
            end
            this.LimitsDataInternal=true;
        end

    end

    methods

        function resetVoxelLabeler(this,data)
            this.VoxelLabeler.reset(data);
        end


        function deleteVoxelLabelData(this,voxelID)
            deleteVoxelLabelData(this.VoxelLabeler,voxelID);
        end


        function setLimitsData(this,TF,xmin,xmax,ymin,ymax,zmin,zmax,pointSize)
            this.Limits=[xmin,xmax,ymin,ymax,zmin,zmax];
            this.PointDimension=pointSize;
            this.LimitsData=TF;
        end

        function setFullView(this)
            this.LimitsDataInternal=false;
            if this.ClusterData
                clusterLidarData(this);
                set(this.AxesHandle,'XLim',this.PointCloud.XLimits,'YLim',...
                this.PointCloud.YLimits,'ZLim',this.PointCloud.ZLimits);
            elseif this.HideGroundDataInternal&&~this.ClusterData
                displayGroundData(this);
                set(this.AxesHandle,'XLim',this.PointCloud.XLimits,'YLim',...
                this.PointCloud.YLimits,'ZLim',this.PointCloud.ZLimits);
            else
                set(this.AxesHandle,'XLim',this.PointCloud.XLimits,'YLim',...
                this.PointCloud.YLimits,'ZLim',this.PointCloud.ZLimits);
            end
            this.ImageHandle.SizeData=10;

            this.PointDimensionInternal=10;
            setVoxellabelPointSize(this.VoxelLabeler,10);
            for seqNo=1:length(this.LabelScatterPlot)
                if isvalid(this.LabelScatterPlot(seqNo))
                    this.LabelScatterPlot(seqNo).SizeData=10;
                end
            end

        end

        function setCameraViewLimits(this)
            XLim=this.AxesHandle.XLim;
            YLim=this.AxesHandle.YLim;
            ZLim=this.AxesHandle.ZLim;
            this.LimitsSettings.XMinInternal=double(XLim(1));
            this.LimitsSettings.XMaxInternal=double(XLim(2));
            this.LimitsSettings.YMinInternal=double(YLim(1));
            this.LimitsSettings.YMaxInternal=double(YLim(2));
            this.LimitsSettings.ZMinInternal=double(ZLim(1));
            this.LimitsSettings.ZMaxInternal=double(ZLim(2));
            if~isequal(this.PointCloud.XLimits,XLim)||...
                isequal(this.PointCloud.YLimits,YLim)||...
                isequal(this.PointCloud.ZLimits,ZLim)
                this.LimitsDataInternal=true;
            end
        end


        function set.UsePCFit(this,TF)
            this.CuboidLabeler.UsePCFit=TF;
        end



        function cameraViewCallback(this,index,operation)









            switch(operation)
            case 0

                if numel(this.CameraViewParameters)<index
                    return;
                end
                this.changeCameraView(index);
            case 1
                if index~=0
                    return
                end

                this.saveCameraView();
            case 2

                this.CameraViewParameters(index)=[];

            end
        end


        function saveCameraView(this)

            this.CameraViewParameters{end+1}={this.AxesHandle.CameraPosition;...
            this.AxesHandle.CameraTarget;...
            this.AxesHandle.CameraViewAngle;...
            this.AxesHandle.CameraViewAngleMode;...
            this.AxesHandle.CameraUpVector;...
            this.AxesHandle.XLim;...
            this.AxesHandle.YLim;...
            this.AxesHandle.ZLim};
        end


        function changeCameraView(this,index)

            this.AxesHandle.CameraPosition=this.CameraViewParameters{index}{1};
            this.AxesHandle.CameraTarget=this.CameraViewParameters{index}{2};
            this.AxesHandle.CameraViewAngle=this.CameraViewParameters{index}{3};
            this.AxesHandle.CameraViewAngleMode=this.CameraViewParameters{index}{4};
            this.AxesHandle.CameraUpVector=this.CameraViewParameters{index}{5};
            this.AxesHandle.XLim=this.CameraViewParameters{index}{6};
            this.AxesHandle.YLim=this.CameraViewParameters{index}{7};
            this.AxesHandle.ZLim=this.CameraViewParameters{index}{8};
        end


        function loadCameraViewFromSession(this,cameraViewFromSession)

            for i=1:numel(cameraViewFromSession)
                cameraParams={cameraViewFromSession{i}.Parameter1;...
                cameraViewFromSession{i}.Parameter2;...
                cameraViewFromSession{i}.Parameter3;...
                cameraViewFromSession{i}.Parameter4;...
                cameraViewFromSession{i}.Parameter5;...
                cameraViewFromSession{i}.Parameter6;...
                cameraViewFromSession{i}.Parameter7;...
                cameraViewFromSession{i}.Parameter8};
                this.CameraViewParameters{end+1}=cameraParams;
            end
        end

        function savedCameraParameters=getSavedCameraParameters(this)

            savedCameraParameters=...
            this.CameraViewParameters;
        end


        function openLimitsSettings(this,limitsSettings)
            this.LimitsSettings=limitsSettings;
            open(limitsSettings,this.PointCloud);
        end


        function set.LimitsData(this,TF)
            this.LimitsDataInternal=TF;
            if TF
                limitsLidarData(this);
            end
        end




        function set.Limits(this,val)
            this.LimitsInternal=val;
        end


        function set.PointDimension(this,val)
            this.PointDimensionInternal=val;
            setVoxellabelPointSize(this.VoxelLabeler,val);
        end


        function tf=isWebFigure(this)
            tf=vision.internal.labeler.jtfeature('UseAppContainer');
        end
    end

end
