classdef HiliteBlockHandler<dependencies.internal.action.DependencyHandler





    properties(Constant)
        Types=strings(1,0);
    end

    methods
        function unhilite=openDownstream(~,dependency)
            unhilite=i_tryToHilite(dependency.DownstreamComponent);
        end

        function unhilite=openUpstream(~,dependency)
            unhilite=i_tryToHilite(dependency.UpstreamComponent);
        end
    end
end

function unhilite=i_tryToHilite(component)
    try
        hilite_system(component.Path,"find");
        unhilite=@()hilite_system(component.Path,"none");
    catch
        unhilite=@()[];
    end
end
