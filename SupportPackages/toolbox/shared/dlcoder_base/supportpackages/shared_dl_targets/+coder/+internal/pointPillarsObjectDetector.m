%#codegen
%#internal




classdef pointPillarsObjectDetector<coder.internal.NetworkWrapper

    properties




AnchorBoxes



ClassNames



PointCloudRange



VoxelSize


NumPillars



NumPointsPerPillar
    end

    methods(Static,Access=public,Hidden)




        function n=matlabCodegenNontunableProperties(~)
            n={'AnchorBoxes','ClassNames','PointCloudRange','VoxelSize','NumPillars','NumPointsPerPillar'};
        end
    end

    methods




        function obj=pointPillarsObjectDetector(matfile,varargin)
            coder.allowpcode('plain');
            coder.internal.prefer_const(matfile);


            containsDLNetwork=true;
            obj=obj@coder.internal.NetworkWrapper(containsDLNetwork,matfile,varargin{:});


            coder.extrinsic('coder.internal.pointPillarsObjectDetector.getNetworkProperties');
            [obj.AnchorBoxes,obj.ClassNames,obj.PointCloudRange,...
            obj.VoxelSize,obj.NumPillars,obj.NumPointsPerPillar]=...
            coder.const(@coder.internal.pointPillarsObjectDetector.getNetworkProperties,matfile);

        end





        function[bboxes,scores,varargout]=detect(this,ptCloud,varargin)


            coder.gpu.internal.kernelfunImpl(false);
            nargoutchk(1,3);

            [params,~]=...
            this.parseDetectInputs(ptCloud,varargin{:});



            ptCloudUnorg=removeInvalidPoints(ptCloud);
            dataIn=[ptCloudUnorg.Location,ptCloudUnorg.Intensity];
            [pillarIndices,pillarEncodedFeatures]...
            =lidar.internal.buildable.createPillarsBuildable.createPillars...
            (dataIn,this.NumPillars,this.NumPointsPerPillar,this.VoxelSize,this.PointCloudRange);




            dlPillarFeatures=dlarray(single(pillarEncodedFeatures),'SSCB');
            dlPillarIndices=dlarray(single(pillarIndices),'SSCB');
            predictions=this.computeNetworkActivations(dlPillarIndices,dlPillarFeatures);



            [bboxes,scores,varargout{1}]=this.iPostprocessSingleDetection(predictions,pillarIndices,params);

        end
    end

    methods(Hidden)
        function identifier=getNetworkWrapperIdentifier(~)

            identifier='pointPillarsObjectDetector';
        end
    end

    methods(Hidden=true,Static)




        function[anchors,classNames,pcRange,voxelSize,numPillars,...
            numPointsPerPillar]=getNetworkProperties(matfile)

            detectorObj=coder.internal.loadDeepLearningNetwork(matfile);

            anchors=detectorObj.AnchorBoxes;


            labelArray=cellstr(detectorObj.ClassNames);

            lengthArray=cellfun(@strlength,labelArray);

            numClasses=coder.const(numel(labelArray));


            classNames=coder.const(char(zeros(numClasses,max(lengthArray))));


            for labelIdx=1:numClasses
                classNames(labelIdx,1:lengthArray(labelIdx))=labelArray{labelIdx};
            end

            pcRange=detectorObj.PointCloudRange;
            voxelSize=detectorObj.VoxelSize;
            numPillars=detectorObj.NumPillars;
            numPointsPerPillar=detectorObj.NumPointsPerPillar;
        end

    end

    methods(Access=private)



        function[params,miniBatchSize]=parseDetectInputs(~,ptCloud,varargin)




            coder.internal.errorIf(~isa(ptCloud,'pointCloud'),'lidar:pointPillarsObjectDetector:invalidInputData');

            possibleNameValues={'Threshold',...
            'MiniBatchSize',...
            'SelectStrongest',...
            'Acceleration'};
            poptions=struct(...
            'CaseSensitivity',false,...
            'PartialMatching','unique',...
            'StructExpand',false,...
            'IgnoreNulls',true);

            defaults=struct('MiniBatchSize',8,...
            'Threshold',0.5,...
            'SelectStrongest',true,...
            'Acceleration','auto');

            miniBatchSize=coder.const(8);

            if(nargin==1)
                params=defaults;
            else
                pstruct=coder.internal.parseParameterInputs(possibleNameValues,poptions,varargin{:});
                Threshold=coder.internal.getParameterValue(pstruct.Threshold,defaults.Threshold,varargin{:});
                SelectStrongest=coder.internal.getParameterValue(pstruct.SelectStrongest,defaults.SelectStrongest,varargin{:});
                miniBatchSize=coder.internal.getParameterValue(pstruct.MiniBatchSize,defaults.MiniBatchSize,varargin{:});
                acceleration=coder.internal.getParameterValue(pstruct.Acceleration,defaults.Acceleration,varargin{:});

                params.Threshold=Threshold;
                params.SelectStrongest=SelectStrongest;
                params.Acceleration=acceleration;
            end


            coder.internal.assert(coder.internal.isConst(miniBatchSize),...
            'dlcoder_spkg:ObjectDetector:VariableSizeMiniBatch');




            vision.internal.cnn.validation.checkMiniBatchSize(coder.const(miniBatchSize),mfilename);




            vision.internal.inputValidation.validateLogical(...
            params.SelectStrongest,'SelectStrongest');




            validateattributes(params.Threshold,{'single','double'},{'nonempty','nonnan',...
            'finite','nonsparse','real','scalar','>=',0,'<=',1},...
            mfilename,'Threshold');




            if~coder.internal.isConst(params.Acceleration)||~coder.const(@(x)strcmpi(x,'none')||strcmpi(x,'auto')||strcmpi(x,'mex'),params.Acceleration)
                coder.internal.error([params.Acceleration,' is not a valid NVP for Acceleration']);
            end
        end


        function YPredictions=computeNetworkActivations(this,pillarIndices,pillarFeatures)

            NumOutputs=coder.const(numel(this.Network.OutputNames));
            YPredictions=cell(NumOutputs,1);
            [YPredictions{:}]=this.Network.predict(pillarIndices,pillarFeatures);
        end


        function[boxPred,scores,labelNames]=iPostprocessSingleDetection(this,YPredData,pillarIndices,params)

            anchorBoxes=this.AnchorBoxes;
            voxelSize=this.VoxelSize;
            pcRange=this.PointCloudRange;

            boxPreds=iGenerateDetections(YPredData,pillarIndices,anchorBoxes,voxelSize,pcRange,params);
            boxClasses=this.ClassNames;
            if~isempty(boxPreds)
                posIdx=find(boxPreds(:,9)>0.15);


                boxPreds(:,7)=rad2deg(boxPreds(:,7));

                if~isempty(posIdx)
                    bboxRotRect=boxPreds(posIdx,[1,2,4,5,7]);
                    scores=boxPreds(posIdx,8);
                    labels=boxPreds(posIdx,9);

                    if params.SelectStrongest
                        [~,scores,labels,idx]=selectStrongestBboxMulticlass(bboxRotRect,scores,labels,...
                        'RatioType','Min','OverlapThreshold',0.1);
                        box3D=boxPreds(idx,:);


                        boxPred=zeros(size(box3D,1),9);
                        boxPred(:,[1,2,3,4,5,6,9])=box3D(:,1:7);
                    else
                        box3D=boxPreds;
                        boxPred=zeros(size(box3D,1),9);
                        boxPred(:,[1,2,3,4,5,6,9])=box3D(:,1:7);
                    end
                    numbboxes=size(boxPred,1);
                    labelNames=returnCategoricalLabels(boxClasses,numbboxes,labels);

                else
                    boxPred=[];
                    scores=[];
                    numBBoxes=0;
                    labels=[];
                    labelNames=returnCategoricalLabels(boxClasses,numBBoxes,labels);
                end
            else
                boxPred=[];
                scores=[];
                numBBoxes=0;
                labels=[];
                labelNames=returnCategoricalLabels(boxClasses,numBBoxes,labels);
            end
        end
    end
end



function boxPreds=iGenerateDetections(YPredictions,pillarIndices,anchorBoxes,vSize,pcRange,params)

    coder.internal.prefer_const(pillarIndices,anchorBoxes,vSize,pcRange);

    confidenceThreshold=params.Threshold;


    [~,anchorsBEV]=lidar.internal.cnn.createAnchorsPointPillars(pcRange,vSize,anchorBoxes);

    dsFactor=coder.const(2);
    xMin=coder.const(pcRange(1,1));
    xMax=coder.const(pcRange(1,2));
    yMin=coder.const(pcRange(1,3));
    yMax=coder.const(pcRange(1,4));

    gridXY=double(zeros([1,2]));
    gridXY(1,1)=coder.const(round((xMax-xMin)/vSize(1,1)));
    gridXY(1,2)=coder.const(round((yMax-yMin)/vSize(1,2)));


    anchorMask=lidar.internal.cnn.createAnchorMaskPointPillars(pillarIndices,pcRange,vSize,gridXY,anchorsBEV);


    anchorMask=anchorMask>1;
    gridX=coder.const(gridXY(1,1)/dsFactor);
    gridY=coder.const(gridXY(1,2)/dsFactor);


    numAnchors=0;
    for i=1:size(anchorBoxes,1)
        numAnchors=numAnchors+size(anchorBoxes{i,1},1);
    end


    newAnchors=cell(1,numAnchors);
    newAnchors=coder.nullcopy(newAnchors);
    ii=1;
    for i=1:size(anchorBoxes,1)
        for j=1:size(anchorBoxes{i,1},1)
            newAnchors{1,ii}=anchorBoxes{i,1}(j,:);
            ii=ii+1;
        end
    end

    anchorMask=reshape(anchorMask,[numAnchors,gridX,gridY]);
    anchorMask=permute(anchorMask,[2,3,1]);

    YPredictionsNew=cell(size(YPredictions));
    for ii=1:size(YPredictions,1)
        YPredictionsNew{ii,1}=squeeze(extractdata(YPredictions{ii,1}));
    end


    predAngle=YPredictionsNew{6,1};
    predOcc=YPredictionsNew{3,1};
    predLoc=reshape(YPredictionsNew{2,1},[gridX,gridY,numAnchors,3]);
    predSz=reshape(YPredictionsNew{1,1},[gridX,gridY,numAnchors,3]);
    predHeading=YPredictionsNew{5,1};
    predClassification=YPredictionsNew{4,1};

    posIndices=find((predOcc>confidenceThreshold)&(anchorMask));
    [row,col,anchorNum]=ind2sub(size(predOcc),posIndices);


    confScore=arrayfun(@(x,y,z)predOcc(x,y,z),row,col,anchorNum);


    xCen=(vSize(1,1))*(dsFactor)*(row-1)+xMin+vSize(1,1);
    yCen=(vSize(1,2))*(dsFactor)*(col-1)+yMin+vSize(1,2);


    xGt=arrayfun(@(x,y,a,c)(predLoc(x,y,a,1)*(sqrt(newAnchors{1,a}(1)^2+newAnchors{1,a}(2)^2))+c),row,col,anchorNum,xCen);
    yGt=arrayfun(@(x,y,a,c)(predLoc(x,y,a,2)*(sqrt(newAnchors{1,a}(1)^2+newAnchors{1,a}(2)^2))+c),row,col,anchorNum,yCen);
    zGt=arrayfun(@(x,y,a,c)(predLoc(x,y,a,3)*newAnchors{1,a}(3)+newAnchors{1,a}(4)),row,col,anchorNum);
    zGt=0.5*zGt;


    lGt=arrayfun(@(x,y,a)(exp(predSz(x,y,a,1))*newAnchors{1,a}(1)),row,col,anchorNum);
    wGt=arrayfun(@(x,y,a)(exp(predSz(x,y,a,2))*newAnchors{1,a}(2)),row,col,anchorNum);
    hGt=arrayfun(@(x,y,a)(exp(predSz(x,y,a,3))*newAnchors{1,a}(3)),row,col,anchorNum);

    hdGt=arrayfun(@(x,y,a)predHeading(x,y,a),row,col,anchorNum);
    hdGt(hdGt>=0.5)=1;
    hdGt(hdGt<0.5)=-1;


    predAngle((predAngle>1)|(predAngle<-1))=0;
    angGt=arrayfun(@(x,y,a,h)(h*asin(predAngle(x,y,a))+newAnchors{1,a}(5)),row,col,anchorNum,hdGt);
    angGt=iWrapToPi(angGt);

    predClassification=reshape(predClassification,gridX,gridY,numAnchors,[]);
    numClasses=size(predClassification,4);


    if(numClasses>1)
        clsMat=zeros(size(row,1),numClasses);
        for i=1:size(row,1)
            clsMat(i,:)=squeeze(predClassification(row(i,1),col(i,1),anchorNum(i,1),:))';
        end
        [~,cls]=max(clsMat,[],2);
    else
        cls=double(arrayfun(@(x,y,a)predClassification(x,y,a),row,col,anchorNum));
        cls=1./(1.+exp(-cls));
        cls(cls>=confidenceThreshold)=1;
        cls(cls<confidenceThreshold)=0;
    end

    boxPreds=[xGt,yGt,zGt,lGt,wGt,hGt,angGt,confScore,cls];
end


function alpha=iWrapToPi(alpha)
    idx=alpha>pi;
    alpha(idx)=alpha(idx)-2*pi;

    idx=alpha<-pi;
    alpha(idx)=alpha(idx)+2*pi;
end



function labelNamesMod=returnCategoricalLabels(classNames,numBBoxes,labels)
    coder.inline('never');



    labelCells=coder.nullcopy(cell(numBBoxes,1));
    for i=1:numBBoxes

        labelCells{i,1}=nonzeros(classNames(labels(i),:))';
    end






    valueset={};
    upperBound=size(classNames,1);
    coder.varsize('valueset',[1,upperBound],[0,1]);
    for i=1:upperBound
        valueset{end+1}=nonzeros(classNames(i,:))';
    end

    labelNames=categorical(labelCells,valueset);
    labelNamesMod=labelNames';
end
