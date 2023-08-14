classdef LUTObjectStrategy<DataTypeOptimization.Parallel.DataTypeMapping.DataTypeObjectStrategy






    properties
pathItem
index
    end

    methods
        function this=LUTObjectStrategy(dataTypeObjectWrapper,pathItem,index)

            this@DataTypeOptimization.Parallel.DataTypeMapping.DataTypeObjectStrategy(dataTypeObjectWrapper)


            this.pathItem=pathItem;
            this.index=index;

        end
    end
    methods(Hidden)

        function modifiedObject=getModifiedObject(this,dataType)


            modifiedObject=copy(this.dataTypeObjectWrapper.Object);


            if strcmp(this.pathItem,'Table')
                modifiedObject.Table.DataType=dataType.evaluatedDTString;
            else

                modifiedObject.Breakpoints(this.index).DataType=dataType.evaluatedDTString;
            end
        end

    end

end

