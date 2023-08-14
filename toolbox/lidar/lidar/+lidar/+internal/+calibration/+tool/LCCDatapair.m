classdef LCCDatapair<handle















    properties(GetAccess='public',SetAccess='private')

        ImageFile=[];
        PointcloudFile=[];


        ImageFeatures=struct('ImageCorners3d',[],'BoardSize',[],'ImageIndicesOfBoardCorners',[]);
        PointcloudFeatures=struct('ManuallySelectedPoints',[],'CheckerboardPlaneIndices',[]);
    end

    properties(GetAccess='public',SetAccess=?lidar.internal.calibration.tool.LCCModel)

        ImagePoints=[];

        LidarPointsOnImage=[];
        ImageColorsOnPointcloud=[];
    end

    properties(SetAccess='private',Hidden)

        IsValidPair=false;

        Image=[];
        UndistortedImage=[];
        Pointcloud=[];
        ThumbnailImage=[];
    end

    methods
        function this=LCCDatapair(imageFile,pointCloudFile)
            this.IsValidPair=(isfile(imageFile)&&isfile(pointCloudFile));
            this.ImageFile=imageFile;
            this.PointcloudFile=pointCloudFile;
        end
    end

    methods(Access={?lidar.internal.calibration.tool.LCCModel,...
        ?matlab.unittest.TestCase})
        function load(this)
            if(~this.IsValidPair)
                return;
            end
            try
                this.Image=imread(this.ImageFile);
                this.Pointcloud=removeInvalidPoints(pcread(this.PointcloudFile));
                this.ThumbnailImage=makeThumbnail(this);
                this.IsValidPair=true;
            catch ME
                this.IsValidPair=false;
                error(ME.message);
            end
        end

        function setUndistortedImage(this,intrinsics)
            if isempty(this.Image)

                im=imread(this.ImageFile);
            else
                im=this.Image;
            end
            this.UndistortedImage=undistortImage(im,intrinsics);
        end

        function value=isEmpty(this)


            value=false(size(this));
            for i=1:length(this)
                value(i)=(isempty(this(i).Image)||isempty(this(i).Pointcloud));
            end
        end

        function clearCalibrationResults(this)
            for i=1:length(this)
                this(i).LidarPointsOnImage=[];
                this(i).ImageColorsOnPointcloud=[];
            end
        end

        function saveSelectedPoints(this,pts)

            this.PointcloudFeatures.ManuallySelectedPoints=pts;
        end

        function[ptCloudUsed,lidarPlaneIndices]=getLidarPlaneIndices(this,params)

            ptCloudUsed=false;
            lidarPlaneIndices=[];

            if isempty(this.PointcloudFeatures.ManuallySelectedPoints)||numel(find(this.PointcloudFeatures.ManuallySelectedPoints))<3


                return
            end
            pc=this.getPointcloud(false);
            location=pc.Location;
            selectedPointCloud=pointCloud(location(this.PointcloudFeatures.ManuallySelectedPoints,:));



            [~,inliers]=pcfitplane(selectedPointCloud,0.1);
            segmentedPlane=select(selectedPointCloud,inliers);
            rectModel=lidar.internal.calibration.fitRectangle3D(segmentedPlane,'O','YPR','Iterations',30);
            dimensions=rectModel.Dimensions;
            dimensions=sort(dimensions,"descend");
            length=dimensions(1);
            width=dimensions(2);

            planeDimension=this.ImageFeatures.BoardSize/1000;
            tolerance=params.getDimensionTolerance();


            minWidthToCheck=planeDimension(1)-planeDimension(1)*tolerance;
            maxWidthToCheck=planeDimension(1)+planeDimension(1)*tolerance;


            minLengthToCheck=planeDimension(2)-planeDimension(2)*tolerance;
            maxLengthToCheck=planeDimension(2)+planeDimension(2)*tolerance;



            if length<maxLengthToCheck&&length>minLengthToCheck&&...
                width>minWidthToCheck&&width<maxWidthToCheck
                lidarPlane=segmentedPlane;
                ptCloudUsed=true;
                lidarPlaneIndices{1}=ismember(location,lidarPlane.Location,'rows');
            end
        end

        function featuresDetectedFlag=detectFeatures(this,params,imageFeatures,pointCloudFeatures,boardSize,worldPoints)

            featuresDetectedFlag=false;
            if(isEmpty(this))
                return;
            end
            imageFeatures=imageFeatures||~this.hasValidImageFeatures();
            if(imageFeatures)
                try
                    planeDimension=boardSize*params.getCheckerboardSquareSizeInMillimeters();
                    padding=params.getCheckerboardPaddingInMillimeters();
                    planeDimension=planeDimension+[padding(2)+padding(4),padding(1)+padding(3)];

                    undistortedPoints=undistortPoints(this.ImagePoints,params.getCameraIntrinsics());
                    [imageCorners3d,dataUsed]=lidar.internal.calibration.extractCorners(undistortedPoints,worldPoints,boardSize,padding,params.getCheckerboardSquareSizeInMillimeters(),params.getCameraIntrinsics(),true);
                catch

                    dataUsed=false;
                    imageCorners3d=[];
                    planeDimension=[];
                end
                if(dataUsed)

                    imPts=projectLidarPointsOnImage(imageCorners3d,params.getCameraIntrinsics(),rigid3d());
                else
                    imPts=[];
                end


                this.ImageFeatures.ImageCorners3d=imageCorners3d;
                this.ImageFeatures.BoardSize=planeDimension;
                this.ImageFeatures.ImageIndicesOfBoardCorners=imPts;
            end

            if(pointCloudFeatures&&this.hasValidImageFeatures())

                try


                    [ptCloudUsed,lidarCheckerboardPlaneIndices]=this.getLidarPlaneIndices(params);

                    if~ptCloudUsed||isempty(lidarCheckerboardPlaneIndices)


                        [~,ptCloudUsed,lidarCheckerboardPlaneIndices]=detectRectangularPlanePoints(...
                        this.Pointcloud,this.ImageFeatures.BoardSize,...
                        'RemoveGround',params.getRemoveGround(),...
                        'ROI',params.getROI(),...
                        'DimensionTolerance',params.getDimensionTolerance(),...
                        'MinDistance',params.getClusterThreshold());
                    end

                    if(~ptCloudUsed)
                        lidarCheckerboardPlaneIndices=[];
                    else
                        lidarCheckerboardPlaneIndices=find(lidarCheckerboardPlaneIndices{1});
                    end
                catch

                    lidarCheckerboardPlaneIndices=[];
                end
                this.PointcloudFeatures.CheckerboardPlaneIndices=lidarCheckerboardPlaneIndices;
            end

            featuresDetectedFlag=hasValidFeatures(this);
        end
    end

    methods(Access={?lidar.internal.calibration.tool.LCCModel,...
        ?lidar.internal.calibration.tool.LCCView,...
        ?matlab.unittest.TestCase})
        function im=getImage(this,overlayFeaturesFlag)
            im=[];
            if(isEmpty(this))
                return;
            end
            if(~exist('overlayFeaturesFlag','var'))
                overlayFeaturesFlag=false;
            end
            if(~overlayFeaturesFlag)
                im=getImageForDisplay(this);
            else
                im=overlayFeaturesOnImage(this);
            end
        end

        function pc=getPointcloud(this,overlayFeaturesFlag)
            pc=[];
            if(isEmpty(this))
                return;
            end
            if(~exist('overlayFeaturesFlag','var'))
                overlayFeaturesFlag=false;
            end
            if(~overlayFeaturesFlag)
                pc=this.Pointcloud;
            else
                pc=overlayFeaturesOnPointcloud(this);
            end
        end

        function im=getImageForDisplay(this)




            if~isempty(this.UndistortedImage)
                img=this.UndistortedImage;
            else
                img=this.Image;
            end
            try
                im=imadjustn(im2uint8(img));
            catch
                im=img;
            end

            if size(im,3)==1
                im=repmat(im,1,1,3);
            end
        end

        function pts=getManuallySelectedPoints(this)
            pts=this.PointcloudFeatures.ManuallySelectedPoints;
        end

        function value=getImageCorners3d(this)
            value=this.ImageFeatures.ImageCorners3d;
        end

        function value=hasValidFeatures(this)

            value=false(size(this));
            for i=1:length(this)
                value(i)=hasValidImageFeatures(this(i))&&hasValidPointcloudFeatures(this(i));
            end
        end

        function value=hasValidImageFeatures(this)
            value=(~isempty(this.ImageFeatures)...
            &&~isempty(this.ImageFeatures.ImageCorners3d)...
            &&~isempty(this.ImageFeatures.BoardSize));
        end

        function value=hasValidPointcloudFeatures(this)
            value=(~isempty(this.PointcloudFeatures)&&~isempty(this.PointcloudFeatures.CheckerboardPlaneIndices));
        end

        function value=getCheckerboardPlane(this)
            value=[];
            if(~this.IsValidPair)
                return;
            end
            if(hasValidPointcloudFeatures(this))
                if(~isempty(this.PointcloudFeatures.CheckerboardPlaneIndices))
                    value=this.Pointcloud.select(this.PointcloudFeatures.CheckerboardPlaneIndices);
                end
            end
        end
    end

    methods(Hidden,Access={?lidar.internal.calibration.tool.LCCModel})
        function flag=isValid(this)
            flag=this.IsValidPair;
        end
    end

    methods(Access={?matlab.unittest.TestCase})

        function thumbnailImg=makeThumbnail(this)

            thumbnailSize=[100,150];

            f=figure('Visible','off');
            pcs=pcshow(pointCloud(rand(10,3)),MarkerSize=30,...
            Parent=axes(f),Projection="orthographic");

            xlim([-10,10]);ylim([-10,10]);

            campos([-65,-20,30]);
            zoom(3);
            grid("off");


            pcs.Children.XData=this.Pointcloud.Location(:,1);
            pcs.Children.YData=this.Pointcloud.Location(:,2);
            pcs.Children.ZData=this.Pointcloud.Location(:,3);
            if(~isempty(this.Pointcloud.Color))
                pcs.Children.CData=this.Pointcloud.Color;
            elseif(~isempty(this.Pointcloud.Intensity))
                pcs.Children.CData=reshape(label2rgb(uint8(this.Pointcloud.Intensity)),[],3);
            else
                pcs.Children.CData=reshape(label2rgb(uint16(abs(this.Pointcloud.Location(:,3))*1000)),[],3);
            end

            img=getImageForDisplay(this);

            pointcloudThumbnail=imresize(getframe(pcs).cdata,thumbnailSize);
            imageThumbnail=imresize(img,thumbnailSize);



            thumbnailImg=[[imageThumbnail,pointcloudThumbnail];zeros(24,thumbnailSize(2)*2,3,'uint8')];

            close(f);
        end

        function img=overlayFeaturesOnImage(this)
            img=getImageForDisplay(this);
            featuresMarked=false;
            font=lidar.internal.getFontByPlatform();

            if(this.hasValidImageFeatures())

                markerColor='red';
                img=insertMarker(img,this.ImageFeatures.ImageIndicesOfBoardCorners,'*','color',markerColor,'size',10);
                img=insertMarker(img,this.ImageFeatures.ImageIndicesOfBoardCorners,'o','color',markerColor,'size',20);
                img=insertMarker(img,this.ImageFeatures.ImageIndicesOfBoardCorners,'o','color',markerColor,'size',18);
                img=insertMarker(img,this.ImageFeatures.ImageIndicesOfBoardCorners,'o','color',markerColor,'size',16);


                fontSize=floor(size(img,1)*0.025);
                if(fontSize<=12)
                    fontSize=12;
                end

                img=insertText(img,[10,10],...
                string(message('lidar:lidarCameraCalibrator:cbCornersText')),...
                'FontSize',fontSize,'Font',font,'TextColor',markerColor,"BoxColor","yellow");
                featuresMarked=true;
                img=insertShape(img,'line',...
                [this.ImageFeatures.ImageIndicesOfBoardCorners;this.ImageFeatures.ImageIndicesOfBoardCorners(1,:)],...
                'LineWidth',5,'Color',markerColor);
            end


            if(~isempty(this.LidarPointsOnImage))
                markerColor=[0,0,0.7]*255;
                img=insertMarker(img,this.LidarPointsOnImage,'o','color',markerColor,'size',1);
                img=insertMarker(img,this.LidarPointsOnImage,'o','color',markerColor,'size',2);
                img=insertMarker(img,this.LidarPointsOnImage,'o','color',markerColor,'size',3);
                img=insertMarker(img,this.LidarPointsOnImage,'o','color',markerColor,'size',4);

                pos=[10,10];
                if(featuresMarked)
                    pos=[10,10+fontSize*2+5];
                end

                fontSize=floor(size(img,1)*0.025);
                if(fontSize<=12)
                    fontSize=12;
                end
                img=insertText(img,pos,...
                string(message('lidar:lidarCameraCalibrator:projectedLidarPointsText')),...
                'FontSize',fontSize,'Font',font,'TextColor',markerColor,"BoxColor","yellow");
            end
        end

        function ptCloud=overlayFeaturesOnPointcloud(this)

            ptCloud=this.Pointcloud;
            if(~isempty(this.ImageColorsOnPointcloud))
                ptCloud=pointCloud(this.Pointcloud.Location,'Color',this.ImageColorsOnPointcloud);
                return;
            end

            if(this.hasValidPointcloudFeatures)


                if(~isempty(this.PointcloudFeatures.CheckerboardPlaneIndices))
                    color=uint8(ones(ptCloud.Count,3)+[10,10,200]);
                    color(this.PointcloudFeatures.CheckerboardPlaneIndices,:)=255;
                    ptCloud=pointCloud(this.Pointcloud.Location,'Color',color);
                    return;
                end
            end

            color=ptCloud.Color;
            if(isempty(color))

                if(~isempty(ptCloud.Intensity))

                    color=reshape(label2rgb(uint8(ptCloud.Intensity)),[],3);
                else

                    color=reshape(label2rgb(uint16(abs(ptCloud.Location(:,3))*1000)),[],3);
                end
            end
            ptCloud=pointCloud(this.Pointcloud.Location,'Color',color);
        end
    end

    methods(Hidden)
        function s=saveobj(this)

            s=struct(this);
        end

        function s=struct(this)



            for i=1:length(this)
                s(i).ImageFile=this(i).ImageFile;
                s(i).PointcloudFile=this(i).PointcloudFile;

                s(i).ImageFeatures=this(i).ImageFeatures;
                s(i).PointcloudFeatures=this(i).PointcloudFeatures;

                s(i).LidarPointsOnImage=this(i).LidarPointsOnImage;
                s(i).ImageColorsOnPointcloud=this(i).ImageColorsOnPointcloud;
                s(i).ImagePoints=this(i).ImagePoints;
            end
        end
    end

    methods(Static,Hidden)
        function this=loadobj(s)

            this=lidar.internal.calibration.tool.LCCDatapair(s.ImageFile,s.PointcloudFile);
            this.ImageFeatures=s.ImageFeatures;
            if~isfield(s.PointcloudFeatures,'ManuallySelectedPoints')



                s.PointcloudFeatures.ManuallySelectedPoints=[];
            end
            this.PointcloudFeatures=s.PointcloudFeatures;
            this.LidarPointsOnImage=s.LidarPointsOnImage;
            this.ImageColorsOnPointcloud=s.ImageColorsOnPointcloud;
            if isfield(s,'ImagePoints')


                this.ImagePoints=s.ImagePoints;
            end
        end
    end
end
