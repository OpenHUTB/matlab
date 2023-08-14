






classdef TensorRTDeepLearningCodegenOptions<coder.internal.DeepLearningCodegenOptionsBase

    properties




CalibrationDataStore


CalibratorType



StrictComputeConstraint

    end

    properties(Hidden)




DynamicRange




LayerPrecision

    end

    methods

        function codegenOptions=TensorRTDeepLearningCodegenOptions(targetLib)

            codegenOptions=codegenOptions@coder.internal.DeepLearningCodegenOptionsBase(targetLib);

            codegenOptions.CalibrationDataStore={};

            codegenOptions.DynamicRange={};

            codegenOptions.LayerPrecision={};

            codegenOptions.CalibratorType='Entropy';

            codegenOptions.StrictComputeConstraint=false;

        end
    end
end

