classdef ModelDependenciesParameterHandler<dependencies.internal.action.DependencyHandler




    properties(Constant)
        Types="ModelReferenceDependency";
    end

    methods
        function unhilite=openUpstream(~,dependency)
            unhilite=@()[];

            [~,modelName,~]=fileparts(dependency.UpstreamNode.Location{1});
            activeConfigSet=getActiveConfigSet(modelName);
            if~isempty(activeConfigSet)
                configset.showParameterGroup(activeConfigSet,{'Model Referencing'})
                configset.highlightParameter(activeConfigSet,'ModelDependencies')
                unhilite=@()configset.clearParameterHighlights(activeConfigSet);
            end
        end
    end
end
