


classdef(Abstract)DeepLearningCodegenOptionsCallback

    methods(Static,Abstract)
        DataType=getDataType(uniqueNetworkIdentifier);
        CodegenOptions=getCodegenOptions(uniqueNetworkIdentifier);
    end

end

