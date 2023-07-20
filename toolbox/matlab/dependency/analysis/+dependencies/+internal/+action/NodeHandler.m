classdef(Abstract)NodeHandler<handle&matlab.mixin.Heterogeneous




    properties(Abstract,Constant)
        NodeFilter(1,1)dependencies.internal.graph.NodeFilter
        DefaultDependencyHandler(1,1)dependencies.internal.action.DependencyHandler;
    end

    methods




        open(this,node);







        restore=edit(this,node);





        save(this,node);





        close(this,node);

    end

end
