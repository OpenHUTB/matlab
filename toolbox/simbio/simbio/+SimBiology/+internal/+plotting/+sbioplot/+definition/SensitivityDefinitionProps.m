classdef SensitivityDefinitionProps<SimBiology.internal.plotting.sbioplot.definition.DefinitionProps

    properties(Access=public)
        Inputs={};
        Outputs={};
    end




    methods(Access=public)
        function info=getStruct(obj)
            info=getStruct@SimBiology.internal.plotting.sbioplot.definition.DefinitionProps(obj);
            info.Inputs=obj.Inputs;
            info.Outputs=obj.Outputs;
        end
    end

    methods(Access=?SimBiology.internal.plotting.sbioplot.definition.DefinitionProps)
        function configureSingleObjectFromStruct(obj,input)
            configureSingleObjectFromStruct@SimBiology.internal.plotting.sbioplot.definition.DefinitionProps(obj,input);
            set(obj,'Inputs',input.Inputs,...
            'Outputs',input.Outputs);
        end
    end

end