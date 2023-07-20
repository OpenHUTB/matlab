

classdef StateflowLoopBodyConstraint<slci.compatibility.Constraint


    methods

        function out=getDescription(aObj)%#ok
            out=['A supported stateflow loop body transition'...
            ,'must not redefine the induction variable'];

        end


        function obj=StateflowLoopBodyConstraint
            obj.setEnum('StateflowLoopBody');
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

            isSupported=aObj.getOwner().isSupportedLoopBody();
            if~isSupported
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowLoopBody',...
                aObj.ParentBlock().getName(),...
                aObj.getOwner().getClassNames());
                return;
            end
        end

    end
end
