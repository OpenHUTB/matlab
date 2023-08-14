classdef OpenBlockParameterHandler<dependencies.internal.action.DependencyHandler





    properties(Constant)
        Types="InterpretedMATLABFcn";
    end

    methods
        function unhilite=openUpstream(~,dependency)
            component=dependency.UpstreamComponent.Path;
            hilite_system(component,"find");
            unhilite=@()hilite_system(component,'none');
            open_system(component,"parameter");
        end
    end
end
