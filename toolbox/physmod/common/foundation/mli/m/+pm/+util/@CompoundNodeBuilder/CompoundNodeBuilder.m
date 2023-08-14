classdef CompoundNodeBuilder<pm.util.NodeBuilder







    methods
        function cHelper=CompoundNodeBuilder(mfunc)
            cHelper=cHelper@pm.util.NodeBuilder(mfunc);
        end
    end
    methods(Sealed=true)
        function compNode=getObject(thisHelper,identifier)


            compNode=feval(thisHelper.FunctionHandle,identifier);
            if(~isempty(compNode))&&(~isa(compNode,'pm.util.CompoundNode'))
                pm_error('physmod:common:foundation:mli:util:nodebuilder:InvalidNode',...
                'pm.util.CompoundNode',class(compNode));
            end
        end
    end
end
