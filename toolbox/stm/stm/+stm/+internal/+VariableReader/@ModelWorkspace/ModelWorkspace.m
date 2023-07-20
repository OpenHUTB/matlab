classdef ModelWorkspace<stm.internal.VariableReader.Base

    properties(Constant)
        Type="model workspace";
    end

    methods
        function this=ModelWorkspace(param,model)
            this=this@stm.internal.VariableReader.Base(param,model);
        end

        function workspace=getWorkspace(this)
            workspace=get_param(this.Model,'modelworkspace');
        end

        function workspace=getVariableWorkspace(this)
            workspace=this.Model;
        end

        function value=getCurrentValue(this)
            value=evalin(this.getWorkspace,this.Param.Name);
        end

        function property=getSimInProperty(this)
            property=this.getSimInVariable;
        end
    end
end
