classdef NodeBuilder










    properties(SetAccess=private)
FunctionHandle
    end
    methods
        function nfHelper=NodeBuilder(mfunc)
            nfHelper.FunctionHandle=mfunc;
        end

        function thisHelper=set.FunctionHandle(thisHelper,func)
            thisHelper.FunctionHandle=pm.util.function_handle(func);
        end

        function visNode=getObject(thisHelper,identifier)


            visNode=feval(thisHelper.FunctionHandle,identifier);
            if(~isempty(visNode))&&(~isa(visNode,'pm.util.Node'))
                pm_error('physmod:common:foundation:mli:util:nodebuilder:InvalidNode',...
                'pm.util.Node',class(visNode));
            end
        end
    end
end
