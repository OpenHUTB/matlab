%#codegen




classdef YOLOv2Network<coder.internal.NetworkWrapper

    properties


LayerSize



AnchorBoxes



ClassNames





TrainingImageSize



LayerIndices


OutputLayerName




FractionDownsampling





WH2HW
    end

    methods(Static,Access=public,Hidden)




        function n=matlabCodegenNontunableProperties(~)
            n={'LayerSize','AnchorBoxes','OutputLayerName',...
            'TrainingImageSize','ClassNames','FractionDownsampling','WH2HW'};
        end



        function optOut=matlabCodegenLowerToStruct(~)
            optOut=true;
        end

        function name=matlabCodegenUserReadableName(~)
            name='yolov2ObjectDetector';
        end
    end

    methods




        function obj=YOLOv2Network(matfile,varargin)
            coder.allowpcode('plain');
            coder.internal.prefer_const(matfile);


            containsDLNetwork=false;
            obj=obj@coder.internal.NetworkWrapper(containsDLNetwork,matfile,varargin{:});


            coder.extrinsic('coder.internal.YOLOv2Network.getNetworkProperties');

resultStruct...
            =coder.const(@coder.internal.YOLOv2Network.getNetworkProperties,matfile);

            obj.LayerSize=resultStruct.LayerSize;
            obj.AnchorBoxes=resultStruct.AnchorBoxes;
            obj.ClassNames=resultStruct.ClassNames;
            obj.TrainingImageSize=resultStruct.TrainingImageSize;
            obj.LayerIndices=resultStruct.LayerIndices;
            obj.OutputLayerName=resultStruct.OutputLayerName;
            obj.FractionDownsampling=resultStruct.FractionDownsampling;
            obj.WH2HW=resultStruct.WH2HW;


        end






        function[bboxes,scores,varargout]=detect(this,I,varargin)

            coder.gpu.internal.kernelfunImpl(false);
            nargoutchk(1,3);

            returnLabels=coder.const(nargout>2);


            coder.extrinsic('vision.internal.detector.checkROI');

            useROI=false;
            if(~isempty(varargin)&&(isa(varargin{1},'numeric')))

                if(isvector(varargin{1})&&(size(varargin{1},2)==4))


                    roi=varargin{1};


                    coder.internal.assert(coder.internal.isConst(roi),...
                    'dlcoder_spkg:ObjectDetector:roiConstant')
                    useROI=true;



                    [params,DetectionInputWasBatchOfImages,MiniBatchSize]=this.parseDetectInputs(I,roi,useROI,varargin{2:end});


                    coder.const(feval('vision.internal.detector.checkROI',roi,size(I)));

                    roiImageSize=coder.const(roi([4,3]));
                else


                    coder.internal.errorIf(true,'dlcoder_spkg:ObjectDetector:roiIncorrectNumel')
                end
            else


                roi=zeros(1,4);



                [params,DetectionInputWasBatchOfImages,MiniBatchSize]=this.parseDetectInputs(I,roi,useROI,varargin{:});
                roiImageSize=coder.const(size(I,1:2));
            end




            Iroi=vision.internal.detector.cropImageIfRequested(I,roi,useROI);

            trainImageSize=this.TrainingImageSize;


            preprocessedImageSize=coder.const(iComputeBestMatch(roiImageSize,trainImageSize));


            if coder.const(((roiImageSize(1)==preprocessedImageSize(1))&&(roiImageSize(2)==preprocessedImageSize(2))))
                Ipreprocessed=Iroi;
            else
                Ipreprocessed=imresize(Iroi,preprocessedImageSize);
            end


            im=this.rescaleData(Ipreprocessed);





            tmpFeatureMap=this.Network.activations(im,this.OutputLayerName,'MiniBatchSize',coder.const(MiniBatchSize));


            sy=coder.const(roiImageSize(1)./preprocessedImageSize(1));
            sx=coder.const(roiImageSize(2)./preprocessedImageSize(2));


            if DetectionInputWasBatchOfImages
                [bboxes,scores,varargout{1}]=this.iPostProcessBatchPredictions(tmpFeatureMap,...
                preprocessedImageSize,params,roi,useROI,sx,sy,returnLabels);
            else
                [bboxes,scores,varargout{1}]=this.iPostProcessActivations(tmpFeatureMap,...
                preprocessedImageSize,params,roi,useROI,sx,sy,returnLabels);
            end


        end

    end

    methods(Hidden)
        function identifier=getNetworkWrapperIdentifier(~)

            identifier='yoloV2ObjectDetector';
        end
    end

    methods(Hidden=true,Static)




        function resultStruct=getNetworkProperties(matfile)
            detectorObj=coder.internal.loadDeepLearningNetwork(matfile);

            externalLayers=detectorObj.Network.Layers;
            LayerIndices.OutputLayerIdx=find(...
            arrayfun(@(x)isa(x,'nnet.cnn.layer.YOLOv2OutputLayer'),...
            externalLayers));
            LayerIndices.ImageLayerIdx=find(...
            arrayfun(@(x)isa(x,'nnet.cnn.layer.ImageInputLayer'),...
            externalLayers));

            resultStruct=struct();
            resultStruct.LayerSize=detectorObj.Network.Layers(LayerIndices.ImageLayerIdx).InputSize;
            resultStruct.AnchorBoxes=detectorObj.AnchorBoxes;


            labelArray=cellstr(detectorObj.ClassNames);

            lengthArray=cellfun(@strlength,labelArray);

            numClasses=numel(labelArray);


            ClassNames=char(zeros(numClasses,max(lengthArray)));


            for labelIdx=1:numClasses
                ClassNames(labelIdx,1:lengthArray(labelIdx))=labelArray{labelIdx};
            end

            resultStruct.ClassNames=ClassNames;

            resultStruct.TrainingImageSize=detectorObj.TrainingImageSize;

            resultStruct.LayerIndices=LayerIndices;

            resultStruct.OutputLayerName=detectorObj.Network.Layers(LayerIndices.OutputLayerIdx).Name;

            resultStruct.FractionDownsampling=detectorObj.FractionDownsampling;

            resultStruct.WH2HW=detectorObj.WH2HW;

        end

    end

    methods(Access=private)




        function[params,detectionInputWasBatchOfImages,miniBatchSize]=parseDetectInputs(this,I,roi,useROI,varargin)




            detectionInputWasBatchOfImages=coder.const(this.iCheckDetectionInputImage(I));

            possibleNameValues={'Threshold',...
            'ExecutionEnvironment',...
            'Acceleration',...
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
            'ExecutionEnvironment','notValid',...
            'Acceleration','none',...
            'MiniBatchSize',128,...
            'useROI',false,...
            'Threshold',0.5,...
            'SelectStrongest',true,...
            'MinSize',[1,1],...
            'MaxSize',inputSize(1:2));

            miniBatchSize=128;

            if(nargin==1)
                params=defaults;
            else
                pstruct=coder.internal.parseParameterInputs(possibleNameValues,poptions,varargin{:});
                Threshold=coder.internal.getParameterValue(pstruct.Threshold,defaults.Threshold,varargin{:});
                SelectStrongest=coder.internal.getParameterValue(pstruct.SelectStrongest,defaults.SelectStrongest,varargin{:});
                MinSize=coder.internal.getParameterValue(pstruct.MinSize,defaults.MinSize,varargin{:});
                MaxSize=coder.internal.getParameterValue(pstruct.MaxSize,defaults.MaxSize,varargin{:});
                Acceleration=coder.internal.getParameterValue(pstruct.Acceleration,defaults.Acceleration,varargin{:});
                miniBatchSize=coder.internal.getParameterValue(pstruct.MiniBatchSize,defaults.MiniBatchSize,varargin{:});

                params.Threshold=Threshold;
                params.SelectStrongest=SelectStrongest;
                params.MinSize=MinSize;
                params.MaxSize=MaxSize;
                params.Acceleration=Acceleration;
            end
            params.roi=roi;
            params.useROI=useROI;


            coder.internal.assert(coder.internal.isConst(miniBatchSize),...
            'dlcoder_spkg:ObjectDetector:VariableSizeMiniBatch');
            miniBatchSize=coder.const(miniBatchSize);




            vision.internal.cnn.validation.checkMiniBatchSize(coder.const(miniBatchSize),mfilename);

            if~coder.internal.isConst(params.Acceleration)||coder.const(@(x)strcmpi(x,'mex')||strcmpi(x,'auto'),params.Acceleration)
                coder.internal.compileWarning(eml_message(...
                'dlcoder_spkg:cnncodegen:IgnoreInputArg','detect','Acceleration'));
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

            if logical(pstruct.ExecutionEnvironment)
                coder.internal.compileWarning(eml_message(...
                'dlcoder_spkg:cnncodegen:IgnoreInputArg','detect','ExecutionEnvironment'));
            end

        end


        function isBatchOfImages=iCheckDetectionInputImage(this,I)

            imSz=coder.nullcopy(zeros(1,4));
            [imSz(1),imSz(2),imSz(3),imSz(4)]=size(I);



            coder.internal.assert(coder.internal.isConst([imSz(1),imSz(2),imSz(3),imSz(4)]),...
            'dlcoder_spkg:ObjectDetector:VariableSizedInputYOLOv2');

            networkInputSize=this.LayerSize;
            networkChannelSize=coder.const(networkInputSize(3));
            imageChannelSize=coder.const(imSz(3));

            isBatchOfImages=coder.const(imSz(4)>1);

            if isBatchOfImages

                Itmp=I(:,:,:,1);
            else
                Itmp=I;
            end


            if networkChannelSize>3||networkChannelSize==2
                vision.internal.inputValidation.validateImage(Itmp,'I','multi-channel');
            else
                vision.internal.inputValidation.validateImage(Itmp,'I');
            end


            coder.internal.errorIf(imageChannelSize~=networkChannelSize,...
            'vision:ObjectDetector:invalidInputImageChannelSize',...
            imageChannelSize,...
            networkChannelSize);
        end


        function[bboxes,scores,labels]=iPostProcessBatchPredictions(this,outputFeatureMap,...
            preprocessedImageSize,params,roi,useROI,sx,sy,returnLabels)

            coder.internal.prefer_const(returnLabels);
            numImages=size(outputFeatureMap,4);
            bboxes=cell(numImages,1);
            scores=cell(numImages,1);
            labels=cell(numImages,1);


            coder.unroll(false);
            for ii=1:numImages
                [bboxes{ii},scores{ii},labels{ii}]=this.iPostProcessActivations(outputFeatureMap(:,:,:,ii),...
                preprocessedImageSize,params,roi,useROI,sx,sy,returnLabels);
            end

        end


        function[bboxes,scores,labelNames]=iPostProcessActivations(this,outputFeatureMap,...
            preprocessedImageSize,params,roi,useROI,sx,sy,returnLabels)

            coder.internal.prefer_const(returnLabels);

            gridSize=size(outputFeatureMap);
            anchors=this.AnchorBoxes;



            featureMapData=reshape(outputFeatureMap,gridSize(1),gridSize(2),size(this.AnchorBoxes,1),gridSize(3)/size(this.AnchorBoxes,1));


            downsampleFactor=preprocessedImageSize(1:2)./gridSize(1:2);

            if coder.const(~this.FractionDownsampling)
                downsampleFactor=floor(downsampleFactor);
            end



            if coder.const(this.WH2HW)
                anchors=[anchors(:,2),anchors(:,1)];
            end


            anchors(:,1)=anchors(:,1)./downsampleFactor(1);
            anchors(:,2)=anchors(:,2)./downsampleFactor(2);





            boxOut=this.yoloPredictBbox(featureMapData,anchors,gridSize(1:2),downsampleFactor);

            threshold=params.Threshold;



            thresholdedPrediction=boxOut(boxOut(:,5)>=threshold,:);


            if~isempty(thresholdedPrediction)
                classPred=thresholdedPrediction(:,6:end);
                scorePred=thresholdedPrediction(:,5);
                bboxesX1Y1X2Y2=thresholdedPrediction(:,1:4);


                bboxesX1Y1X2Y2=iClipBBox(bboxesX1Y1X2Y2,preprocessedImageSize);


                bboxPred=scaleX1X2Y1Y2(bboxesX1Y1X2Y2,sx,sy);


                [bboxPred,scorePred,classPred]=this.filterBBoxes(bboxPred,scorePred,classPred,params.MinSize,params.MaxSize);

                if params.SelectStrongest
                    [bboxes,scores,labels]=selectStrongestBboxMulticlass(bboxPred,scorePred,classPred,...
                    'RatioType','Union','OverlapThreshold',0.5);
                else
                    bboxes=bboxPred;
                    scores=scorePred;
                    labels=classPred;
                end


                bboxes(:,1:2)=vision.internal.detector.addOffsetForROI(bboxes(:,1:2),roi,useROI);

                if returnLabels
                    numBBoxes=size(bboxes,1);
                    labelNames=returnCategoricalLabels(this,numBBoxes,labels);
                else
                    labelNames=[];
                end

            else

                bboxes=zeros(0,4,'double');
                scores=zeros(0,1,'single');

                if returnLabels
                    numBBoxes=0;
                    labels=[];
                    labelNames=returnCategoricalLabels(this,numBBoxes,labels);
                else
                    labelNames=[];
                end

            end

        end







        function xyBbox=yoloPredictBbox(~,featureMap,anchors,gridSize,downSamplingFactor)

            xyBbox=coder.nullcopy(zeros(gridSize(1,2)*gridSize(1,1)*size(anchors,1),6,'like',featureMap));
            numAnchors=size(anchors,1);
            probPred=coder.nullcopy(zeros(size(featureMap,4)-5,1));


            coder.gpu.internal.kernelImpl(false);
            for anchorIdx=1:size(anchors,1)

                coder.gpu.internal.kernelImpl(false);
                for colIdx=0:gridSize(1,2)-1

                    coder.gpu.internal.kernelImpl(false);
                    for rowIdx=0:gridSize(1,1)-1

                        ind=rowIdx*gridSize(1,2)*numAnchors+colIdx*numAnchors+anchorIdx;


                        cx=(featureMap(rowIdx+1,colIdx+1,anchorIdx,2)+colIdx)*downSamplingFactor(1,2);
                        cy=(featureMap(rowIdx+1,colIdx+1,anchorIdx,3)+rowIdx)*downSamplingFactor(1,1);


                        bw=featureMap(rowIdx+1,colIdx+1,anchorIdx,4)*anchors(anchorIdx,2)*downSamplingFactor(1,2);
                        bh=featureMap(rowIdx+1,colIdx+1,anchorIdx,5)*anchors(anchorIdx,1)*downSamplingFactor(1,1);

                        xyBbox(ind,1)=(cx-bw/2);
                        xyBbox(ind,2)=(cy-bh/2);
                        xyBbox(ind,3)=(cx+bw/2);
                        xyBbox(ind,4)=(cy+bh/2);

                        probPred(1:end)=featureMap(rowIdx+1,colIdx+1,anchorIdx,6:end);
                        iouPred=featureMap(rowIdx+1,colIdx+1,anchorIdx,1);


                        [imax,idx]=max(probPred);
                        confScore=iouPred*imax;

                        xyBbox(ind,5)=confScore;
                        xyBbox(ind,6)=idx;

                    end
                end
            end
        end




        function resImg=rescaleData(~,I)
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




        function[bboxes1,scores1,labels1]=filterBBoxes(~,bboxes,scores,labels,minSize,maxSize)


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

        function labelNames=returnCategoricalLabels(obj,numBBoxes,labels)
            coder.inline('never');



            labelCells=coder.nullcopy(cell(numBBoxes,1));
            for i=1:numBBoxes

                labelCells{i,1}=nonzeros(obj.ClassNames(labels(i),:))';
            end






            valueset={};
            upperBound=size(obj.ClassNames,1);
            coder.varsize('valueset',[1,upperBound],[0,1]);
            for i=1:upperBound
                valueset{end+1}=nonzeros(obj.ClassNames(i,:))';
            end

            labelNames=categorical(labelCells,valueset);
        end

    end

end





function outSize=iComputeBestMatch(preprocessedImageSize,trainingImageSize)
    coder.internal.prefer_const(preprocessedImageSize,trainingImageSize);
    preprocessedImageSize=repmat(preprocessedImageSize,size(trainingImageSize,1),1);
    Xdist=(preprocessedImageSize(:,1)-trainingImageSize(:,1));
    Ydist=(preprocessedImageSize(:,2)-trainingImageSize(:,2));
    dist=sqrt(Xdist.^2+Ydist.^2);
    [~,ind]=coder.const(@min,dist);
    outSize=coder.const(trainingImageSize(ind,:));
end


function clippedBBox=iClipBBox(bbox,imgSize)

    clippedBBox=double(bbox);

    x1=clippedBBox(:,1);
    y1=clippedBBox(:,2);

    x2=clippedBBox(:,3);
    y2=clippedBBox(:,4);

    x1(x1<1)=1;
    y1(y1<1)=1;

    x2(x2>imgSize(2))=imgSize(2);
    y2(y2>imgSize(1))=imgSize(1);

    clippedBBox=[x1,y1,x2,y2];
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




    scaledBoxes(:,3)=scaledBoxes(:,3)-scaledBoxes(:,1)+1;
    scaledBoxes(:,4)=scaledBoxes(:,4)-scaledBoxes(:,2)+1;
end

function c=maxFunc(a,b)
    c=max(a,b);
end

function c=minFunc(a,b)
    c=min(a,b);
end
