classdef TableValuesStringForFloat<handle



    methods(Static)
        function tableValuesString=getTableValuesString(tableValues,tableValuesType)
            tableValues=reshape(tableValues,[],1);
            tableValuesString=['tableValues = coder.const(',mat2str(fixed.internal.math.castUniversal(tableValues,tableValuesType.tostring),'class'),...
            ');',newline;];
        end
    end
end
