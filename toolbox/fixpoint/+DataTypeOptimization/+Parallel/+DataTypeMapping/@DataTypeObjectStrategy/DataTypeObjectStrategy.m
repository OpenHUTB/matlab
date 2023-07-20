classdef DataTypeObjectStrategy<DataTypeOptimization.Parallel.DataTypeMapping.MappingStrategy







    properties
dataTypeObjectWrapper
    end

    methods
        function this=DataTypeObjectStrategy(dataTypeObjectWrapper)
            this.dataTypeObjectWrapper=dataTypeObjectWrapper;

        end

        function simulationInput=addEntry(this,simulationInput,dataType)


            modifiedObject=this.getModifiedObject(dataType);



            if this.dataTypeObjectWrapper.WorkspaceType==SimulinkFixedPoint.AutoscalerVarSourceTypes.Model
                simulationInput=simulationInput.setVariable(this.dataTypeObjectWrapper.Name,...
                modifiedObject,...
                'Workspace',this.dataTypeObjectWrapper.getDataSource.ownerName);
            else

                simulationInput=simulationInput.setVariable(this.dataTypeObjectWrapper.Name,modifiedObject);
            end
        end

    end

    methods(Hidden)

        function modifiedObject=getModifiedObject(this,dataType)


            modifiedObject=slprivate('copyHelper',this.dataTypeObjectWrapper.Object);
            modifiedObject.DataType=dataType.evaluatedDTString;
        end
    end
end

