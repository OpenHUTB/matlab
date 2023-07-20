%#codegen


function[obj,out]=predictAndUpdateState(obj,indata,varargin)




    coder.allowpcode('plain');
    coder.internal.allowHalfInputs;
    coder.inline('never');
    coder.internal.reference_parameter(obj);

    unSupportedTargets={'arm-compute-mali','cmsis-nn'};
    coder.extrinsic('dlcoder_base.internal.checkFunctionSupportForTarget');
    coder.const(@dlcoder_base.internal.checkFunctionSupportForTarget,'predictAndUpdateState',obj.DLTargetLib,unSupportedTargets);


    coder.internal.DeepLearningNetworkUtils.validateStatefulCall(obj.IsRNN,'predictAndUpdateState');
    out=obj.predictForRNN(indata,'predictAndUpdateState',varargin{:});

    obj.callUpdateState();
end
