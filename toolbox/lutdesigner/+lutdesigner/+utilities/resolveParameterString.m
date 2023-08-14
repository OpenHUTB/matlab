function[value,context,type]=resolveParameterString(parameterOwner,parameterName,str)

















    parameterOwnerHandle=get_param(parameterOwner,'Handle');


    if~isParameterEvaluated(parameterOwnerHandle,parameterName)
        value=str;
        if nargout>1
            context='';
            type='value';
        end
        return;
    end

    strToResolve=strtrim(str);
    if isvarname(strToResolve)

        [value,exists]=slResolve(strToResolve,parameterOwnerHandle,'variable');
        if exists
            if nargout>1
                if strcmp(strToResolve,parameterName)
                    resolutionMode='startAboveMask';
                else
                    resolutionMode='hierarchical';
                end
                context=slResolve(strToResolve,parameterOwnerHandle,'context',resolutionMode);
                type='variable';
            end
            return;
        end
    end



    value=slResolve(str,parameterOwnerHandle,'expression');
    if nargout>1
        context='';
        type='expression';
    end
end

function tf=isParameterEvaluated(parameterOwnerHandle,parameterName)


    maskObject=Simulink.Mask.get(parameterOwnerHandle);
    if~isempty(maskObject)
        maskParameter=maskObject.getParameter(parameterName);
        if~isempty(maskParameter)
            tf=strcmp(maskParameter.Evaluate,'on');
            return;
        end
    end

    dialogParameters=get_param(parameterOwnerHandle,'ObjectParameters');
    tf=~ismember('dont-eval',dialogParameters.(parameterName).Attributes);
end
