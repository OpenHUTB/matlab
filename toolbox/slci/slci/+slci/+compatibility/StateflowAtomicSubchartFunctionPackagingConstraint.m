




classdef StateflowAtomicSubchartFunctionPackagingConstraint<slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok
            out='Stateflow atomic subchart should have the InlineOption setting set to Inline';
        end


        function obj=StateflowAtomicSubchartFunctionPackagingConstraint
            obj.setEnum('StateflowAtomicSubchartFunctionPackaging');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];
            atomicSubchartUddObj=aObj.getOwner().getUDDObject();
            if~strcmpi(get_param(atomicSubchartUddObj.Path,...
                'RTWSystemCode'),...
                'Inline')
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowAtomicSubchartFunctionPackaging',...
                aObj.ParentBlock().getName());
                return;
            end
        end
    end
end
