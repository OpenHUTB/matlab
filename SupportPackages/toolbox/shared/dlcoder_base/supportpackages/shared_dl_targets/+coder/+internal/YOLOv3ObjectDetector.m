%#codegen




classdef YOLOv3ObjectDetector<coder.internal.NetworkWrapper

    properties




AnchorBoxes



ClassNames



InputSize
    end

    properties(Access=private)

LayerSize



LayerIndices
    end

    methods(Static,Access=public,Hidden)




        function n=matlabCodegenNontunableProperties(~)
            n={'LayerSize','LayerIndices','AnchorBoxes','ClassNames','InputSize'};
        end

        function name=matlabCodegenUserReadableName(~)
            name='yolov3ObjectDetector';
        end
    end

    methods




        function obj=YOLOv3ObjectDetector(matfile,varargin)
            coder.allowpcode('plain');
            coder.internal.prefer_const(matfile);


            containsDLNetwork=true;
            obj=obj@coder.internal.NetworkWrapper(containsDLNetwork,matfile,varargin{:});


            coder.extrinsic('coder.internal.YOLOv3ObjectDetector.getNetworkProperties');
            [obj.LayerSize,obj.AnchorBoxes,obj.ClassNames,obj.InputSize,obj.LayerIndices]...
            =coder.const(@coder.internal.YOLOv3ObjectDetector.getNetworkProperties,matfile);

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
                [params,detectionInputWasBatchOfImages]=this.parseDetectInputs(I,roi,useROI,varargin{2:end});

                roiImageSize(1)=roi(4);
                roiImageSize(2)=roi(3);
                if(numel(inputImageSize)==3)
                    roiImageSize(3)=inputImageSize(3);
                end
            else


                roi=coder.nullcopy(zeros(1,4));



                [params,detectionInputWasBatchOfImages]=this.parseDetectInputs(I,roi,useROI,varargin{:});
                roiImageSize(1)=size(I,1);
                roiImageSize(2)=size(I,2);
                if(numel(inputImageSize)==3)
                    roiImageSize(3)=size(I,3);
                end
            end



            Iroi=vision.internal.detector.cropImageIfRequested(I,roi,useROI);


            if strcmp(params.DetectionPreprocessing,'auto')
                Ipreprocessed=dlarray(iPreprocessData(Iroi,inputImageSize),"SSCB");
            else
                Iroi=im2single(Iroi);
                Ipreprocessed=dlarray(Iroi,"SSCB");
            end



            numOutputs=coder.const(numel(this.Network.OutputNames));
            YPredictions=cell(numOutputs,1);

            [YPredictions{:}]=this.Network.predict(Ipreprocessed);
            predictions=this.yolov3Transform(YPredictions);


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

            identifier='yoloV3ObjectDetector';
        end
    end

    methods(Hidden=true,Static)




        function[layerSize,anchors,classNames,inputSize,layerIndices]=getNetworkProperties(matfile)
            detectorObj=coder.internal.loadDeepLearningNetwork(matfile);

            externalLayers=detectorObj.Network.Layers;
            layerIndices.ImageLayerIdx=find(...
            arrayfun(@(x)isa(x,'nnet.cnn.layer.ImageInputLayer'),...
            externalLayers));
            layerSize=detectorObj.Network.Layers(layerIndices.ImageLayerIdx).InputSize;

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



        function[params,detectionInputWasBatchOfImages]=parseDetectInputs(this,I,roi,useROI,varargin)




            detectionInputWasBatchOfImages=coder.const(this.iCheckDetectionInputImage(I));

            possibleNameValues={'Threshold',...
            'DetectionPreprocessing',...
            'MiniBatchSize',...
            'SelectStrongest',...
            'MinSize',...
            'MaxSize'};
            poptions=struct(...
            'CaseSensitivity',false,...
            'PartialMatching','unique',...
            'StructExpand',false,...
            'IgnoreNulls',true);


            inputSize=coder.nullcopy(zeros(1,4));
            [inputSize(1),inputSize(2),inputSize(3),inputSize(4)]=size(I);

            defaults=struct('roi',zeros(1,4),...
            'DetectionPreprocessing','auto',...
            'MiniBatchSize',128,...
            'useROI',false,...
            'Threshold',0.5,...
            'SelectStrongest',true,...
            'MinSize',[1,1],...
            'MaxSize',inputSize(1:2));

            miniBatchSize=128;

            if(nargin==1)
                params=coder.internal.constantPreservingStruct(...
                'Threshold',defaults.Threshold,...
                'SelectStrongest',defaults.SelectStrongest,...
                'MinSize',defaults.MinSize,...
                'MaxSize',defaults.MaxSize,...
                'DetectionPreprocessing',defaults.DetectionPreprocessing,...
                'MiniBatchSize',defaults.MiniBatchSize,...
                'roi',roi,...
                'useROI',useROI);
            else
                pstruct=coder.internal.parseParameterInputs(possibleNameValues,poptions,varargin{:});
                threshold=coder.internal.getParameterValue(pstruct.Threshold,defaults.Threshold,varargin{:});
                selectStrongest=coder.internal.getParameterValue(pstruct.SelectStrongest,defaults.SelectStrongest,varargin{:});
                minSize=coder.internal.getParameterValue(pstruct.MinSize,defaults.MinSize,varargin{:});
                maxSize=coder.internal.getParameterValue(pstruct.MaxSize,defaults.MaxSize,varargin{:});
                detectionPreprocessing=coder.internal.getParameterValue(pstruct.DetectionPreprocessing,defaults.DetectionPreprocessing,varargin{:});
                miniBatchSize=coder.internal.getParameterValue(pstruct.MiniBatchSize,defaults.MiniBatchSize,varargin{:});

                params=coder.internal.constantPreservingStruct(...
                'Threshold',threshold,...
                'SelectStrongest',selectStrongest,...
                'MinSize',minSize,...
                'MaxSize',maxSize,...
                'DetectionPreprocessing',detectionPreprocessing,...
                'MiniBatchSize',miniBatchSize,...
                'roi',roi,...
                'useROI',useROI);
            end


            coder.internal.assert(coder.internal.isConst(miniBatchSize),...
            'dlcoder_spkg:ObjectDetector:VariableSizeMiniBatch');




            vision.internal.cnn.validation.checkMiniBatchSize(coder.const(miniBatchSize),mfilename);




            if~coder.internal.isConst(params.DetectionPreprocessing)||~coder.const(@(x)strcmpi(x,'none')||strcmpi(x,'auto'),params.DetectionPreprocessing)
                coder.internal.assert(false,'dlcoder_spkg:ObjectDetector:InvalidNVP');
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

            networkInputSize=this.LayerSize;
            networkChannelSize=coder.const(networkInputSize(3));
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


        function predictions=yolov3Transform(this,YPredictions)

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
                predictions{ii,4}=coder.internal.layer.elementwiseOperation(@exp,YPredictionsData(:,:,wIds,:),single(1));


                startIdx=4;
                hIds=coder.const(startIdx:stride:endIdx);
                predictions{ii,5}=coder.internal.layer.elementwiseOperation(@exp,YPredictionsData(:,:,hIds,:),single(1));


                nonClassIds=coder.const([xIds,yIds,wIds,hIds,confIds]);



                classIdx=setdiff(allIds,nonClassIds,'stable');
                predictions{ii,6}=coder.internal.layer.sigmoid(YPredictionsData(:,:,classIdx,:));
            end
        end


        function[bboxes,scores,labels]=postProcessBatchPredictions(this,predictions,...
            imageSize,networkInputSize,params,classes,returnLabels)

            coder.internal.prefer_const(returnLabels,imageSize,networkInputSize,classes)

            numImages=size(predictions{1,1},4);
            bboxes=cell(numImages,1);
            scores=cell(numImages,1);
            labels=cell(numImages,1);


            coder.unroll(false);
            for ii=1:numImages
                extractedPredictionsForImage=iExtractPredictionsForBatchIndex(predictions,ii);
                [bboxes{ii},scores{ii},labels{ii}]=this.postprocessSingleDetection(extractedPredictionsForImage,...
                imageSize,networkInputSize,params,classes,returnLabels);
            end
        end


        function[bboxes,scores,labelNames]=postprocessSingleDetection(this,extractDetections,...
            imageSize,networkInputSize,params,classes,returnLabels)

            coder.internal.prefer_const(returnLabels);

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

            [bboxes,scores,labelNames]=iPostProcessDetections(detections,classes,params,imageSize,networkInputSize,returnLabels);
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
    end
end


function image=iPreprocessData(image,targetSize)

    imgSize=size(image);


    if numel(imgSize)<3
        image=repmat(image,1,1,3);
    end

    image=im2single(rescaleData(image));

    image=iLetterBoxImage(image,coder.const(targetSize(1:2)));

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


function Inew=iLetterBoxImage(I,targetSize)






    coder.internal.prefer_const(targetSize);

    [Irow,Icol,Ichannels,IBatchSize]=coder.const(@size,I,1:4);


    arI=coder.const(Irow./Icol);


    if(coder.const(arI<1))
        IcolFin=targetSize(1,2);
        IrowFin=coder.const(floor(IcolFin.*arI));
    else
        IrowFin=targetSize(1,1);
        IcolFin=coder.const(floor(IrowFin./arI));
    end


    Itmp=imresize(I,[IrowFin,IcolFin]);



    if(coder.const(arI<1))
        buff=coder.const(targetSize(1,1)-IrowFin);
    else
        buff=coder.const(targetSize(1,2)-IcolFin);
    end


    if(coder.const(buff==0))
        Inew=Itmp;
    else

        Inew=coder.const(ones([targetSize,Ichannels,IBatchSize],'like',I).*0.5);

        buffVal=coder.const(floor(buff/2));
        if(coder.const(arI<1))
            Inew(buffVal:buffVal+IrowFin-1,:,:,:)=Itmp;
        else
            Inew(:,buffVal:buffVal+IcolFin-1,:,:)=Itmp;
        end
    end

end


function[bboxes,scores,labelNames]=iPostProcessDetections(detections,classes,params,inputImageSize,networkInputSize,returnLabels)

    if~isempty(detections)

        scorePred=detections(:,1);
        bboxTemp=detections(:,2:5);
        classPred=detections(:,6);

        if(strcmp(params.DetectionPreprocessing,'auto'))

            scale=[networkInputSize(2),networkInputSize(1),networkInputSize(2),networkInputSize(1)];
            bboxTemp=bsxfun(@times,scale,bboxTemp);



            bboxTemp=iConvertCenterToTopLeft(bboxTemp);

            [shiftedBboxes,shiftedImSz]=iDeLetterBoxImage(bboxTemp,networkInputSize,inputImageSize);
            bboxPred=iScaleBboxes(shiftedBboxes,inputImageSize,shiftedImSz);
        else
            scale=[inputImageSize(2),inputImageSize(1),inputImageSize(2),inputImageSize(1)];
            bboxTemp=bsxfun(@times,scale,bboxTemp);



            bboxPred=iConvertCenterToTopLeft(bboxTemp);
        end


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
            detectionsWd=minFunc(bboxes(i,1)+bboxes(i,3),inputImageSize(1,2));
            bboxes(i,3)=detectionsWd-bboxes(i,1);

            detectionsHt=minFunc(bboxes(i,2)+bboxes(i,4),inputImageSize(1,1));
            bboxes(i,4)=detectionsHt-bboxes(i,2);
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
    bboxes(:,1)=bboxes(:,1)-bboxes(:,3)/2+0.5;
    bboxes(:,2)=bboxes(:,2)-bboxes(:,4)/2+0.5;
    coder.gpu.kernel();
    for i=1:numel(bboxes)
        bboxes(i)=floor(bboxes(i));
        if bboxes(i)<1
            bboxes(i)=1;
        end
    end
end


function[bboxes,newImSz]=iDeLetterBoxImage(bboxes,inpSz,imgSz)












    arI=coder.const(imgSz(1,1)./imgSz(1,2));
    if coder.const(arI<1)
        IcolFin=inpSz(1,2);
        IrowFin=IcolFin.*arI;


        buff=inpSz(1,1)-IrowFin;
        dcShift=buff/2;


        bboxes(:,2)=max(1,(bboxes(:,2)-dcShift));
        newImSz=[IrowFin,IcolFin];
    else
        IrowFin=inpSz(1,1);
        IcolFin=IrowFin./arI;


        buff=inpSz(1,2)-IcolFin;
        dcShift=buff/2;


        bboxes(:,1)=max(1,(bboxes(:,1)-dcShift));
        newImSz=[IrowFin,IcolFin];
    end
end


function bboxPred=iScaleBboxes(bboxes,imSz,newImSz)
    scale=imSz(1:2)./newImSz;

    bboxesX1Y1X2Y2=xywhToX1Y1X2Y2(bboxes);


    bboxesX1Y1X2Y2(:,3)=minFunc(bboxesX1Y1X2Y2(:,3),newImSz(1,2));
    bboxesX1Y1X2Y2(:,4)=minFunc(bboxesX1Y1X2Y2(:,4),newImSz(1,1));


    bboxesX1Y1X2Y2=scaleX1X2Y1Y2(bboxesX1Y1X2Y2,scale(2),scale(1));
    bboxPred=x1y1x2y2ToXYWH(bboxesX1Y1X2Y2);
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


function boxes=xywhToX1Y1X2Y2(boxes)



    boxes(:,3)=boxes(:,1)+boxes(:,3)-1;
    boxes(:,4)=boxes(:,2)+boxes(:,4)-1;
end


function scaledBoxes=scaleX1X2Y1Y2(boxes,sx,sy)













    u1=boxes(:,1)-0.5;
    u2=boxes(:,3)+0.5;
    v1=boxes(:,2)-0.5;
    v2=boxes(:,4)+0.5;


    x1=u1*sx+(1-sx)/2;
    x2=u2*sx+(1-sx)/2;
    y1=v1*sy+(1-sy)/2;
    y2=v2*sy+(1-sy)/2;


    x1=x1+0.5;
    x2=x2-0.5;
    y1=y1+0.5;
    y2=y2-0.5;

    scaledBoxes=floor([x1,y1,x2,y2]);
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


function boxes=x1y1x2y2ToXYWH(boxes)



    boxes(:,3)=boxes(:,3)-boxes(:,1)+1;
    boxes(:,4)=boxes(:,4)-boxes(:,2)+1;
end


function c=maxFunc(a,b)
    c=max(a,b);
end


function c=minFunc(a,b)
    c=min(a,b);
end

function extractedPredictionsForImage=iExtractPredictionsForBatchIndex(predictions,batchIndex)
    coder.inline('always');



    extractedPredictionsForImage=cell(size(predictions));
    for i=1:numel(predictions)
        elementVal=predictions{i};
        extractedPredictionsForImage{i}=elementVal(:,:,:,batchIndex);
    end

end


