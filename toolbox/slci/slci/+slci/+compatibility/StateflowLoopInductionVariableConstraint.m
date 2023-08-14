

classdef StateflowLoopInductionVariableConstraint<slci.compatibility.Constraint


    methods

        function out=getDescription(aObj)%#ok
            out=['A supported stateflow loop has unsupported'...
            ,'loop induction variable in the for loop condition'];
        end


        function obj=StateflowLoopInductionVariableConstraint
            obj.setEnum('StateflowLoopInductionVariable');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
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


        function out=check(aObj)
            out=[];


            assert(isa(aObj.getOwner(),'slci.stateflow.Transition'));
            isLoopCondition=aObj.getOwner().isLoopCondTransition();
            if isLoopCondition
                isSupported=aObj.getOwner().hasSupportedLoopInductionVar();
                if~isSupported
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'StateflowLoopInductionVariable',...
                    aObj.ParentBlock().getName());
                    return;
                end
            end
        end
    end
end
