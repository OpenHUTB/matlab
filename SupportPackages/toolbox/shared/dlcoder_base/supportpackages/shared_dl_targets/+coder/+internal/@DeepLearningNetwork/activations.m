%#codegen





function out=activations(obj,varargin)




    coder.allowpcode('plain');
    coder.gpu.internal.kernelfunImpl(false);
    coder.inline('never');
    coder.internal.allowHalfInputs;

    coder.extrinsic('dlcoder_base.internal.checkFunctionSupportForTarget');
    coder.const(@dlcoder_base.internal.checkFunctionSupportForTarget,'activations',obj.DLTargetLib,'cmsis-nn');


    if obj.IsRNN

        in=varargin{1};
        layerArg=varargin{2};
        nvps={varargin{3:end}};

        out=obj.activationsForRNN(in,layerArg,'activations',nvps{:});
    else
        numInputs=coder.const(obj.NumInputLayers);


        iValidateNumInputs(numInputs,(nargin-1));

        dataInputs={varargin{1:numInputs}};
        dataInputsSingle=cell(numInputs,1);



        inputFeatureSizes=cell(numInputs,1);

        for i=1:numInputs
            in=dataInputs{i};


            [height,width,channels,batchSize]=...
            coder.internal.iohandling.cnn.InputDataPreparer.parseInputSize(in,obj.NetworkInputSizes{i},'activations',obj.DLTargetLib);

            inputFeatureSizes{i}=[height,width,channels];


            coder.internal.coderNetworkUtils.checkAndWarnForHalfInput(class(in),obj.DataType,'activations');


            dataInputsSingle{i}=single(in);
        end


        layerArg=varargin{numInputs+1};



        layerArg=coder.internal.DeepLearningNetworkUtils.validateLayerArg(layerArg);


        optionalArgs={varargin{numInputs+2:end}};
        miniBatchSize=coder.internal.DeepLearningNetwork.parseInputsCodegenActivationsCNN(optionalArgs{:});

        out=obj.activationsForCNN(numInputs,dataInputsSingle,layerArg,inputFeatureSizes,batchSize,miniBatchSize);
    end
end


function iValidateNumInputs(expectedNumInputs,actualNumberOfInputs)
    coder.inline('always');

    coder.internal.assert(actualNumberOfInputs>=expectedNumInputs,'dlcoder_spkg:cnncodegen:InsufficientInputs',expectedNumInputs);
end
