classdef(Abstract)BlockParameterStrategy<DataTypeOptimization.Parallel.DataTypeMapping.MappingStrategy





    methods
        function simulationInput=addEntry(this,simulationInput,dataType)
            [blockPath,propertyName,propertyValue]=this.getBlockParameterElements(dataType);


            simulationInput=simulationInput.setBlockParameter(...
            blockPath,...
            propertyName,...
            propertyValue);
        end
    end

    methods(Abstract)
        [blockPath,propertyName,propertyValue]=getBlockParameterElements(this,dataType);
    end
end

