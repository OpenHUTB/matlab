


classdef FuncProtoCtrlConstraint<slci.compatibility.Constraint

    methods(Access=protected)

        function out=getIncompatibilityTextOrObj(aObj,aTextOrObj)
            out=getIncompatibilityTextOrObj@slci.compatibility.Constraint(...
            aObj,aTextOrObj,'CustomFuncProtoCtrl',...
            aObj.ParentModel().getName());
        end

    end

    methods

        function obj=FuncProtoCtrlConstraint()
            obj.setFatal(false);
            obj.setEnum('FuncProtoCtrl');
            obj.setCompileNeeded(0);
        end

        function out=check(aObj)
            out=[];
            funcProtoCtrl=aObj.ParentModel().getParam('RTWFcnClass');
            if~isempty(funcProtoCtrl)&&~isa(funcProtoCtrl,'RTW.FcnDefault')
                out=aObj.getIncompatibility();
            end
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin)
            RecAction=DAStudio.message('Slci:compatibility:FuncProtoCtrlConstraintRecAction');
            SubTitle=DAStudio.message('Slci:compatibility:FuncProtoCtrlConstraintSubTitle');
            Information=DAStudio.message('Slci:compatibility:FuncProtoCtrlConstraintInfo');
            if status
                StatusText=DAStudio.message('Slci:compatibility:FuncProtoCtrlConstraintPass');
            else
                StatusText=DAStudio.message('Slci:compatibility:FuncProtoCtrlConstraintWarn');
            end
        end

    end
end


