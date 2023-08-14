classdef BreakPointObjectStrategy<DataTypeOptimization.Parallel.DataTypeMapping.DataTypeObjectStrategy






    methods(Hidden)

        function modifiedObject=getModifiedObject(this,dataType)
            modifiedObject=copy(this.dataTypeObjectWrapper.Object);
            modifiedObject.Breakpoints.DataType=dataType.evaluatedDTString;
        end

    end

end

