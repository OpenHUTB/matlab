function setDefaultClassName(hSrc)









    if~isempty(hSrc.ModelClassName)
        return;
    end

    hModel=hSrc.ModelHandle;

    if~ishandle(hModel)
        DAStudio.error('RTW:fcnClass:invalidMdlHdl');
    else
        try
            obj=get_param(hModel,'object');
            if~obj.isa('Simulink.BlockDiagram')
                DAStudio.error('RTW:fcnClass:invalidMdlHdl');
            end
        catch
            DAStudio.error('RTW:fcnClass:invalidMdlHdl');
        end
    end

    fullname=getfullname(hModel);

    hSrc.ModelClassName=[fullname];
