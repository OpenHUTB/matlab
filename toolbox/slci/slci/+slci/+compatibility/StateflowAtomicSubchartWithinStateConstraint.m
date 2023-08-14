



classdef StateflowAtomicSubchartWithinStateConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Stateflow states should not contain atomic subchart';
        end

        function obj=StateflowAtomicSubchartWithinStateConstraint
            obj.setEnum('StateflowAtomicSubchartWithinState');
            obj.setCompileNeeded(0);
            obj.setFatal(true);
        end

        function out=check(aObj)
            out=[];
            aStateUDDObj=aObj.getOwner().getUDDObject();
            if~isempty(slci.internal.getSFActiveObjs(aStateUDDObj.find(...
                '-isa','Stateflow.AtomicSubchart')))
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowAtomicSubchartWithinState',...
                aObj.getOwner().getName());
                return;
            end
        end
    end
end
