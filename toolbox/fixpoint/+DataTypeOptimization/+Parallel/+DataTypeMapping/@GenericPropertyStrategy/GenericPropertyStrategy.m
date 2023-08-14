classdef GenericPropertyStrategy<DataTypeOptimization.Parallel.DataTypeMapping.BlockParameterStrategy





    properties(SetAccess=private)
BlockPath
PropertyName
PropertyValue
    end

    methods
        function this=GenericPropertyStrategy(blockPath,propertyName,propertyValue)

            this.BlockPath=blockPath;


            this.PropertyName=propertyName;


            this.PropertyValue=propertyValue;
        end

        function[blockPath,propertyName,propertyValue]=getBlockParameterElements(this,~)

            blockPath=this.BlockPath;


            propertyName=this.PropertyName;


            propertyValue=this.PropertyValue;
        end
    end
end

