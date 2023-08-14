classdef StringForOutputTypeFloat<FunctionApproximation.internal.outputtypestring.StringsForOutputType



    methods(Static)
        function string=getStringForOutputType(outputType)


            string=['output = zeros(size(inputValues1),''like'',',mat2str(fixed.internal.math.castUniversal([],outputType.tostring),'class'),');'];
        end
    end
end
