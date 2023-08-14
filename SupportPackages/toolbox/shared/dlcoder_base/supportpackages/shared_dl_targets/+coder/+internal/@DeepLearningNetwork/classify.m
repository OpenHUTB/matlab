%#codegen
function[labels,scores]=classify(obj,varargin)




    coder.allowpcode('plain');
    coder.internal.allowHalfInputs;


    coder.extrinsic('coder.internal.DeepLearningNetwork.validateNetworkForClassify');
    isClassificationNetwork=coder.const(coder.internal.DeepLearningNetwork.validateNetworkForClassify(obj.DLTNetwork));
    coder.internal.assert(isClassificationNetwork,'dlcoder_spkg:cnncodegen:InvalidNetworkForClassify');

    numInputs=coder.const(obj.NumInputLayers);


    iValidateNumInputs(numInputs,(nargin-1));

    dataInputs={varargin{1:numInputs}};
    for i=1:numInputs

        coder.internal.coderNetworkUtils.checkAndWarnForHalfInput(class(dataInputs{i}),obj.DataType,'classify');
    end


    scores=obj.predict(varargin{:});



    labelsCell=obj.postProcessOutputToReturnCategorical({scores});


    labels=labelsCell{1};

end


function iValidateNumInputs(expectedNumInputs,actualNumberOfInputs)
    coder.inline('always');

    coder.internal.assert(actualNumberOfInputs>=expectedNumInputs,'dlcoder_spkg:cnncodegen:InsufficientInputs',expectedNumInputs);
end
