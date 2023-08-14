function[resolvedVal,status]=resolveConfigSetValue(sysRoot,ParameterName)

    resolvedVal=[];
    status=true;


    data=configset.internal.getConfigSetStaticData;
    param=data.getParam(ParameterName);



    if iscell(param)
        param=param{1};
    end


    if strcmp(param.Type,'string')

        paramVal=get_param(sysRoot,ParameterName);



        if~isempty(paramVal)&&isstring(paramVal)
            resolvedVal=str2num(paramVal);%#ok<ST2NM>
        end


        if isempty(resolvedVal)
            try
                resolvedVal=slResolve(paramVal,get_param(sysRoot,'Handle'));
            catch
                resolvedVal=[];
            end
        end
    end

    if isempty(resolvedVal)

        resolvedVal=get_param(sysRoot,ParameterName);
        status=false;
    end
end