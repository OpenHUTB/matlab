

classdef StateflowLoopAfterConstraint<slci.compatibility.Constraint


    methods

        function out=getDescription(aObj)%#ok
            out=['A supported stateflow loop back-edge transition'...
            ,'must define only one action that increments the '...
            ,'scalar induction variable with a literal value.'];

        end


        function obj=StateflowLoopAfterConstraint
            obj.setEnum('StateflowLoopAfter');
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

            isSupported=aObj.getOwner().isSupportedLoopAfter();
            if~isSupported
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowLoopAfter',...
                aObj.ParentBlock().getName(),...
                aObj.getOwner().getClassNames());
                return;
            end
        end

    end
end
