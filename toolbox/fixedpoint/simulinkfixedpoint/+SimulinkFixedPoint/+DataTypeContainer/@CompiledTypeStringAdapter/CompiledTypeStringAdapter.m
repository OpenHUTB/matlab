classdef CompiledTypeStringAdapter<handle












    properties(SetAccess=private)
        OldString;
        NewString;
    end
    methods
        function this=CompiledTypeStringAdapter(dataTypeString)
            this.OldString=dataTypeString;
            this.NewString=this.OldString;
            if SimulinkFixedPoint.DataTypeContainer.isFixedPointTypeSimulinkName(dataTypeString)
                try





                    numericType=numerictype(dataTypeString);
                    this.NewString=tostring(numericType);
                catch
                end
            end
        end
    end
end


