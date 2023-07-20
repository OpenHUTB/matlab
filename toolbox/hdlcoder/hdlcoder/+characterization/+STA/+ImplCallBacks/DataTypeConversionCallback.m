
classdef DataTypeConversionCallback<characterization.STA.ImplementationCallback





    methods
        function self=DataTypeConversionCallback()
            self@characterization.STA.ImplementationCallback();
        end

        function preprocessModelDependentParams(~,modelInfo)
            set_param(modelInfo.blockPath,'OutDataTypeStr','int32');
        end
    end
end
