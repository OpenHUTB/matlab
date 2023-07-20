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

    set_param(hModel,'RTWFcnClass',hSrc);
