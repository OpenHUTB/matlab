%#codegen





classdef ssdObjectDetector<coder.internal.NetworkWrapper

    properties



AnchorBoxes




ClassNames



InputSize

    end

    properties(Hidden=true)



BackgroundIndex
    end

    methods(Static,Access=public,Hidden)




        function n=matlabCodegenNontunableProperties(~)
            n={'AnchorBoxes','ClassNames','InputSize',...
            'BackgroundIndex'};
        end



        function optOut=matlabCodegenLowerToStruct(~)
            optOut=true;
        end

        function name=matlabCodegenUserReadableName(~)
            name='ssdObjectDetector';
        end
    end

    methods




        function obj=ssdObjectDetector(matfile,varargin)
            coder.allowpcode('plain');
            coder.internal.prefer_const(matfile);


            containsDLNetwork=false;
            obj=obj@coder.internal.NetworkWrapper(containsDLNetwork,matfile,varargin{:});


            coder.extrinsic('coder.internal.ssdObjectDetector.getDetectorProperties');
            [obj.AnchorBoxes,obj.ClassNames,obj.InputSize,obj.BackgroundIndex]...
            =coder.const(@coder.internal.ssdObjectDetector.getDetectorProperties,matfile);

        end






        function[bboxes,scores,varargout]=detect(this,I,varargin)

            coder.gpu.internal.kernelfunImpl(false);
            nargoutchk(1,3);
            returnLabels=coder.const(nargout>2);



            coder.extrinsic('vision.internal.detector.checkROI');

            useROI=false;
            trainingImageSize=coder.const(this.InputSize);
            preprocessedImageSize=coder.nullcopy(zeros(1,2));

            if(~isempty(varargin)&&(isa(varargin{1},'numeric')))

                if(isvector(varargin{1})&&(size(varargin{1},2)==4))


                    roi=varargin{1};


                    coder.internal.assert(coder.internal.isConst(roi),...
                    'dlcoder_spkg:ObjectDetector:roiConstant')
                    useROI=true;


                    coder.const(feval('vision.internal.detector.checkROI',roi,size(I)));



                    [params,DetectionInputWasBatchOfImages,MiniBatchSize]=this.parseDetectInputs(I,roi,useROI,varargin{2:end});


                    preprocessedImageSize(1)=roi(4);
                    preprocessedImageSize(2)=roi(3);

                else


                    coder.internal.errorIf(true,'dlcoder_spkg:ObjectDetector:roiIncorrectNumel')
                end
            else


                roi=coder.nullcopy(zeros(1,4));



                [params,DetectionInputWasBatchOfImages,MiniBatchSize]=this.parseDetectInputs(I,roi,useROI,varargin{:});
                preprocessedImageSize(1)=size(I,1);
                preprocessedImageSize(2)=size(I,2);
            end



            Iroi=vision.internal.detector.cropImageIfRequested(I,roi,useROI);



            if coder.internal.isConst(preprocessedImageSize)...
                &&isequal(preprocessedImageSize,trainingImageSize(1:2))
                Ipreprocessed=Iroi;
            else
                Ipreprocessed=coder.nullcopy(zeros(coder.const(trainingImageSize(1)),coder.const(trainingImageSize(2)),...
                size(Iroi,3),size(Iroi,4),'like',Iroi));
                Ipreprocessed(:,:,:,:)=imresize(Iroi,[trainingImageSize(1),trainingImageSize(2)]);
            end


            [scorestmp,bboxestmp]=this.Network.predict(Ipreprocessed,'MiniBatchSize',coder.const(MiniBatchSize));


            originalSize=[size(I,1),size(I,2),size(I,3)];
            if DetectionInputWasBatchOfImages
                [bboxes,scores,varargout{1}]=this.iPostProcessBatchPredictions(bboxestmp,scorestmp,...
                originalSize,params,roi,useROI,returnLabels);
            else
                [bboxes,scores,varargout{1}]=this.iPostProcessActivations(bboxestmp,scorestmp,...
                originalSize,params,roi,useROI,returnLabels);
            end


        end

    end

    methods(Hidden)
        function identifier=getNetworkWrapperIdentifier(~)

            identifier='ssdObjectDetector';
        end
    end

    methods(Hidden=true,Static)




        function[anchors,classNames,inputSize,backgroundIndex]=getDetectorProperties(matfile)
            detectorObj=coder.internal.loadDeepLearningNetwork(matfile);


            inputSize=detectorObj.InputSize;
            anchors=detectorObj.TiledAnchorBoxes;

            labelArray=detectorObj.ClassNames;
            lengthArray=cellfun(@strlength,labelArray);
            numClasses=numel(labelArray);
            classNames=char(zeros(numClasses,max(lengthArray)));
            for labelIdx=1:numClasses
                classNames(labelIdx,1:lengthArray(labelIdx))=labelArray{labelIdx};
            end
            backgroundIndex=size(classNames,1)+1;
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

            defaults=struct('roi',[],...
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
                acceleration=coder.internal.getParameterValue(pstruct.Acceleration,defaults.Acceleration,varargin{:});
                miniBatchSize=coder.internal.getParameterValue(pstruct.MiniBatchSize,defaults.MiniBatchSize,varargin{:});

                params.Threshold=Threshold;
                params.SelectStrongest=SelectStrongest;
                vision.internal.detector.ValidationUtils.checkSize(MinSize,'MinSize',mfilename);
                params.MinSize=[MinSize(1),MinSize(2)];
                vision.internal.detector.ValidationUtils.checkSize(MaxSize,'MinSize',mfilename);
                params.MaxSize=[MaxSize(1),MaxSize(2)];
                params.Acceleration=acceleration;
            end

            params.roi=roi;
            params.useROI=useROI;


            coder.internal.assert(coder.internal.isConst(miniBatchSize),...
            'dlcoder_spkg:ObjectDetector:VariableSizeMiniBatch');
            miniBatchSize=coder.const(miniBatchSize);


            vision.internal.cnn.validation.checkMiniBatchSize(coder.const(miniBatchSize),mfilename);

            if~coder.internal.isConst(params.Acceleration)||~coder.const(strcmpi(params.Acceleration,'none'))
                coder.internal.compileWarning(eml_message(...
                'dlcoder_spkg:cnncodegen:IgnoreInputArg','detect','Acceleration'));
            end

            vision.internal.inputValidation.validateLogical(...
            params.SelectStrongest,'SelectStrongest');

            validateMinSize=logical(pstruct.MinSize);
            validateMaxSize=logical(pstruct.MaxSize);



            if coder.const(validateMinSize)
                vision.internal.detector.ValidationUtils.checkMinSize(...
                params.MinSize,[1,1],mfilename);
            end




            if coder.const(validateMaxSize)

                vision.internal.detector.ValidationUtils.checkMaxSize(params.MaxSize,params.MinSize,mfilename);
                coder.internal.errorIf(params.useROI&&(params.MaxSize(1)>params.roi(1,4))&&(params.MaxSize(2)>params.roi(1,3)),...
                'vision:ssd:modelMaxSizeGTROISize',...
                params.roi(1,4),params.roi(1,3));

                coder.internal.errorIf(~params.useROI&&any(params.MaxSize>inputSize(1:2)),...
                'vision:ssd:modelMaxSizeGTImgSize',...
                inputSize(1),inputSize(2));
            end

            if coder.const(validateMaxSize)&&coder.const(validateMinSize)
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


            coder.internal.assert(coder.internal.isConst([imSz(3),imSz(4)]),...
            'dlcoder_spkg:ObjectDetector:VariableSizeChannelBatchSSD');

            networkChannelSize=coder.const(this.InputSize(3));
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


        function[bboxes,scores,labels]=iPostProcessBatchPredictions(this,bboxesAll,scoresAll,originalSize,params,roi,useROI,returnLabels)

            coder.internal.prefer_const(returnLabels);

            numImages=size(bboxesAll,4);
            bboxes=cell(numImages,1);
            scores=cell(numImages,1);
            labels=cell(numImages,1);


            coder.unroll(false);
            for ii=1:numImages
                [bboxes{ii},scores{ii},labels{ii}]=this.iPostProcessActivations(bboxesAll(:,:,:,ii),scoresAll(:,:,:,ii),...
                originalSize,params,roi,useROI,returnLabels);
            end

        end






        function[bboxes,scores,labelNames]=iPostProcessActivations(this,bboxes,scores,originalSize,params,roi,useROI,returnLabels)

            coder.internal.prefer_const(returnLabels);


            bboxes=permute(bboxes,[1,3,2,4]);


            trainedImageScale=[this.InputSize(1:2),this.InputSize(1:2)];
            outImageScale=[originalSize(2),originalSize(1)...
            ,originalSize(2),originalSize(1)];


            anchorBoxes=this.AnchorBoxes;
            for i=1:size(anchorBoxes,1)
                anchorBoxes(i,:)=anchorBoxes(i,:).*trainedImageScale;
            end


            bboxes=this.decode(anchorBoxes,bboxes);

            coder.gpu.kernel();
            for i=1:size(bboxes,1)
                bboxes(i,:)=bboxes(i,:).*(outImageScale./trainedImageScale);
            end


            scores(:,this.BackgroundIndex)=-realmax('single');




            [scores,labels]=max(scores,[],3);




            [bboxPred,scorePred,classPred]=this.filterBBoxes(bboxes,scores,labels,...
            params.Threshold,params.MinSize,params.MaxSize,originalSize);



            if params.SelectStrongest
                [bboxes,scores,labels]=selectStrongestBboxMulticlass(bboxPred,scorePred,classPred,...
                'RatioType','Union','OverlapThreshold',0.5);
            else
                bboxes=bboxPred;
                scores=scorePred;
                labels=classPred;
            end


            bboxes(:,1:2)=vision.internal.detector.addOffsetForROI(bboxes(:,1:2),roi,useROI);



            coder.gpu.kernel();
            for i=1:size(bboxes,1)
                bboxes(i,:)=floor(bboxes(i,:));
                bboxes(i,[1,2])=max(bboxes(i,[1,2]),1);
            end

            if returnLabels
                numBBoxes=size(bboxes,1);
                labelNames=returnCategoricalLabels(this,numBBoxes,labels);
            else
                labelNames=[];
            end
        end




        function bboxes=decode(~,P,reg)

            x=reg(:,1)*0.1;
            y=reg(:,2)*0.1;
            w=reg(:,3)*0.2;
            h=reg(:,4)*0.2;


            px=P(:,1)+P(:,3)/2;
            py=P(:,2)+P(:,4)/2;


            gx=P(:,3).*x+px;
            gy=P(:,4).*y+py;

            gw=P(:,3).*exp(w);
            gh=P(:,4).*exp(h);


            bboxes=[gx-gw/2,gy-gh/2,gw,gh];
            bboxes=double(bboxes);

        end





        function[bboxes1,scores1,labels1]=filterBBoxes(~,bboxes,scores,labels,threshold,minSize,maxSize,imageSize)





            predicateArray=coder.nullcopy(zeros(size(bboxes,1),1,'int32'));

            coder.gpu.kernel;
            for i=1:size(bboxes,1)
                x1=bboxes(i,1);
                y1=bboxes(i,2);
                x2=bboxes(i,3)+x1-1;
                y2=bboxes(i,4)+y1-1;
                if(scores(i)>threshold&&...
                    bboxes(i,4)>=minSize(1)&&...
                    bboxes(i,3)>=minSize(2)&&...
                    bboxes(i,4)<=maxSize(1)&&...
                    bboxes(i,3)<=maxSize(2)&&...
                    (x2>1)&&(y2>1)&&...
                    (x1<imageSize(2))&&(y1<imageSize(1)))

                    predicateArray(i)=1;
                else
                    predicateArray(i)=0;

                end
            end

            predicateArray=cumsum(predicateArray);

            newNumElem=predicateArray(end);

            bboxes1=coder.nullcopy(zeros(newNumElem,4,'like',bboxes));
            scores1=coder.nullcopy(zeros(newNumElem,1,'like',scores));
            labels1=coder.nullcopy(zeros(newNumElem,1,'like',labels));


            if predicateArray(1)==1
                bboxes1(1,:)=bboxes(1,:);
                scores1(1)=scores(1);
                labels1(1)=labels(1);
            end

            coder.gpu.kernel;
            for i=2:numel(predicateArray)

                if(predicateArray(i)~=predicateArray(i-1))
                    bboxes1(predicateArray(i),:)=bboxes(i,:);
                    scores1(predicateArray(i))=scores(i);
                    labels1(predicateArray(i))=labels(i);

                end

            end

        end


        function labelNames=returnCategoricalLabels(obj,numBBoxes,labels)
            coder.inline('never');



            labelCells=coder.nullcopy(cell(numBBoxes,1));
            for i=1:numBBoxes


                labelCells{i}=nonzeros(obj.ClassNames(labels(i),:))';
            end






            valueset={};
            upperBound=size(obj.ClassNames,1);



            coder.varsize('valueset',[1,upperBound],[0,1]);
            for i=1:size(obj.ClassNames,1)
                valueset{end+1}=nonzeros(obj.ClassNames(i,:))';
            end

            labelNames=categorical(labelCells,valueset);
        end

    end

end
