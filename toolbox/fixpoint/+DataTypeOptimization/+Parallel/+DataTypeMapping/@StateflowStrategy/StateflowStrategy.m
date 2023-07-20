classdef StateflowStrategy<DataTypeOptimization.Parallel.DataTypeMapping.MappingStrategy





    properties
stateflowEntity
    end

    methods
        function this=StateflowStrategy(stateflowEntity)
            this.stateflowEntity=stateflowEntity;
        end

        function simulationInput=addEntry(this,simulationInput,dataType)


            newDataType=numerictype(dataType.evaluatedNumericType);
            modelName=bdroot(this.stateflowEntity.Machine.Path);
            simulationInput=simulationInput.setVariable(this.stateflowEntity.DataType,newDataType,'Workspace',modelName);

        end

    end

end

