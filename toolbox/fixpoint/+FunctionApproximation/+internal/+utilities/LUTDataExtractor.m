classdef(Sealed)LUTDataExtractor





    methods(Access=?FunctionApproximation.internal.AbstractUtils)

        function this=LUTDataExtractor()
        end
    end

    methods
        function data=extractData(~,functionWrapper)

            if isa(functionWrapper,'FunctionApproximation.internal.functionwrapper.OperatorWrapper')...
                ||isa(functionWrapper,'FunctionApproximation.internal.functionwrapper.SerializationNeedingWrapper')
                data=functionWrapper.Data;
            else
                data=FunctionApproximation.internal.serializabledata.LUTModelData.empty;
            end
        end
    end
end


