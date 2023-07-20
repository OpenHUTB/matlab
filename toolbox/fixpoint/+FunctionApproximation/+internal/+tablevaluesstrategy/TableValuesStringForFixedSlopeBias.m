classdef TableValuesStringForFixedSlopeBias<handle



    methods(Static)
        function tableValuesString=getTableValuesString(tableValues,tableValuesType)
            tableValues=fi(tableValues,tableValuesType);

            tableValuesString=['tableValues = coder.const(',tableValues.tostring,');',newline];
        end
    end
end
