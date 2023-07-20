







classdef Session<vision.internal.labeler.tool.Session

    properties
CachedAutomationROIs

UnimportedROIs

ConnectorHandle
CustomLabels



LabelingModeLayout



ClusterViewStatus


SavedSelectedSignals

    end

    properties(Access=protected)


RangeSliderStatus


SignalModel


AlternateFilePath

    end

    properties(Access=protected)




        FrameIdxIntervalStrct;



ConnectorLabelNames




IncompleteLoad
    end

    properties(Hidden)

ProjectedViewStatus
    end

    events
AddedSignals
RemovedSignals
    end




    methods

        function this=Session()
            this@vision.internal.labeler.tool.Session();

            import vision.internal.videoLabeler.tool.signalLoading.*
            this.SignalModel=SignalLoadModel();
        end

        function resetIsPixelLabelChangedAll(this)
            resetIsPixelLabelChangedAll(this.ROIAnnotations);
        end

        function updateSignalModel(this,~,evtData)

            import vision.internal.videoLabeler.tool.events.*

            if nargin==3
                signalModel=evtData.SignalModel;
                this.SignalModel=signalModel;
                resetFlag=true;
            else
                resetFlag=false;
            end


            [signalsAdded,signalsDeleted]=getSignalChanges(this.SignalModel);
            [startTime,endTime]=getStartAndEndTime(this);

            timeInfo=struct();
            timeInfo.StartTime=startTime;
            timeInfo.EndTime=endTime;

            for idx=1:numel(signalsDeleted)
                signalName=signalsDeleted(idx);


                removeAnnotationsBySignal(this.ROIAnnotations,signalName);
                removeAnnotationsBySignal(this.FrameAnnotations,signalName);


                if~isempty(this.TempDirectory)


                    delete([this.TempDirectory,filesep,[char(signalName),'_Label_','*.png']]);
                end


                resetIsPixelLabelChanged(this.ROIAnnotations,signalName);
            end



            if numel(signalsDeleted)>0
                signalsBeingAdded=~isempty(signalsAdded)&&~isempty(fieldnames(signalsAdded));
                evtData=RemovedSignalsEvent(signalsDeleted,signalsBeingAdded);
                notify(this,'RemovedSignals',evtData);
            end

            if~isempty(signalsAdded)>0

                for idx=1:numel(signalsAdded.SignalNames)
                    signalName=signalsAdded.SignalNames(idx);
                    signalType=signalsAdded.SignalType(idx);
                    numFrames=signalsAdded.NumFrames(idx);
                    this.ROIAnnotations.addSourceInformation(signalName,signalType,numFrames,resetFlag);
                    this.FrameAnnotations.addSourceInformation(signalName,numFrames);
                end

                evtData=AddedSignalsEvent(signalsAdded,timeInfo);
                notify(this,'AddedSignals',evtData);
            end

            clearSignalChanges(this.SignalModel);




            this.IsChanged=true;


        end







        function checkImagePaths(this,currentSessionFilePath,origFullSessionFileName)

            origPath=fileparts(origFullSessionFileName);
            this.AlternateFilePath=[string(origPath),string(currentSessionFilePath)];
        end
    end




    methods(Access=public,Hidden)
        function selectedSignalsInfo=loadSelectedSignalInfo(this)
            selectedSignalsInfo=this.SavedSelectedSignals;
        end

        function saveSelectedSignalInfo(this,selectedSignalsInfo)
            this.SavedSelectedSignals=selectedSignalsInfo;
        end
    end




    methods


        function labels=exportLabelAnnotations(this,signalNames)


            import vision.internal.videoLabeler.tool.signalLoading.helpers.*

            if nargin<2
                signalNames=getSignalNames(this);
            end


            definitions=exportLabelDefinitions(this);


            timeVectors=getTimeVectors(this.SignalModel,signalNames);

            if isa(this,'driving.internal.videoLabeler.tool.Session')
                maintainROIOrder=false;
            else
                maintainROIOrder=true;
            end

            roiAnnotationsTable=this.ROIAnnotations.export2table(timeVectors,signalNames,maintainROIOrder);
            frameAnnotationsTable=this.FrameAnnotations.export2table(timeVectors,signalNames);


            data=horzcat(roiAnnotationsTable{1},frameAnnotationsTable{1});

            names=definitions.Name((definitions.Type~=labelType.PixelLabel));

            anyPixelLabels=ismember('PixelLabelID',definitions.Properties.VariableNames);
            if anyPixelLabels
                names(end+1)={'PixelLabelData'};
            end






            if isa(this,'driving.internal.videoLabeler.tool.Session')
                appName=vision.getMessage('vision:labeler:ToolTitleGTL');
            else
                appName=vision.getMessage('vision:labeler:ToolTitleVL');
            end

            data.Properties.Description=vision.getMessage('vision:labeler:ExportTableDescription',appName,date);
            if isempty(definitions)
                labels=[];
            else
                signalSource=getSource(this.SignalModel);

                dataSource=createGTDataSourceFromMultiSource(signalSource);
                labels=groundTruth(dataSource,definitions,data);
            end
        end



        function TF=exportPixelLabelData(this,newFolder)

            TF=true;
            signalNames=getSignalNames(this);

            for sigId=1:numel(signalNames)
                signalName=signalNames(sigId);
                copyFlag=copyPixelLabelFileFromTemp(this,signalName,newFolder);
                TF=TF&copyFlag;
            end
        end



        function[data,exceptions]=readDataBySignalId(this,signalId,frameIndex,imageSize)

            exceptions=[];


            if(imageSize>0)

                [positions,labelNames,sublabelNames,selfUIDs,...
                parentUIDs,colors,shapes,order,roiVisibility]=...
                this.queryROILabelAnnotationByReaderId(signalId,frameIndex);


                [sceneNames,sceneColors,sceneLabelIds]=...
                this.queryFrameLabelAnnotationByReaderId(signalId,frameIndex);


                data.ImageIndex=frameIndex;


                signalNames=getSignalNames(this);
                signalName=signalNames(signalId);
                fileName=fullfile(this.TempDirectory,formMaskFileName(this,signalName,frameIndex));
                data.LabelMatrixFilename=fileName;
            else

                positions={};
                labelNames={};
                sublabelNames={};
                selfUIDs={};
                parentUIDs={};
                colors={};
                shapes=labelType([]);
                roiVisibility={};
                sceneNames={};
                sceneColors={};
                sceneLabelIds=[];
                data.ImageIndex=[];
                data.LabelMatrixFilename=[];
            end


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



        function refreshPixelLabelAnnotation(this)

            signalNames=getSignalNames(this);

            for sigId=1:numel(signalNames)
                signalName=signalNames(sigId);
                addTempFilePathsToAnnotationSet(this,signalName);
            end
        end



        function deletePixelLabelData(this,labelID)


            signalNames=getSignalNames(this);
            for sigId=1:numel(signalNames)

                signalName=signalNames(sigId);

                for idx=1:getNumFramesBySignal(this,signalName)
                    try
                        maskFileName=formMaskFileName(this,signalName,idx);
                        L=imread(fullfile(this.TempDirectory,maskFileName));
                        L(L==labelID)=0;
                        imwrite(L,fullfile(this.TempDirectory,maskFileName));

                    catch

                    end
                end
            end

            setIsPixelLabelChangedAll(this.ROIAnnotations);
        end




        function TF=importPixelLabelData(this)

            TF=true;


            if isempty(this.TempDirectory)
                setTempDirectory(this);
            end

            signalNames=getSignalNames(this);

            for sigId=1:numel(signalNames)

                signalName=signalNames(sigId);


                for idx=1:getNumFramesBySignal(this,signalName)
                    isCopied=copyPixelLabelFileToTemp(this,signalName,idx);
                    if~isCopied
                        TF=false;
                    end
                end

            end

            resetIsPixelLabelChangedAll(this.ROIAnnotations);
        end



        function saveSessionData(this)


            [pathstr,name,~]=fileparts(this.FileName);

            sessionPath=fullfile(pathstr,['.',name,'_SessionData']);


            if hasPixelLabels(this)


                if~isfolder(sessionPath)
                    mkdir(sessionPath)
                    if ispc

                        fileattrib(sessionPath,'+h')
                    end
                end

                signalNames=getSignalNames(this);

                for sigId=1:numel(signalNames)
                    signalName=signalNames(sigId);



                    isPixelLabelChanged=getIsPixelLabelChanged(this.ROIAnnotations,signalName);

                    for idx=1:getNumFramesBySignal(this,signalName)


                        filePath=getPixelLabelAnnotation(this.ROIAnnotations,...
                        signalName,idx);
                        newFilePath=fullfile(sessionPath,formMaskFileName(this,signalName,idx));
                        if~isempty(filePath)
                            if isPixelLabelChanged(idx)&&~strcmp(filePath,newFilePath)


                                copyfile(filePath,newFilePath,'f');
                                setPixelLabelAnnotation(this,signalName,...
                                idx,newFilePath);
                            else
                                if exist(newFilePath,'file')


                                    setPixelLabelAnnotation(this,signalName,...
                                    idx,newFilePath);
                                end
                            end
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



        function loadLabelDefinitions(this,definitions)
            signalNames=getSignalNames(this);
            reset(this);

            for idx=1:numel(signalNames)
                signalName=signalNames(idx);
                numFrames=getNumFramesBySignal(this,signalName);
                if numFrames>0
                    signalType=getSignalTypes(this.SignalModel,signalName);
                    this.ROIAnnotations.addSourceInformation(signalName,signalType,numFrames);
                    this.FrameAnnotations.addSourceInformation(signalName,numFrames);

                end
            end
            resetIsPixelLabelChangedAll(this.ROIAnnotations);
            addDefinitions(this,definitions);
        end

        function name=getConvertedSignalName(~,signalName)
            name=signalName;
        end
    end




    methods






        function setFrameIdxIntervalFromTimeInterval(this,timeIntervalIn)

            signalNames=getSignalNames(this);
            signalNames=cellstr(signalNames);
            numSignal=numel(signalNames);
            this.FrameIdxIntervalStrct=repmat(struct('SignalName','','FrameIdxInterval',[]),[numSignal,1]);

            for i=1:numSignal
                signalName_i=string(signalNames{i});
                frameIdxInterval=[1,1];
                timeInterval=clipTimeInterval(this.SignalModel,timeIntervalIn,signalName_i);

                frameIdxInterval(1)=getFrameIndexFromTime(this.SignalModel,...
                timeInterval(1),signalName_i);
                frameIdxInterval(2)=getFrameIndexFromTime(this.SignalModel,...
                timeInterval(2),signalName_i);
                this.FrameIdxIntervalStrct(i).SignalName=signalName_i;
                this.FrameIdxIntervalStrct(i).FrameIdxInterval=frameIdxInterval;
            end

        end

        function frameIdxInterval=getFrameIndexInterval(this,signalName)


            signalName=cellstr(signalName);
            numSignal=numel(this.FrameIdxIntervalStrct);
            frameIdxIntervalAll=[];
            for i=1:numSignal
                signalName_i=this.FrameIdxIntervalStrct(i).SignalName;
                if find(ismember(signalName_i,signalName))
                    frameIdxInterval=this.FrameIdxIntervalStrct(i).FrameIdxInterval;
                    frameIdxIntervalAll=[frameIdxIntervalAll,frameIdxInterval];%#ok<AGROW>
                end
            end

            frameIdxInterval=[min(frameIdxIntervalAll),max(frameIdxIntervalAll)];




        end

        function replaceROIAnnotations(this,signalName,frameIdxInterval,selectedROIs,currentIndex,unimportedROIs)


            this.UnimportedROIs=unimportedROIs;

            roiNames={selectedROIs.Label};
            parentRoiNames={selectedROIs.ParentName};
            selfUIDs={selectedROIs.ID};
            parentUIDs={selectedROIs.ParentUID};
            positions={selectedROIs.Position};

            [labelNames,sublabelNames,labelUIDs,sublabelUIDs]=...
            convert2LabelSublabelInfo(selfUIDs,parentUIDs,roiNames,parentRoiNames);
            replace(this.ROIAnnotations,signalName,frameIdxInterval(1):frameIdxInterval(2),currentIndex,...
            labelNames,sublabelNames,...
            labelUIDs,sublabelUIDs,...
            positions);
        end

        function replaceFrameAnnotationsAllSignals(this,validFrameLabelNames)


            numSignal=numel(this.FrameIdxIntervalStrct);

            for i=1:numSignal
                signalName_i=this.FrameIdxIntervalStrct(i).SignalName;
                frameIdxInterval_i=this.FrameIdxIntervalStrct(i).FrameIdxInterval;
                replace(this.FrameAnnotations,signalName_i,frameIdxInterval_i(1):frameIdxInterval_i(2),validFrameLabelNames);
            end
        end






        function replaceROIAnnotationsForUndo(this,signalName,cachedROIs)



            frameIdxInterval=getFrameIndexInterval(this,signalName);



            replace(this.ROIAnnotations,signalName,frameIdxInterval(1):frameIdxInterval(2));


            times=[cachedROIs.Time];
            uniqueTimes=unique(times);

            for n=1:numel(uniqueTimes)

                idx=find(times==uniqueTimes(n));

                labelNames=cell(numel(idx),1);
                sublabelNames=cell(numel(idx),1);
                positions=cell(numel(idx),1);
                labelUIDs=cell(numel(idx),1);
                sublabelUIDs=cell(numel(idx),1);
                for m=1:numel(idx)

                    labelNames{m}=cachedROIs(idx(m)).Label;
                    sublabelNames{m}='';

                    labelUIDs{m}=cachedROIs(idx(m)).ID;
                    sublabelUIDs{m}='';


                    positions{m}=cachedROIs(idx(m)).Position;
                end


                frameIndex=getFrameIndexFromTime(this.SignalModel,...
                uniqueTimes(n),signalName);

                addAnnotation(this.ROIAnnotations,signalName,frameIndex,labelNames,sublabelNames,labelUIDs,sublabelUIDs,positions)
            end
        end






        function replaceFrameAnnotationsForUndoAllSignals(this)




            numSignal=numel(this.FrameIdxIntervalStrct);

            for i=1:numSignal
                signalName_i=this.FrameIdxIntervalStrct(i).SignalName;
                frameIdxInterval_i=this.FrameIdxIntervalStrct(i).FrameIdxInterval;
                replace(this.FrameAnnotations,signalName_i,frameIdxInterval_i(1):frameIdxInterval_i(2));
            end
        end





        function replacePixelLabels(this)


            rmdir(this.TempDirectory,'s');


            status=mkdir(this.TempDirectory);
            if~status
                assert(false,'Unable to create directory for automation');
            end

            numSignal=numel(this.FrameIdxIntervalStrct);
            for i=1:numSignal
                signalName=this.FrameIdxIntervalStrct(i).SignalName;
                frameIdxInterval=this.FrameIdxIntervalStrct(i).FrameIdxInterval;
                for idx=frameIdxInterval(1):frameIdxInterval(2)
                    setPixelLabelAnnotation(this,signalName,idx,'');
                end
            end
        end







        function mergeAnnotations(this,signalName,isForwardAutomation)


            numSignal=numel(this.FrameIdxIntervalStrct);
            for i=1:numSignal
                signalName_i=this.FrameIdxIntervalStrct(i).SignalName;
                frameIdxInterval_i=this.FrameIdxIntervalStrct(i).FrameIdxInterval;

                if isForwardAutomation
                    idxValues=frameIdxInterval_i(1):frameIdxInterval_i(2);
                else
                    idxValues=frameIdxInterval_i(2):-1:frameIdxInterval_i(1);
                end
                idx=find(signalName_i==signalName);
                if find(ismember(signalName_i,signalName))
                    mergeWithCache(this.ROIAnnotations,signalName_i,idxValues,this.UnimportedROIs{idx});
                end

                mergeWithCache(this.FrameAnnotations,signalName_i,idxValues);
            end
        end

        function frameIdxInterval=getFrameIdxInterval(this,signalName)
            numSignal=numel(this.FrameIdxIntervalStrct);
            for i=1:numSignal
                signalName_i=this.FrameIdxIntervalStrct(i).SignalName;

                if strcmp(signalName_i,signalName)
                    frameIdxInterval=this.FrameIdxIntervalStrct(i).FrameIdxInterval;
                end
            end
        end


        function rois=getROIsInTimeInterval(this,signalName)

            fieldNames={'ID','Type','Name','Position','Attributes','Time'};

            rois=[];

            frameIdxInterval=getFrameIdxInterval(this,signalName);
            tIdx=frameIdxInterval(1):frameIdxInterval(2);

            [allUIDs,allPositions,allNames,~,allShapes,allAttributes]=this.ROIAnnotations.queryAnnotationsInInterval(signalName,tIdx);
            timeStamps=getTimeVectors(this.SignalModel,signalName);
            timeStamps=seconds(timeStamps{1});

            for nidx=1:numel(tIdx)
                IDs=allUIDs{nidx};
                positions=allPositions{nidx};
                names=allNames{nidx};
                shapes=allShapes{nidx};
                attributes=allAttributes{nidx};

                for n=1:numel(positions)




                    pos=positions{n};

                    for m=1:size(pos,1)
                        newROI.ID=IDs{n};
                        newROI.Type=shapes(n);
                        newROI.Name=names{n};
                        newROI.Position=pos(m,:);
                        newROI.Attributes=attributes(n);
                        newROI.Time=timeStamps(tIdx(nidx));


                        rois=[rois;newROI];%#ok<AGROW>
                    end
                end
            end
            if isempty(rois)

                rois=cell2struct(cell(numel(fieldNames),1),fieldNames);
                rois(1,:)=[];
            end

        end





        function mergePixelLabels(this,signalName)

            frameIdxInterval=getFrameIdxInterval(this,signalName);
            indices=frameIdxInterval(1):frameIdxInterval(2);
            mergePixelLabelsInAnnotaitonSet(this,signalName,indices);
        end

        function pixelLabelDefs=getPixelLabelDefinitions(this)
            pixelLabelDefs=this.ROILabelSet;
        end

        function idx=getFrameIndexFromTime(this,t,signalName)
            signalName=string(signalName);
            idx=getFrameIndexFromTime(this.SignalModel,t,signalName);
        end
    end




    methods
        function saveLabelModeLayout(this,layout)
            this.LabelingModeLayout=layout;
        end

        function layout=getLabelModeLayout(this,container)
            layout=this.LabelingModeLayout;
            oldLayout=isa(layout,'com.mathworks.widgets.desk.DTDocumentContainer$Tiling');
            if useAppContainer&&oldLayout
                layout=struct('DocumentGridDimensions',container.DocumentGridDimensions,...
                'LayoutJSON',container.LayoutJSON);
            end
        end
    end




    methods
        function isValid=isValidName(this,labelName)

            roiLabelNames={this.ROILabelSet.DefinitionStruct.Name};
            frameLabelNames={this.FrameLabelSet.DefinitionStruct.Name};
            connectorLabelNames=this.ConnectorLabelNames;
            isValid=isempty(find(strcmp(roiLabelNames,labelName),1))...
            &&isempty(find(strcmp(frameLabelNames,labelName),1))...
            &&isempty(find(strcmp(connectorLabelNames,labelName),1));
        end

        function setConnectorLabelNames(this,names)

            this.ConnectorLabelNames=names;
        end
    end




    methods

        function signalModel=getSignalModel(this)
            signalModel=this.SignalModel;
        end

        function numSignals=getNumberOfSignals(this)
            numSignals=getNumberOfSignals(this.SignalModel);
        end



        function numFrames=getNumFrames(this)
            numFrames=getNumberOfFrames(this.SignalModel);
        end

        function numFrames=getNumFramesBySignal(this,signalName)
            numFrames=getNumberOfFrames(this.SignalModel,signalName);
        end

        function TF=hasPointCloudSignal(this)
            TF=hasPointCloudSignal(this.SignalModel);
        end

        function TF=hasSignal(this)
            TF=hasImageVideoSignal(this.SignalModel);
        end

        function[startTime,endTime]=getStartAndEndTime(this)
            [startTime,endTime]=getStartAndEndTime(this.SignalModel);
        end



        function dataSource=getDataSource(this)
            signalInfo=getSignalInfo(this.SignalModel);
            signalName=signalInfo.SignalName(1);

            sourceName=getSourceNamesFromSignalNames(this.SignalModel,signalName);
            dataSource=groundTruthDataSource(sourceName);
        end

        function sourceName=getSourceNamesFromSignalNames(this,signalName)
            sourceName=getSourceNamesFromSignalNames(this.SignalModel,signalName);
        end

        function timeVectors=getTimeVectors(this,signalNames)
            timeVectors=getTimeVectors(this.SignalModel,signalNames);
        end

        function alternatePath=getAlternateFilePath(this)
            alternatePath=this.AlternateFilePath;
        end

        function signalNames=getSignalNames(this)
            signalNames=getSignalNames(this.SignalModel);
        end

        function validTimeVector=getValidTimeVector(this,tStart,tEnd,signalName)
            if nargin<4
                signalName=[];
            end
            validTimeVector=getValidTimeVector(this.SignalModel,tStart,...
            tEnd,signalName);
            validTimeVector=seconds(validTimeVector);
        end

        function saveProjectedView(this,status)
            this.ProjectedViewStatus=status;
        end

        function status=getProjectedView(this)
            status=this.ProjectedViewStatus;
        end

    end




    methods
        function setRangeSliderStaus(this,status)
            this.RangeSliderStatus=status;
        end

        function status=getRangeSliderStatus(this)
            status=this.RangeSliderStatus;
        end


        function setClusterViewStatus(this,status)
            this.ClusterViewStatus=status;
        end

    end




    methods
        function resetSession(this)
            reset(this);

            import vision.internal.videoLabeler.tool.signalLoading.*
            this.SignalModel=SignalLoadModel();

            this.CachedAutomationROIs=[];
            this.UnimportedROIs=[];
            this.ConnectorHandle=[];
            this.CustomLabels=[];
            this.LabelingModeLayout=[];
            this.RangeSliderStatus=[];
            this.AlternateFilePath=[];
            this.FrameIdxIntervalStrct=[];
            this.ConnectorLabelNames=[];
            this.ClusterViewStatus=false;
            this.ProjectedViewStatus=false;
        end
    end




    methods(Access=protected)

        function value=getVersion(this)
            value=versionFromProductName(this,...
            "vision","Computer Vision Toolbox");
        end


        function addData(this,gTruth)

            definitions=gTruth.LabelDefinitions;

            signalNames=getSignalNames(this);


            if isa(gTruth,'groundTruth')
                labelDataTables{1}=gTruth.LabelData;
                orderData=gTruth.getPolygonOrder();
            else
                labelDataTables=processLabelData(this,gTruth,signalNames);
                index=find(string(definitions.Properties.VariableNames)=="LabelType",1);

                if~isempty(index)
                    definitions.Properties.VariableNames{index}='Type';
                    definitions(definitions.Type==labelType.Cuboid,:)=[];
                end

                orderData=[];
            end


            for idx=1:numel(signalNames)
                labelData=labelDataTables{idx};
                this.addLabelData(signalNames(idx),definitions,labelData,1:height(labelData),orderData);
            end
        end

        function labelData=processLabelData(~,gTruth,signalNames)

            labelData=cell(numel(signalNames),1);

            for idx=1:numel(signalNames)
                signalName=signalNames(idx);
                roiDataTable=gTruth.ROILabelData.(signalName);

                sceneLabelNames=string(gTruth.LabelDefinitions.Name(gTruth.LabelDefinitions.LabelType==labelType.Scene));

                if~isempty(sceneLabelNames)
                    timestamps=roiDataTable.Time;
                    sceneDataTable=gTruth.SceneLabelData.labelDataAtTime(...
                    sceneLabelNames,timestamps);
                else
                    sceneDataTable=timetable(roiDataTable.Time);
                end


                labelData{idx}=[roiDataTable,sceneDataTable];
            end
        end
    end


    methods(Hidden)
        function that=saveobj(this,saveLayout)


            if nargin==1
                saveLayout=true;
            end

            that.FileName=this.FileName;
            that.SignalModel=this.SignalModel;
            that.ROILabelSet=this.ROILabelSet;
            that.ROISublabelSet=this.ROISublabelSet;
            that.ROIAttributeSet=this.ROIAttributeSet;
            that.FrameLabelSet=this.FrameLabelSet;
            that.ROIAnnotations=this.ROIAnnotations;
            that.FrameAnnotations=this.FrameAnnotations;
            that.RangeSliderStatus=this.RangeSliderStatus;
            that.CachedAutomationROIs=this.CachedAutomationROIs;
            that.UnimportedROIs=this.UnimportedROIs;
            that.ConnectorHandle=this.ConnectorHandle;
            that.CustomLabels=this.CustomLabels;
            that.Version=this.Version;
            that.ShowROILabelMode=this.ShowROILabelMode;
            that.ClusterViewStatus=this.ClusterViewStatus;
            that.SavedSelectedSignals=this.SavedSelectedSignals;
            that.AlgorithmInstances=this.AlgorithmInstances;

            if saveLayout
                that.LabelingModeLayout=serialize(this.LabelingModeLayout);
            end
            that.ProjectedViewStatus=this.ProjectedViewStatus;
        end

    end


    methods(Static,Hidden)
        function this=loadobj(that,loadLayout)


            if nargin==1
                loadLayout=true;
            end




            that.Version=vision.internal.labeler.tool.Session....
            findVersionInfoByProductName(that.Version,...
            "Computer Vision Toolbox");

            if isa(that,'vision.internal.videoLabeler.tool.Session')
                this=that;
            else
                this=vision.internal.videoLabeler.tool.Session;
                loadObjHelper(this,that,loadLayout);
            end
        end
    end

    methods(Access=protected)

        function loadObjHelper(this,that,loadLayout)
            is18aOrGreater=isfield(that,'LabelingModeLayout');
            is20aOrGreater=isfield(that,'SignalModel');
            is20bOrGreater=isfield(that,'ClusterViewStatus');

            this.FileName=that.FileName;
            this.ROIAnnotations=that.ROIAnnotations;
            this.FrameAnnotations=that.FrameAnnotations;

            loadAlgorithmInstances(this,that);

            if is20aOrGreater
                this.SignalModel=that.SignalModel;
                this.RangeSliderStatus=that.RangeSliderStatus;



                if~isfield(this.RangeSliderStatus,'TimeSettings')
                    this.RangeSliderStatus.TimeSettings=[];
                end
                this.ClusterViewStatus=false;

            elseif is20bOrGreater
                this.ClusterViewStatus=that.ClusterViewStatus;
            else




                this.SignalModel=vision.internal.videoLabeler.tool.signalLoading.SignalLoadModel();
                loadSuccess=loadSourcesFromOldSession(this,that);

                this.IncompleteLoad=~loadSuccess;

                fixDataLoadingIssues(this);

                this.RangeSliderStatus=struct();
                this.RangeSliderStatus.SliderStartTime=that.SliderStartTime;
                this.RangeSliderStatus.SliderEndTime=that.SliderEndTime;
                this.RangeSliderStatus.SliderCurrentTime=that.SliderCurrentTime;
                this.RangeSliderStatus.SnapButtonStatus=that.SnapButtonStatus;
                this.RangeSliderStatus.TimeSettings=[];

                this.ClusterViewStatus=false;
            end

            this.loadClusterViewStatus(that);


            this.loadROILabelMode(that);

            if~isfield(that,'SavedSelectedSignals')


                this.SavedSelectedSignals=[];
            else

                this.SavedSelectedSignals=that.SavedSelectedSignals;
            end

            this.ROIAnnotations.configure()
            this.FrameAnnotations.configure();

            this.FrameLabelSet=that.FrameLabelSet;
            [this.ROILabelSet,this.ROISublabelSet,this.ROIAttributeSet]...
            =this.ROIAnnotations.getLabelSets();
            this.CachedAutomationROIs=that.CachedAutomationROIs;
            this.UnimportedROIs=that.UnimportedROIs;
            if isfield(that,'ConnectorHandle')
                this.ConnectorHandle=that.ConnectorHandle;
            end
            if isfield(that,'CustomLabels')
                this.CustomLabels=that.CustomLabels;
            end


            if is18aOrGreater&&loadLayout

                deserializeFlag=true;

                if~isstruct(that.LabelingModeLayout)&&isempty(char(that.LabelingModeLayout))
                    deserializeFlag=false;
                end

                if deserializeFlag
                    this.LabelingModeLayout=deserialize(that.LabelingModeLayout);
                end
            end

            if isfield(that,'ProjectedViewStatus')
                this.ProjectedViewStatus=that.ProjectedViewStatus;
            else
                this.ProjectedViewStatus=false;
            end
        end

        function TF=loadSourcesFromOldSession(this,sessionObj)
            sourceType=vision.internal.labeler.DataSourceType(string(sessionObj.SourceType));
            if~isempty(sourceType)
                if isequal(sourceType,vision.internal.labeler.DataSourceType.VideoReader)
                    sourceName=sessionObj.VideoFileName;
                    sourceParams=[];
                    signalSource=vision.labeler.loading.VideoSource();
                elseif isequal(sourceType,vision.internal.labeler.DataSourceType.ImageSequence)
                    sourceName=sessionObj.VideoFileName;
                    sourceParams=[];
                    timeStamps=sessionObj.Timestamps;
                    signalSource=vision.labeler.loading.ImageSequenceSource();
                    signalSource.setTimestamps(timeStamps);
                elseif isequal(sourceType,vision.internal.labeler.DataSourceType.CustomReader)
                    sourceName=sessionObj.VideoFileName;
                    timeStamps=sessionObj.Timestamps;
                    functionHandle=sessionObj.CustomReaderFunction;

                    signalSource=vision.labeler.loading.CustomImageSource();
                    signalSource.setTimestamps(timeStamps);

                    sourceParams=struct();
                    sourceParams.FunctionHandle=functionHandle;
                end

                TF=callLoadSource(this.SignalModel,signalSource,sourceName,sourceParams);
            else
                TF=true;
            end
        end
    end

    methods(Hidden)
        function fixDataLoadingIssues(this)

            if this.IncompleteLoad
                signalNames=getSignalNames(this);

                for idx=1:numel(signalNames)
                    signalName=signalNames(idx);
                    signalType=vision.labeler.loading.SignalType.Image;
                    numImages=getNumberOfFrames(this.SignalModel,...
                    signalName);

                    addSourceInformation(this.ROIAnnotations,signalName,...
                    signalType,numImages);


                    addSourceInformation(this.FrameAnnotations,...
                    signalName,numImages);

                    this.IncompleteLoad=true;
                end
            end
        end

        function sourceNames=getSourceNamesNotLoaded(this)
            sourcesNotLoaded=getSourcesNotLoaded(this.SignalModel);
            if~isempty(sourcesNotLoaded)
                sourceNames=string({sourcesNotLoaded.SourceName});
            else
                sourceNames=[];
            end
        end

        function that=loadClusterViewStatus(this,that)


            if isfield(that,'ClusterViewStatus')
                this.ClusterViewStatus=that.ClusterViewStatus;
            else


                this.ClusterViewStatus=false;
            end
        end
    end

end


function[labelNames,sublabelNames,labelUIDs,sublabelUIDs]=convert2LabelSublabelInfo(selfUIDs,parentUIDs,roiNames,parentRoiNames)


    numROIs=numel(selfUIDs);

    labelNames=cell(numROIs,1);
    sublabelNames=cell(numROIs,1);
    labelUIDs=cell(numROIs,1);
    sublabelUIDs=cell(numROIs,1);

    for i=1:numROIs
        if strcmp(parentUIDs,'')
            labelUIDs{i}=selfUIDs{i};
            sublabelUIDs{i}='';

            labelNames{i}=roiNames{i};
            sublabelNames{i}='';
        else
            labelUIDs{i}=parentUIDs{i};
            sublabelUIDs{i}=selfUIDs{i};

            labelNames{i}=parentRoiNames{i};
            sublabelNames{i}=roiNames{i};
        end
    end
end

function out=serialize(layout)
    if isa(layout,'com.mathworks.widgets.desk.DTDocumentContainer$Tiling')
        out=com.mathworks.widgets.desk.TilingSerializer.serialize(layout);%#ok<JAPIMATHWORKS>
    else
        out=layout;
    end
end

function out=deserialize(layout)
    if isa(layout,'java.lang.String')
        out=com.mathworks.widgets.desk.TilingSerializer.deserialize(layout);%#ok<JAPIMATHWORKS>
    else
        out=layout;
    end
end

function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end
