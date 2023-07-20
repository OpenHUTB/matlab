


classdef NegativeModelParameterConstraint<slci.compatibility.Constraint

    properties(Access=private)
        fParameterName='';
        fUnsupportedValues={};
        inverseLogic=false;
    end

    methods(Access=private)

        function setParameterName(aObj,aParameterName)
            aObj.fParameterName=aParameterName;
        end

        function addUnsupportedValue(aObj,aUnsupportedValue)
            aObj.fUnsupportedValues{end+1}=aUnsupportedValue;
        end

    end

    methods(Access=protected)

        function out=getIncompatibilityTextOrObj(aObj,aTextOrObj)
            out=getIncompatibilityTextOrObj@slci.compatibility.Constraint(...
            aObj,aTextOrObj,'UnsupportedModelParameterValueNeg',...
            aObj.ParentModel().getName(),aObj.getParameterName(),...
            aObj.getListOfStrings(aObj.getUnsupportedValues,false));
        end

    end

    methods

        function out=getID(aObj)
            out=aObj.getParameterName;
        end

        function out=getUnsupportedValues(aObj)
            out=aObj.fUnsupportedValues;
        end

        function out=getParameterName(aObj)
            out=aObj.fParameterName;
        end

        function setInverseLogic(aObj,flag)
            aObj.inverseLogic=flag;
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

            if status
                if strcmp(ui{3},DAStudio.message('Slci:compatibility:checkbox'))
                    if strcmp(aObj.getUnsupportedValues{1},'off')
                        if~aObj.inverseLogic
                            StatusText=DAStudio.message('Slci:compatibility:SLCIPassStrSelected',ui{2});
                        else
                            StatusText=DAStudio.message('Slci:compatibility:SLCIPassStrCleared',ui{2});
                        end
                    else
                        if~aObj.inverseLogic
                            StatusText=DAStudio.message('Slci:compatibility:SLCIPassStrCleared',ui{2});
                        else
                            StatusText=DAStudio.message('Slci:compatibility:SLCIPassStrSelected',ui{2});
                        end
                    end
                else
                    StatusText=DAStudio.message('Slci:compatibility:SLCIPassStrNeg',ui{2},aObj.getListOfStrings(aObj.getUnsupportedValues,true));
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
                        if~aObj.inverseLogic
                            RecAction=DAStudio.message('Slci:compatibility:SLCIRecActionCheckBoxClearStr',linkStr);
                            StatusText=DAStudio.message('Slci:compatibility:SLCIWarnCheckBoxClearStr',ui{2});
                        else
                            RecAction=DAStudio.message('Slci:compatibility:SLCIRecActionCheckBoxSelectStr',linkStr);
                            StatusText=DAStudio.message('Slci:compatibility:SLCIWarnCheckBoxSelectStr',ui{2});
                        end
                    else
                        if~aObj.inverseLogic
                            RecAction=DAStudio.message('Slci:compatibility:SLCIRecActionCheckBoxSelectStr',linkStr);
                            StatusText=DAStudio.message('Slci:compatibility:SLCIWarnCheckBoxSelectStr',ui{2});
                        else
                            RecAction=DAStudio.message('Slci:compatibility:SLCIRecActionCheckBoxClearStr',linkStr);
                            StatusText=DAStudio.message('Slci:compatibility:SLCIWarnCheckBoxClearStr',ui{2});
                        end
                    end
                else
                    StatusText=DAStudio.message('Slci:compatibility:SLCIWarnStrNeg',ui{2},aObj.getListOfStrings(aObj.getUnsupportedValues,true));
                    RecAction=DAStudio.message('Slci:compatibility:SLCIRecActionStrNeg',linkStr,aObj.getListOfStrings(aObj.getUnsupportedValues,true));
                end
            end
            if strcmp(ui{3},DAStudio.message('Slci:compatibility:checkbox'))
                if strcmp(aObj.getListOfStrings(aObj.getUnsupportedValues,true),'''on''')
                    if~aObj.inverseLogic
                        Information=DAStudio.message('Slci:compatibility:SLCIInfoStrCheckBoxCleared',ui{2});
                    else
                        Information=DAStudio.message('Slci:compatibility:SLCIInfoStrCheckBoxSelected',ui{2});
                    end
                else
                    if~aObj.inverseLogic
                        Information=DAStudio.message('Slci:compatibility:SLCIInfoStrCheckBoxSelected',ui{2});
                    else
                        Information=DAStudio.message('Slci:compatibility:SLCIInfoStrCheckBoxCleared',ui{2});
                    end
                end
            else
                Information=DAStudio.message('Slci:compatibility:SLCIInfoStrNeg',ui{2},aObj.getListOfStrings(aObj.getUnsupportedValues,true));
            end
            SubTitle=DAStudio.message('Slci:compatibility:SLCISubTitleStr',['''',ui{4},'''']);

        end

        function obj=NegativeModelParameterConstraint(aFatal,aParameterName,varargin)
            obj.setCompileNeeded(0);
            obj.setFatal(aFatal);
            obj.setParameterName(aParameterName);
            for i=1:nargin-2
                obj.addUnsupportedValue(varargin{i});
            end
            obj.setEnum('NegativeModelParameter');
        end

        function out=check(aObj)
            out=[];
            parameterName=aObj.getParameterName();
            parameterValue=aObj.ParentModel().getParam(parameterName);
            unsupportedValues=aObj.getUnsupportedValues();
            for idx=1:numel(unsupportedValues)
                if strcmpi(parameterValue,unsupportedValues{idx})
                    out=aObj.getIncompatibility();
                    return
                end
            end
        end

    end
end
