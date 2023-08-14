classdef ActualVsPredictedDefinitionProps<SimBiology.internal.plotting.sbioplot.definition.DefinitionProps

    methods(Static)
        function const=INDIVIDUAL()
            const='Individual';
        end

        function const=POPULATION()
            const='Population';
        end

        function const=PARAMETER_TYPE()
            const='Parameter Type';
        end
    end

    properties(Access=public)
        ParameterTypeCategory=SimBiology.internal.plotting.categorization.CategoryDefinition.empty;
    end




    methods(Access=public)
        function info=getStruct(obj)
            info=getStruct@SimBiology.internal.plotting.sbioplot.definition.DefinitionProps(obj);
            info.ParameterTypeCategory=obj.ParameterTypeCategory.getStruct();
        end
    end

    methods(Access=?SimBiology.internal.plotting.sbioplot.definition.DefinitionProps)
        function configureSingleObjectFromStruct(obj,input)
            configureSingleObjectFromStruct@SimBiology.internal.plotting.sbioplot.definition.DefinitionProps(obj,input);
            set(obj,'ParameterTypeCategory',SimBiology.internal.plotting.categorization.CategoryDefinition(input.ParameterTypeCategory));
        end
    end

end