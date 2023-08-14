classdef SimulationTargetHandler<dependencies.internal.action.DependencyHandler




    properties(Constant)
        Types="SimulationTarget";
    end

    methods
        function unhilite=openUpstream(~,dependency)

            unhilite=@()[];

            cs=getConfigSet(dependency);

            if~isempty(cs)
                configset.showParameterGroup(cs,{'Simulation Target'});
            end
        end
    end
end
