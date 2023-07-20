classdef BaseWorkspace<stm.internal.VariableReader.Base

    properties(Constant)
        Type="base workspace";
    end

    methods
        function this=BaseWorkspace(param,model)
            if nargin==0
                param=struct;
                model="";
            end

            this=this@stm.internal.VariableReader.Base(param,model);
        end

        function value=getCurrentValue(this)
            value=evalin('base',this.Param.Name);
        end

        function property=getSimInProperty(this)
            property=this.getSimInVariable;
        end
    end
end
