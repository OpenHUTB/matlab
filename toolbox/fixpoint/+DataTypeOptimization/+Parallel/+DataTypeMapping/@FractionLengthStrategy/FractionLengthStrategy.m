classdef FractionLengthStrategy<DataTypeOptimization.Parallel.DataTypeMapping.BlockParameterStrategy






    properties(SetAccess=private)
BlockPath
PropertyName
    end

    methods
        function this=FractionLengthStrategy(blockPath,propertyName)

            this.BlockPath=blockPath;


            this.PropertyName=propertyName;
        end

        function[blockPath,propertyName,propertyValue]=getBlockParameterElements(this,dataType)

            blockPath=this.BlockPath;


            propertyName=this.PropertyName;


            propertyValue=num2str(dataType.evaluatedNumericType.FractionLength);

        end
    end
end

