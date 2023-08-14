

classdef StateflowDefaultTransitionConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Stateflow chart or state substates must have a default transition.';
        end

        function obj=StateflowDefaultTransitionConstraint
            obj.setEnum('StateflowDefaultTransition');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            uddObject=aObj.ParentState.getUDDObject;
            substates=aObj.ParentState.getSubstates;


            isParallel=false;
            if(~isempty(substates))
                isParallel=strcmpi(substates(1).getUDDObject.Type,'AND');
            end




            if isempty(uddObject.defaultTransitions)...
                &&~isempty(substates)...
                &&~isParallel
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowDefaultTransition',...
                aObj.ParentBlock.getName());
                return;
            end
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin)
            if status
                status='Pass';
            else
                status='Warn';
            end
            enum=aObj.getEnum();
            classnames=aObj.getOwner.getClassNames;
            Information=DAStudio.message(['Slci:compatibility:',enum,'ConstraintInfo']);
            SubTitle=DAStudio.message(['Slci:compatibility:',enum,'ConstraintSubTitle']);
            RecAction=DAStudio.message(['Slci:compatibility:',enum,'ConstraintRecAction'],classnames);
            StatusText=DAStudio.message(['Slci:compatibility:',enum,'Constraint',status],classnames);
        end

    end
end
