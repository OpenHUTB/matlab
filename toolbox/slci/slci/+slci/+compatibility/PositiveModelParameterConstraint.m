


classdef PositiveModelParameterConstraint<slci.compatibility.Constraint

    properties(Access=private)
        fParameterName='';
        fSupportedValues={};
        inverseLogic=false;
    end

    methods(Access=private)

        function setParameterName(aObj,aParameterName)
            aObj.fParameterName=aParameterName;
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
            out=aObj.getParameterName;
        end

        function out=getParameterName(aObj)
            out=aObj.fParameterName;
        end

        function out=getSupportedValues(aObj)
            out=aObj.fSupportedValues;
        end

        function setInverseLogic(aObj,flag)
            aObj.inverseLogic=flag;
        end


        function out=hasAutoFix(~)
            out=true;
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin)
            RecAction='';
            strType={'Pane','Path','Type','Prompt','ParentPane'};
            param=aObj.getParameterName;
            ui={DAStudio.message(['Slci:configsetMA:',param,strType{1}]),...
            DAStudio.message(['Slci:configsetMA:',param,strType{2}]),...
            DAStudio.message(['Slci:configsetMA:',param,strType{3}]),...
            DAStudio.message(['Slci:configsetMA:',param,strType{4}]),...
            };
            if~isempty(varargin)&&strcmp(varargin{1},'fix')
                supportedValues=aObj.getSupportedValues;
                supportedValues=aObj.getListOfStrings(supportedValues(1),true);
            else
                supportedValues=aObj.getListOfStrings(aObj.getSupportedValues,true);
            end
            if isempty(supportedValues)||strcmpi(supportedValues,'''''')
                supportedValues='""';
            end
            if status
                if strcmp(ui{3},DAStudio.message('Slci:compatibility:checkbox'))
                    if strcmp(aObj.getSupportedValues{1},'off')
                        if aObj.inverseLogic
                            StatusText=DAStudio.message('Slci:compatibility:SLCIPassStrSelected',ui{2});
                        else
                            StatusText=DAStudio.message('Slci:compatibility:SLCIPassStrCleared',ui{2});
                        end
                    else
                        if aObj.inverseLogic
                            StatusText=DAStudio.message('Slci:compatibility:SLCIPassStrCleared',ui{2});
                        else
                            StatusText=DAStudio.message('Slci:compatibility:SLCIPassStrSelected',ui{2});
                        end
                    end
                else
                    StatusText=DAStudio.message('Slci:compatibility:SLCIPassStr',ui{2},supportedValues);
                end
            else
                encodedModelName=modeladvisorprivate('HTMLjsencode',get_param(aObj.ParentModel().getName,'Name'),'encode');
                encodedModelName=[encodedModelName{:}];
                if~isempty(ui{1})
                    linkStr=['<a href = "matlab: modeladvisorprivate openCSAndHighlight ',...
                    [encodedModelName,' ''',param,''' '],'">',ui{2},'</a>'];
                else
                    linkStr=ui{2};
                end
                if strcmp(ui{3},DAStudio.message('Slci:compatibility:checkbox'))
                    if strcmp(aObj.getSupportedValues{1},'off')
                        if aObj.inverseLogic
                            RecAction=DAStudio.message('Slci:compatibility:SLCIRecActionCheckBoxSelectStr',linkStr);
                            StatusText=DAStudio.message('Slci:compatibility:SLCIWarnCheckBoxSelectStr',ui{2});
                        else
                            RecAction=DAStudio.message('Slci:compatibility:SLCIRecActionCheckBoxClearStr',linkStr);
                            StatusText=DAStudio.message('Slci:compatibility:SLCIWarnCheckBoxClearStr',ui{2});
                        end
                    else
                        if aObj.inverseLogic
                            RecAction=DAStudio.message('Slci:compatibility:SLCIRecActionCheckBoxClearStr',linkStr);
                            StatusText=DAStudio.message('Slci:compatibility:SLCIWarnCheckBoxClearStr',ui{2});
                        else
                            RecAction=DAStudio.message('Slci:compatibility:SLCIRecActionCheckBoxSelectStr',linkStr);
                            StatusText=DAStudio.message('Slci:compatibility:SLCIWarnCheckBoxSelectStr',ui{2});
                        end
                    end
                else
                    StatusText=DAStudio.message('Slci:compatibility:SLCIWarnStr',ui{2},supportedValues);
                    RecAction=DAStudio.message('Slci:compatibility:SLCIRecActionStr',linkStr,supportedValues);
                end
            end
            if(strcmp(supportedValues,'""'))
                supportedValues='"" (i.e. unspecified)';
            end
            if strcmp(ui{3},DAStudio.message('Slci:compatibility:checkbox'))
                if strcmp(supportedValues,'''on''')
                    if~aObj.inverseLogic
                        Information=DAStudio.message('Slci:compatibility:SLCIInfoStrCheckBoxSelected',ui{2});
                    else
                        Information=DAStudio.message('Slci:compatibility:SLCIInfoStrCheckBoxCleared',ui{2});
                    end
                else
                    if~aObj.inverseLogic
                        Information=DAStudio.message('Slci:compatibility:SLCIInfoStrCheckBoxCleared',ui{2});
                    else
                        Information=DAStudio.message('Slci:compatibility:SLCIInfoStrCheckBoxSelected',ui{2});
                    end
                end
            else
                Information=DAStudio.message('Slci:compatibility:SLCIInfoStr',ui{2},supportedValues);
            end
            SubTitle=DAStudio.message('Slci:compatibility:SLCISubTitleStr',['''',ui{4},'''']);
        end

        function obj=PositiveModelParameterConstraint(aFatal,aParameterName,varargin)
            obj.setCompileNeeded(0);
            obj.setFatal(aFatal);
            obj.setParameterName(aParameterName);
            for i=1:nargin-2
                obj.addSupportedValue(varargin{i});
            end
            obj.setEnum('PositiveModelParameter');
        end

        function out=check(aObj)
            out=[];
            parameterName=aObj.getParameterName();
            parameterValue=aObj.ParentModel().getParam(parameterName);
            if strcmpi(class(parameterValue),'double')
                parameterValue=num2str(parameterValue);
            end
            supportedValues=aObj.getSupportedValues;
            for idx=1:numel(supportedValues)
                if strcmpi(parameterValue,supportedValues{idx})
                    return
                end
            end
            out=aObj.getIncompatibility();
        end


        function out=fix(aObj,~)
            supportedValues=aObj.getSupportedValues;


            parameterName=aObj.getParameterName();
            try
                aObj.ParentModel().setParam(parameterName,supportedValues{1});
                out=true;
            catch

                out=false;
            end

        end
    end
end
