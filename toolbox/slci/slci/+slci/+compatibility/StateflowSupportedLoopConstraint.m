


classdef StateflowSupportedLoopConstraint<slci.compatibility.Constraint


    methods

        function out=getDescription(aObj)%#ok
            out=['A supported stateflow loop header junction must have '...
            ,'two incoming transition: (1) defines the induction '...
            ,'initial value and (2) defines the induction step. '...
            ,'The condition must have a < or <= and must be bounded.'];
        end


        function obj=StateflowSupportedLoopConstraint
            obj.setEnum('StateflowSupportedLoop');
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

            isUnsupported=aObj.getOwner().isLoopHeader()...
            &&~aObj.getOwner().isSupportedLoop();
            if isUnsupported
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowSupportedLoop',...
                aObj.ParentBlock().getName(),...
                aObj.getOwner().getClassNames());
                return;
            end
        end

    end
end
