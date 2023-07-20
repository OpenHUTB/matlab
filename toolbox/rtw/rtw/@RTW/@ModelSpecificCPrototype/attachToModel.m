function attachToModel(hSrc,modelName)








    if ischar(modelName)
        try
            hModel=get_param(modelName,'Handle');
        catch
            DAStudio.error('RTW:fcnClass:invalidModelName',modelName);
        end
    else
        hModel=modelName;
    end

    try
        obj=get_param(hModel,'object');
        if~obj.isa('Simulink.BlockDiagram')
            DAStudio.error('RTW:fcnClass:invalidMdlHdl');
        end
    catch
        DAStudio.error('RTW:fcnClass:invalidMdlHdl');
    end

    fullname=get_param(hModel,'Name');


    if isempty(hSrc.FunctionName)
        hSrc.FunctionName=sprintf('%s_custom',fullname);
    end
    if isempty(hSrc.InitFunctionName)
        hSrc.InitFunctionName=sprintf('%s_initialize',fullname);
    end

    hSrc.ModelHandle=hModel;
    set_param(hModel,'RTWFcnClass',hSrc);
