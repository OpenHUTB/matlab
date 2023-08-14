



classdef StateflowBackTrackingConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Every non-terminating junction must have exactly one unconditional transition exiting it';
        end

        function obj=StateflowBackTrackingConstraint
            obj.setEnum('StateflowBackTracking');
            obj.setCompileNeeded(0);
            obj.setFatal(true);
        end

        function out=check(aObj)
            out=[];
            outgoing=aObj.ParentJunction().getOutgoingTransitions();
            if~isempty(outgoing)
                numUnconditional=0;
                for i=1:numel(outgoing)
                    if~outgoing(i).HasCondition()
                        numUnconditional=numUnconditional+1;
                    end
                end




                if isa(aObj.ParentJunction().getUDDObject().Subviewer,...
                    'Stateflow.TruthTable')&&(numel(outgoing)==1)
                    return;
                end

                if numUnconditional>1
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'StateflowBackTracking',...
                    aObj.ParentBlock().getName());
                    return;
                elseif numUnconditional==0
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'StateflowBackTracking',...
                    aObj.ParentBlock().getName());
                    return;
                end
            end
        end

    end
end
