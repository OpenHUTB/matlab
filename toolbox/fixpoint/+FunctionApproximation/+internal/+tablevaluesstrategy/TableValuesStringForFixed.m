classdef TableValuesStringForFixed<handle



    methods(Static)
        function tableValuesString=getTableValuesString(tableValues,tableValuesType)
            tableValuesString=fi(tableValues,tableValuesType);
            tableValuesString=['tableValues = coder.const(',tableValuesString.tostring,');',newline];
        end
    end
end
