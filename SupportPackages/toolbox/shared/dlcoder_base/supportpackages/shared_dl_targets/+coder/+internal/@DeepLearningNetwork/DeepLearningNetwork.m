%#codegen


classdef DeepLearningNetwork<handle







    properties(Access=private)
anchor



MatFile



VariableName



BatchSize




NetworkInputSizes




ClassificationOutputLayersBool


DLTargetLib



CustomLayerProperties
    end

    properties(SetAccess=private)


InputNames



OutputNames
    end


    properties(Access=protected)




DLTNetwork


NetworkInfo





InputLayerIndices



OutputLayerIndices


NumInputLayers


NumOutputLayers



NetworkName


IsRNN



        DataType='fp32'





HasSequenceOutput





CodegenInputSizes
    end

    properties(Constant)
        predictFcnName='#predict';
        resetStateFcnName='#resetState';
        updateStateFcnName='#updateState';
        activationFcnName='#activation';
        setsizeFcnName='#setsize';
        setupFcnName='#setup';
        deleteFcnName='#delete';

        predictAnchorName='#__predict__';
        resetStateAnchorName='#__resetState__';
        updateStateAnchorName='#__updateState__';
        activationAnchorName='#__activation__';
        setupAnchorName='#__setup__';
        deleteAnchorName='#__delete__';

        customPredictAnchor='#__customPredict__';
        callPredictForCustomLayersAnchor='#__callPredictForCustomLayer__';
        customPropSzAnchor='#__customPropSz__';
        customPropertiesAnchor='#__customProperties__';

        setLearnablesAnchorName='#__setLearnables__';
        setLearnablesFcnName='#setLearnables';

        NetworkWrapperAnchor='#__networkWrapper__';
    end


    methods(Hidden=true)


        function obj=DeepLearningNetwork(matfile,variableName,varargin)
            coder.allowpcode('plain');
            coder.extrinsic('coder.internal.DeepLearningNetwork.parseNetwork');
            coder.extrinsic('coder.internal.getFileInfo');
            coder.extrinsic('coder.internal.getDeepLearningConfig');
            coder.extrinsic('dltargets.internal.validateSimulinkCodegenSettings');
            coder.extrinsic('dltargets.internal.getNetworkIdentifier');
            coder.extrinsic('coder.internal.getDeepLearningCodegenOptionsCallback');


            if~coder.target('MATLAB')
                coder.license('checkout','Neural_Network_Toolbox');
            end


            coder.internal.coderNetworkUtils.validateMatFileAndVariableName(matfile,variableName);


            [fileName,~,~]=coder.const(@coder.internal.getFileInfo,matfile);
            coder.internal.addDependentFile(fileName);

            obj.MatFile=matfile;


            networkFcnName=...
            coder.const(@feval,'coder.internal.coderNetworkUtils.parseCoderLoadNetworkVarargin',varargin{:});

            obj.setNetworkName(networkFcnName);

            obj.DLTargetLib=coder.internal.coderNetworkUtils.getTargetLib();

            ctx=eml_option('CodegenBuildContext');



            [obj.DLTNetwork,mxArrayVarName]=feval('coder.internal.DeepLearningNetwork.getNetworkObj',obj.MatFile,variableName);


            obj.VariableName=coder.const(mxArrayVarName);

            if~strcmp(obj.DLTargetLib,'disabled')



                dlConfig=coder.const(@coder.internal.getDeepLearningConfig,ctx,obj.DLTargetLib);

                dlCodegenOptionsCallback=coder.const(@coder.internal.getDeepLearningCodegenOptionsCallback,ctx);

                networkIdentifier=coder.const(@dltargets.internal.getNetworkIdentifier,obj.DLTNetwork);


                obj.DataType=coder.const(@feval,'coder.internal.coderNetworkUtils.populateDataType',dlConfig,dlCodegenOptionsCallback,networkIdentifier);
            else
                obj.DataType='fp32';
            end


            resultStruct=...
            coder.const(@coder.internal.DeepLearningNetwork.parseNetwork,obj.DLTNetwork);



            obj.InputLayerIndices=resultStruct.InputLayerIndices;
            obj.OutputLayerIndices=resultStruct.OutputLayerIndices;
            obj.NetworkInputSizes=resultStruct.NetworkInputSizes;
            obj.IsRNN=resultStruct.IsRNN;
            obj.HasSequenceOutput=resultStruct.HasSequenceOutput;
            obj.NumInputLayers=coder.const(numel(obj.InputLayerIndices));
            obj.NumOutputLayers=coder.const(numel(obj.OutputLayerIndices));
            obj.ClassificationOutputLayersBool=coder.const(resultStruct.ClassificationLayers);
            obj.InputNames=coder.const(resultStruct.InputNames);
            obj.OutputNames=coder.const(resultStruct.OutputNames);

            obj.setup();



            if~coder.internal.isAmbiguousComplexity&&~coder.internal.isAmbiguousTypes
                coder.internal.coderNetworkUtils.registerDependencies;
            end

        end


        function delete(obj)



            coder.inline('never');





            if coder.const(coder.const(~(strcmp(obj.DLTargetLib,'none')))&&...
                ~coder.const(@feval,'dlcoderfeature','LibraryFreeCGIR'))
                coder.internal.defer_inference('callDelete',obj);
            end
        end

        function setupNetworkWrapper(obj,networkWrapperIdentifier)
            coder.inline('never');





            coder.internal.defer_inference('callSetupNetworkWrapper',obj,networkWrapperIdentifier);
        end
    end

    methods(Access=public)


        varargout=predict(obj,varargin);


        out=activations(obj,varargin);


        [labels,scores]=classify(obj,varargin);


        [newNet,out]=predictAndUpdateState(obj,indata,varargin);


        [newNet,out]=classifyAndUpdateState(obj,indata,varargin);

        obj=resetState(obj);

    end


    methods(Access=private)



        validate(obj)


        function setNetworkName(obj,varargin)
            coder.inline('always');
            coder.extrinsic('fileparts');
            if nargin>1&&~isempty(varargin{1})
                netName=varargin{1};
                coder.internal.assert((coder.internal.isCharOrScalarString(netName)&&...
                coder.internal.isConst(netName)),...
                'dlcoder_spkg:cnncodegen:invalid_networkname');
            else
                [~,netName,~]=coder.const(@fileparts,obj.MatFile);
            end

            obj.NetworkName=netName;
        end


        function callSetup(obj)
            coder.inline('always');



            if coder.internal.is_defined(obj.anchor)

                coder.ceval('-layout:any',obj.setupAnchorName,...
                coder.internal.stringConst(obj.NetworkName));


                coder.ceval('-layout:any',obj.setupFcnName,...
                coder.ref(obj.anchor));
            end
        end


        function callSetLearnables(obj,learnables)
            coder.inline('always');


            coder.ceval('-layout:any',obj.setLearnablesAnchorName,coder.ref(learnables));


            coder.ceval('-layout:any',obj.setLearnablesFcnName,coder.wref(obj.anchor),coder.ref(learnables));

        end


        function callSetupNetworkWrapper(obj,networkWrapperIdentifier)
            coder.inline('always');
            coder.internal.prefer_const(networkWrapperIdentifier);



            if coder.internal.is_defined(obj.anchor)


                coder.ceval('-layout:any',obj.NetworkWrapperAnchor,coder.rref(obj.anchor),...
                coder.internal.stringConst(networkWrapperIdentifier));
            end
        end



        out=callPredictForRNN(obj,minibatch,...
        outputFeatureSize,miniBatchSequenceLengthValue,...
        isSequenceOutput,isCellInput,isImageInput,isImageOutput);


        out=activationsForCNN(obj,numInputs,dataInputsSingle,layerArg,inputFeatureSizes,batchSize,miniBatchSize);


        out=activationsForRNN(obj,in,layerArg,callerFunction,varargin);


        callPredictForCustomLayers(obj,miniBatchSequenceLengthValue);

    end

    methods(Access=protected)




        setAnchor(obj)


        function setup(obj)
            coder.inline('never');
            coder.internal.defer_inference('callSetup',obj);
        end


        function callUpdateState(obj)
            coder.ceval('-layout:any',obj.updateStateAnchorName);
            coder.ceval('-layout:any',obj.updateStateFcnName,...
            coder.wref(obj.anchor));
        end


        function callResetState(obj)


            coder.internal.assert(coder.const(coder.internal.is_defined(obj.anchor)),...
            'dlcoder_spkg:cnncodegen:NoInferenceCalls');

            coder.ceval('-layout:any',obj.resetStateAnchorName);
            coder.ceval('-layout:any',obj.resetStateFcnName,...
            coder.wref(obj.anchor));
        end

        function callSetSize(obj,sequenceLength)
            coder.inline('always');
            coder.ceval('-layout:any',obj.setsizeFcnName,...
            coder.wref(obj.anchor),...
            uint32(sequenceLength));
        end

        function callDelete(obj)
            if coder.internal.is_defined(obj.anchor)




                coder.inline('never');
                coder.ceval('-layout:any',obj.deleteAnchorName);
                coder.ceval('-layout:any',obj.deleteFcnName,...
                coder.wref(obj.anchor));
            end
        end


        function outData=prepareVectorData(~,inData)
            outData=inData;
        end

        out=callPredict(obj,inputsT,outsizes,numOutputs);

        out=callActivationsForCNN(obj,inputsT,outsizes,numOutputs);

        out=callActivationsForRNN(obj,minibatch,layerIdx,portIdx,...
        outputFeatureSize,miniBatchSequenceLengthValue,...
        isSequenceOutput,isSequenceFolded,...
        isCellInput,isImageInput,isImageOutput);


        out=predictForRNN(obj,in,callerFunction,varargin);



        [miniBatch,sampleSequenceLengths,miniBatchSequenceLengthValue]=prepareMinibatchForRNN(obj,...
        indata,inputSize,miniBatchSize,sequenceLengthMode,sequencePaddingValue,...
        sequencePaddingDirection,isCellInput,isImageInput,miniBatchIdx,numMiniBatches,...
        remainder,callerFunction);


        reshapedSample=prepareRNNCellOutput(obj,outMiniBatch,outputFeatureSize,miniBatchSequenceLengths,...
        sequenceLength,sequencePaddingDirection,sampleIdx,isImageOutput);


        outSample=prepareImageOutSampleForActivations(obj,outMiniBatch,sampleIdx,isCellInput);
        outSample=prepareVectorOutSampleForActivations(obj,outMiniBatch,sampleIdx,isCellInput);


        processedOutput=postProcessOutputToReturnCategorical(obj,scores);

        minibatchsize=getMiniBatchSize(obj);


        obj=setNetworkInfo(obj);
        obj=setCustomLayerProperties(obj);

    end

    methods(Static)


        parseInputsCodegenPredictRNN(varargin);


        parseInputsCodegenPredictCNN(varargin);


        parseInputsCodegenActivationsCNN(varargin);


        parseInputsCodegenActivationsRNN(varargin);



        resultStruct=parseNetwork(net);


        [isCellInput,isImageInput,batchSize,miniBatchSize,numMiniBatches,remainder,outputFeatureSize,isImageOutput]=...
        processInputSizeForPredictForRNN(obj,in,miniBatchSize,callerFunction,varargin);


        [isCellInput,isImageInput,batchSize,miniBatchSize,numMiniBatches,remainder,...
        outputFeatureSize,layerIdx,portIdx,isSequenceOutput,isSequenceFolded,isImageOutput]=...
        processInputSizeForActivationsForRNN(obj,in,layerArg,miniBatchSize,callerFunction,varargin);


        [isCellInput,isImageInput,batchSize,miniBatchSize,numMiniBatches,remainder]=...
        setInputSizeForRNN(obj,in,miniBatchSize,callerFunction,varargin);


        setNetworkSizes(obj,height,width,channels,miniBatchSize,batchSize,callerFunction);

    end

    methods(Static,Hidden)

        function n=matlabCodegenNontunableProperties(~)
            n={'MatFile','VariableName','CodegenInputSizes','BatchSize','NetworkName','IsRNN',...
            'HasSequenceOutput','InputLayerIndices','OutputLayerIndices',...
            'NetworkInputSizes','NumInputLayers','NumOutputLayers','ClassificationOutputLayersBool',...
            'DLTargetLib','InputNames','OutputNames','DataType',...
            'CustomLayerLearnablesIdx','CustomLayerProperties'};
        end

        function n=matlabCodegenMxArrayNontunableProperties(~)
            n={'DLTNetwork','NetworkInfo'};
        end

        function name=matlabCodegenUserReadableName(~)
            name='DeepLearningNetwork';
        end

        function[net,variableName]=getNetworkObj(matfile,variableName)
            [matObj,variableName]=coder.internal.loadCachedDeepLearningObj(matfile,variableName,ReturnNetwork=true);
            if(isa(matObj,'yolov2ObjectDetector')||...
                isa(matObj,'ssdObjectDetector'))
                net=matObj.Network;
            else
                net=matObj;
            end
        end











        function[opMiniBatchSizes,opBatchSizes,opPaddedBatchSizes]=getIOProps(net,ipSizes,...
            miniBatchSize,batchSize,paddedBatchSize)

            [~,outputLayers]=dltargets.internal.getIOLayers(net);
            [opMiniBatchSizes,opBatchSizes,opPaddedBatchSizes]=...
            coder.internal.iohandling.cnn.OutputDataPreparer.getOutputSizeForPredict(net,...
            outputLayers,...
            ipSizes,...
            miniBatchSize,...
            batchSize,...
            paddedBatchSize);
        end


        function isRNN=checkForSequenceNetwork(net)
            isRNN=any(net.getInternalDAGNetwork.HasSequenceInput);
        end


        function[outputFeatureSize,isImageOutput]=getIOPropsForRNN(...
            net,hasSequenceOutput,networkInfo)

            [~,outputLayers]=dltargets.internal.getIOLayers(net);

















            numOutputs=numel(outputLayers);
            assert(numOutputs==1,...
            'dlcoder_spkg:cnncodegen:MIMONotSupportedForLSTMs',...
            getString(message('dlcoder_spkg:cnncodegen:MIMONotSupportedForLSTMs')));

            outputFormat=networkInfo.LayerInfoMap(outputLayers{1}.Name).outputFormats{1};
            outputSizes=networkInfo.LayerInfoMap(outputLayers{1}.Name).outputSizes{1};
            assert(contains(outputFormat,'C'));



            spatialDimIndices=strfind(outputFormat,'S');
            numSpatialDims=numel(spatialDimIndices);

            if numSpatialDims==0

                isImageOutput=false;
                outputFeatureSize=outputSizes(strfind(outputFormat,'C'));
            else
                assert(numSpatialDims==2);

                singletonSpatialDims=all(outputSizes(spatialDimIndices)==1);
                outputLayer=outputLayers{1};
                if singletonSpatialDims&&...
                    (~hasSequenceOutput||isa(outputLayer,'nnet.cnn.layer.ClassificationOutputLayer'))
                    isImageOutput=false;
                    outputFeatureSize=outputSizes(strfind(outputFormat,'C'));
                else
                    isImageOutput=true;
                    outputFeatureSize=outputSizes(strfind(outputFormat,("S"|"C")));
                end
            end
        end


        function warnInputArgs(varargin)
            for k=1:2:numel(varargin)
                coder.internal.compileWarning(eml_message(...
                'dlcoder_spkg:cnncodegen:IgnoreInputArg','predict',varargin{k}));
            end
        end


        function cellData=wrapMatData(matData,seqLengths)
            featureDim=size(matData,1);
            batchSize=size(matData,2);


            cellData=cell(batchSize,1);
            for i=1:batchSize
                cellData{i}=reshape(matData(:,i,1:seqLengths(i)),[featureDim,seqLengths(i)]);
            end
        end




        function[isClassificationNetwork]=validateNetworkForClassify(net)

            [~,outputLayers]=dltargets.internal.getIOLayers(net);


            coder.internal.assert(numel(outputLayers)==1,...
            'dlcoder_spkg:cnncodegen:ClassifyInvalidForMultipleOutputs');

            opLayer=nnet.cnn.layer.Layer.getInternalLayers(outputLayers{1});
            isClassificationNetwork=isa(opLayer{1},'nnet.internal.cnn.layer.ClassificationLayer');
        end


        function[classNames,isOrdinal]=getClassNames(net,outputLayerIndex)

            [~,outputLayers]=dltargets.internal.getIOLayers(net);


            outputLayer=outputLayers{outputLayerIndex};
            isOrdinal=false;
            if isprop(outputLayer,'Classes')&&~isempty(outputLayer.Classes)
                isOrdinal=isordinal(outputLayer.Classes);
                labelArray=cellstr(outputLayer.Classes);
                lengthArray=cellfun(@strlength,labelArray);
                numClasses=numel(outputLayer.Classes);
                classNames=char(zeros(numClasses,max(lengthArray)));
                for labelIdx=1:numClasses
                    classNames(labelIdx,1:lengthArray(labelIdx))=labelArray{labelIdx};
                end
            else


                assert(isprop(outputLayer,'Classes')||~isempty(outputLayer.Classes));
            end
        end



        function optOut=matlabCodegenLowerToStruct(~)
            optOut=true;
        end


    end


    methods(Static,Access=private,Hidden)

        function varargout=layerPredictWithRowMajority(layer,isInputFormatted,inputDlarrayFormat,states,varargin)




            coder.inline('never');



            coder.rowMajor;
            shouldPreserveFunctionInterface=true;
            [varargout{:}]=coder.internal.coderNetworkUtils.customLayerPredict(layer,...
            isInputFormatted,inputDlarrayFormat,states,shouldPreserveFunctionInterface,...
            varargin{:});
        end

        function varargout=layerPredictWithColMajority(layer,isInputFormatted,inputDlarrayFormat,states,varargin)




            coder.inline('never');



            coder.columnMajor;
            shouldPreserveFunctionInterface=true;


            [varargout{:}]=coder.internal.coderNetworkUtils.customLayerPredict(layer,...
            isInputFormatted,inputDlarrayFormat,states,shouldPreserveFunctionInterface,...
            varargin{:});
        end
    end

    methods(Hidden)
        function setLearnables(obj,learnables)
            coder.inline('never');




            assert(false,"setLearnables for DAGNetwork is not supported.");
            coder.internal.defer_inference('callSetLearnables',obj,learnables);
        end
    end

end

