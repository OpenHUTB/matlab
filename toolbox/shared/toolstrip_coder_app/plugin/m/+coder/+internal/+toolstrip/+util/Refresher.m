classdef Refresher<handle


    properties
ctx
cps
        refreshOnlyToolstrip=false;
    end

    methods
        function obj=Refresher(studio,varargin)
            ctx=coder.internal.toolstrip.util.getCurrentAppContext(studio);
            if nargin>=2
                obj.refreshOnlyToolstrip=varargin{1};
            end
            if~isempty(ctx)

                obj.ctx=ctx;
            end

            cp=simulinkcoder.internal.CodePerspective.getInstance;
            obj.cps=cp.getFlag(studio.App.blockDiagramHandle,studio);
            if~isempty(obj.cps)
                obj.cps.active=false;
            end
        end

        function delete(obj)
            if~isempty(obj.ctx)
                obj.ctx.updateTypeChain();

            end

            if~obj.refreshOnlyToolstrip&&~isempty(obj.cps)
                obj.cps.active=true;
                obj.cps.reset();
            end
        end
    end
end

