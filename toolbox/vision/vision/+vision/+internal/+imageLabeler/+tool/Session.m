







classdef Session<vision.internal.labeler.tool.Session
    properties(SetAccess=private)
        ImageFilenames=cell(0,1);
        Datastore=[];

        SelectedImageIdx=[];
    end

    properties(Access=private)

        RemoveSessionDir=true;
        CurrentViewROIPosition(:,4)

    end

    properties
        IsDataBlockedImage(1,1)logical=false;
    end

    properties(Access=private)
        OrigBlockedImageObjects=blockedImage.empty();
    end

    properties(Access=private,Transient)
        BlockedImageObjects=blockedImage.empty();
    end

    methods


        function addImagesToSession(this,signalName,imageData)


            if this.IsDataBlockedImage

                if isa(imageData(1),'blockedImage')
                    fileNames=cell(numel(imageData),1);
                    for idx=1:numel(imageData)
                        fileNames{idx}=char(imageData(idx).Source);
                        this.BlockedImageObjects(end+1)=imageData(idx);
                        this.OrigBlockedImageObjects(end+1)=imageData(idx);
                    end
                    this.ImageFilenames=[this.ImageFilenames;fileNames];

                else
                    this.ImageFilenames=[this.ImageFilenames;imageData];
                    createAndCacheBlockedImages(this,imageData);
                end
            else

                if isa(imageData,'matlab.io.datastore.FileBasedDatastore')
                    this.Datastore=copy(imageData);
                    this.ImageFilenames=[this.ImageFilenames;imageData.Files];
                else

                    if~isempty(this.Datastore)
                        this.Datastore.Files=[this.Datastore.Files;imageData];
                    end
                    this.ImageFilenames=[this.ImageFilenames;imageData];
                end

            end

            signalType=vision.labeler.loading.SignalType.Image;

            this.ROIAnnotations.appendSourceInformation(signalName,signalType,getNumImages(this));
            this.FrameAnnotations.appendSourceInformation(signalName,getNumImages(this));
            this.IsChanged=true;

        end


        function removeImagesFromSession(this,removedImageIndices)

            seesionDirtyFlag=(this.HasROILabels||this.HasFrameLabels)...
            ||(getNumImages(this)~=numel(removedImageIndices));


            removeAllAnnotations(this.ROIAnnotations,removedImageIndices);


            if this.hasPixelLabels()
                renameAndRemoveLabelMatrixFiles(this,removedImageIndices);
            end


            removeAllAnnotations(this.FrameAnnotations,removedImageIndices);


            this.ImageFilenames(removedImageIndices)=[];


            if this.IsDataBlockedImage
                this.BlockedImageObjects(removedImageIndices)=[];
                if~isempty(this.OrigBlockedImageObjects)
                    this.OrigBlockedImageObjects(removedImageIndices)=[];
                end


                if isempty(this.BlockedImageObjects)
                    this.BlockedImageObjects=blockedImage.empty();
                    this.OrigBlockedImageObjects=blockedImage.empty();
                end
            end


            if~isempty(this.Datastore)
                this.Datastore.Files=setdiff(this.Datastore.Files,...
                this.Datastore.Files(removedImageIndices),'stable');
            end




            if hasPixelLabels(this)
                this.RemoveSessionDir=true;
            end

            if seesionDirtyFlag
                this.IsChanged=true;
            else
                this.IsChanged=false;
            end
        end


        function mergeGeneratedOverviewLevel(this,bimOverview,idx)

            if this.BlockedImageObjects(idx).NumLevels==1
                currBim=this.BlockedImageObjects(idx);
                adapter=vision.internal.imageLabeler.tool.blockedImage.CompositeAdapter(currBim,bimOverview);

                warnStruct=warning('off');
                resetWarnings=onCleanup(@()warning(warnStruct));

                bimMerged=blockedImage(currBim.Source,'Adapter',adapter);

                this.BlockedImageObjects(idx)=bimMerged;

            end

        end


        function renameAndRemoveLabelMatrixFiles(this,removedImageIndices)



            firstRemovedImgIdx=min(removedImageIndices);
            lastImageIdx=getNumImages(this);
            offset=0;

            for idx=firstRemovedImgIdx:lastImageIdx
                try
                    if~isempty(find(removedImageIndices==idx,1))
                        fileName=fullfile(this.TempDirectory,sprintf('Label_%d.png',idx));
                        if exist(fileName,'file')
                            delete(fileName);
                        end

                        offset=offset+1;
                    else
                        newFileIndex=idx-offset;
                        filePath=getPixelLabelAnnotation(this.ROIAnnotations,[],newFileIndex);
                        if~isempty(filePath)

                            filePath=fullfile(this.TempDirectory,...
                            sprintf('Label_%d.png',idx));
                            newFilePath=fullfile(this.TempDirectory,...
                            sprintf('Label_%d.png',newFileIndex));
                            movefile(filePath,newFilePath,'f');

                            setPixelLabelAnnotation(this,'',newFileIndex,newFilePath);
                        end
                    end
                catch

                end
            end
        end


        function[rotatedImages,imageSizes]=rotateImages(this,imagesToBeRotatedIdx,rotationType)


            numImagesRotated=0;
            imageSizes=[];

            for idx=imagesToBeRotatedIdx
                try
                    filename=this.ImageFilenames{idx};

                    im=imread(filename);

                    imageSizes=[imageSizes;size(im,[1,2])];%#ok<AGROW>

                    if strcmpi(rotationType,'Clockwise')
                        imRot=imrotate(im,-90);
                    elseif strcmpi(rotationType,'CounterClockwise')
                        imRot=imrotate(im,90);
                    end


                    imwrite(imRot,filename);


                    [positions,labelNames,sublabelNames,selfUIDs,parentUIDs,~,~]=this.ROIAnnotations.queryAnnotationByReaderId(1,idx);
                    isLabels=cellfun(@isempty,parentUIDs);
                    for i=1:length(isLabels)
                        if(isLabels(i))
                            sublabelUIDs{i}='';
                            labelUIDs{i}=selfUIDs{i};
                        else
                            sublabelUIDs{i}=selfUIDs{i};
                            labelUIDs{i}=parentUIDs{i};
                        end
                    end
                    if hasPixelLabels(this)
                        labelFilePath=getPixelLabelAnnotation(this.ROIAnnotations,[],idx);
                        if~isempty(labelFilePath)
                            labelFilePath=fullfile(this.TempDirectory,...
                            sprintf('Label_%d.png',idx));
                            labelIm=imread(labelFilePath);
                            if strcmpi(rotationType,'Clockwise')
                                labelImRot=imrotate(labelIm,-90);
                            elseif strcmpi(rotationType,'CounterClockwise')
                                labelImRot=imrotate(labelIm,90);
                            end
                            imwrite(labelImRot,labelFilePath);
                        end
                    end

                    if~isempty(positions)
                        [numRows,numCols,~]=size(im);
                        newPositions=cell(size(positions,1),size(positions,2));
                        for roiType=1:numel(positions)
                            roiPositions=positions{roiType};
                            newROIPositions=zeros(size(roiPositions,1),...
                            size(roiPositions,2));
                            if(size(roiPositions,2)==4)
                                for rectRoiIdx=1:size(roiPositions,1)
                                    oldPoints=roiPositions(rectRoiIdx,:);
                                    if strcmpi(rotationType,'Clockwise')
                                        x=numRows-(oldPoints(2)+oldPoints(4));
                                        y=oldPoints(1);
                                    elseif strcmpi(rotationType,'CounterClockwise')
                                        x=oldPoints(2);
                                        y=numCols-(oldPoints(1)+oldPoints(3));
                                    end
                                    newPoints=[x,y,oldPoints(4),oldPoints(3)];
                                    newROIPositions(rectRoiIdx,:)=newPoints;
                                end
                            elseif(size(roiPositions,2)==8)
                                for projectedRoiIdx=1:size(roiPositions,1)
                                    oldPoints=roiPositions(projectedRoiIdx,:);
                                    if strcmpi(rotationType,'Clockwise')
                                        x1=numRows-(oldPoints(2)+oldPoints(4));
                                        y1=oldPoints(1);
                                        x2=numRows-(oldPoints(6)+oldPoints(8));
                                        y2=oldPoints(5);
                                    elseif strcmpi(rotationType,'CounterClockwise')
                                        x1=oldPoints(2);
                                        y1=numCols-(oldPoints(1)+oldPoints(3));
                                        x2=oldPoints(6);
                                        y2=numCols-(oldPoints(5)+oldPoints(7));
                                    end
                                    newPoints=[x1,y1,oldPoints(4),oldPoints(3),x2,y2,oldPoints(8),oldPoints(7)];
                                    newROIPositions(projectedRoiIdx,:)=newPoints;
                                end
                            else
                                for lineRoiIdx=1:size(roiPositions,1)
                                    oldPoints=roiPositions(lineRoiIdx,:);
                                    if strcmpi(rotationType,'Clockwise')
                                        x=numRows-oldPoints(2);
                                        y=oldPoints(1);
                                    elseif strcmpi(rotationType,'CounterClockwise')
                                        x=oldPoints(2);
                                        y=numCols-oldPoints(1);
                                    end
                                    newPoints=[x,y];
                                    newROIPositions(lineRoiIdx,:)=newPoints;
                                end
                            end
                            newPositions{roiType}=newROIPositions;
                        end

                        addROILabelAnnotations(this,"",idx,labelNames,sublabelNames,labelUIDs,sublabelUIDs,newPositions);
                    end
                    numImagesRotated=numImagesRotated+1;
                catch
                    rotatedImages=imagesToBeRotatedIdx(1:numImagesRotated);
                    return;
                end
            end

            rotatedImages=imagesToBeRotatedIdx;
            this.IsChanged=true;
        end


        function set.ImageFilenames(this,names)

            names=reshape(names,[],1);
            this.ImageFilenames=names;
        end


        function addLabelsDefinitions(this,definitions)

            addDefinitions(this,definitions);
        end


        function numberOfImages=getNumImages(this)
            numberOfImages=numel(this.ImageFilenames);
        end

        function numFrames=getNumFramesBySignal(this,~)
            numFrames=getNumImages(this);
        end


        function numFrames=getNumFrames(this)
            numFrames=getNumImages(this);
        end


        function TF=hasImages(this)
            TF=numel(this.ImageFilenames)>0;
        end


        function TF=hasSignal(this)
            TF=hasImages(this);
        end


        function TF=hasDatastore(this)
            TF=~isempty(this.Datastore);
        end


        function setSelectedImageIdx(this,idx)
            this.SelectedImageIdx=idx;
        end


        function idx=getSelectedImageIdx(this)
            if~isempty(this.SelectedImageIdx)
                idx=this.SelectedImageIdx;
            else
                idx=1;
            end
        end

        function name=getConvertedSignalName(~,~)
            name='';
        end
    end

    methods

        function labels=exportLabelAnnotations(this,signalName)

            if nargin<2
                signalName='';
            end


            definitions=exportLabelDefinitions(this);


            unused=[];
            maintainROIOrder=true;
            roiAnnotationsTable=this.ROIAnnotations.export2table(unused,signalName,maintainROIOrder);
            frameAnnotationsTable=this.FrameAnnotations.export2table(unused,signalName);

            if iscell(roiAnnotationsTable)
                roiAnnotationsTable=roiAnnotationsTable{1};
            end

            if iscell(frameAnnotationsTable)
                frameAnnotationsTable=frameAnnotationsTable{1};
            end


            data=horzcat(roiAnnotationsTable,frameAnnotationsTable);
            names=definitions.Name((definitions.Type~=labelType.PixelLabel));

            anyPixelLabels=ismember('PixelLabelID',definitions.Properties.VariableNames);
            if anyPixelLabels
                names(end+1)={'PixelLabelData'};
            end

            data.Properties.Description=...
            vision.getMessage('vision:labeler:ExportTableDescription',...
            vision.getMessage('vision:labeler:ToolTitleIL'),date);

            if~isempty(this.Datastore)
                source=groundTruthDataSource(this.Datastore);
            else
                source=groundTruthDataSource(this.ImageFilenames);
            end

            labels=groundTruth(source,definitions,data);
        end




        function[data,exceptions]=readData(this,idx)

            if this.IsDataBlockedImage
                [data,exceptions]=this.readDataBlockedImage(idx);
            else
                [data,exceptions]=this.readDataImage(idx);
            end

        end






        function checkImagePaths(this,currentSessionFilePath,...
            origFullSessionFileName)



            for i=1:numel(this.ImageFilenames)
                if~exist(this.ImageFilenames{i},'file')

                    this.ImageFilenames{i}=...
                    vision.internal.uitools.tryToAdjustPath(...
                    this.ImageFilenames{i},...
                    currentSessionFilePath,origFullSessionFileName);

                    if this.hasDatastore()
                        this.Datastore.Files{i}=this.ImageFilenames{i};
                    end
                end
            end
        end



        function TF=exportPixelLabelData(this,newFolder)

            signalName='';

            TF=copyPixelLabelFileFromTemp(this,signalName,newFolder);
        end

        function[img,imgFileName,exceptions]=getImageAndImageFilename(this,imgIndex)

            exceptions=[];


            imgFileName=this.ImageFilenames{imgIndex};

            try
                if~this.IsDataBlockedImage
                    img=imread(imgFileName);
                else
                    if isa(this.BlockedImageObjects(imgIndex),'blockedImage')
                        img=this.BlockedImageObjects(imgIndex);
                    else
                        img=blockedImage(imgFileName);
                        this.BlockedImageObjects(imgIndex)=img;
                    end
                end

            catch ME
                I=imread(fullfile(toolboxdir('images'),'icons','CorruptedImage_72.png'));

                img=I;


                imgFileName=string(NaN);
                exceptions=[exceptions,ME];
            end
        end

        function[data,exceptions]=readDataBySignalId(this,signalId,frameIndex,~)




            [img,imgFileName,exceptions]=getImageAndImageFilename(this,frameIndex);
            data.Image=img;
            data.ImageFilename=imgFileName;


            [positions,labelNames,sublabelNames,selfUIDs,...
            parentUIDs,colors,shapes,roiVisibility]=...
            this.queryROILabelAnnotationByReaderId(signalId,frameIndex);

            [sceneNames,sceneColors,sceneLabelIds]=...
            this.queryFrameLabelAnnotationByReaderId(signalId,frameIndex);

            data.Positions=positions;
            data.LabelNames=labelNames;
            data.SublabelNames=sublabelNames;
            data.SelfUIDs=selfUIDs;
            data.ParentUIDs=parentUIDs;
            data.Colors=colors;
            data.Shapes=shapes;
            data.ROIVisibility=roiVisibility;


            data.SceneNames=sceneNames;
            data.SceneColors=sceneColors;
            data.SceneLabelIds=sceneLabelIds;


            data.hasPixelLabelInfo=false;
            data.ImageIndex=frameIndex;
            data.NumberOfPixelLabels=this.getNumPixelLabels();

            if this.IsDataBlockedImage

            else

                fileName=fullfile(this.TempDirectory,sprintf('Label_%d.png',frameIndex));
                data.LabelMatrixFilename=fileName;
                imageSize=size(data.Image);

                if~isempty(this.TempDirectory)
                    try


                        data.LabelMatrix=imread(fileName);


                        lsz=size(data.LabelMatrix);


                        if~isequal(lsz(1:2),imageSize(1:2))
                            exceptions=[exceptions...
                            ,MException(message('vision:labeler:PixelLabelDataSizeMismatch'))];
                        end

                        if(numel(lsz)~=2)
                            exceptions=[exceptions...
                            ,MException(message('vision:labeler:PixelLabelChannelSizeMismatch'))];
                        end


                        data.hasPixelLabelInfo=true;
                    catch
                        data.LabelMatrix=zeros(imageSize(1:2),'uint8');
                    end

                else
                    data.LabelMatrix=zeros(imageSize(1:2),'uint8');
                end
            end


        end



        function refreshPixelLabelAnnotation(this)

            signalName='';
            addTempFilePathsToAnnotationSet(this,signalName);
        end



        function saveSessionData(this)


            [pathstr,name,~]=fileparts(this.FileName);

            sessionPath=fullfile(pathstr,['.',name,'_SessionData']);


            if hasPixelLabels(this)

                if~isfolder(sessionPath)

                    createNewDirAndSave=true;
                else








                    if this.RemoveSessionDir
                        rmdir(sessionPath,'s');
                        createNewDirAndSave=true;
                    else
                        createNewDirAndSave=false;
                    end
                end

                if createNewDirAndSave
                    mkdir(sessionPath)
                    if ispc

                        fileattrib(sessionPath,'+h')
                    end

                    if~isempty(this.TempDirectory)
                        copyfile(this.TempDirectory,sessionPath);
                    end


                    for idx=1:getNumImages(this)
                        filePath=getPixelLabelAnnotation(this.ROIAnnotations,...
                        [],idx);
                        if~isempty(filePath)
                            newFilePath=fullfile(sessionPath,sprintf('Label_%d.png',idx));
                            setPixelLabelAnnotation(this,'',...
                            idx,newFilePath);
                        end
                    end
                    this.RemoveSessionDir=false;
                else


                    for idx=1:getNumImages(this)


                        filePath=getPixelLabelAnnotation(this.ROIAnnotations,...
                        [],idx);
                        isPixelLabelChanged=getIsPixelLabelChanged(this.ROIAnnotations,[]);
                        if~isempty(filePath)&&isPixelLabelChanged(idx)
                            copyfile(filePath,sessionPath,'f');
                            newFilePath=fullfile(sessionPath,sprintf('Label_%d.png',idx));
                            setPixelLabelAnnotation(this,'',...
                            idx,newFilePath);
                        end
                    end
                end
            else


                if isfolder(sessionPath)


                    rmdir(sessionPath,'s');
                end
            end

            resetIsPixelLabelChangedAll(this.ROIAnnotations);

        end



        function deletePixelLabelData(this,val)

            for idx=1:getNumImages(this)
                try
                    L=imread(fullfile(this.TempDirectory,sprintf('Label_%d.png',idx)));
                    L(L==val)=0;
                    imwrite(L,fullfile(this.TempDirectory,sprintf('Label_%d.png',idx)));
                catch

                end
            end

            setIsPixelLabelChangedAll(this.ROIAnnotations);
        end







        function replaceROIAnnotations(this,signalName,imageIndices)

            replace(this.ROIAnnotations,signalName,imageIndices);
        end

        function replaceFrameAnnotationsAllSignals(this,signalName,imageIndices,validFrameLabels)

            replace(this.FrameAnnotations,signalName,imageIndices,validFrameLabels);
        end





        function replaceAnnotationsForUndo(this,signalName,imageIndices)



            replace(this.ROIAnnotations,signalName,imageIndices);
            replace(this.FrameAnnotations,signalName,imageIndices);
        end





        function replacePixelLabels(this,indices)


            rmdir(this.TempDirectory,'s');


            status=mkdir(this.TempDirectory);
            if~status
                assert(false,'Unable to create directory for automation');
            end

            for idx=1:numel(indices)
                setPixelLabelAnnotation(this,'',indices(idx),'');
            end

        end







        function mergeAnnotations(this,signalName,imageIndices)

            mergeWithCache(this.ROIAnnotations,signalName,imageIndices);
            mergeWithCache(this.FrameAnnotations,signalName,imageIndices);
        end





        function mergePixelLabels(this,indices)
            signalName='';
            mergePixelLabelsInAnnotaitonSet(this,signalName,indices);
        end




        function loadLabelDefinitions(this,definitions)
            numImages=getNumImages(this);







            if this.IsDataBlockedImage
                refresh(this);
            else
                reset(this);
            end

            signalName='';
            signalType=vision.labeler.loading.SignalType.Image;

            if numImages>0
                this.ROIAnnotations.addSourceInformation(signalName,...
                signalType,numImages);
                this.FrameAnnotations.addSourceInformation(signalName,...
                numImages);
            end

            resetIsPixelLabelChangedAll(this.ROIAnnotations);
            addDefinitions(this,definitions);
        end




        function TF=importPixelLabelData(this)

            TF=true;


            if isempty(this.TempDirectory)
                setTempDirectory(this);
            end

            signalName='';

            for idx=1:getNumImages(this)
                isCopied=copyPixelLabelFileToTemp(this,signalName,idx);
                if~isCopied
                    TF=false;
                end
            end

            resetIsPixelLabelChangedAll(this.ROIAnnotations);
        end

        function updateSignalModel(this,~,~)

            signalName='Image';
            signalType=vision.labeler.loading.SignalType.Image;
            numFrames=getNumImages(this);

            if numFrames>0
                appendSourceInformation(this.ROIAnnotations,signalName,...
                signalType,getNumImages(this));

                appendSourceInformation(this.FrameAnnotations,...
                signalName,getNumImages(this));
            end

        end

        function numResLevels=getNumResLevels(self,varargin)
            if isempty(varargin)
                imgIndex=self.SelectedImageIdx;
            else
                imgIndex=varargin{1};
            end

            bim=self.BlockedImageObjects(imgIndex);
            if isa(bim.Adapter,'vision.internal.imageLabeler.tool.blockedImage.CompositeAdapter')




                numResLevels=1;
            else
                numResLevels=size(bim.Size,1);
            end
        end

        function levelSizes=getLevelSizes(self,varargin)
            if isempty(varargin)
                imgIndex=self.SelectedImageIdx;
            else
                imgIndex=varargin{1};
            end
            bim=self.BlockedImageObjects(imgIndex);
            if isa(bim.Adapter,'vision.internal.imageLabeler.tool.blockedImage.CompositeAdapter')




                levelSizes=bim.Size(1,:);
            else
                levelSizes=bim.Size;
            end

        end




        function setCurrentViewPosition(self,position,idx)
            self.CurrentViewROIPosition(idx,:)=position;
        end

        function pos=getCurrentViewPosition(self,idx)
            if nargin==2
                pos=self.CurrentViewROIPosition(idx,:);
            elseif nargin==1
                pos=self.CurrentViewROIPosition;
            end
        end

    end

    methods



        function resetSession(this)
            reset(this);
            this.ImageFilenames={};
            this.BlockedImageObjects=blockedImage.empty();
            this.OrigBlockedImageObjects=blockedImage.empty();
            this.SelectedImageIdx=[];
            this.Datastore=[];
            resetIsPixelLabelChangedAll(this.ROIAnnotations);
            if~isempty(this.TempDirectory)
                rmdir(this.TempDirectory,'s');
            end
            this.TempDirectory=[];

            this.IsDataBlockedImage=false;
            this.CurrentViewROIPosition=[];
        end

        function refresh(this)




            this.FileName=[];
            this.ROILabelSet=vision.internal.labeler.ROILabelSet;
            this.ROISublabelSet=vision.internal.labeler.ROISublabelSet;
            this.ROIAttributeSet=vision.internal.labeler.ROIAttributeSet;
            this.ROIAnnotations=vision.internal.labeler.ROIAnnotationSet(this.ROILabelSet,this.ROISublabelSet,this.ROIAttributeSet);
            this.AlgorithmInstances={};
            resetIsPixelLabelChangedAll(this);

            this.FrameLabelSet=vision.internal.labeler.FrameLabelSet;
            this.FrameAnnotations=vision.internal.labeler.FrameAnnotationSet(this.FrameLabelSet);
            this.IsChanged=false;

        end

        function numSignals=getNumberOfSignals(this)
            if hasImages(this)
                numSignals=1;
            else
                numSignals=0;
            end
        end

        function idx=getFrameIndexFromTime(~,t,~)
            idx=t;
        end

        function signalNames=getSignalNames(this)
            signalNames="";
        end
    end

    methods(Access=private)

        function[data,exceptions]=readDataImage(this,idx)

            filename=this.ImageFilenames{idx};
            data.ImageFilename=filename;

            exceptions=[];


            try

                if~isempty(this.Datastore)
                    data.Image=read(subset(this.Datastore,idx));
                    vision.internal.inputValidation.validateImage(data.Image);
                else
                    data.Image=vision.internal.readLabelerImages(filename);
                end
                imageReadError=false;

            catch ME
                I=imread(fullfile(toolboxdir('images'),'icons','CorruptedImage_72.png'));

                data.Image=I;


                data.ImageFilenames=string(NaN);

                imageReadError=true;
                exceptions=[exceptions,ME];
            end

            imageSize=size(data.Image);




            data.hasPixelLabelInfo=true;


            if~isempty(this.TempDirectory)
                filename=fullfile(this.TempDirectory,sprintf('Label_%d.png',idx));

                try


                    data.LabelMatrix=imread(filename);



                    lsz=size(data.LabelMatrix);
                    if~isequal(lsz(1:2),imageSize(1:2))
                        exceptions=[exceptions...
                        ,MException(message('vision:labeler:PixelLabelDataSizeMismatch'))];
                        data.LabelMatrix=zeros(imageSize(1:2),'uint8');
                    end

                    if(numel(lsz)~=2)
                        exceptions=[exceptions...
                        ,MException(message('vision:labeler:PixelLabelChannelSizeMismatch'))];
                        data.LabelMatrix=zeros(imageSize(1:2),'uint8');
                    end
                catch
                    data.LabelMatrix=zeros(imageSize(1:2),'uint8');
                end

            else
                data.LabelMatrix=zeros(imageSize(1:2),'uint8');
            end


            data.ImageIndex=idx;
            data.LabelMatrixFilename=fullfile(this.TempDirectory,sprintf('Label_%d.png',idx));
            data.NumberOfPixelLabels=this.getNumPixelLabels();


            if imageReadError

                [positions,labelNames,sublabelNames,...
                selfUIDs,parentUIDs,colors,shapes,order,roiVisibility]=deal({},{},{},{},{},{},labelType.empty,[],{});
                [sceneNames,sceneColors,sceneLabelIds]=deal({},{},[]);
            else
                [positions,labelNames,sublabelNames,...
                selfUIDs,parentUIDs,colors,shapes,order,roiVisibility]=...
                this.queryROILabelAnnotationByReaderId(1,idx);
                [sceneNames,sceneColors,sceneLabelIds]=...
                this.queryFrameLabelAnnotationByReaderId(1,idx);
            end



            if(~isempty(order))
                if(~isempty(order{1}))
                    [~,roiIdx]=sort(cell2mat(order));
                else
                    roiIdx=1:numel(positions);
                end
            else
                roiIdx=1:numel(positions);
            end

            data.Positions=positions(roiIdx);

            data.LabelNames=labelNames(roiIdx);
            data.SublabelNames=sublabelNames(roiIdx);
            data.SelfUIDs=selfUIDs(roiIdx);
            data.ParentUIDs=parentUIDs(roiIdx);
            data.Colors=colors(roiIdx);
            data.Shapes=shapes(roiIdx);
            data.order=order(roiIdx);
            data.ROIVisibility=roiVisibility(roiIdx);

            data.SceneNames=sceneNames;
            data.SceneColors=sceneColors;
            data.SceneLabelIds=sceneLabelIds;


            [xLim,yLim]=this.computeAxesLimits(idx);
            data.XLim=xLim;
            data.YLim=yLim;
        end

        function[data,exceptions]=readDataBlockedImage(this,idx)

            filename=this.ImageFilenames{idx};
            data.ImageFilename=filename;

            exceptions=[];


            try
                if isa(this.BlockedImageObjects(idx),'blockedImage')
                    hBim=this.BlockedImageObjects(idx);
                else
                    hBim=blockedImage(filename);
                end

                data.Image=hBim;

                imageReadError=false;

            catch ME
                I=imread(fullfile(toolboxdir('images'),'icons','CorruptedImage_72.png'));

                data.Image=I;


                data.ImageFilenames=string(NaN);

                imageReadError=true;
                exceptions=[exceptions,ME];
            end


            data.hasPixelLabelInfo=false;

            data.ImageIndex=idx;


            if imageReadError

                [positions,labelNames,sublabelNames,...
                selfUIDs,parentUIDs,colors,shapes,roiVisibility]=deal({},{},{},{},{},{},labelType.empty,{});
                [sceneNames,sceneColors,sceneLabelIds]=deal({},{},[]);
            else
                [positions,labelNames,sublabelNames,...
                selfUIDs,parentUIDs,colors,shapes,order,roiVisibility]=...
                this.queryROILabelAnnotationByReaderId(1,idx);
                [sceneNames,sceneColors,sceneLabelIds]=...
                this.queryFrameLabelAnnotationByReaderId(1,idx);
            end


            if(~isempty(order))
                [~,roiIdx]=sort(cell2mat(order));
            else
                roiIdx=1:numel(positions);
            end


            data.Positions=positions(roiIdx);

            data.LabelNames=labelNames(roiIdx);
            data.SublabelNames=sublabelNames(roiIdx);
            data.SelfUIDs=selfUIDs(roiIdx);
            data.ParentUIDs=parentUIDs(roiIdx);
            data.Colors=colors(roiIdx);
            data.Shapes=shapes(roiIdx);
            data.order=order(roiIdx);
            data.ROIVisibility=roiVisibility(roiIdx);

            data.SceneNames=sceneNames;
            data.SceneColors=sceneColors;
            data.SceneLabelIds=sceneLabelIds;


            [xLim,yLim]=this.computeAxesLimits(idx);
            data.XLim=xLim;
            data.YLim=yLim;

        end

        function[xLim,yLim]=computeAxesLimits(this,idx)

            xLim=[];
            yLim=[];
            if size(this.CurrentViewROIPosition,1)<idx||all(this.CurrentViewROIPosition(idx,:)==0)
                return
            end

            pos=this.CurrentViewROIPosition(idx,:);
            xLim=[pos(1),pos(1)+pos(3)];
            yLim=[pos(2),pos(2)+pos(4)];
        end

    end

    methods(Access=protected)


        function value=getVersion(this)
            value=versionFromProductName(this,...
            "vision","Computer Vision Toolbox");
        end


        function addData(this,data)

            signalName='Image';


            addImagesToSession(this,signalName,data.DataSource.Source);

            definitions=data.LabelDefinitions;


            this.addLabelData(signalName,definitions,data.LabelData,1:height(data.LabelData),data.getPolygonOrder())

        end
    end

    methods(Access=?matlab.unittest.TestCase)

        function imageFileNames=getImageFileNames(this)
            imageFileNames=this.ImageFilenames;
        end
    end

    methods(Hidden)

        function that=saveobj(this)
            that.ImageFilenames=this.ImageFilenames;
            that.Datastore=this.Datastore;
            that.SelectedImageIdx=this.SelectedImageIdx;
            that.FileName=this.FileName;
            that.ROILabelSet=this.ROILabelSet;
            that.ROISublabelSet=this.ROISublabelSet;
            that.ROIAttributeSet=this.ROIAttributeSet;
            that.FrameLabelSet=this.FrameLabelSet;
            that.ROIAnnotations=this.ROIAnnotations;
            that.FrameAnnotations=this.FrameAnnotations;
            that.Version=this.Version;
            that.ShowROILabelMode=this.ShowROILabelMode;
            that.IsDataBlockedImage=this.IsDataBlockedImage;
            that.CurrentViewROIPosition=this.CurrentViewROIPosition;
            that.OrigBlockedImageObjects=this.OrigBlockedImageObjects;
            that.AlgorithmInstances=this.AlgorithmInstances;

        end

    end

    methods(Static,Hidden)

        function this=loadobj(that)
            this=vision.internal.imageLabeler.tool.Session;




            that.Version=vision.internal.labeler.tool.Session....
            findVersionInfoByProductName(...
            that.Version,"Computer Vision Toolbox");

            versionInfo=that.Version;
            is20aOrGreater=isfield(that,'ShowROILabelMode')...
            ||isempty(versionInfo)...
            ||(str2double(versionInfo.Version)>=9.1...
            ||contains(versionInfo.Release,'2020a'));

            is21aOrGreater=isfield(that,'IsDataBlockedImage');

            this.ImageFilenames=that.ImageFilenames;
            this.FileName=that.FileName;
            this.ROILabelSet=that.ROILabelSet;
            this.FrameLabelSet=that.FrameLabelSet;
            this.ROIAnnotations=that.ROIAnnotations;
            [this.ROILabelSet,this.ROISublabelSet,this.ROIAttributeSet]...
            =this.ROIAnnotations.getLabelSets();
            this.FrameAnnotations=that.FrameAnnotations;

            loadAlgorithmInstances(this,that);


            this.IsDataBlockedImage=false;
            this.CurrentViewROIPosition=zeros(numel(that.ImageFilenames),4);
            this.BlockedImageObjects=blockedImage.empty();
            this.OrigBlockedImageObjects=blockedImage.empty();

            if is20aOrGreater

                oldSignalName='';
                newSignalName='Image';


                if is21aOrGreater

                    this.IsDataBlockedImage=that.IsDataBlockedImage;

                    if this.IsDataBlockedImage

                        if~isempty(that.OrigBlockedImageObjects)&&numel(that.OrigBlockedImageObjects)==numel(this.ImageFilenames)
                            this.OrigBlockedImageObjects=that.OrigBlockedImageObjects;
                            this.BlockedImageObjects=that.OrigBlockedImageObjects;
                        end

                    end

                    this.CurrentViewROIPosition=that.CurrentViewROIPosition;

                end

                updateSignalName(this,oldSignalName,newSignalName);

            else
                signalName='Image';
                signalType=vision.labeler.loading.SignalType.Image;

                appendSourceInformation(this.ROIAnnotations,signalName,...
                signalType,getNumImages(this));

                appendSourceInformation(this.FrameAnnotations,...
                signalName,getNumImages(this));
            end



            this.loadROILabelMode(that);


            if this.IsDataBlockedImage&&isempty(this.OrigBlockedImageObjects)
                createAndCacheBlockedImages(this,this.ImageFilenames)
            end

            configure(this.ROIAnnotations);
            configure(this.FrameAnnotations);
            resetIsPixelLabelChangedAll(this.ROIAnnotations);
            updatePropsForVersionsSupported(this,that);

        end
    end

    methods(Access=private)
        function updatePropsForVersionsSupported(this,that)
            versionInfo=that.Version;
            is18bOrGreater=isempty(versionInfo)||...
            (str2double(versionInfo.Version)>=8.2...
            ||contains(versionInfo.Release,'2018b'));

            is20bOrGreater=(str2double(versionInfo.Version)>=9.2...
            ||contains(versionInfo.Release,'2020b'));

            if is18bOrGreater
                if isfield(that,'SelectedImageIdx')
                    this.SelectedImageIdx=that.SelectedImageIdx;
                end
            end

            if is20bOrGreater
                if isfield(that,'Datastore')
                    this.Datastore=that.Datastore;
                end
            end

        end

        function createAndCacheBlockedImages(this,filenames)



            warnStruct=warning('off');
            resetWarnings=onCleanup(@()warning(warnStruct));

            for idx=1:length(filenames)
                this.BlockedImageObjects(end+1)=blockedImage(filenames{idx});
            end

        end
    end
end
