







classdef Session<vision.internal.labeler.tool.Session&...
    vision.internal.videoLabeler.tool.Session


    properties(SetAccess=private,Hidden)

SavedCameraViewParameters
    end

    properties

SyncImageViewerHandle
ROILidarLabelSet
VoxelLabelDataPath


    end


    methods
        function resetSession(this)
            resetSession@vision.internal.videoLabeler.tool.Session(this);
            this.SyncImageViewerHandle=[];
        end
    end


    methods(Access=protected)

        function value=getVersion(~)
            value=ver('lidar');
        end
    end

    methods

        function this=Session()
            this@vision.internal.videoLabeler.tool.Session();

            import vision.internal.videoLabeler.tool.signalLoading.*
            this.SignalModel=SignalLoadModel();
            this.ROILabelSet=lidar.internal.labeler.ROILabelSet;
            this.ROIAnnotations=lidar.internal.labeler.ROIAnnotationSet(this.ROILabelSet,this.ROISublabelSet,this.ROIAttributeSet);
            this.FrameAnnotations=lidar.internal.labeler.FrameAnnotationSet(this.FrameLabelSet);
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


                    delete([this.TempDirectory,filesep,[char(signalName),'_Label_','*.mat']]);
                end

                resetIsVoxelLabelChanged(this.ROIAnnotations,signalName);
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


        function loadLabelAnnotations(this,gTruth)

            definitions=gTruth.LabelDefinitions;
            definitions=convertDefinitions(this,definitions);

            loadLabelDefinitions(this,definitions)

            addData(this,gTruth);
        end




        function loadLabelDefinitions(this,definitions)
            signalNames=getSignalNames(this);
            reset(this);
            this.ROILabelSet=lidar.internal.labeler.ROILabelSet;
            this.ROIAnnotations=lidar.internal.labeler.ROIAnnotationSet(this.ROILabelSet,this.ROISublabelSet,this.ROIAttributeSet);
            this.FrameAnnotations=lidar.internal.labeler.FrameAnnotationSet(this.FrameLabelSet);


            for idx=1:numel(signalNames)
                signalName=signalNames(idx);
                numFrames=getNumFramesBySignal(this,signalName);
                if numFrames>0
                    signalType=getSignalTypes(this.SignalModel,signalName);
                    this.ROIAnnotations.addSourceInformation(signalName,signalType,numFrames);
                    this.FrameAnnotations.addSourceInformation(signalName,numFrames);
                end
            end
            resetIsVoxelLabelChangedAll(this.ROIAnnotations);
            addLabelDefinitions(this,definitions);
        end

        function newDefinitions=convertDefinitions(~,definitions)
            hasHierarchy=any(contains(definitions.Properties.VariableNames,'Hierarchy'));
            hasVoxelLabelID=any(contains(definitions.Properties.VariableNames,'VoxelLabelID'));
            temp=[];
            for i=1:size(definitions,1)
                temp=[temp,vision.labeler.loading.SignalType.PointCloud];
            end
            temp1=table(temp');
            temp1.Properties.VariableNames{1}='SignalType';

            assert(size(definitions,2)==6||size(definitions,2)==5||size(definitions,2)==7,...
            vision.getMessage('lidar:labeler:NotProperLabeldefs'));

            if hasHierarchy&&hasVoxelLabelID
                newDefinitions=[definitions(:,1),temp1,definitions(:,2),definitions(:,4),definitions(:,5),definitions(:,3),definitions(:,7),definitions(:,6)];
                labelSetTable=table({},{},{},{},{},{},{},{},'VariableNames',{'Name','SignalType','LabelType','Group','Description','LabelColor','Hierarchy','VoxelLabelID'});
            elseif hasVoxelLabelID
                newDefinitions=[definitions(:,1),temp1,definitions(:,2),definitions(:,4),definitions(:,5),definitions(:,3),definitions(:,6)];
                labelSetTable=table({},{},{},{},{},{},{},'VariableNames',{'Name','SignalType','LabelType','Group','Description','LabelColor','VoxelLabelID'});
            elseif hasHierarchy
                newDefinitions=[definitions(:,1),temp1,definitions(:,2),definitions(:,4),definitions(:,5),definitions(:,3),definitions(:,6)];
                labelSetTable=table({},{},{},{},{},{},{},'VariableNames',{'Name','SignalType','LabelType','Group','Description','LabelColor','Hierarchy'});
            else
                newDefinitions=[definitions(:,1),temp1,definitions(:,2),definitions(:,4),definitions(:,5),definitions(:,3)];
                labelSetTable=table({},{},{},{},{},{},'VariableNames',{'Name','SignalType','LabelType','Group','Description','LabelColor'});
            end
            labelSetTable=table2struct(labelSetTable);
            definitions=newDefinitions;
            definitions.Properties.VariableNames{3}='LabelType';

            for i=1:size(definitions,1)
                if iscell(definitions(i,3).LabelType)
                    defType=definitions(i,3).LabelType{1};
                else
                    defType=definitions(i,3).LabelType;
                end
                labelDefType='';
                if defType==labelType.Cuboid
                    if iscell(iscell(definitions(i,3).LabelType))
                        labelDefType={labelType.Rectangle};
                    else
                        labelDefType=labelType.Rectangle;
                    end

                elseif defType==labelType.Line
                    if iscell(iscell(definitions(i,3).LabelType))
                        labelDefType={labelType.Line};
                    else
                        labelDefType=labelType.Line;
                    end
                else

                    labelSetTable=[labelSetTable;table2struct(definitions(i,:))];
                    continue;
                end

                if~isempty(labelDefType)
                    if hasHierarchy&&hasVoxelLabelID
                        if iscell(definitions(i,7).Hierarchy)
                            heirarchyStruct=definitions(i,7).Hierarchy{1};
                        else
                            heirarchyStruct=definitions(i,7).Hierarchy(1);
                        end

                        temp=struct('Name',definitions(i,1).Name{1},...
                        'SignalType',vision.labeler.loading.SignalType.Image,'LabelType',labelDefType,...
                        'Group',definitions(i,4).Group{1},'Description',definitions(i,5).Description{1},...
                        'LabelColor',definitions(i,6).LabelColor{1},'Hierarchy',heirarchyStruct,...
                        'VoxelLabelID',definitions(i,8).VoxelLabelID{1});
                    elseif hasHierarchy
                        if iscell(definitions(i,7).Hierarchy)
                            heirarchyStruct=definitions(i,7).Hierarchy{1};
                        else
                            heirarchyStruct=definitions(i,7).Hierarchy(1);
                        end
                        temp=struct('Name',definitions(i,1).Name{1},...
                        'SignalType',vision.labeler.loading.SignalType.Image,'LabelType',labelDefType,...
                        'Group',definitions(i,4).Group{1},'Description',definitions(i,5).Description{1},...
                        'LabelColor',definitions(i,6).LabelColor{1},'Hierarchy',heirarchyStruct);
                    elseif hasVoxelLabelID
                        temp=struct('Name',definitions(i,1).Name{1},...
                        'SignalType',vision.labeler.loading.SignalType.Image,'LabelType',labelDefType,...
                        'Group',definitions(i,4).Group{1},'Description',definitions(i,5).Description{1},...
                        'LabelColor',definitions(i,6).LabelColor{1},'VoxelLabelID',definitions(i,7).VoxelLabelID{1});
                    else
                        temp=struct('Name',definitions(i,1).Name{1},...
                        'SignalType',vision.labeler.loading.SignalType.Image,'LabelType',labelDefType,...
                        'Group',definitions(i,4).Group{1},'Description',definitions(i,5).Description{1},...
                        'LabelColor',definitions(i,6).LabelColor{1});
                    end
                    labelSetTable=[labelSetTable;temp];
                    labelSetTable=[labelSetTable;table2struct(definitions(i,:))];
                end
            end
            labelSetTable=struct2table(labelSetTable,'AsArray',true);
            newDefinitions=labelSetTable;
        end




        function saveCameraViewToSession(this,savedCameraViewsParameters,...
            savedCameraViewNames)
            if~(numel(savedCameraViewNames)==...
                numel(savedCameraViewsParameters))
                return;
            end












            dataToBeSaved={};
            for i=1:numel(savedCameraViewNames)
                dataToBeSaved{end+1}=struct('Name',savedCameraViewNames{i},...
                'Parameter1',savedCameraViewsParameters{i}(1),...
                'Parameter2',savedCameraViewsParameters{i}(2),...
                'Parameter3',savedCameraViewsParameters{i}(3),...
                'Parameter4',savedCameraViewsParameters{i}(4),...
                'Parameter5',savedCameraViewsParameters{i}(5),...
                'Parameter6',savedCameraViewsParameters{i}(6),...
                'Parameter7',savedCameraViewsParameters{i}(7),...
                'Parameter8',savedCameraViewsParameters{i}(8));
            end
            this.SavedCameraViewParameters=dataToBeSaved;
        end



        function labelObj=createLabelObject(~,labelDef)
            lblType=labelDef.Type;
            labelName=labelDef.Name;
            if isfield(labelDef,'Color')
                labelColor=labelDef.Color;
            else
                labelColor='';
            end

            if isfield(labelDef,'Group')
                groupName=labelDef.Group;
            else
                groupName='None';
            end

            if isfield(labelDef,'Description')
                labelDesc=labelDef.Description;
            else
                labelDesc='';
            end

            if labelDef.Type==lidarLabelType.Voxel

                voxelLabelID=labelDef.VoxelLabelID;
                labelObj=lidar.internal.labeler.ROILabel(lblType,labelName,labelDesc,groupName,voxelLabelID);
            else
                labelObj=lidar.internal.labeler.ROILabel(lblType,labelName,labelDesc,groupName);
            end
            labelObj.Color=labelColor;
        end
    end

    methods(Sealed,Access=protected)

        function addLabelDefinitions(this,definitions)

            index=find(string(definitions.Properties.VariableNames)=="LabelType",1);

            if~isempty(index)
                definitions.Properties.VariableNames{index}='Type';


                idx=1:numel(definitions.Type);
                for i=1:numel(definitions.Type)
                    if iscell(definitions.Type)
                        defType=definitions.Type{i};
                    else
                        defType=definitions.Type(i);
                    end
                    signalType=definitions.SignalType(i);

                    if~((defType==labelType.Line&&signalType==vision.labeler.loading.SignalType.PointCloud)...
                        ||defType==labelType.Cuboid)
                        idx(i)=0;
                    end
                end
                idx=nonzeros(idx);
                definitions(idx,:)=[];
            end


            idx=find(strcmpi(definitions.Properties.VariableNames,'LabelColor'));
            if~isempty(idx)
                definitions.Properties.VariableNames{idx}='Color';
            end

            definitions=table2struct(definitions);
            hasGroup=isfield(definitions,'Group');
            hasDescription=isfield(definitions,'Description');
            hasColor=isfield(definitions,'Color');



            allDefs=definitions(getROILabels({definitions.Type}));

            if~isempty(allDefs)
                s=decodeImportedLabelDef(this,allDefs);


                for lbl=1:numel(s.Label)
                    roiLabel=s.Label{lbl};
                    this.ROILabelSet.addLabel(roiLabel);


                    thisLblAttribCells=s.AttribOfLabel{lbl};
                    for lblAt=1:numel(thisLblAttribCells)
                        this.ROIAttributeSet.addAttribute(thisLblAttribCells{lblAt});
                    end
                end
            end


            frameLabelDefs=definitions(getSceneLabels({definitions.Type}));
            for n=1:numel(frameLabelDefs)
                labelName=frameLabelDefs(n).Name;

                if hasGroup
                    labelGroup=frameLabelDefs(n).Group;
                else
                    labelGroup='None';
                end

                if hasDescription
                    labelDesc=frameLabelDefs(n).Description;
                else
                    labelDesc='';
                end

                frameLabel=vision.internal.labeler.FrameLabel(labelName,labelDesc,labelGroup);

                if hasColor
                    color=frameLabelDefs(n).Color;
                    frameLabel.Color=color;
                end

                this.FrameLabelSet.addLabel(frameLabel);
            end
            this.IsChanged=true;
        end
    end




    methods
        function reset(this)

            this.FileName=[];
            this.ROILabelSet=lidar.internal.labeler.ROILabelSet;
            this.ROISublabelSet=vision.internal.labeler.ROISublabelSet;
            this.ROIAttributeSet=vision.internal.labeler.ROIAttributeSet;
            this.ROIAnnotations=lidar.internal.labeler.ROIAnnotationSet(this.ROILabelSet,this.ROISublabelSet,this.ROIAttributeSet);

            resetIsVoxelLabelChangedAll(this);

            this.FrameLabelSet=vision.internal.labeler.FrameLabelSet;
            this.FrameAnnotations=vision.internal.labeler.FrameAnnotationSet(this.FrameLabelSet);

            this.resetTempDirectory();
            this.IsChanged=false;
        end

        function setIsVoxelLabelChangedAll(this)
            setIsVoxelLabelChangedAll(this.ROIAnnotations);
        end

        function resetIsVoxelLabelChangedAll(this)
            resetIsVoxelLabelChangedAll(this.ROIAnnotations);
        end
    end




    methods

        function roiSummary=queryROISummary(this,signalName,labelNames,timeIndices)
            roiSummary=struct();
            for n=1:numel(labelNames)
                thisLabel=labelNames{n};
                if this.isaVoxelLabel(thisLabel)
                    voxelLabelIndex=getVoxelLabelIndex(this,thisLabel);
                    thisSummary=this.ROIAnnotations.queryVoxelSummary(signalName,voxelLabelIndex,timeIndices);
                else
                    thisSummary=this.ROIAnnotations.queryShapeSummary(signalName,thisLabel,timeIndices);
                end
                roiSummary.(thisLabel)=thisSummary;
            end
        end


        function sceneSummary=querySceneSummary(this,signalName,labels,timeIndices)
            sceneSummary=this.FrameAnnotations.querySummary(signalName,labels,timeIndices);
        end


        function voxelLabelIndex=getVoxelLabelIndex(this,labelName)


            for n=1:this.ROILabelSet.NumLabels
                if strcmp(this.ROILabelSet.DefinitionStruct(n).Name,labelName)...
                    &&strcmp(this.ROILabelSet.DefinitionStruct(n).Type,'Voxel')
                    voxelLabelIndex=this.ROILabelSet.DefinitionStruct(n).VoxelLabelID;
                    return
                end
            end

            voxelLabelIndex=0;
        end
    end

    methods(Access=protected)

        function loadObjHelper(this,that,loadLayout)

            loadObjHelper@vision.internal.videoLabeler.tool.Session(this,that,loadLayout);

            this.SyncImageViewerHandle=that.SyncImageViewerHandle;
            this.SavedCameraViewParameters=that.SavedCameraViewParameters;
        end


        function addData(this,gTruth)

            definitions=gTruth.LabelDefinitions;
            definitions=convertDefinitions(this,definitions);

            signalNames=getSignalNames(this);


            labelDataTables{1}=gTruth.LabelData;

            index=find(string(definitions.Properties.VariableNames)=="LabelType",1);
            if~isempty(index)
                definitions.Properties.VariableNames{index}='Type';


                roiId=(definitions.Type==labelType.Line&...
                definitions.SignalType==vision.labeler.loading.SignalType.PointCloud)...
                |definitions.Type==labelType.Cuboid;
                definitions(roiId,:)=[];
            end


            for idx=1:numel(signalNames)
                labelData=labelDataTables{idx};
                this.addLabelData(signalNames(idx),definitions,labelData,1:height(labelData),[]);
            end
        end
    end
    methods

        function roiLabel=addROILabel(this,roiLabel,hFig)


            roiLabel=this.ROILabelSet.addLabel(roiLabel,hFig);
            this.IsChanged=true;
        end

        function isValid=isValidName(this,labelName)

            roiLabelNames={this.ROILabelSet.DefinitionStruct.Name};
            frameLabelNames={this.FrameLabelSet.DefinitionStruct.Name};
            connectorLabelNames=this.ConnectorLabelNames;
            isValid=isempty(find(strcmp(roiLabelNames,labelName),1))...
            &&isempty(find(strcmp(frameLabelNames,labelName),1))...
            &&isempty(find(strcmp(connectorLabelNames,labelName),1));
        end


        function[roiLabels,frameLabels]=getLabelDefinitions(this)




            import vision.internal.labeler.*;

            numROILabels=this.ROILabelSet.NumLabels;

            is21bOrEarlier=strcmp(class(this.ROILabelSet),'vision.internal.labeler.ROILabelSet');

            if is21bOrEarlier
                roiLabels=repmat(vision.internal.labeler.ROILabel(labelType.empty,'','',''),1,numROILabels);
            else
                roiLabels=repmat(lidar.internal.labeler.ROILabel(labelType.empty,'','',''),1,numROILabels);
            end

            for n=1:numROILabels
                roiLabels(n)=this.ROILabelSet.queryLabel(n);
                roiLabels(n)=appendAttributeDef(this,roiLabels(n));
            end

            if is21bOrEarlier
                roiLabelSet=lidar.internal.labeler.ROILabelSet();
                for n=1:numROILabels
                    roiLabelSet.addLabel(roiLabels(n));
                end
                this.ROILabelSet=roiLabelSet;
            end

            numFrameLabels=this.FrameLabelSet.NumLabels;
            frameLabels=repmat(FrameLabel('','',''),1,numFrameLabels);
            for n=1:numFrameLabels
                frameLabels(n)=this.FrameLabelSet.queryLabel(n);
            end
        end



        function addAlgorithmLabels(this,signalName,t,index,labelData,varargin)



            if isempty(labelData)
                return;
            end

            if nargin>5
                im=varargin{1};
                imageSize=size(im.Location);
            end

            index=max(index,1);

            if istable(labelData)
                labelData=table2struct(labelData);
            end

            if iscategorical(labelData)

                try
                    filename=fullfile(this.TempDirectory,formMaskFileName(this,signalName,index));
                    L=load(filename).L;

                    lsz=size(L);
                    sz=size(labelData);
                    if~isequal(lsz(1),sz(1))&&numel(imageSize)==2
                        error(message('lidar:labeler:VoxelLabelDataSizeMismatch'));
                    end
                catch
                    if numel(imageSize)==2
                        L=[im.Location,zeros(imageSize(1),1,class(im.Location))];
                    else
                        L=[reshape(im.Location,imageSize(1)*imageSize(2),3),zeros(imageSize(1)*imageSize(2),1,class(im.Location))];
                    end
                end



                appliedLabels=categories(labelData);

                if numel(size(L))==2

                    labels=L(:,4);
                else

                    labels=L(:,:,4);
                end


                for idx=1:numel(appliedLabels)
                    roiLabel=queryLabel(this.ROILabelSet,appliedLabels{idx});
                    labels(labelData==appliedLabels{idx})=roiLabel.VoxelLabelID;
                end
                if ismatrix(im.Location)
                    L(:,1:3)=im.Location;
                    L(:,4)=labels;
                else
                    L=im.Location;
                    if numel(size(labels))==3
                        L(:,:,4)=labels;
                    else
                        L(:,:,4)=reshape(labels,imageSize(1),imageSize(2));
                    end
                end

                TF=writeData(this,signalName,L,index);
                if~TF
                    filename='';
                end
                setVoxelLabelAnnotation(this,signalName,index,filename);

            else
                isROILabel=getROILabels({labelData.Type});
                isSceneLabel=getSceneLabels({labelData.Type});

                autoROILabels=labelData(isROILabel);
                autoSceneLabels=labelData(isSceneLabel);

                autoROILabelNames={autoROILabels.Name};
                if isempty(autoROILabels)
                    autoROILabelUID={};
                    hasAutoAttribute=false;
                    autoROILabelAttributes={};
                else
                    autoROILabelUID={autoROILabels.LabelUID};
                    hasAutoAttribute=isfield(autoROILabels,'Attributes');
                    if hasAutoAttribute
                        autoROILabelAttributes={autoROILabels.Attributes};
                    else
                        autoROILabelAttributes=cell(numel(autoROILabelUID),1);
                    end
                end
                autoROIPositions={autoROILabels.Position};


                [oldROIPositions,oldROINames,~,...
                oldSelfUIDs,~,~,~]=queryROILabelAnnotationBySignalName(this,signalName,index);

                numLabels=numel([oldROINames,autoROILabelNames]);
                allEmptyStr=cell(1,numLabels);allEmptyStr(:)={''};
                allSublabelNames=allEmptyStr;
                allSublabelUIDs=allEmptyStr;

                addROILabelAnnotations(this,signalName,index,[oldROINames,autoROILabelNames],allSublabelNames,...
                [oldSelfUIDs,autoROILabelUID],allSublabelUIDs,...
                [oldROIPositions,autoROIPositions]);

                if hasAutoAttribute
                    updateAttributeAnnotationForAlgo(this,signalName,index,autoROILabelUID,autoROILabelNames,autoROILabelAttributes);
                end

                autoSceneLabelNames={autoSceneLabels.Name};
                if~isempty(autoSceneLabelNames)
                    signalNames=getSignalNames(this);
                    for readerIdx=1:numel(signalNames)
                        signalName_i=signalNames{readerIdx};
                        idx=getFrameIndexFromTime(this,t,signalName_i);
                        oldFrameLabelNames=queryFrameLabelAnnotationBySignalName(this,signalName_i,idx);
                        addFrameLabelAnnotation(this,signalName_i,idx,[oldFrameLabelNames,autoSceneLabelNames]);
                    end
                end
            end
            this.IsChanged=true;
        end





        function replaceVoxelLabels(this)


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
                    setVoxelLabelAnnotation(this,signalName,idx,'');
                end
            end
        end


        function isVoxLabel=isaVoxelLabel(this,labelName)

            isVoxLabel=isaVoxelLabel(this.ROILabelSet,labelName);
        end





        function mergeVoxelLabels(this,signalName,imageData)

            frameIdxInterval=getFrameIdxInterval(this,signalName);
            indices=frameIdxInterval(1):frameIdxInterval(2);
            mergeVoxelLabelsInAnnotaitonSet(this,signalName,indices,imageData);
        end


        function modifyROILabelSet(this,that)
            import vision.internal.labeler.*;

            numROILabels=that.ROILabelSet.NumLabels;

            is21bOrEarlier=strcmp(class(that.ROILabelSet),'vision.internal.labeler.ROILabelSet');

            if is21bOrEarlier
                roiLabels=repmat(vision.internal.labeler.ROILabel(labelType.empty,'','',''),1,numROILabels);
            else
                roiLabels=repmat(lidar.internal.labeler.ROILabel(labelType.empty,'','',''),1,numROILabels);
            end

            for n=1:numROILabels
                roiLabels(n)=that.ROILabelSet.queryLabel(n);
                roiLabels(n)=appendAttributeDef(that,roiLabels(n));
            end

            if is21bOrEarlier
                roiLabelSet=lidar.internal.labeler.ROILabelSet();
                for n=1:numROILabels
                    roiLabelSet.addLabel(roiLabels(n));
                end
                this.ROILabelSet=roiLabelSet;
            end

            this.ROIAnnotations=lidar.internal.labeler.ROIAnnotationSet(this.ROILabelSet,that.ROISublabelSet,that.ROIAttributeSet,that.ROIAnnotations);
            this.FrameAnnotations=lidar.internal.labeler.FrameAnnotationSet(that.FrameLabelSet,that.FrameAnnotations);
        end
    end


    methods(Static,Hidden)
        function this=loadobj(that)


            if isa(that,'lidar.internal.lidarLabeler.tool.Session')
                this=that;
            else
                this=lidar.internal.lidarLabeler.tool.Session;

                loadObjHelper(this,that,true);
            end
        end
    end

    methods
        function gTruth=exportLabelAnnotations(this,signalNames)

            if nargin<2
                signalNames=getSignalNames(this);
            end


            sources=getSource(this.SignalModel);
            dataSources=vision.labeler.loading.MultiSignalSource.empty;

            selectedSignalNames=[];

            for sourceId=1:numel(sources)

                currentSource=sources(sourceId);

                sourceSignalNames=currentSource.SignalName;

                if any(ismember(signalNames,sourceSignalNames))
                    selectedSignalNames=[selectedSignalNames,sourceSignalNames];%#ok<AGROW>

                    className=class(currentSource);

                    newSource=eval(className);

                    newSource.loadSource(currentSource.SourceName,...
                    currentSource.SourceParams);

                    newSource.setTimestamps(currentSource.Timestamp);

                    dataSources=[dataSources;newSource];%#ok<AGROW>
                end
            end


            definitions=exportLabelDefinitions(this);


            timeVectors=getTimeVectors(this.SignalModel,selectedSignalNames);

            maintainROIOrder=false;

            roiAnnotationsTable=this.ROIAnnotations.export2table(timeVectors,selectedSignalNames,maintainROIOrder);
            frameAnnotationsTable=this.FrameAnnotations.export2table(timeVectors,signalNames);
            data=horzcat(roiAnnotationsTable{1},frameAnnotationsTable{1});
            appName=vision.getMessage('lidar:labeler:ToolTitleLL');
            data.Properties.Description=vision.getMessage('vision:labeler:ExportTableDescription',appName,date);

            gTruth=groundTruthLidar(dataSources,definitions,data);
        end

        function definitions=exportLabelDefinitions(this)

            definitions=exportLabelDefinition(this);
            definitions=formatLabelDefinitionTable(this,definitions);

            roiIndices=definitions.SignalType==vision.labeler.loading.SignalType.PointCloud;
            sceneIndices=definitions.SignalType==vision.labeler.loading.SignalType.Time;
            indices=roiIndices|sceneIndices;
            newLabelDefs=definitions(indices,:);
            if any(contains(definitions.Properties.VariableNames,'VoxelLabelID'))&&any(contains(definitions.Properties.VariableNames,'Hierarchy'))
                reorderLabelDefs=[newLabelDefs(:,1),newLabelDefs(:,3),newLabelDefs(:,6),newLabelDefs(:,4),newLabelDefs(:,5),newLabelDefs(:,7),newLabelDefs(:,8)];
            elseif any(contains(definitions.Properties.VariableNames,'Hierarchy'))
                reorderLabelDefs=[newLabelDefs(:,1),newLabelDefs(:,3),newLabelDefs(:,6),newLabelDefs(:,4),newLabelDefs(:,5),newLabelDefs(:,7)];
            elseif any(contains(definitions.Properties.VariableNames,'VoxelLabelID'))
                reorderLabelDefs=[newLabelDefs(:,1),newLabelDefs(:,3),newLabelDefs(:,6),newLabelDefs(:,4),newLabelDefs(:,5),newLabelDefs(:,7)];
            elseif~isempty(newLabelDefs)
                reorderLabelDefs=[newLabelDefs(:,1),newLabelDefs(:,3),newLabelDefs(:,6),newLabelDefs(:,4),newLabelDefs(:,5)];
            end
            reorderLabelDefs.Properties.VariableNames{2}='Type';
            definitions=reorderLabelDefs;
        end


        function definitions=exportLabelDefinition(this)


            roiDefinitionsTable=this.ROILabelSet.export2table;

            sublabelAttribStruct=extractSublabelAttribDefStruct(this,roiDefinitionsTable);
            roiDefinitionsTable=addHierarchyColumnIfNeeded(this,roiDefinitionsTable,sublabelAttribStruct);


            frameDefinitionsTable=this.FrameLabelSet.export2table;


            idx=find(strcmpi(frameDefinitionsTable.Properties.VariableNames,'PixelLabelID'));
            frameDefinitionsTable.Properties.VariableNames{idx}='VoxelLabelID';

            if hasSublabelOrAttributeDefs(this)
                frameDefinitionsTable=addEmptyHierarchyColumn(this,frameDefinitionsTable);
            end

            if~hasVoxelLabel(this.ROILabelSet)


                roiDefinitionsTable.VoxelLabelID=[];
                frameDefinitionsTable.VoxelLabelID=[];
            end



            roiDefinitions=table2struct(roiDefinitionsTable);
            if numel(roiDefinitions)==1&&isfield(roiDefinitions,'Hierarchy')...
                &&~(iscell(roiDefinitions.Hierarchy))
                roiDefinitions.Hierarchy={roiDefinitions.Hierarchy};
            end


            if isfield(roiDefinitions,'VoxelLabelID')&&~(iscell(roiDefinitions(1).VoxelLabelID))
                for i=1:numel(roiDefinitions)
                    roiDefinitions(i).VoxelLabelID={roiDefinitions(i).VoxelLabelID};
                end
            end
            frameDefinitions=table2struct(frameDefinitionsTable);
            definitions=struct2table([roiDefinitions;frameDefinitions],"AsArray",true);

            if~iscell(definitions.LabelColor)
                definitions.LabelColor=mat2cell(definitions.LabelColor,...
                ones(1,size(definitions.LabelColor,1)),size(definitions.LabelColor,2));
            end

        end


        function sublabelAttribStruct=extractSublabelAttribDefStruct(this,roiDefinitionsTable)

            s=[];
            labelNames=roiDefinitionsTable.Name;
            labelTypes=roiDefinitionsTable.Type;
            labelDescriptions=roiDefinitionsTable.Description;

            numLabels=length(labelNames);
            for i=1:numLabels
                if iscell(labelTypes)
                    labeltype=labelTypes{i};
                else
                    labeltype=labelTypes(i);
                end

                if(labeltype~=lidarLabelType.Voxel)
                    labelName=labelNames{i};
                    attribDef4LabelStruct=this.ROIAttributeSet.exportDef2struct(labelName,'');
                    s=appendAtributeofLabelToStruct(this,s,labelName,attribDef4LabelStruct);



                    if isfield(s,labelName)


                        s.(labelName).Type=labeltype;
                        s.(labelName).Description=labelDescriptions{i};
                    end
                end
            end

            sublabelAttribStruct=s;
        end



        function TF=exportVoxelLabelData(this,newFolder)

            TF=true;
            signalNames=getSignalNames(this);

            for sigId=1:numel(signalNames)
                signalName=signalNames(sigId);
                copyFlag=copyVoxelLabelFileFromTemp(this,signalName,newFolder);
                TF=TF&copyFlag;
            end
        end



        function[data,exceptions]=readDataBySignalId(this,signalId,frameIndex,im)

            exceptions=[];

            if(~isempty(im)&&all(size(im.Location)>0))

                imageSize=size(im.Location);


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

                imageSize=[];
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


            data.hasVoxelLabelInfo=false;
            data.LabelMatrix=[];

            if~isempty(this.TempDirectory)&&~isempty(imageSize)
                try


                    data.LabelMatrix=load(fileName).L;



                    lsz=size(data.LabelMatrix);
                    if~isequal(lsz(1),imageSize(1))&&numel(imageSize)==2
                        exceptions=[exceptions...
                        ,MException(message('lidar:labeler:VoxelLabelDataSizeMismatch'))];
                    end



                    data.hasVoxelLabelInfo=true;
                catch
                    if numel(imageSize)==2
                        data.LabelMatrix=[im.Location,zeros(imageSize(1),1,class(im.Location))];
                    elseif numel(imageSize)==3
                        data.LabelMatrix=[reshape(im.Location,imageSize(1)*imageSize(2),3),zeros(imageSize(1)*imageSize(2),1,class(im.Location))];
                    end
                end

            else
                if numel(imageSize)==2
                    data.LabelMatrix=[im.Location,zeros(imageSize(1),1,class(im.Location))];
                elseif numel(imageSize)==3
                    data.LabelMatrix=[reshape(im.Location,imageSize(1)*imageSize(2),3),zeros(imageSize(1)*imageSize(2),1,class(im.Location))];
                end
            end
        end




        function refreshVoxelLabelAnnotation(this)

            signalNames=getSignalNames(this);

            for sigId=1:numel(signalNames)
                signalName=signalNames(sigId);
                addTempFilePathsToAnnotationSet(this,signalName);
            end
        end



        function TF=hasVoxelLabel(this)
            TF=hasVoxelLabel(this.ROILabelSet);
        end


        function N=getVoxelLabels(this)
            N=getNextVoxelLabel(this.ROILabelSet);
        end


        function N=getNumVoxelLabels(this)
            N=this.ROILabelSet.getNumROIByType(lidarLabelType.Voxel);
        end



        function TF=writeData(this,signalName,L,idx)
            try
                save(fullfile(this.TempDirectory,formMaskFileName(this,signalName,idx)),'L');
                setIsVoxelLabelChangedByIdx(this.ROIAnnotations,signalName,idx);
                TF=true;
            catch
                TF=false;
            end
        end




        function setVoxelLabelAnnotation(this,signalName,index,labelPath)

            if isempty(this.TempDirectory)
                setTempDirectory(this);
            end

            index=max(index,1);
            this.ROIAnnotations.setVoxelLabelAnnotation(signalName,index,labelPath);
            setIsVoxelLabelChangedByIdx(this.ROIAnnotations,signalName,index);
            this.IsChanged=true;
        end

        function name=formMaskFileName(this,signalName,idx)
            signalName4Tool=getConvertedSignalName(this,signalName);
            name=sprintf('Label_%d.mat',idx);
            if~isempty(signalName4Tool)
                name=[char(signalName4Tool),'_',name];
            end
        end




        function deleteVoxelLabelData(this,labelID)


            signalNames=getSignalNames(this);
            for sigId=1:numel(signalNames)

                signalName=signalNames(sigId);

                for idx=1:getNumFramesBySignal(this,signalName)
                    try
                        maskFileName=formMaskFileName(this,signalName,idx);
                        L=load(fullfile(this.TempDirectory,maskFileName)).L;
                        labels=L(:,4);
                        labels(labels==labelID)=0;
                        L(:,4)=labels;
                        save(fullfile(this.TempDirectory,formMaskFileName(this,signalName,idx)),'L');
                    catch

                    end
                end
            end

            setIsVoxelLabelChangedAll(this.ROIAnnotations);
        end




        function TF=importVoxelLabelData(this)

            TF=true;


            if isempty(this.TempDirectory)
                setTempDirectory(this);
            end

            signalNames=getSignalNames(this);

            for sigId=1:numel(signalNames)

                signalName=signalNames(sigId);


                for idx=1:getNumFramesBySignal(this,signalName)
                    isCopied=copyVoxelLabelFileToTemp(this,signalName,idx);
                    if~isCopied
                        TF=false;
                    end
                end
            end

            resetIsVoxelLabelChangedAll(this.ROIAnnotations);
        end




        function saveSessionData(this)


            [pathstr,name,~]=fileparts(this.FileName);

            sessionPath=fullfile(pathstr,['.',name,'_SessionData']);


            if hasVoxelLabel(this)


                if~isfolder(sessionPath)
                    mkdir(sessionPath)
                    if ispc

                        fileattrib(sessionPath,'+h')
                    end
                end

                signalNames=getSignalNames(this);

                for sigId=1:numel(signalNames)
                    signalName=signalNames(sigId);



                    isVoxelLabelChanged=getIsVoxelLabelChanged(this.ROIAnnotations,signalName);

                    for idx=1:getNumFramesBySignal(this,signalName)


                        filePath=getVoxelLabelAnnotation(this.ROIAnnotations,...
                        signalName,idx);
                        newFilePath=fullfile(sessionPath,formMaskFileName(this,signalName,idx));
                        if~isempty(filePath)
                            if isVoxelLabelChanged(idx)&&~strcmp(filePath,newFilePath)


                                copyfile(filePath,newFilePath,'f');
                                setVoxelLabelAnnotation(this,signalName,...
                                idx,newFilePath);
                            else
                                if exist(newFilePath,'file')


                                    setVoxelLabelAnnotation(this,signalName,...
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

            resetIsVoxelLabelChangedAll(this.ROIAnnotations);

        end


        function voxelDataPath=getVoxelLabelDataPath(this)
            voxelDataPath=this.VoxelLabelDataPath;
        end


        function labelVisibility=getGlobalVoxelLabelVisibility(this)


            labelVisibility=true(255,1);
            roiDefStruct=this.ROILabelSet.DefinitionStruct;
            for i=1:numel(roiDefStruct)
                if isequal(roiDefStruct(i).Type,...
                    lidarLabelType.Voxel)&&~roiDefStruct(i).ROIVisibility
                    labelVisibility(roiDefStruct(i).VoxelLabelID)=false;
                end
            end
        end


        function setVoxelLabelDataPath(this,voxelDataPath)
            this.VoxelLabelDataPath=voxelDataPath;
        end



        function s=decodeImportedLabelDef(this,allDefs)
            numLabels=numel(allDefs);
            hasHierarchyCol=isfield(allDefs,'Hierarchy');

            for lbl=1:numLabels
                thisDef=allDefs(lbl);
                s.Label{lbl}=createLabelObject(this,thisDef);

                s.AttribOfLabel{lbl}={};
                s.Sublabel{lbl}={};
                s.AttribOfSublabel{lbl}={};

                if hasHierarchyCol
                    thisLabelHierarchy=thisDef.Hierarchy;
                    if~isempty(thisLabelHierarchy)
                        labelName=thisDef.Name;
                        s.AttribOfLabel{lbl}=createAttribOfLabelObjects(this,labelName,thisLabelHierarchy);

                        [thisSublabelObs,thisAttribObjs]=createSublabelAttribObjects(this,labelName,thisLabelHierarchy);
                        s.Sublabel{lbl}=thisSublabelObs;
                        s.AttribOfSublabel{lbl}=thisAttribObjs;
                    end
                end
            end
        end


        function addLabelData(this,signalName,definitions,labelData,indices,orderData)


            labels=table2struct(labelData);
            if(~isempty(orderData))
                polyOrderData=table2struct(orderData);
            else
                polyOrderData=[];
            end

            fields=fieldnames(labels);


            areROIsPresent=any(getROILabels(definitions.Type));
            if areROIsPresent
                [~,rectangleLabels]=findLabelTypeIdx(definitions.Type,labelType.Rectangle);
                [~,lineLabels]=findLabelTypeIdx(definitions.Type,labelType.Line);
                [~,voxelLabels]=findLabelTypeIdx(definitions.Type,lidarLabelType.Voxel);

                roiLabels=definitions{...
                (rectangleLabels|lineLabels|voxelLabels),'Name'};
                [roiLabels,isROILabel]=intersect(fields,roiLabels,'stable');

                isVoxelLabel=find(strcmp(fields,'VoxelLabelData'));
            else
                isROILabel=false(size(fields));
            end


            areFrameLabelsPresent=any(getSceneLabels(definitions.Type));
            if areFrameLabelsPresent
                frameLabels=definitions{getSceneLabels(definitions.Type),'Name'};
                [~,isFrameLabel]=intersect(fields,frameLabels,'stable');
            else
                isFrameLabel=false(size(fields));
            end


            for n=1:numel(indices)
                positionsOrFrameLabel=struct2cell(labels(n));

                roiOrder=[];

                if areROIsPresent
                    if~isempty(isROILabel)
                        positions=positionsOrFrameLabel(isROILabel);
                        numROILabels=length(positions);

                        if numROILabels
                            sublabelNames=repmat({''},numROILabels,1);
                            roiPositions=cell(numROILabels,1);
                            roiLabelList=repmat({''},numROILabels,1);
                            labelUID=repmat({''},numROILabels,1);
                            sublabelUID=repmat({''},numROILabels,1);
                            order=zeros(numROILabels,1);
                            attributeROIUID={};
                            attributeLabelNames={};
                            attributeSublabelNames={};
                            attributeData={};

                            idx=0;



                            containsSublabels=isstruct(positions{1});

                            for roiLabel=1:numROILabels

                                if~iscell(positions{roiLabel})&&size(positions{roiLabel},2)==2...
                                    &&~isstruct(positions{roiLabel})
                                    positions{roiLabel}={positions(roiLabel)};
                                end

                                numberOfROIs=getNumROIs(positions{roiLabel});
                                for roi=1:numberOfROIs
                                    if isempty(positions{roiLabel})

                                        continue;
                                    end
                                    if containsSublabels
                                        roiPosition=positions{roiLabel}(roi).Position;
                                    else
                                        roiPosition=positions{roiLabel}(roi,:);



                                    end

                                    idx=idx+1;
                                    roiLabelList{idx,1}=roiLabels{roiLabel};
                                    roiPositions{idx,1}=roiPosition;
                                    sublabelNames{idx,1}='';
                                    uid=vision.internal.getUniqueID();
                                    labelUID{idx,1}=uid;
                                    sublabelUID{idx,1}='';



                                    order(idx)=-1;


                                    if containsSublabels
                                        fields=fieldnames(positions{roiLabel}(roi));
                                        sublabelAndAttrNames=fields(~(string(fields)=="Position"));
                                        numSubAndAttr=numel(sublabelAndAttrNames);
                                        attrNames={};
                                        subNames={};

                                        if~any(contains(definitions.Properties.VariableNames,'Hierarchy'))
                                            Hierarchy=repmat(struct(),height(definitions),1);
                                            definitions=addvars(definitions,Hierarchy);
                                        end


                                        if isstruct(definitions.Hierarchy)
                                            definitions.Hierarchy=num2cell(definitions.Hierarchy);
                                        end

                                        hierarchyIdx=string(definitions.Name)==string(roiLabels{roiLabel});
                                        selectedHierarchy=definitions.Hierarchy{hierarchyIdx};

                                        for i=1:numSubAndAttr
                                            isValidStruct=~isempty(selectedHierarchy)&&...
                                            isfield(selectedHierarchy,sublabelAndAttrNames{i});



                                            if isValidStruct
                                                subAttrStruct=selectedHierarchy.(sublabelAndAttrNames{i});
                                            end
                                            if isValidStruct&&this.isAttributeStruct(subAttrStruct)
                                                attrNames=[attrNames;sublabelAndAttrNames{i}];%#ok<AGROW>
                                            end
                                        end

                                        for attrNum=1:numel(attrNames)
                                            attrName=attrNames{attrNum,:};
                                            attributeROIUID{end+1}=uid;%#ok<AGROW>
                                            attributeLabelNames{end+1}=roiLabels{roiLabel};%#ok<AGROW>
                                            attributeSublabelNames{end+1}='';%#ok<AGROW>
                                            attribS=selectedHierarchy.(attrName);
                                            [type,~]=this.decodeAttributeTypeValue(attribS);
                                            attributeData{end+1}=struct('AttributeName',attrName,...
                                            'AttributeType',type,...
                                            'AttributeValue',positions{roiLabel}(roi).(attrName));%#ok<AGROW>
                                        end
                                    end
                                end
                            end

                            [~,sortidx]=sort(order,'descend');
                            this.ROIAnnotations.addAnnotation(signalName,indices(n),...
                            roiLabelList(sortidx),sublabelNames(sortidx),labelUID(sortidx),...
                            sublabelUID,roiPositions(sortidx));
                            for i=1:numel(attributeROIUID)
                                updateAnnotationsForAttributesValue(this,...
                                signalName,indices(n),attributeROIUID{i},...
                                attributeLabelNames{i},...
                                attributeSublabelNames{i},attributeData{i});
                            end
                        end
                    end

                    if isVoxelLabel

                        if isempty(this.TempDirectory)
                            setTempDirectory(this);
                        end
                        positions=positionsOrFrameLabel(isVoxelLabel);
                        assert(numel(positions)==1,'Expected just 1 file');

                        if~isempty(positions{1})



                            this.copyData(signalName,positions{1},...
                            indices(n));
                        end
                    end
                end

                if areFrameLabelsPresent
                    frLabelData=positionsOrFrameLabel(isFrameLabel);
                    this.FrameAnnotations.appendAnnotation(signalName,indices(n),...
                    frameLabels,frLabelData);
                end
            end
            this.IsChanged=true;
        end

    end

    methods(Access=protected)

        function mergeVoxelLabelsInAnnotaitonSet(this,signalName,indices,imagesData)


            autoDirectory=this.TempDirectory;
            cachedDirectory=fileparts(autoDirectory);

            for idx=1:numel(indices)
                imageData=imagesData{idx};

                maskFileName=formMaskFileName(this,signalName,indices(idx));
                autoLabelFile=fullfile(autoDirectory,maskFileName);
                cachedLabelFile=fullfile(cachedDirectory,maskFileName);

                if~exist(autoLabelFile,'file')
                    return;
                end

                try
                    L=load(cachedLabelFile).L;
                catch
                    L=[];
                end

                try
                    autoL=load(autoLabelFile).L;

                    if isempty(L)
                        sz=size(imageData.Location);
                        if ismatrix(imageData.Location)
                            L=[imageData.Location,zeros(sz(1),1,class(imageData.Location))];
                        else
                            L=imageData.Location;
                            L(:,:,4)=zeros(sz(1),sz(2),class(imageData.Location));
                        end
                    end


                    if numel(size(L))==2
                        L(autoL(:,4)>0,:)=autoL(autoL(:,4)>0,:);
                    else
                        sz=size(L);
                        L=reshape(L,sz(1)*sz(2),4);
                        autoL=reshape(autoL,sz(1)*sz(2),4);
                        L(autoL(:,4)>0,:)=autoL(autoL(:,4)>0,:);
                        L=reshape(L,sz);
                    end

                    save(cachedLabelFile,'L');

                    setIsVoxelLabelChangedByIdx(this.ROIAnnotations,signalName,indices(idx));
                    setVoxelLabelAnnotation(this,signalName,indices(idx),...
                    cachedLabelFile);
                catch
                    setVoxelLabelAnnotation(this,signalName,indices(idx),...
                    '');
                end
            end
        end


        function TF=copyVoxelLabelFileToTemp(this,signalName,idx)
            TF=true;
            try
                filePath=getVoxelLabelAnnotation(this.ROIAnnotations,...
                signalName,idx);
                if~isempty(filePath)
                    maskFileName=formMaskFileName(this,signalName,idx);
                    newFilePath=fullfile(this.TempDirectory,maskFileName);


                    if~contains(filePath,maskFileName)
                        filePath=fullfile(filePath,maskFileName);
                    end
                    copyfile(filePath,newFilePath,'f');


                    fileattrib(newFilePath,'+w');
                    setVoxelLabelAnnotation(this,signalName,idx,...
                    newFilePath);
                end
            catch
                setVoxelLabelAnnotation(this,signalName,idx,'');
                TF=false;
            end
        end

        function TF=copyVoxelLabelFileFromTemp(this,signalName,newFolder)
            TF=true;
            signalName=char(signalName);
            if~isempty(this.TempDirectory)
                for idx=1:getNumFramesBySignal(this,signalName)
                    try
                        filePath=getVoxelLabelAnnotation(this.ROIAnnotations,...
                        signalName,idx);
                        if~isempty(filePath)
                            newFilePath=fullfile(newFolder,formMaskFileName(this,signalName,idx));
                            copyfile(filePath,newFilePath,'f');
                            setVoxelLabelAnnotation(this,signalName,idx,...
                            newFilePath);
                        end
                    catch
                        setVoxelLabelAnnotation(this,signalName,idx,'');
                        TF=false;
                    end
                end
            else
                TF=false;
            end
        end

        function addTempFilePathsToAnnotationSet(this,signalName)
            for idx=1:getNumFramesBySignal(this,signalName)
                filePath=getVoxelLabelAnnotation(this.ROIAnnotations,...
                signalName,idx);
                if~isempty(filePath)
                    newFilePath=fullfile(this.TempDirectory,formMaskFileName(this,signalName,idx));
                    setVoxelLabelAnnotation(this,signalName,idx,...
                    newFilePath);
                end
            end
        end
    end

    methods(Access=private)
        function outputLabelDefinitions=formatLabelDefinitionTable(~,inputLabelDefinitions)


            index=string(inputLabelDefinitions.Properties.VariableNames)=="Type";
            inputLabelDefinitions.Properties.VariableNames{index}='LabelType';



            inputLabelDefinitions=replicateLabelsForPCData(...
            inputLabelDefinitions,labelType.Rectangle,labelType.Cuboid);
            inputLabelDefinitions=replicateLabelsForPCData(...
            inputLabelDefinitions,labelType.Line,labelType.Line);


            signalTypes=vision.labeler.loading.SignalType.empty(height(inputLabelDefinitions),0);

            additionalEntry=0;
            totalEntry=height(inputLabelDefinitions)-numel(findLabelTypeIdx(inputLabelDefinitions.LabelType,labelType.Line))/2;
            for idx=1:totalEntry
                if~iscell(inputLabelDefinitions.LabelType)
                    type=inputLabelDefinitions.LabelType(idx+additionalEntry);
                else
                    type=inputLabelDefinitions.LabelType{idx+additionalEntry};
                end
                switch type
                case{labelType.Rectangle}
                    signalTypes(idx+additionalEntry)=vision.labeler.loading.SignalType.Image;
                case{labelType.Cuboid}
                    signalTypes(idx+additionalEntry)=vision.labeler.loading.SignalType.PointCloud;
                case{labelType.Line}
                    signalTypes(idx+additionalEntry)=vision.labeler.loading.SignalType.Image;
                    additionalEntry=additionalEntry+1;
                    signalTypes(idx+additionalEntry)=vision.labeler.loading.SignalType.PointCloud;
                case labelType.Scene
                    signalTypes(idx+additionalEntry)=vision.labeler.loading.SignalType.Time;
                otherwise
                    signalTypes(idx+additionalEntry)=vision.labeler.loading.SignalType.PointCloud;
                end
            end

            inputLabelDefinitions=addvars(inputLabelDefinitions,signalTypes',...
            'After','Name','NewVariableNames',"SignalType");

            inputLabelDefinitions=movevars(inputLabelDefinitions,'Group',...
            'After','LabelType');
            inputLabelDefinitions=movevars(inputLabelDefinitions,'Description',...
            'After','Group');
            inputLabelDefinitions=movevars(inputLabelDefinitions,'LabelColor',...
            'After','Description');

            variableNames=string(inputLabelDefinitions.Properties.VariableNames);

            if any(variableNames=="Hierarchy")
                columnName='LabelColor';
                inputLabelDefinitions=movevars(inputLabelDefinitions,'Hierarchy',...
                'After',columnName);


                indice=find(inputLabelDefinitions.SignalType==vision.labeler.loading.SignalType.PointCloud);
                for idx=1:numel(indice)
                    rowIdx=indice(idx);
                    if iscell(inputLabelDefinitions.Hierarchy)
                        hierarchyStruct=inputLabelDefinitions.Hierarchy{rowIdx};
                        if isstruct(hierarchyStruct)
                            inputLabelDefinitions.Hierarchy{rowIdx}.Type=labelType.Cuboid;
                        end
                    else
                        hierarchyStruct=inputLabelDefinitions.Hierarchy(rowIdx);
                        if isstruct(hierarchyStruct)
                            inputLabelDefinitions.Hierarchy(rowIdx).Type=labelType.Cuboid;
                        end
                    end
                end
            end

            if any(variableNames=="Hierarchy")
                if any(variableNames=="VoxelLabelID")
                    columnName='VoxelLabelID';
                else
                    columnName='LabelColor';
                end
                inputLabelDefinitions=movevars(inputLabelDefinitions,'Hierarchy',...
                'After',columnName);
            end

            outputLabelDefinitions=inputLabelDefinitions;
        end
    end

    methods(Hidden)
        function that=saveobj(this,~)
            that=saveobj@vision.internal.videoLabeler.tool.Session(this);
            that.SyncImageViewerHandle=this.SyncImageViewerHandle;
            that.SavedCameraViewParameters=this.SavedCameraViewParameters;
        end
    end
end

function inputLabelDefinitions=replicateLabelsForPCData(inputLabelDefinitions,labelTypes,suportedLabelType)
    indices=findLabelTypeIdx(inputLabelDefinitions.LabelType,labelTypes);

    for idx=1:numel(indices)

        rowIdx=indices(idx);
        inputLabelDefinitions=[inputLabelDefinitions(1:rowIdx,:);...
        inputLabelDefinitions(rowIdx,:);...
        inputLabelDefinitions(rowIdx+1:end,:)];

        if iscell(inputLabelDefinitions.LabelType)
            inputLabelDefinitions.LabelType{rowIdx+1}=suportedLabelType;
        else
            inputLabelDefinitions.LabelType(rowIdx+1)=suportedLabelType;
        end

        indices(idx+1:end)=indices(idx+1:end)+1;
    end
end

function[idx,logicalIdx]=findLabelTypeIdx(labelTypeChoicesEnum,labels)

    idx=1:numel(labelTypeChoicesEnum);
    logicalIdx=ones(1,numel(labelTypeChoicesEnum));
    if~iscell(labelTypeChoicesEnum)
        for i=1:numel(labelTypeChoicesEnum)
            if~(labelTypeChoicesEnum(i)==labels)
                idx(i)=0;
                logicalIdx(i)=0;
            end
        end
    else
        for i=1:numel(labelTypeChoicesEnum)
            if~(labelTypeChoicesEnum{i}==labels)
                idx(i)=0;
                logicalIdx(i)=0;
            end
        end
    end
    idx=nonzeros(idx);
end


function n=getNumROIs(pos)
    if isstruct(pos)

        n=numel(pos);
    elseif ismatrix(pos)

        n=size(pos,1);
    elseif iscell(pos)
        n=numel(pos);
    else

        assert(false,"LabelData in groundTruth contains invalid entries.");
    end
end



function idx=getROILabels(labels)
    idx=1:numel(labels);
    if iscell(labels)
        for i=1:numel(labels)
            if~(isROI(labels{i}))
                idx(i)=0;
            end
        end
    else
        for i=1:numel(labels)
            if~(isROI(labels(i)))
                idx(i)=0;
            end
        end
    end
    idx=nonzeros(idx);
end


function idx=getSceneLabels(labels)

    idx=1:numel(labels);
    if iscell(labels)
        for i=1:numel(labels)
            if~(isScene(labels{i}))
                idx(i)=0;
            end
        end
    else
        for i=1:numel(labels)
            if~(isScene(labels(i)))
                idx(i)=0;
            end
        end
    end
    idx=nonzeros(idx);
end