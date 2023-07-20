


classdef ERTTargetConstraint<slci.compatibility.Constraint

    methods(Access=protected)

        function out=getIncompatibilityTextOrObj(aObj,aTextOrObj)
            out=getIncompatibilityTextOrObj@slci.compatibility.Constraint(...
            aObj,aTextOrObj,'IsERTTarget',aObj.ParentModel().getName());
        end

    end

    methods

        function obj=ERTTargetConstraint(varargin)
            obj.setEnum('ERTTarget');
            obj.setCompileNeeded(0);
        end

        function out=check(aObj)
            out=[];
            cs=getActiveConfigSet(aObj.ParentModel().getHandle());
            if~strcmpi(get_param(cs,'IsERTTarget'),'on')
                out=aObj.getIncompatibility();
            end
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin)
            RecAction=DAStudio.message('Slci:compatibility:ERTTargetConstraintRecAction',aObj.ParentModel.getName);
            SubTitle=DAStudio.message('Slci:compatibility:ERTTargetConstraintSubTitle');
            Information=DAStudio.message('Slci:compatibility:ERTTargetConstraintInfo');
            if status
                StatusText=DAStudio.message('Slci:compatibility:ERTTargetConstraintPass');
            else
                StatusText=DAStudio.message('Slci:compatibility:ERTTargetConstraintWarn',aObj.ParentModel.getName);
            end
        end

    end
end
