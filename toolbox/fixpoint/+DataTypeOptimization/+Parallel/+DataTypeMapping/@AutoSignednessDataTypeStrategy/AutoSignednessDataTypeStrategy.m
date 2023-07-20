classdef AutoSignednessDataTypeStrategy<DataTypeOptimization.Parallel.DataTypeMapping.BlockParameterStrategy







    properties(SetAccess=private)
BlockPath
PropertyName
    end

    methods
        function this=AutoSignednessDataTypeStrategy(blockPath,propertyName)

            this.BlockPath=blockPath;


            this.PropertyName=propertyName;
        end

        function[blockPath,propertyName,propertyValue]=getBlockParameterElements(this,dataType)

            blockPath=this.BlockPath;


            propertyName=this.PropertyName;


            typestring='';%#ok<NASGU>
            nt=dataType.evaluatedNumericType;
            if nt.isscalingslopebias()
                typestring=sprintf('fixdt([],%d,%d,%d)',...
                nt.WordLength,nt.Slope,nt.Bias);
            else
                typestring=sprintf('fixdt([],%d,%d)',...
                nt.WordLength,nt.FractionLength);
            end
            propertyValue=typestring;
        end
    end
end

