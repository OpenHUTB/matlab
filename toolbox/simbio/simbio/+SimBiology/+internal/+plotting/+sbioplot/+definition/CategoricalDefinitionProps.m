classdef CategoricalDefinitionProps<SimBiology.internal.plotting.sbioplot.definition.DefinitionProps

    properties(Access=public)
        AutoAddAllStatesToLog=true;
        Categories=SimBiology.internal.plotting.categorization.CategoryDefinition.empty;
    end




    methods(Access=public)
        function info=getStruct(obj)
            info=getStruct@SimBiology.internal.plotting.sbioplot.definition.DefinitionProps(obj);
            info.AutoAddAllStatesToLog=obj.AutoAddAllStatesToLog;
            info.Categories=obj.Categories.getStruct();
        end
    end

    methods(Access=?SimBiology.internal.plotting.sbioplot.definition.DefinitionProps)
        function configureSingleObjectFromStruct(obj,input)
            configureSingleObjectFromStruct@SimBiology.internal.plotting.sbioplot.definition.DefinitionProps(obj,input);
            set(obj,'AutoAddAllStatesToLog',input.AutoAddAllStatesToLog,...
            'Categories',SimBiology.internal.plotting.categorization.CategoryDefinition(input.Categories));
        end
    end

end