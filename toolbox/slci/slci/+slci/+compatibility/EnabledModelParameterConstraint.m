


classdef EnabledModelParameterConstraint<slci.compatibility.Constraint

    properties(Access=private)
        fParameterName='';
        fSupportedValues={};
    end

    methods(Access=private)

        function setParameterName(aObj,aParameterName)
            aObj.fParameterName=aParameterName;
        end

        function out=getSupportedValues(aObj)
            out=aObj.fSupportedValues;
        end

        function addSupportedValue(aObj,aSupportedValue)
            aObj.fSupportedValues{end+1}=aSupportedValue;
        end

    end

    methods(Access=protected)

        function out=getIncompatibilityTextOrObj(aObj,aTextOrObj)
            out=getIncompatibilityTextOrObj@slci.compatibility.Constraint(...
            aObj,aTextOrObj,'UnsupportedModelParameterValuePos',...
            aObj.ParentModel().getName(),aObj.getParameterName(),...
            aObj.getListOfStrings(aObj.getSupportedValues,false));
        end

    end

    methods
        function out=getID(aObj)
            out=[aObj.enum,'_',aObj.getParameterName];
        end

        function out=getParameterName(aObj)
            out=aObj.fParameterName;
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,~,varargin)
            SubTitle='';
            Information='';
            strType={'Pane','Path'};
            param=aObj.getParameterName;
            ui={DAStudio.message(['Slci:configsetMA:',param,strType{1}]),...
            DAStudio.message(['Slci:configsetMA:',param,strType{2}]),...
            };

            encodedModelName=modeladvisorprivate('HTMLjsencode',get_param(aObj.ParentModel().getName,'Name'),'encode');
            encodedModelName=[encodedModelName{:}];
            if~isempty(ui{1})
                linkStr=['<a href = "matlab: modeladvisorprivate openCSAndHighlight ',...
                [encodedModelName,' ''',param,''' '],'">',ui{2},'</a>'];
            else
                linkStr=ui{2};
            end
            StatusText=DAStudio.message('Slci:compatibility:EnabledModelParameterConstraintWarn',linkStr);
            RecAction=DAStudio.message('Slci:compatibility:EnabledModelParameterConstraintRecAction',linkStr);
        end

        function obj=EnabledModelParameterConstraint(aFatal,aParameterName,varargin)
            obj.setCompileNeeded(0);
            obj.setFatal(aFatal);
            obj.setParameterName(aParameterName);
        end

        function out=check(aObj)
            out=[];
            parameterName=aObj.getParameterName();
            try
                cs=getActiveConfigSet(aObj.ParentModel().getHandle);
                csEnabled=slprivate('slCSPropGUIQuickMapping',cs,parameterName,'Param2UI',1);
                if csEnabled.Enabled
                    return;
                end
                out=aObj.getIncompatibility();
            catch ME %#ok
            end
        end

        function out=hasAutoFix(~)
            out=true;
        end

        function out=fix(aObj,~)
            out=false;
            supportedValues=aObj.getSupportedValues;
            if numel(supportedValues)==1
                parameterName=aObj.getParameterName();
                try
                    aObj.ParentModel().setParam(parameterName,supportedValues{1});
                    out=true;
                catch ME %#ok
                end
            end
        end
    end
end
