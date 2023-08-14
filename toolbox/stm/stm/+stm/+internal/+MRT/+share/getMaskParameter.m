function[maskParam,msg]=getMaskParameter(source,paramName)




    msg='';
    if(nargin<2)
        paramName='';
    end
    try
        p=Simulink.Mask.get(source);
        if(~isempty(paramName))
            maskParam=p.getParameter(paramName);
            if(isempty(maskParam))
                msg=stm.internal.MRT.share.getString(...
                'stm:Parameters:MaskInitOverrideError',paramName);
            end
        end
    catch err
        if(strcmp(err.identifier,'MATLAB:undefinedVarOrClass')||...
            strcmp(err.identifier,'MATLAB:subscripting:classHasNoPropertyOrMethod'))

            tmpH=get_param(source,'Handle');
            if(~isempty(paramName))
                maskParam=struct('Name',paramName,'Value','');
                maskNames=get_param(tmpH,'MaskNames');
                maskValues=get_param(tmpH,'MaskValues');
                for k=1:length(maskNames)
                    if(strcmp(paramName,maskNames{k}))
                        maskParam.Value=maskValues{k};
                    end
                end
            end
        else
            throw(err);
        end
    end
end
