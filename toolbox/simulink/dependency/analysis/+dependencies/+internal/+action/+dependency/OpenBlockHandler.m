classdef OpenBlockHandler<dependencies.internal.action.DependencyHandler





    properties(Constant)
        Types=["SFunctionBuilder","Stateflow"];


    end

    methods
        function unhilite=openUpstream(~,dependency)
            location=dependency.UpstreamComponent.Path;
            hilite_system(location,"find");
            open_system(location);
            unhilite=@()hilite_system(location,"none");
        end
    end
end
