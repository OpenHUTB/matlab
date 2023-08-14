%#codegen


function obj=resetState(obj)





    coder.allowpcode('plain');
    coder.inline('never');
    coder.internal.reference_parameter(obj);


    unSupportedTargets={'arm-compute-mali','cmsis-nn'};
    coder.extrinsic('dlcoder_base.internal.checkFunctionSupportForTarget');
    coder.const(@dlcoder_base.internal.checkFunctionSupportForTarget,'resetState',obj.DLTargetLib,unSupportedTargets);






    coder.internal.defer_inference('callResetState',obj);
end
