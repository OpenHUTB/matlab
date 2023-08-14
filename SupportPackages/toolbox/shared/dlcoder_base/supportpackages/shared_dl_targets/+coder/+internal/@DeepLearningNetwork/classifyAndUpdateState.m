%#codegen


function[obj,labels,scores]=classifyAndUpdateState(obj,indata,varargin)




    coder.allowpcode('plain');
    coder.internal.allowHalfInputs;
    coder.inline('never');
    coder.internal.reference_parameter(obj);

    coder.extrinsic('dlcoder_base.internal.checkFunctionSupportForTarget');
    coder.const(@dlcoder_base.internal.checkFunctionSupportForTarget,'classifyAndUpdateState',obj.DLTargetLib,'cmsis-nn');


    coder.internal.DeepLearningNetworkUtils.validateStatefulCall(obj.IsRNN,'classifyAndUpdateState');
    scores=obj.predictForRNN(indata,'classifyAndUpdateState',varargin{:});

    obj.callUpdateState();



    labelsCell=obj.postProcessOutputToReturnCategorical({scores});


    labels=labelsCell{1};

end
