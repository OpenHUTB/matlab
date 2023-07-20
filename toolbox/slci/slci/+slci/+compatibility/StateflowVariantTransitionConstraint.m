

classdef StateflowVariantTransitionConstraint<slci.compatibility.Constraint


    methods

        function out=getDescription(aObj)%#ok
            out='Transitions configured as Variant transitions are not supported';
        end


        function obj=StateflowVariantTransitionConstraint
            obj.setEnum('StateflowVariantTransition');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];

            assert(isa(aObj.getOwner(),'slci.stateflow.Transition'));
            transition=aObj.getOwner();
            transitionObject=transition.getUDDObject();
            if transitionObject.IsVariant
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowVariantTransition',...
                aObj.ParentBlock().getName());
            end
        end
    end
end
