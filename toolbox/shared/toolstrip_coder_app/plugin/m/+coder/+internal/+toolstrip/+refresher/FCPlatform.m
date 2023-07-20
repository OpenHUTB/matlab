function FCPlatform(data,cbinfo,action)

















    mdl=cbinfo.editorModel.handle;
    ecd=get_param(mdl,'EmbeddedCoderDictionary');
    name=get_param(mdl,'PlatformDefinition');

    fc=[];
    if exist(ecd,'file')
        helper=coder.internal.CoderDataStaticAPI.getHelper();
        try
            fc=helper.getFunctionPlatforms(ecd);
        catch
        end
    end

    action.selected=~strcmp(name,configset.internal.getApplicationPlatformName);
    if action.selected
        action.text=name;
        if isempty(fc)||~strcmp(fc.Name,name)

            action.description=[...
            message('ToolstripCoderApp:toolstrip:SDPFunctionComponentDescription').getString...
            ,' ',message('ToolstripCoderApp:toolstrip:SDPFunctionComponentUnavailable').getString];
            action.enabled=false;
        else
            action.description=fc.Description;
            action.enabled=true;
        end
    elseif~isempty(fc)

        action.text=fc.Name;
        action.description=fc.Description;
        action.enabled=true;
    else

        action.text=message('ToolstripCoderApp:toolstrip:SDPFunctionComponentText').getString;
        action.description=message('ToolstripCoderApp:toolstrip:SDPFunctionComponentDescription').getString;
        action.enabled=false;
    end

    if~action.selected&&action.enabled
        cs=getActiveConfigSet(mdl);
        if isa(cs,'Simulink.ConfigSetRef')
            action.enabled=false;
        end
    end

    if action.selected
        cgb=get_param(mdl,'CodeGenBehavior');
        if strcmp(cgb,'None')
            action.selected=false;
        end
    end

    if strcmp(data,'dropdown')
        action.enabled=true;
    end




