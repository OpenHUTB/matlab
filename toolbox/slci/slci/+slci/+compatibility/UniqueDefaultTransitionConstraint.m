


classdef UniqueDefaultTransitionConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='A control flow may only have 1 default transition';
        end

        function obj=UniqueDefaultTransitionConstraint
            obj.setEnum('UniqueDefaultTransition');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            transitions=aObj.getOwner.getDefaultTransitions();
            if numel(transitions)>1
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'UniqueDefaultTransition',...
                aObj.ParentBlock().getName());
                return;
            end
        end

    end
end

