classdef AliasTypeObjectStrategy<DataTypeOptimization.Parallel.DataTypeMapping.DataTypeObjectStrategy






    methods(Hidden)

        function modifiedObject=getModifiedObject(this,dataType)

            modifiedObject=this.dataTypeObjectWrapper.Object;

            modifiedObject.BaseType=dataType.evaluatedDTString;
        end

    end

end

