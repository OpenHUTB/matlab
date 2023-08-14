classdef HiliteManager<handle





    properties(Constant)
        Instance=dependencies.internal.action.dependency.HiliteManager;
    end

    properties(Access=private)
        Unhilite(1,1)function_handle=@()[];
    end

    methods
        function hilite(this,node,dependency,handlerOpenFunc)
            registry=dependencies.internal.Registry.Instance;
            depHandlers=registry.DependencyHandlers';

            this.doUnhilite();
            dependencies.internal.action.open(node);

            basetype=dependency.Type.Base.ID;

            for handler=depHandlers
                if ismember(basetype,handler.Types)
                    unhilite=handlerOpenFunc(handler,dependency);
                    this.setNextUnhilite(unhilite);
                    return
                end
            end

            nodeHandlers=registry.NodeHandlers';

            for handler=nodeHandlers
                if apply(handler.NodeFilter,node)
                    depHandler=handler.DefaultDependencyHandler;
                    unhilite=handlerOpenFunc(depHandler,dependency);
                    this.setNextUnhilite(unhilite);
                    return
                end
            end
        end
    end

    methods(Access=private)
        function this=HiliteManager
        end

        function doUnhilite(this)
            try %#ok<TRYNC>
                this.Unhilite();
            end
        end

        function setNextUnhilite(this,func)
            this.Unhilite=func;
        end
    end
end
