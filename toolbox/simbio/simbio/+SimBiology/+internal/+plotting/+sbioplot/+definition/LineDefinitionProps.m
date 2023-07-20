classdef LineDefinitionProps<SimBiology.internal.plotting.sbioplot.definition.CategoricalDefinitionProps

    properties(Access=public)
        MatchGroupsAcrossDataSources=true;
    end




    methods(Access=public)
        function info=getStruct(obj)
            info=getStruct@SimBiology.internal.plotting.sbioplot.definition.CategoricalDefinitionProps(obj);
            info.MatchGroupsAcrossDataSources=obj.MatchGroupsAcrossDataSources;
        end
    end

    methods(Access=?SimBiology.internal.plotting.sbioplot.definition.DefinitionProps)
        function configureSingleObjectFromStruct(obj,input)
            configureSingleObjectFromStruct@SimBiology.internal.plotting.sbioplot.definition.CategoricalDefinitionProps(obj,input);
            set(obj,'MatchGroupsAcrossDataSources',input.MatchGroupsAcrossDataSources);
        end
    end

end