classdef MaskParameter
































    properties
        Prompt='';
        VarName='';
        Value='';
        Type='edit';
        Evaluate='off';
        Tunable='off';
        PopupChoices={};
        Enable='on';
        Visible='on';
        Hidden='off';
        ReadOnly='off';
        Tab='';
        RuntimeConfigurable='off';
    end
    methods
        function slmaskP=MaskParameter()
        end

        function thisParam=set.Prompt(thisParam,paramPrompt)
            if ischar(paramPrompt)
                thisParam.Prompt=paramPrompt;
            else
                pm_error('physmod:pm_sli:sli:maskparameter:InvalidPropValue','Prompt','string');
            end
        end

        function thisParam=set.VarName(thisParam,paramVarName)
            if isvarname(paramVarName)
                thisParam.VarName=paramVarName;
            else
                pm_error('physmod:pm_sli:sli:maskparameter:InvalidPropValue','VarName','valid variable name');
            end
        end

        function thisParam=set.Type(thisParam,paramType)
            if ischar(paramType)
                paramType=lower(paramType);
                switch(paramType)
                case{'edit'}
                    thisParam.Type=paramType;
                    thisParam.PopupChoices={};
                case 'popup'
                    thisParam.Type=paramType;
                    thisParam.Evaluate=false;
                case 'checkbox'
                    thisParam.Type=paramType;
                    thisParam.PopupChoices={};
                    thisParam.Evaluate=false;
                otherwise
                    pm_error('physmod:pm_sli:sli:maskparameter:InvalidPropValue','Type','''edit'',''popup'' or ''checkbox''.');
                end
            else
                pm_error('physmod:pm_sli:sli:maskparameter:InvalidPropValue','Type','string');
            end
        end

        function thisParam=set.Evaluate(thisParam,isEval)
            thisParam.Evaluate=getOnOff(isEval);
        end

        function thisParam=set.Tunable(thisParam,isTune)
            thisParam.Tunable=getOnOff(isTune);
        end

        function thisParam=set.Enable(thisParam,isEn)
            thisParam.Enable=getOnOff(isEn);
        end

        function thisParam=set.Visible(thisParam,isVis)
            thisParam.Visible=getOnOff(isVis);
        end

        function thisParam=set.Hidden(thisParam,isHide)
            thisParam.Hidden=getOnOff(isHide);
        end

        function thisParam=set.ReadOnly(thisParam,isReadOnly)
            thisParam.ReadOnly=getOnOff(isReadOnly);
        end

        function thisParam=set.Value(thisParam,defVal)
            switch thisParam.Type
            case 'edit'
                if ischar(defVal)
                    thisParam.Value=defVal;
                else
                    pm_error('physmod:pm_sli:sli:maskparameter:InvalidEditParamValue',thisParam.VarName);
                end
            case 'popup'
                isAchoice=any(strcmp(thisParam.PopupChoices,defVal));
                if isAchoice
                    thisParam.Value=defVal;
                else
                    pm_error('physmod:pm_sli:sli:maskparameter:InvalidPopupParamValue',thisParam.VarName);
                end
            case 'checkbox'
                thisParam.Value=getOnOff(defVal);
            end
        end

        function thisParam=set.PopupChoices(thisParam,choices)
            if strcmp(thisParam.Type,'popup')||isempty(choices)
                if iscell(choices)
                    isStr=cellfun(@ischar,choices);
                    if all(isStr)
                        thisParam.PopupChoices=choices;
                    else
                        pm_error('physmod:pm_sli:sli:maskparameter:InvalidPopupChoices');
                    end
                else
                    pm_error('physmod:pm_sli:sli:maskparameter:InvalidPopupChoices');
                end
            else
                pm_error('physmod:pm_sli:sli:maskparameter:CannotSetChoicesForNonPopup',thisParam.VarName);
            end
        end

        function thisParam=set.Tab(thisParam,tabName)
            if ischar(tabName)
                thisParam.Tab=tabName;
            else
                pm_error('physmod:pm_sli:sli:maskparameter:TabNameNotString');
            end
        end

        function thisParam=set.RuntimeConfigurable(thisParam,isRtpConfig)
            thisParam.RuntimeConfigurable=getOnOff(isRtpConfig);
        end
    end
end

function retVal=getOnOff(boolVal)
    boolVal=lower(boolVal);
    switch boolVal
    case{'on','off'}
        retVal=boolVal;
    case 1
        retVal='on';
    case 0
        retVal='off';
    otherwise
        pm_error('physmod:pm_sli:sli:maskparameter:InvalidOnOffSetting');
    end
end
