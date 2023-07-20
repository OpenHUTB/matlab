classdef LCCModel<handle











    properties(GetAccess='public',SetAccess='private')

        Datapairs=[];
        Params=lidar.internal.calibration.tool.APIParameters;


        NumDatapairs=0;


        WorldPoints=[];
        BoardSize=[];


        LidarToCameraTransform=[];
        CalibrationErrors=[];


        SessionModifiedFromLastSave=false;
    end

    properties(Hidden,SetAccess='private')

        NewSessionFlag=true;
    end

    methods
        function this=LCCModel()
            initializeState(this);
        end

        function initializeState(this)
            cleanState(this);
            setDefaultParams(this);
            this.NewSessionFlag=true;
        end

        function cleanState(this)

            this.Datapairs=[];
            this.NumDatapairs=0;
            this.Params=lidar.internal.calibration.tool.APIParameters;
            this.NewSessionFlag=true;
            this.clearCalibrationResults();
        end

        function flag=isNewSession(this)
            flag=this.NewSessionFlag;
        end

        function setSessionModified(this,value)
            this.SessionModifiedFromLastSave=value;
        end

        function flag=isDataLoaded(this)
            flag=~isempty(this.NumDatapairs)&&~isempty(this.Datapairs)&&...
            this.NumDatapairs==sum(~isEmpty(this.Datapairs));
        end

        function flag=areFeaturesDetected(this)
            flag=sum(this.Datapairs.hasValidFeatures())>=this.getMinDataPairsForCalibration();
        end

        function flag=isCalibrationDone(this)
            flag=~isempty(this.LidarToCameraTransform)&&~isempty(this.CalibrationErrors);
        end

        function clearCalibrationResults(this)
            this.LidarToCameraTransform=[];
            this.CalibrationErrors=[];
            if(~isempty(this.Datapairs))
                this.Datapairs.clearCalibrationResults();
            end
        end

        function imagePoints=computeImagePoints(this)
            [imagePoints,this.BoardSize,imageIdx]=detectCheckerboardPoints({this.Datapairs.ImageFile}','PartialDetections',false,'MinCornerMetric',this.Params.getMinCornerMetric());
            idx=1;
            for i=1:this.NumDatapairs
                if imageIdx(i)
                    this.Datapairs(i).ImagePoints=imagePoints(:,:,idx);
                    idx=idx+1;
                end
            end
        end

        function computeWorldPoints(this)
            squareSize=this.Params.getCheckerboardSquareSizeInMillimeters();
            this.WorldPoints=generateCheckerboardPoints(this.BoardSize,squareSize);
        end

        function cameraParams=calibrateCamera(this,imagePoints)
            if~isempty(this.Datapairs(1).Image)
                imageSize=[size(this.Datapairs(1).Image,1),size(this.Datapairs(1).Image,2)];
            else

                im=imread(this.Datapairs(1).ImageFile);
                imageSize=[size(im,1),size(im,2)];
            end
            cameraParams=estimateCameraParameters(imagePoints,this.WorldPoints,...
            'ImageSize',imageSize);
        end

        function[params,successFlag]=computeIntrinsics(this)

            successFlag=true;
            try




                imagePoints=this.computeImagePoints();


                this.computeWorldPoints();


                params=this.calibrateCamera(imagePoints);
                params=params.Intrinsics;
            catch
                params=[];
                successFlag=false;
            end
            this.Params.setCameraIntrinsics(params);
            if~isempty(this.Params.getCameraIntrinsics())
                for i=1:this.NumDatapairs
                    this.Datapairs(i).setUndistortedImage(this.Params.getCameraIntrinsics());
                end
            end
        end

        function removeDatapair(this,index)
            if(index<1||index>length(this.Datapairs))
                return;
            end
            this.Datapairs(index)=[];
            this.NumDatapairs=length(this.Datapairs);
            if(this.NumDatapairs<=0)

                this.initializeState();
            end
            this.setSessionModified(true);
        end

        function updateSelectedPoints(this,ptsCellArray)

            for i=1:this.NumDatapairs
                this.Datapairs(i).saveSelectedPoints(ptsCellArray{i});
            end
        end

        function updateSelectedPointsByIndex(this,index,pts)


            this.Datapairs(index).saveSelectedPoints(pts);
        end

        function ptCloud=getCurrentPointcloud(this,index)
            ptCloud=this.Datapairs(index).getPointcloud(true);
        end

        function pts=getSelectedPoints(this)
            pts=cell([1,this.NumDatapairs]);
            for i=1:this.NumDatapairs
                pts{i}=this.getSelectedPointsByIndex(i);
            end
        end

        function pts=getSelectedPointsByIndex(this,index)
            pts=this.Datapairs(index).getManuallySelectedPoints();
        end


        function loadData(this,fig)



            if(isempty(this.Datapairs))
                return;
            end
            fromInd=1;
            for i=1:length(this.Datapairs)
                if(isEmpty(this.Datapairs(i)))
                    fromInd=i;
                    break;
                end
            end

            toInd=length(this.Datapairs);

            showPrgressDialog=~isempty(fig);
            if(showPrgressDialog)
                progressDialog=uiprogressdlg(fig,'Message','',...
                'Title',string(message('lidar:lidarCameraCalibrator:addDataPromptTitle')));
                progressDialog.ShowPercentage='on';
            end

            for i=fromInd:toInd
                if(showPrgressDialog)
                    progressDialog.Message=string(message('lidar:lidarCameraCalibrator:addDataLoading',(i-fromInd)+1,1+(toInd-fromInd)));
                    progressDialog.Value=(i-fromInd+1)/(toInd-fromInd+1);
                end
                this.Datapairs(i).load();
            end

            if~isempty(this.Params.getCameraIntrinsics())
                for i=1:this.NumDatapairs
                    this.Datapairs(i).setUndistortedImage(this.Params.getCameraIntrinsics());
                end
            end

            this.NumDatapairs=length(this.Datapairs);

            if(showPrgressDialog)
                progressDialog.Value=1;
                progressDialog.delete;
            end
        end

        function doDetection(this,fig)

            detectFeatures(this,true,true,fig);
        end

        function detectFeatures(this,detectImgFeaturesFlag,detectPtcFeaturesFlag,fig)


            showPrgressDialog=~isempty(fig);
            if(showPrgressDialog)
                progressDialog=uiprogressdlg(fig,'Message','',...
                'Title',string(message('lidar:lidarCameraCalibrator:progressDialogTitle')));
                progressDialog.ShowPercentage='on';
            end


            if(this.Params.CameraIntrinsics.UseComputedOrLoadedFlag&&isempty(this.Params.CameraIntrinsics.Computed))
                progressDialog.Title=string(message('lidar:lidarCameraCalibrator:computingIntrinsicsDialogTitle'));
                progressDialog.Message=string(message('lidar:lidarCameraCalibrator:computingIntrinsicsDialogMsg'));
                progressDialog.Indeterminate='on';
                [params,successFlag]=computeIntrinsics(this);
                if(~successFlag)

                    if(showPrgressDialog)
                        progressDialog.Message=string(message('lidar:lidarCameraCalibrator:errorComputingIntrinsics'));
                        progressDialog.Icon="error";
                        pause(1);
                        progressDialog.delete;
                    end
                    return;
                end
                this.Params.setCameraIntrinsics(params);
                if~isempty(this.Params.getCameraIntrinsics())
                    for i=1:this.NumDatapairs
                        this.Datapairs(i).setUndistortedImage(this.Params.getCameraIntrinsics());
                    end
                end
                progressDialog.Indeterminate='off';
                progressDialog.Title=string(message('lidar:lidarCameraCalibrator:progressDialogTitle'));
            end

            if(showPrgressDialog)
                progressDialog.Value=0;
            end

            rng('default');
            numDetected=0;
            for i=1:this.NumDatapairs
                progressDialog.Message=string(message('lidar:lidarCameraCalibrator:progressDialogPromptMsg',mat2str(i),mat2str(this.NumDatapairs)));

                detectedFlag=this.Datapairs(i).detectFeatures(this.Params,detectImgFeaturesFlag,detectPtcFeaturesFlag,this.BoardSize,this.WorldPoints);
                numDetected=numDetected+detectedFlag;
                if(showPrgressDialog)
                    progressDialog.Value=i/this.NumDatapairs;
                end
            end

            if(showPrgressDialog)

                progressDialog.Value=1;
                progressDialog.Message=string(message('lidar:lidarCameraCalibrator:progressDialogLastPromptMsg',mat2str(numDetected),mat2str(this.NumDatapairs)));
                progressDialog.Icon="info";
                pause(1);
                progressDialog.delete;


                if numDetected==0
                    noDetectionAlertDlg=uiconfirm(fig,string(message('lidar:lidarCameraCalibrator:noDetectionAlertDlgMsg')),...
                    string(message('lidar:lidarCameraCalibrator:noDetectionAlertDlgTitle')),...
                    'Options',string(message('MATLAB:uistring:popupdialogs:OK')),'Icon','warning');
                end
            end


            clearCalibrationResults(this);

        end

        function successFlag=doCalibration(this)
            successFlag=true;
            lidarCheckerboardPlanes=pointCloud(rand(10,3));
            imageCorners3d=zeros(4,3,1);
            k=0;
            for i=1:this.NumDatapairs
                if(this.Datapairs(i).hasValidFeatures())
                    k=k+1;
                    lidarCheckerboardPlanes(k)=this.Datapairs(i).getCheckerboardPlane();
                    imageCorners3d(:,:,k)=this.Datapairs(i).getImageCorners3d();
                end
            end
            if(k<=0)
                return;
            end

            try
                [this.LidarToCameraTransform,this.CalibrationErrors]=...
                estimateLidarCameraTransform(lidarCheckerboardPlanes,...
                imageCorners3d,this.Params.getCameraIntrinsics(),...
                'InitialTransform',this.Params.getInitialTransform(),...
                'verbose',false);
            catch

                this.LidarToCameraTransform=[];
                this.CalibrationErrors=[];
                successFlag=false;
            end

            if(~isempty(this.LidarToCameraTransform))

                for i=1:this.NumDatapairs
                    try
                        lidarPointsOnImage=...
                        projectLidarPointsOnImage(this.Datapairs(i).getCheckerboardPlane(),...
                        this.Params.getCameraIntrinsics(),this.LidarToCameraTransform);
                    catch
                        lidarPointsOnImage=[];
                    end

                    this.Datapairs(i).LidarPointsOnImage=lidarPointsOnImage;

                    try
                        [~,imageColorsOnPC]=...
                        fuseCameraToLidar(this.Datapairs(i).Image,this.Datapairs(i).Pointcloud,...
                        this.Params.getCameraIntrinsics(),this.LidarToCameraTransform.invert(),'b');
                    catch
                        imageColorsOnPC=[];
                    end

                    this.Datapairs(i).ImageColorsOnPointcloud=imageColorsOnPC;
                end
            end

        end


        function[imgValid,ptcValid,pairValid,imgSizesNotsame,validImgFiles,validPtcFiles]=validateDataPaths(this,imgPath,ptcPath)


            imgValid=true;
            ptcValid=true;
            pairValid=true;
            imgSizesNotsame=false;
            validImgFiles=[];
            validPtcFiles=[];
            try
                imds=imageDatastore(imgPath);
            catch

                imgValid=false;
            end

            try
                pcds=fileDatastore(ptcPath,'ReadFcn',@pcread,'FileExtensions',{'.pcd','.ply'});
            catch

                ptcValid=false;
            end
            if(~imgValid||~ptcValid)
                pairValid=false;
                return;
            end


            [~,ptcFile]=fileparts(pcds.Files);
            [~,imgFile]=fileparts(imds.Files);
            if(length(pcds.Files)==1)



                ptcFile={ptcFile};
            end
            if(length(imds.Files)==1)
                imgFile={imgFile};
            end

            [v,imgInd,ptcInd]=intersect(imgFile,ptcFile);
            if(isempty(v))
                pairValid=false;
                return;
            end

            validImgFiles=imds.Files(imgInd);
            validPtcFiles=pcds.Files(ptcInd);


            validImg=false(length(validImgFiles),1);
            validPtcFile=false(length(validImgFiles),1);

            lastImgSize=[];
            if(this.NumDatapairs>0)

                lastImgSize=size(this.Datapairs(1).Image);
            end

            for i=1:length(validImgFiles)

                try
                    temp=imread(validImgFiles{i});
                    validImg(i)=true;
                    if(isempty(lastImgSize))
                        lastImgSize=size(temp);
                    else
                        if(~isequal(lastImgSize,size(temp)))

                            imgSizesNotsame=true;
                            return;
                        end
                    end

                catch

                    validImg(i)=false;
                end

                try
                    temp=pcread(validPtcFiles{i});%#ok<NASGU>
                    validPtcFile(i)=true;
                catch

                    validPtcFile(i)=false;
                end
            end
            imgValid=any(validImg);
            ptcValid=any(validPtcFile);
            validPairs=find(validImg&validPtcFile);
            pairValid=~isempty(validPairs);

            validImgFiles=validImgFiles(validPairs);
            validPtcFiles=validPtcFiles(validPairs);
        end

        function[errorStatus,messageId]=addDataFiles(this,imgPath,ptcPath)




            errorStatus=0;
            messageId='';

            [imgValid,ptcValid,pairValid,imgSizesNotsame,validImgFiles,validPtcFiles]=validateDataPaths(this,imgPath,ptcPath);

            if(~imgValid)
                errorStatus=2;
                messageId='lidar:lidarCameraCalibrator:addDataEmptyImageFolder';
                return;
            end

            if(~ptcValid)
                errorStatus=2;
                messageId='lidar:lidarCameraCalibrator:addDataEmptyPointcloudFolder';
                return;
            end

            if(~pairValid)
                errorStatus=2;
                messageId='lidar:lidarCameraCalibrator:addDataNoMatchingPairs';

                return;
            end

            if(imgSizesNotsame)
                errorStatus=2;

                if(this.NumDatapairs<=0)
                    messageId='lidar:lidarCameraCalibrator:imageSizesMismatch';
                else
                    messageId='lidar:lidarCameraCalibrator:imageSizesMismatchWithSession';
                end
                return;
            end

            imgFileList=validImgFiles;
            ptcFileList=validPtcFiles;
            currentImgFiles=[];
            currentPointcloudFiles=[];
            if(~isempty(this.Datapairs))
                currentImgFiles={this.Datapairs.ImageFile}';
                currentPointcloudFiles={this.Datapairs.PointcloudFile}';
            end
            if(isempty(currentImgFiles))

                currentImgFiles=imgFileList;
                currentPointcloudFiles=ptcFileList;
                messageId=string(message('lidar:lidarCameraCalibrator:addDataInfo',length(currentImgFiles)));
            else

                commonFiles=intersect(currentImgFiles,imgFileList);
                if(~isempty(commonFiles)||~isempty(intersect(currentPointcloudFiles,ptcFileList)))

                    errorStatus=1;
                    messageId='lidar:lidarCameraCalibrator:addDataDuplicatePairs';
                    if(isempty(setdiff(imgFileList,currentImgFiles))||isempty(setdiff(ptcFileList,currentPointcloudFiles)))




                        errorStatus=2;
                        messageId='lidar:lidarCameraCalibrator:addDataDuplicatePairs';
                        return;
                    else

                        currentImgFiles=setdiff(imgFileList,currentImgFiles);
                        currentPointcloudFiles=setdiff(ptcFileList,currentPointcloudFiles);
                    end
                else

                    currentImgFiles=imgFileList;
                    currentPointcloudFiles=ptcFileList;
                end
            end

            this.NewSessionFlag=false;
            for i=1:length(currentImgFiles)
                this.Datapairs=[this.Datapairs,lidar.internal.calibration.tool.LCCDatapair(currentImgFiles{i},currentPointcloudFiles{i})];
            end
            this.NumDatapairs=length(this.Datapairs);
        end
    end

    methods

        function value=getCheckerboardSettings(this)
            value.Units=this.Params.getCheckerboardSettingUnits();
            value.Squaresize=this.Params.getCheckerboardSquareSize();
            value.Padding=this.Params.getCheckerboardPadding();
        end

        function setCheckerboardSettings(this,value)
            this.Params.setCheckerboardSettingUnits(value.Units);
            this.Params.setCheckerboardSquareSize(value.Squaresize);
            this.Params.setCheckerboardPadding(value.Padding);
        end

        function value=getMinDataPairsForCalibration(this)
            value=this.Params.MinDataPairsForCalibration;
        end
    end

    methods

        function setDefaultParams(this)
            this.Params=lidar.internal.calibration.tool.APIParameters;
        end

        function setInitialValues(this,view)
            cuboidPosition=getCuboidPositionFromROI(this.Params);
            setInitialValues(view,...
            this.Params.getRemoveGround(),...
            this.Params.getClusterThreshold(),...
            this.Params.getDimensionTolerance(),...
            cuboidPosition);
        end
    end


    methods


        function validSession=loadSession(this,sessionData)

            validSession=false;
            if(isempty(sessionData))
                return;
            end
            try
                this.NumDatapairs=sessionData.NumDatapairs;
                this.Datapairs=sessionData.Datapairs;
                this.Params=sessionData.AlgorithmParameters;
                this.LidarToCameraTransform=sessionData.LidarToCameraTransform;
                this.CalibrationErrors=sessionData.CalibrationErrors;

                if(isfield(sessionData,'WorldPoints')&&isempty(sessionData.WorldPoints))||...
                    (isfield(sessionData,'BoardSize')||isempty(sessionData.BoardSize))
                    this.computeIntrinsics();
                else
                    this.WorldPoints=sessionData.WorldPoints;
                    this.BoardSize=sessionData.BoardSize;
                end
            catch
                validSession=false;
                return;
            end
            this.NewSessionFlag=false;
            validSession=true;
        end
    end

    methods
        function updateFigureInView(this,view,index)
            if(index<1||index>this.NumDatapairs||isempty(this.Datapairs))
                return;
            end

            imgDetected=string(message('lidar:lidarCameraCalibrator:sbImageFeaturesDetected'));
            ptcDetected=string(message('lidar:lidarCameraCalibrator:sbPointcloudFeaturesDetected'));
            if(~this.Datapairs(index).hasValidImageFeatures())
                imgDetected=string(message('lidar:lidarCameraCalibrator:sbImageFeaturesNotDetected'));
            end
            if(~this.Datapairs(index).hasValidPointcloudFeatures())
                ptcDetected=string(message('lidar:lidarCameraCalibrator:sbPointcloudFeaturesNotDetected'));
            end

            k=string(message('lidar:lidarCameraCalibrator:sbDatabrowserItemSelected'))+...
            ": [ "+imgDetected+" ] , [ "+ptcDetected+" ].";

            view.updateStatusText(k);

            view.CurrentItemIndex=index;
            view.CurrentItemSelectedPoints=this.getSelectedPointsByIndex(index);
            view.HasValidPCFeatures=this.Datapairs(index).hasValidPointcloudFeatures();

            updateImageData(view,this.Datapairs(index).getImage(true),...
            dir(this.Datapairs(index).ImageFile).name)

            updatePointcloudData(view,this,this.Datapairs(index).getPointcloud(true),...
            dir(this.Datapairs(index).PointcloudFile).name);

        end

        function generateScript(this)
            codeGenerator=vision.internal.calibration.tool.MCodeGenerator;

            codeGenerator.addLine(sprintf(['%% Auto-generated by ',...
            '%s app on %s'],'LidarCameraCalibrator',date));
            codeGenerator.addLine(['%----------------------------------------',...
            '---------------']);
            codeGenerator.addLine('% ');

            codeGenerator.addReturn();
            codeGenerator.addLine('%% Image files');
            imageFilePaths={this.Datapairs.ImageFile}';
            files=sprintf(sprintf("%s %s",repmat("'%s'; ...\n\t",[1,length(imageFilePaths)-1]),"'%s'"),imageFilePaths{1:end});
            codeGenerator.addLine(sprintf('imageFilePaths = { %s };',files));

            codeGenerator.addReturn();
            codeGenerator.addLine('%% Point cloud files');
            ptcFilePaths={this.Datapairs.PointcloudFile}';
            files=sprintf(sprintf("%s %s",repmat("'%s'; ...\n\t",[1,length(ptcFilePaths)-1]),"'%s'"),ptcFilePaths{1:end});
            codeGenerator.addLine(sprintf('ptcFilePaths = { %s };',files));

            codeGenerator.addReturn();
            codeGenerator.addLine('%% Load initial parameters');
            codeGenerator.addLine(sprintf('squareSize = %d;',this.Params.getCheckerboardSquareSizeInMillimeters()));
            codeGenerator.addLine(sprintf('padding = %s;',mat2str(this.Params.getCheckerboardPaddingInMillimeters())));


            codeGenerator.addReturn();

            if(this.Params.CameraIntrinsics.UseComputedOrLoadedFlag)

                codeGenerator.addLine('%% Compute camera intrinsics');
                codeGenerator.addLine('% Detect calibration pattern');
                codeGenerator.addLine('[imagePoints, boardSize] = detectCheckerboardPoints(imageFilePaths);');

                codeGenerator.addLine('% Generate world coordinates of the corners of the squares');
                codeGenerator.addLine('worldPoints = generateCheckerboardPoints(boardSize, squareSize);');

                codeGenerator.addLine('% Calibrate the camera');
                codeGenerator.addLine('I = imread(imageFilePaths{1});');
                codeGenerator.addLine('imageSize = [size(I, 1), size(I, 2)];');
                codeGenerator.addLine('params = estimateCameraParameters(imagePoints, worldPoints, ''ImageSize'', imageSize);');
                codeGenerator.addLine('intrinsics = params.Intrinsics;');
            else

                codeGenerator.addLine(sprintf('intrinsics = %s;',this.Params.CameraIntrinsics.LoadStringForGenScript));
            end

            codeGenerator.addReturn();
            codeGenerator.addLine('%% Estimate 3D checkerboard points from images');
            codeGenerator.addLine(sprintf('minCornerMetric = %f;',this.Params.getMinCornerMetric()));
            codeGenerator.addLine('[imageCorners3d, planeDimension, dataUsed] = estimateCheckerboardCorners3d(imageFilePaths, intrinsics, squareSize, ''Padding'', padding, ''MinCornerMetric'', minCornerMetric);');

            codeGenerator.addReturn();
            codeGenerator.addLine('% Filter images and point clouds that are not used');
            codeGenerator.addLine('imageFilePaths = imageFilePaths(dataUsed);');
            codeGenerator.addLine('ptcFilePaths = ptcFilePaths(dataUsed);');

            codeGenerator.addReturn();
            codeGenerator.addLine('%% Detect plane segment from point clouds');
            codeGenerator.addLine(sprintf('minDistance = %f;',this.Params.getClusterThreshold()));
            codeGenerator.addLine(sprintf('roi = %s;',mat2str(this.Params.getROI())));
            codeGenerator.addLine(sprintf('dimTol = %f;',this.Params.getDimensionTolerance()));
            codeGenerator.addLine(sprintf('removeGround = %s;',mat2str(this.Params.getRemoveGround())));

            codeGenerator.addLine(char("rng('default');"));
            codeGenerator.addLine('detectionResults = struct();');
            codeGenerator.addLine('k = 1;');
            codeGenerator.addLine('for i = 1:numel(ptcFilePaths)');
            codeGenerator.addLine('[detectionResults(i).lidarCheckerboardPlane, detectionResults(i).ptCloudUsed] = detectRectangularPlanePoints(ptcFilePaths{i}, planeDimension, ''RemoveGround'', removeGround, ''ROI'', roi, ''DimensionTolerance'', dimTol, ''MinDistance'', minDistance);');
            codeGenerator.addLine('if detectionResults(i).ptCloudUsed');
            codeGenerator.addLine('lidarCheckerboardPlanes(k) = detectionResults(i).lidarCheckerboardPlane;');
            codeGenerator.addLine('k = k + 1;');
            codeGenerator.addLine('end');
            codeGenerator.addLine('end');

            codeGenerator.addReturn();
            codeGenerator.addLine('% Filter images and point clouds that are not used');
            codeGenerator.addLine('imageFilePaths = imageFilePaths([detectionResults.ptCloudUsed]);');
            codeGenerator.addLine('ptcFilePaths = ptcFilePaths([detectionResults.ptCloudUsed]);');
            codeGenerator.addReturn();
            codeGenerator.addLine('% Filter image corners that are not used');
            codeGenerator.addLine('imageCorners3d = imageCorners3d(:, :, [detectionResults.ptCloudUsed]);')
            codeGenerator.addReturn();

            codeGenerator.addReturn();
            codeGenerator.addLine('%% Estimate transformation between lidar point cloud and image 3-D corners');
            if(~isempty(this.Params.getInitialTransform()))

                codeGenerator.addLine(sprintf('initialTransform = rigid3d( ...\n %s, ...\n %s);',...
                mat2str(this.Params.getInitialTransform().Rotation),...
                mat2str(this.Params.getInitialTransform().Translation)));

                codeGenerator.addLine(char("[tform, errors] = "...
                +"estimateLidarCameraTransform(lidarCheckerboardPlanes, imageCorners3d, intrinsics,"...
                +"'InitialTransform', initialTransform, "...
                +"'verbose', true);"));

            else

                codeGenerator.addLine('[tform, errors] = estimateLidarCameraTransform(lidarCheckerboardPlanes, imageCorners3d, intrinsics, ''verbose'', true);');
            end
            codeGenerator.addReturn();
            codeGenerator.addLine('%% Project lidar points to an image');
            codeGenerator.addLine('figure');
            codeGenerator.addLine('im = imread(imageFilePaths{1});');
            codeGenerator.addLine('im = undistortImage(im, intrinsics);');
            codeGenerator.addLine('imPts = projectLidarPointsOnImage(lidarCheckerboardPlanes(1),intrinsics, tform);');
            codeGenerator.addLine('im = insertMarker(im ,imPts,''*'',''color'',''blue'',''size'', 3);');
            codeGenerator.addLine('imshow(im);');

            codeGenerator.addReturn();
            codeGenerator.addLine('%% Plot the errors');
            codeGenerator.addLine('figure');
            codeGenerator.addLine('subplot(1,3,1);');
            codeGenerator.addLine('h1 = bar(errors.TranslationError, 0.4);');
            codeGenerator.addLine('subplot(1,3,2);');
            codeGenerator.addLine('h2 = bar(errors.RotationError, 0.4);');
            codeGenerator.addLine('subplot(1,3,3);');
            codeGenerator.addLine('h3 = bar(errors.ReprojectionError, 0.4);');
            codeGenerator.addLine('t1 = title(h1.Parent, ''Translation Errors'', ''Units'', ''normalized'');');
            codeGenerator.addLine('t2 = title(h2.Parent, ''Rotation Errors'', ''Units'', ''normalized'');');
            codeGenerator.addLine('t3 = title(h3.Parent, ''Reprojection Errors'', ''Units'', ''normalized'');');
            codeGenerator.addLine('set(t1, ''Position'', get(t1, ''Position'')+[0 0.04 0]);');
            codeGenerator.addLine('set(t2, ''Position'', get(t2, ''Position'')+[0 0.04 0]);');
            codeGenerator.addLine('set(t3, ''Position'', get(t3, ''Position'')+[0 0.04 0]);');
            codeGenerator.addLine('xlabel(h1.Parent, ''Image - Point Cloud Pairs'');');
            codeGenerator.addLine('xlabel(h2.Parent, ''Image - Point Cloud Pairs'');');
            codeGenerator.addLine('xlabel(h3.Parent, ''Image - Point Cloud Pairs'');');
            codeGenerator.addLine('ylabel(h1.Parent, ''Error (meters)'');');
            codeGenerator.addLine('ylabel(h2.Parent, ''Error (degrees)'');');
            codeGenerator.addLine('ylabel(h3.Parent, ''Error (pixels)'');');

            content=codeGenerator.CodeString;


            editorDoc=matlab.desktop.editor.newDocument(content);

            editorDoc.smartIndentContents;
            editorDoc.goToLine(1);
        end
    end

end
