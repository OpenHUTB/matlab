classdef BlockParameter<stm.internal.VariableReader.Base

    properties(Constant)
        Type="block parameter";
    end

    methods
        function this=BlockParameter(param,model)
            this=this@stm.internal.VariableReader.Base(param,model);
        end

        function value=getCurrentValue(~)

            value=[];
        end

        function property=getSimInProperty(this)
            property=arrayfun(@(r)...
            Simulink.Simulation.BlockParameter(r.Param.Source,r.Param.Name,r.getOverrideValue),...
            this);
        end
    end

    methods(Access=protected)
        function value=getParamValue(this)
            value=this.Param.Value;
        end
    end

    methods(Static)
        function mask=isBlockParameter(sourceTypes)
            bpType=stm.internal.VariableReader.BlockParameter.Type;
            mask=sourceTypes=="mask workspace"|...
            sourceTypes==bpType|...
            getSimulinkBlockHandle(sourceTypes)~=-1;
        end
    end
end
