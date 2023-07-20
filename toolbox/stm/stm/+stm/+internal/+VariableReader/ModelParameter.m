classdef ModelParameter<stm.internal.VariableReader.Base

    properties(Constant)
        Type="model parameter";
    end

    methods
        function this=ModelParameter(param,model)
            this=this@stm.internal.VariableReader.Base(param,model);
        end

        function value=getCurrentValue(~)

            value=[];
        end

        function property=getSimInProperty(this)
            property=arrayfun(@(r)...
            Simulink.Simulation.ModelParameter(r.Param.Name,r.getOverrideValue),...
            this);
        end
    end

    methods(Access=protected)
        function value=getParamValue(this)
            value=this.Param.Value;
        end
    end
end
