classdef FullDataTypeStrategy<DataTypeOptimization.Parallel.DataTypeMapping.BlockParameterStrategy






    properties(SetAccess=private)
BlockPath
PropertyName
    end

    methods
        function this=FullDataTypeStrategy(blockPath,propertyName)

            this.BlockPath=blockPath;


            this.PropertyName=propertyName;
        end

        function[blockPath,propertyName,propertyValue]=getBlockParameterElements(this,dataType)

            blockPath=this.BlockPath;


            propertyName=this.PropertyName;


            propertyValue=dataType.evaluatedDTString;
        end
    end
end

