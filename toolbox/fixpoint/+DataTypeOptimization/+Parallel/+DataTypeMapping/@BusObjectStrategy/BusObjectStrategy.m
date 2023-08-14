classdef BusObjectStrategy<DataTypeOptimization.Parallel.DataTypeMapping.DataTypeObjectStrategy







    properties
        elementIndex;
    end

    methods
        function this=BusObjectStrategy(busObjectHandle,pathItem)

            this@DataTypeOptimization.Parallel.DataTypeMapping.DataTypeObjectStrategy(...
            SimulinkFixedPoint.WrapperCreator.getWrapper(...
            busObjectHandle.Object,...
            busObjectHandle.busName,...
            busObjectHandle.ContextName,...
            busObjectHandle.WorkspaceType));

            this.elementIndex=busObjectHandle.leafChildName2IndexMap(pathItem);
        end

        function simulationInput=addEntry(this,simulationInput,dataType)
            identicalName=strcmp({simulationInput.Variables.Name},this.dataTypeObjectWrapper.Name);

            if~any(identicalName)

                modifiedObject=this.dataTypeObjectWrapper.Object;
            else

                modifiedObject=simulationInput.Variables(identicalName).Value;
            end


            modifiedObject.Elements(this.elementIndex).DataType=dataType.evaluatedDTString;




            simulationInput=simulationInput.setVariable(this.dataTypeObjectWrapper.Name,modifiedObject);

        end

    end

end

