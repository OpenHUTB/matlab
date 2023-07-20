


classdef StrictBusMsgConstraint<slci.compatibility.Constraint

    methods(Access=protected)

        function out=getIncompatibilityTextOrObj(aObj,aTextOrObj)
            out=getIncompatibilityTextOrObj@slci.compatibility.Constraint(...
            aObj,aTextOrObj,'UnsupportedModelParameterValuePos',...
            aObj.ParentModel().getName(),'StrictBusMsg',...
            'ErrorOnBusTreatedAsVector');
        end

    end

    methods

        function obj=StrictBusMsgConstraint()
            obj.setEnum('StrictBusMsg');
            obj.setCompileNeeded(0);
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin)
            encodedModelName=modeladvisorprivate('HTMLjsencode',get_param(aObj.ParentModel().getName,'Name'),'encode');
            encodedModelName=[encodedModelName{:}];

            linkStr1=['<a href = "matlab: modeladvisorprivate openCSAndHighlight ',...
            [encodedModelName,' ''','StrictBusMsg',''' '],'">',DAStudio.message('Slci:compatibility:StrictBusMsgConstraintParamPath1'),'</a>'];
            RecAction='';
            SubTitle=DAStudio.message('Slci:compatibility:StrictBusMsgConstraintSubTitle');
            Information=DAStudio.message('Slci:compatibility:StrictBusMsgConstraintInfo');

            if status
                StatusText=DAStudio.message('Slci:compatibility:StrictBusMsgConstraintPass');
            else
                StatusText=DAStudio.message('Slci:compatibility:StrictBusMsgConstraintWarn');
                RecAction=DAStudio.message('Slci:compatibility:StrictBusMsgConstraintRecAction',linkStr1);
            end
        end

        function out=check(aObj)
            out=[];
            parameterValue=aObj.ParentModel().getParam('StrictBusMsg');
            if strcmpi(parameterValue,'ErrorOnBusTreatedAsVector')
                return;
            end
            out=aObj.getIncompatibility();
        end

        function out=hasAutoFix(~)
            out=true;
        end

        function out=fix(aObj,~)
            out=false;
            try
                aObj.ParentModel().setParam('StrictBusMsg','ErrorOnBusTreatedAsVector');
                out=true;
            catch
            end
        end

    end
end
