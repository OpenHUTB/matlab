classdef FitPlotDefinitionProps<SimBiology.internal.plotting.sbioplot.definition.DefinitionProps

    properties(Access=public)
        Type='individual';
        Layout='trellis';
        Categories=SimBiology.internal.plotting.categorization.CategoryDefinition.empty;
    end




    methods(Static)
        function const=INDIVIDUAL()
            const='individual';
        end

        function const=POPULATION()
            const='population';
        end

        function const=TRELLIS()
            const='trellis';
        end

        function const=ONE_AXES()
            const='One Axes';
        end
    end




    methods(Access=public)
        function info=getStruct(obj)
            info=getStruct@SimBiology.internal.plotting.sbioplot.definition.DefinitionProps(obj);
            info.Type=obj.Type;
            info.Layout=obj.Layout;
            info.Categories=obj.Categories.getStruct();
        end
    end

    methods(Access=?SimBiology.internal.plotting.sbioplot.definition.DefinitionProps)
        function configureSingleObjectFromStruct(obj,input)
            configureSingleObjectFromStruct@SimBiology.internal.plotting.sbioplot.definition.DefinitionProps(obj,input);
            set(obj,'Type',input.Type,...
            'Layout',input.Layout,...
            'Categories',SimBiology.internal.plotting.categorization.CategoryDefinition(input.Categories));
        end
    end

end