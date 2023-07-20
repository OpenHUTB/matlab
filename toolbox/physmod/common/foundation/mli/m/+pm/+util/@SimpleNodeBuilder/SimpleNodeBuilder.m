classdef SimpleNodeBuilder<pm.util.NodeBuilder








    methods
        function sHelper=SimpleNodeBuilder(mfunc)
            sHelper=sHelper@pm.util.NodeBuilder(mfunc);
        end
    end
    methods(Sealed=true)
        function simpNode=getObject(thisHelper,identifier)


            simpNode=feval(thisHelper.FunctionHandle,identifier);
            if(~isempty(simpNode))&&(~isa(simpNode,'pm.util.SimpleNode'))
                pm_error('physmod:common:foundation:mli:util:nodebuilder:InvalidNode',...
                'pm.util.SimpleNode',class(simpNode));
            end
        end
    end
end
