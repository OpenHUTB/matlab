classdef SignednessStrategy<DataTypeOptimization.Parallel.DataTypeMapping.BlockParameterStrategy






    properties(SetAccess=private)
BlockPath
PropertyName
    end

    methods
        function this=SignednessStrategy(blockPath,propertyName)

            this.BlockPath=blockPath;


            this.PropertyName=propertyName;
        end

        function[blockPath,propertyName,propertyValue]=getBlockParameterElements(this,dataType)

            sString='off';
            if dataType.evaluatedNumericType.SignednessBool
                sString='on';
            end


            blockPath=this.BlockPath;


            propertyName=this.PropertyName;


            propertyValue=sString;

        end
    end
end

