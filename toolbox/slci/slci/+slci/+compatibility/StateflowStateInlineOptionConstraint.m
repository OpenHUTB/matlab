


classdef StateflowStateInlineOptionConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Stateflow states should have the InlineOption setting set to Inline';
        end

        function obj=StateflowStateInlineOptionConstraint
            obj.setEnum('StateflowStateInlineOption');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            stateUddObj=aObj.getOwner().getUDDObject();
            if~strcmpi(stateUddObj.InlineOption,'Inline')
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowStateInlineOption',...
                aObj.ParentBlock().getName());
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
            Information=DAStudio.message(['Slci:compatibility:',enum,'ConstraintInfo']);
            SubTitle=DAStudio.message(['Slci:compatibility:',enum,'ConstraintSubTitle']);
            RecAction=DAStudio.message(['Slci:compatibility:',enum,'ConstraintRecAction']);
            StatusText=DAStudio.message(['Slci:compatibility:',enum,'Constraint',status]);
        end


        function out=hasAutoFix(~)
            out=true;
        end

        function out=fix(aObj,~)
            out=aObj.setOwnerSetting('InlineOption','Inline');
        end

    end
end
