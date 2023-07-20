


classdef StateflowUnconditionalTransitionConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Every unconditional transition must be last in execution order';
        end

        function obj=StateflowUnconditionalTransitionConstraint
            obj.setEnum('StateflowUnconditionalTransition');
            obj.setCompileNeeded(0);
            obj.setFatal(true);
        end

        function out=check(aObj)
            out=[];
            outgoing=aObj.ParentJunction().getOutgoingTransitions();
            if~isempty(outgoing)
                orderUnconditional=0;
                numUnconditional=0;
                for i=1:numel(outgoing)
                    if~outgoing(i).HasCondition()
                        orderUnconditional=i;
                        numUnconditional=numUnconditional+1;
                    end
                end
                if orderUnconditional>0&&...
                    orderUnconditional<numel(outgoing)&&...
                    numUnconditional<2



                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'StateflowUnconditionalTransitionNotLast',...
                    aObj.ParentBlock().getName());
                    return;
                end
            end
        end

    end
end

