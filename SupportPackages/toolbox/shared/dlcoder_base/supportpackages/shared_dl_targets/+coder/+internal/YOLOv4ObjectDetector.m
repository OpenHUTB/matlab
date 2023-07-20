%#codegen



classdef YOLOv4ObjectDetector<coder.internal.NetworkWrapper

    properties




AnchorBoxes



ClassNames



InputSize
    end

    methods(Static,Access=public,Hidden)




        function n=matlabCodegenNontunableProperties(~)
            n={'AnchorBoxes','ClassNames','InputSize'};
        end

    end

    methods




        function obj=YOLOv4ObjectDetector(matfile,varargin)
            coder.allowpcode('plain');


            containsDLNetwork=true;
            obj=obj@coder.internal.NetworkWrapper(containsDLNetwork,matfile,varargin{:});


            coder.extrinsic('coder.internal.YOLOv4ObjectDetector.getNetworkProperties');
            [obj.AnchorBoxes,obj.ClassNames,obj.InputSize]...
            =coder.const(@coder.internal.YOLOv4ObjectDetector.getNetworkProperties,matfile);

        end






        function[bboxes,scores,varargout]=detect(this,I,varargin)

            coder.gpu.internal.kernelfunImpl(false);
            nargoutchk(1,3);

            returnLabels=coder.const(nargout>2);


            coder.extrinsic('vision.internal.detector.checkROI');

            useROI=false;
            inputImageSize=this.InputSize;
            roiImageSize=coder.nullcopy(ones(1,numel(inputImageSize)));

            if(~isempty(varargin)&&(isa(varargin{1},'numeric')))

                roi=varargin{1};


                coder.internal.assert(coder.internal.isConst(roi),...
                'dlcoder_spkg:ObjectDetector:roiConstant')
                coder.internal.errorIf(~(isvector(roi)&&(size(roi,2)==4)),'dlcoder_spkg:ObjectDetector:roiIncorrectNumel')


                coder.const(feval('vision.internal.detector.checkROI',roi,size(I)));



                useROI=true;
                [params,detectionInputWasBatchOfImages,miniBatchSize]=this.parseDetectInputs(I,roi,useROI,varargin{2:end});

                roiImageSize(1)=roi(4);
                roiImageSize(2)=roi(3);
                if(numel(inputImageSize)==3)
                    roiImageSize(3)=inputImageSize(3);
                end
            else


                roi=coder.nullcopy(zeros(1,4));



                [params,detectionInputWasBatchOfImages,miniBatchSize]=this.parseDetectInputs(I,roi,useROI,varargin{:});
                roiImageSize(1)=size(I,1);
                roiImageSize(2)=size(I,2);
                if(numel(inputImageSize)==3)
                    roiImageSize(3)=size(I,3);
                end
            end



            iRoi=vision.internal.detector.cropImageIfRequested(I,roi,useROI);

            iPreprocessed=dlarray(iPreprocessData(iRoi,inputImageSize),"SSCB");



            predictions=this.computeNetworkActivations(iPreprocessed);


            if detectionInputWasBatchOfImages
                [bboxes,scores,varargout{1}]=this.postProcessBatchPredictions(predictions,...
                roiImageSize,inputImageSize,params,this.ClassNames,returnLabels);
            else
                [bboxes,scores,varargout{1}]=this.postprocessSingleDetection(predictions,...
                roiImageSize,inputImageSize,params,this.ClassNames,returnLabels);
            end
        end
    end

    methods(Hidden)
        function identifier=getNetworkWrapperIdentifier(~)

            identifier='yoloV4ObjectDetector';
        end
    end

    methods(Hidden=true,Static)




        function[anchors,classNames,inputSize]=getNetworkProperties(matfile)
            detectorObj=coder.internal.loadDeepLearningNetwork(matfile);


            anchors=detectorObj.AnchorBoxes;


            labelArray=cellstr(detectorObj.ClassNames);

            lengthArray=cellfun(@strlength,labelArray);

            numClasses=numel(labelArray);


            classNames=char(zeros(numClasses,max(lengthArray)));


            for labelIdx=1:numClasses
                classNames(labelIdx,1:lengthArray(labelIdx))=labelArray{labelIdx};
            end

            inputSize=detectorObj.InputSize;
        end

    end

    methods(Access=private)



        function[params,detectionInputWasBatchOfImages,miniBatchSize]=parseDetectInputs(this,I,roi,useROI,varargin)




            detectionInputWasBatchOfImages=coder.const(this.iCheckDetectionInputImage(I));

            possibleNameValues={'Threshold',...
            'MiniBatchSize',...
            'SelectStrongest',...
            'MinSize',...
            'MaxSize',...
            'ExecutionEnvironment',...
            'Acceleration'};
            poptions=struct(...
            'CaseSensitivity',false,...
            'PartialMatching','unique',...
            'StructExpand',false,...
            'IgnoreNulls',true);


            inputSize=coder.nullcopy(zeros(1,4));
            [inputSize(1),inputSize(2),inputSize(3),inputSize(4)]=size(I);

            defaults=struct('MiniBatchSize',128,...
            'Threshold',0.5,...
            'SelectStrongest',true,...
            'MinSize',[1,1],...
            'MaxSize',inputSize(1:2),...
            'ExecutionEnvironment','auto',...
            'Acceleration','auto');

            if(nargin==1)
                params=defaults;
            else
                pstruct=coder.internal.parseParameterInputs(possibleNameValues,poptions,varargin{:});
                params.Threshold=coder.internal.getParameterValue(pstruct.Threshold,defaults.Threshold,varargin{:});
                params.SelectStrongest=coder.internal.getParameterValue(pstruct.SelectStrongest,defaults.SelectStrongest,varargin{:});
                params.MinSize=coder.internal.getParameterValue(pstruct.MinSize,defaults.MinSize,varargin{:});
                params.MaxSize=coder.internal.getParameterValue(pstruct.MaxSize,defaults.MaxSize,varargin{:});
                miniBatchSize=coder.internal.getParameterValue(pstruct.MiniBatchSize,defaults.MiniBatchSize,varargin{:});
                params.ExecutionEnvironment=coder.internal.getParameterValue(pstruct.ExecutionEnvironment,defaults.ExecutionEnvironment,varargin{:});
                params.Acceleration=coder.internal.getParameterValue(pstruct.Acceleration,defaults.Acceleration,varargin{:});
            end
            params.roi=roi;
            params.useROI=useROI;


            coder.internal.assert(coder.internal.isConst(miniBatchSize),...
            'dlcoder_spkg:ObjectDetector:VariableSizeMiniBatch');




            vision.internal.cnn.validation.checkMiniBatchSize(coder.const(miniBatchSize),mfilename);




            if logical(pstruct.ExecutionEnvironment)
                coder.internal.compileWarning(...
                'dlcoder_spkg:cnncodegen:IgnoreInputArg','detect','ExecutionEnvironment');
            end




            if logical(pstruct.Acceleration)
                coder.internal.compileWarning(...
                'dlcoder_spkg:cnncodegen:IgnoreInputArg','detect','Acceleration');
            end




            vision.internal.inputValidation.validateLogical(...
            params.SelectStrongest,'SelectStrongest');

            validateMinSize=logical(pstruct.MinSize);
            validateMaxSize=logical(pstruct.MaxSize);




            if validateMinSize
                vision.internal.detector.ValidationUtils.checkMinSize(...
                params.MinSize,[1,1],mfilename);
            end




            if validateMaxSize
                vision.internal.detector.ValidationUtils.checkSize(params.MaxSize,'MaxSize',mfilename);
                coder.internal.errorIf(params.useROI&&(params.MaxSize(1)>params.roi(1,4))&&(params.MaxSize(2)>params.roi(1,3)),...
                'vision:yolo:modelMaxSizeGTROISize',...
                params.roi(1,4),params.roi(1,3));
                coder.internal.errorIf(~params.useROI&&any(params.MaxSize>inputSize(1:2)),...
                'vision:yolo:modelMaxSizeGTImgSize',...
                inputSize(1),inputSize(2));
            end

            if validateMaxSize&&validateMinSize
                coder.internal.errorIf(any(params.MinSize>=params.MaxSize),...
                'vision:ObjectDetector:minSizeGTMaxSize');
            end




            if params.useROI
                inputSize=params.roi([4,3]);
                vision.internal.detector.ValidationUtils.checkImageSizes(inputSize(1:2),params,validateMinSize,...
                params.MinSize,...
                'vision:ObjectDetector:ROILessThanMinSize',...
                'vision:ObjectDetector:ROILessThanMinSize');
            else
                vision.internal.detector.ValidationUtils.checkImageSizes(inputSize(1:2),params,validateMaxSize,...
                params.MinSize,...
                'vision:ObjectDetector:ImageLessThanMinSize',...
                'vision:ObjectDetector:ImageLessThanMinSize');
            end




            validateattributes(params.Threshold,{'single','double'},{'nonempty','nonnan',...
            'finite','nonsparse','real','scalar','>=',0,'<=',1},...
            mfilename,'Threshold');
        end


        function isBatchOfImages=iCheckDetectionInputImage(this,I)

            imSz=coder.nullcopy(zeros(1,4));
            [imSz(1),imSz(2),imSz(3),imSz(4)]=size(I);


            coder.internal.assert(coder.internal.isConst([imSz(3),imSz(4)]),...
            'dlcoder_spkg:ObjectDetector:VariableSizeChannelBatch',mfilename);

            networkInputSize=this.InputSize;
            if numel(networkInputSize)==3
                networkChannelSize=coder.const(networkInputSize(3));
            else
                networkChannelSize=coder.const(1);
            end
            imageChannelSize=coder.const(imSz(3));

            isBatchOfImages=coder.const(imSz(4)>1);

            if isBatchOfImages

                Itmp=I(:,:,:,1);
            else
                Itmp=I;
            end


            if coder.const(networkChannelSize>3||networkChannelSize==2)
                vision.internal.inputValidation.validateImage(Itmp,'I','multi-channel');
            else
                vision.internal.inputValidation.validateImage(Itmp,'I');
            end


            coder.internal.errorIf(imageChannelSize~=networkChannelSize,...
            'vision:ObjectDetector:invalidInputImageChannelSize',...
            imageChannelSize,...
            networkChannelSize);
        end


        function predictions=yolov4Transform(this,YPredictions)

            numPredictionHeads=coder.const(size(YPredictions,1));
            predictions=cell(numPredictionHeads,6);


            coder.unroll();
            for ii=1:numPredictionHeads

                numChannelsPred=coder.const(size(YPredictions{ii},3));
                numAnchors=coder.const(size(this.AnchorBoxes{ii},1));
                numPredElemsPerAnchors=coder.const(numChannelsPred/numAnchors);
                allIds=coder.const(1:numChannelsPred);

                stride=coder.const(numPredElemsPerAnchors);
                endIdx=coder.const(numChannelsPred);

                YPredictionsData=extractdata(YPredictions{ii});


                startIdx=5;
                confIds=coder.const(startIdx:stride:endIdx);
                predictions{ii,1}=coder.internal.layer.sigmoid(YPredictionsData(:,:,confIds,:));


                startIdx=1;
                xIds=coder.const(startIdx:stride:endIdx);
                predictions{ii,2}=coder.internal.layer.sigmoid(YPredictionsData(:,:,xIds,:));


                startIdx=2;
                yIds=coder.const(startIdx:stride:endIdx);
                predictions{ii,3}=coder.internal.layer.sigmoid(YPredictionsData(:,:,yIds,:));


                startIdx=3;
                wIds=coder.const(startIdx:stride:endIdx);
                predictions{ii,4}=coder.internal.layer.elementwiseOperationInPlace(@exp,YPredictionsData(:,:,wIds,:));


                startIdx=4;
                hIds=coder.const(startIdx:stride:endIdx);
                predictions{ii,5}=coder.internal.layer.elementwiseOperationInPlace(@exp,YPredictionsData(:,:,hIds,:));


                nonClassIds=coder.const([xIds,yIds,wIds,hIds,confIds]);



                classIdx=setdiff(allIds,nonClassIds,'stable');
                predictions{ii,6}=coder.internal.layer.sigmoid(YPredictionsData(:,:,classIdx,:));
            end
        end


        function[bboxes,scores,labels]=postProcessBatchPredictions(this,predictions,...
            imageSize,networkInputSize,params,classes,returnLabels)

            coder.internal.prefer_const(returnLabels,imageSize,networkInputSize,classes)

            numImages=size(predictions{1,1},4);
            numNetworkOutputs=size(predictions,1);
            bboxes=cell(numImages,1);
            scores=cell(numImages,1);
            labels=cell(numImages,1);

            for ii=1:numImages
                fmap=cell(numNetworkOutputs,6);
                for i=1:6
                    for j=1:numNetworkOutputs
                        feature=predictions{j,i};
                        fmap{j,i}=feature(:,:,:,ii);
                    end
                end
                [bboxes{ii},scores{ii},labels{ii}]=this.postprocessSingleDetection(fmap,...
                imageSize,networkInputSize,params,classes,returnLabels);
            end
        end


        function[bboxes,scores,labelNames]=postprocessSingleDetection(this,extractDetections,...
            imageSize,networkInputSize,params,classes,returnLabels)

            coder.internal.prefer_const(returnLabels,imageSize,networkInputSize,classes);

            detectionsCell=this.anchorBoxGenerator(extractDetections,networkInputSize);






            numCells=size(detectionsCell,1);
            detectionSize=coder.nullcopy(zeros(1,numCells));
            for iCell=1:numCells
                detectionSize(iCell)=numel(detectionsCell{iCell,1});
            end
            detectionSizeIndx=[0,cumsum(detectionSize)];
            predSize=5+size(classes,1);
            detections=coder.nullcopy(zeros(detectionSizeIndx(end),predSize,'single'));
            for iCell=1:numCells
                for iCol=1:5
                    detections(detectionSizeIndx(iCell)+1:detectionSizeIndx(iCell+1),iCol)=reshapePredictions(detectionsCell{iCell,iCol});
                end
                detections(detectionSizeIndx(iCell)+1:detectionSizeIndx(iCell+1),6:end)=reshapeClasses(detectionsCell{iCell,6},size(classes,1));
            end


            [classProbs,classIdx]=max(detections(:,6:end),[],2);
            detections(:,1)=detections(:,1).*classProbs;
            detections(:,6)=classIdx;


            detections=detections(detections(:,1)>=params.Threshold,:);

            [bboxes,scores,labelNames]=iPostProcessDetections(detections,classes,params,imageSize,returnLabels);
        end


        function YPredCell=anchorBoxGenerator(this,YPredCell,inputImageSize)

            anchorIndex=2:5;
            numPredictionHeads=size(YPredCell,1);
            tiledAnchors=cell(numPredictionHeads,size(anchorIndex,2));
            for i=1:numPredictionHeads
                anchors=this.AnchorBoxes{i};
                [h,w,~,n]=size(YPredCell{i,1});
                [tiledAnchors{i,2},tiledAnchors{i,1}]=ndgrid(0:h-1,0:w-1,1:size(anchors,1),1:n);
                [~,~,tiledAnchors{i,3}]=ndgrid(0:h-1,0:w-1,anchors(:,2),1:n);
                [~,~,tiledAnchors{i,4}]=ndgrid(0:h-1,0:w-1,anchors(:,1),1:n);
            end


            for i=1:size(YPredCell,1)
                [h,w,~,~]=size(YPredCell{i,1});
                YPredCell{i,anchorIndex(1)}=(tiledAnchors{i,1}+YPredCell{i,anchorIndex(1)})./w;
                YPredCell{i,anchorIndex(2)}=(tiledAnchors{i,2}+YPredCell{i,anchorIndex(2)})./h;
                YPredCell{i,anchorIndex(3)}=(tiledAnchors{i,3}.*YPredCell{i,anchorIndex(3)})./inputImageSize(2);
                YPredCell{i,anchorIndex(4)}=(tiledAnchors{i,4}.*YPredCell{i,anchorIndex(4)})./inputImageSize(1);
            end
        end


        function predictions=computeNetworkActivations(this,I)

            NumOutputs=coder.const(numel(this.Network.OutputNames));
            YPredictions=cell(NumOutputs,1);

            [YPredictions{:}]=this.Network.predict(I);
            predictions=this.yolov4Transform(YPredictions);
        end
    end
end


function image=iPreprocessData(image,targetSize)

    image=imresize(image,targetSize(1:2));
    image=single(rescaleData(image));
end




function resImg=rescaleData(I)
    coder.gpu.internal.kernelfunImpl(false);


    if coder.gpu.internal.isGpuEnabled
        outVal=gpucoder.reduce(I(:),{@minFunc,@maxFunc});
        minVal=single(outVal(1));
        maxVal=single(outVal(2));
    else
        minVal=single(min(I(:)));
        maxVal=single(max(I(:)));
    end

    I=single(I);

    resImg=(I-minVal)./(maxVal-minVal);
end


function[bboxes,scores,labelNames]=iPostProcessDetections(detections,classes,params,inputImageSize,returnLabels)

    if~isempty(detections)

        scorePred=detections(:,1);
        bboxTemp=detections(:,2:5);
        classPred=detections(:,6);


        scale=[inputImageSize(2),inputImageSize(1),inputImageSize(2),inputImageSize(1)];
        bboxTemp=bsxfun(@times,scale,bboxTemp);



        bboxPred=iConvertCenterToTopLeft(bboxTemp);


        [bboxPred,scorePred,classPred]=iFilterBBoxes(bboxPred,scorePred,...
        classPred,params.MinSize,params.MaxSize);


        if params.SelectStrongest
            [bboxes,scores,labels]=selectStrongestBboxMulticlass(bboxPred,scorePred,classPred,...
            'RatioType','Union','OverlapThreshold',0.5);
        else
            bboxes=bboxPred;
            scores=scorePred;
            labels=classPred;
        end


        coder.gpu.kernel();
        for i=1:size(bboxes,1)
            detectionsWd=min(bboxes(i,1)+bboxes(i,3),inputImageSize(1,2));
            bboxes(i,3)=detectionsWd-bboxes(i,1);
            detectionsHt=min(bboxes(i,2)+bboxes(i,4),inputImageSize(1,1));
            bboxes(i,4)=detectionsHt-bboxes(i,2);
        end
        for i=1:numel(bboxes)
            if bboxes(i)<1
                bboxes(i)=1;
            end
        end


        bboxes(:,1:2)=vision.internal.detector.addOffsetForROI(bboxes(:,1:2),params.roi,params.useROI);

        if returnLabels
            numBBoxes=size(bboxes,1);
            labelNames=returnCategoricalLabels(classes,numBBoxes,labels);
        else
            labelNames=[];
        end

    else
        bboxes=zeros(0,4,'single');
        scores=zeros(0,1,'single');
        if returnLabels
            numBBoxes=0;
            labels=[];
            labelNames=returnCategoricalLabels(classes,numBBoxes,labels);
        else
            labelNames=[];
        end
    end
end


function x=reshapePredictions(pred)
    [h,w,c,n]=size(pred);
    x=reshape(pred,h*w*c,1,n);
end


function x=reshapeClasses(pred,numclasses)
    [h,w,c,n]=size(pred);
    numanchors=(c/numclasses);
    x=reshape(pred,h*w,numclasses,numanchors,n);
    x=permute(x,[1,3,2,4]);
    [h,w,c,n]=size(x);
    x=reshape(x,h*w,c,n);
end



function bboxes=iConvertCenterToTopLeft(bboxes)
    coder.gpu.kernel();
    for i=1:size(bboxes,1)
        bboxes(i,1)=bboxes(i,1)-bboxes(i,3)/2+0.5;
        bboxes(i,2)=bboxes(i,2)-bboxes(i,4)/2+0.5;
    end
    for i=1:numel(bboxes)
        if bboxes(i)<1
            bboxes(i)=1;
        end
    end
end




function[bboxes1,scores1,labels1]=iFilterBBoxes(bboxes,scores,labels,minSize,maxSize)


    count=0;
    bboxes1=coder.nullcopy(zeros(size(bboxes,1),4,'like',bboxes));
    scores1=coder.nullcopy(zeros(size(bboxes,1),1,'like',scores));
    labels1=coder.nullcopy(zeros(size(bboxes,1),1,'like',labels));
    for i=1:size(bboxes,1)
        if(bboxes(i,4)>=minSize(1)&&bboxes(i,3)>=minSize(2)&&bboxes(i,4)<=maxSize(1)&&bboxes(i,3)<=maxSize(2))
            count=count+1;
            bboxes1(count,:)=bboxes(i,:);
            scores1(count)=scores(i);
            labels1(count)=labels(i);

        end
    end

    bboxes1(count+1:end,:)=[];
    scores1(count+1:end)=[];
    labels1(count+1:end)=[];

end


function labelNames=returnCategoricalLabels(classNames,numBBoxes,labels)
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
end


function c=maxFunc(a,b)
    c=max(a,b);
end


function c=minFunc(a,b)
    c=min(a,b);
end
