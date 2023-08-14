


classdef ConditionallyExecuteInputsConstraint<slci.compatibility.Constraint

    methods(Access=protected)

        function out=getIncompatibilityTextOrObj(aObj,aTextOrObj)
            out=getIncompatibilityTextOrObj@slci.compatibility.Constraint(...
            aObj,aTextOrObj,'IsConditionallyExecuteInputs',aObj.ParentModel().getName());
        end

    end

    methods

        function obj=ConditionallyExecuteInputsConstraint(varargin)
            obj.setEnum('ConditionallyExecuteInputs');
            obj.setCompileNeeded(false);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            cs=getActiveConfigSet(aObj.ParentModel().getHandle());
            if strcmpi(get_param(cs,'ConditionallyExecuteInputs'),'on')
                if~strcmpi(get_param(cs,'LocalBlockOutputs'),'on')
                    out=aObj.getIncompatibility();
                end
            end
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin)
            RecAction=DAStudio.message('Slci:compatibility:ConditionallyExecuteInputsConstraintRecAction',aObj.ParentModel.getName,aObj.ParentModel.getName);
            SubTitle=DAStudio.message('Slci:compatibility:ConditionallyExecuteInputsConstraintSubTitle');
            Information=DAStudio.message('Slci:compatibility:ConditionallyExecuteInputsConstraintInfo');
            if status
                StatusText=DAStudio.message('Slci:compatibility:ConditionallyExecuteInputsConstraintPass');
            else
                StatusText=DAStudio.message('Slci:compatibility:ConditionallyExecuteInputsConstraintWarn',aObj.ParentModel.getName,aObj.ParentModel.getName);
            end
        end

    end
end
