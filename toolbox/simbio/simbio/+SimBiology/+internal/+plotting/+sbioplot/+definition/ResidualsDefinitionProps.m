classdef ResidualsDefinitionProps<SimBiology.internal.plotting.sbioplot.definition.DefinitionProps




    methods(Static)
        function const=TIME()
            const='time';
        end

        function const=GROUP()
            const='group';
        end

        function const=PREDICTIONS()
            const='predictions';
        end

        function const=RESIDUALS_TYPE()
            const='Residuals Type';
        end
    end

    properties(Access=public)
        XAxis=SimBiology.internal.plotting.sbioplot.definition.ResidualsDefinitionProps.TIME;
        ResidualsCategory=SimBiology.internal.plotting.categorization.CategoryDefinition.empty;
    end




    methods(Access=public)
        function info=getStruct(obj)
            info=getStruct@SimBiology.internal.plotting.sbioplot.definition.DefinitionProps(obj);
            info.XAxis=obj.XAxis;
            info.ResidualsCategory=obj.ResidualsCategory.getStruct();
        end
    end

    methods(Access=?SimBiology.internal.plotting.sbioplot.definition.DefinitionProps)
        function configureSingleObjectFromStruct(obj,input)
            configureSingleObjectFromStruct@SimBiology.internal.plotting.sbioplot.definition.DefinitionProps(obj,input);
            set(obj,'XAxis',input.XAxis,...
            'ResidualsCategory',SimBiology.internal.plotting.categorization.CategoryDefinition(input.ResidualsCategory));
        end
    end
end