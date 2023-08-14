classdef GenerateDataTypeForFloatingPointRules<handle




    methods(Static)
        function dataType=generateDataType(typesVector)
            if any(arrayfun(@isdouble,typesVector))


                dataType=numerictype('double');
            elseif any(arrayfun(@issingle,typesVector))...
                ||all(arrayfun(@ishalf,typesVector))


                dataType=numerictype('single');
            end
        end
    end
end
