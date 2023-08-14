classdef RTEDataItemUtils<handle




    methods(Static,Access='public')

        function[declType,declVarName,firstElementIndex]=getDeclarationTypeAndVar(typeInfo,...
            dataVarName,...
            preserveDimensions)
            if typeInfo.IsArray
                declType=typeInfo.BaseRteType;
                if preserveDimensions
                    dimensions=typeInfo.DimensionsStr;
                    dimsString='';
                    firstElementIndex='';
                    for dimIdx=1:length(dimensions)
                        dimsString=sprintf('%s[%s]',dimsString,dimensions(dimIdx));
                        firstElementIndex=sprintf('%s[0]',firstElementIndex);
                    end
                else
                    dimsString=sprintf('[%s]',typeInfo.WidthStr);
                    firstElementIndex='';
                end
                declVarName=sprintf('%s%s',dataVarName,dimsString);
            else
                declType=typeInfo.RteType;
                declVarName=dataVarName;
                firstElementIndex='';
            end
        end

    end
end
