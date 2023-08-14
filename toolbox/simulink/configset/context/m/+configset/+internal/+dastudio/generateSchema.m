function schemas=generateSchema(callbackInfo)



    schemas={@importActiveCS,@exportActiveCS,'separator',@addCS,@addCSRef,'separator',@convertToRef};
end

function schema=importActiveCS(callbackInfo)%#ok<*INUSD>
    schema=DAStudio.ActionSchema;
    schema.label=DAStudio.message('Simulink:ConfigSet:MEContextMenuCSImport');
    schema.tag='Simulink:ConfigSet:ImportCS';
    schema.userdata.enabled='on';
    schema.userdata.visible='on';
    schema.callback=@importActiveCS_callback;
end

function importActiveCS_callback(callbackInfo)
    configset.internal.dastudio.slImportConfigSet(callbackInfo.uiObject);
end

function schema=exportActiveCS(callbackInfo)
    model=callbackInfo.uiObject;
    configuration=getActiveConfigSet(model);

    schema=DAStudio.ActionSchema;
    schema.label=DAStudio.message('Simulink:ConfigSet:MEContextMenuCSExport');
    schema.tag='Simulink:ConfigSet:ExportCS';
    schema.userdata.visible='on';

    if isempty(configuration.getParent)||~isa(configuration,'Simulink.ConfigSet')
        schema.userdata.enabled='off';
    else
        schema.userdata.enabled='on';
    end

    schema.callback=@exportActiveCS_callback;
end

function exportActiveCS_callback(callbackInfo)
    configset.internal.dastudio.slExportConfigSet(callbackInfo.uiObject);
end

function schema=addCS(callbackInfo)
    schema=DAStudio.ActionSchema;
    schema.label=DAStudio.message('Simulink:ConfigSet:MEContextMenuCSAddCS');
    schema.tag='Simulink:ConfigSet:addCS';
    schema.userdata.enabled='on';
    schema.userdata.visible='on';
    schema.callback=@addCS_callback;
end

function addCS_callback(callbackInfo)
    model=callbackInfo.uiObject;
    configset.internal.dastudio.addConfiguration(model,Simulink.ConfigSet);
end

function schema=addCSRef(callbackInfo)
    schema=DAStudio.ActionSchema;
    schema.label=DAStudio.message('Simulink:ConfigSet:MEContextMenuCSAddCSRef');
    schema.tag='Simulink:ConfigSet:addCSRef';
    schema.userdata.enabled='on';
    schema.userdata.visible='on';
    schema.callback=@addCSRef_callback;
end

function addCSRef_callback(callbackInfo)
    model=callbackInfo.uiObject;
    configset.internal.dastudio.addConfiguration(model,Simulink.ConfigSetRef);
end

function schema=convertToRef(callbackInfo)
    model=callbackInfo.uiObject;
    configuration=getActiveConfigSet(model);

    schema=DAStudio.ActionSchema;
    schema.label=DAStudio.message('Simulink:ConfigSet:MEContextMenuCSConvert');
    schema.tag='Simulink:ConfigSet:convertCStoCSRef';
    schema.userdata.visible='on';

    if isempty(configuration.getParent)||~isa(configuration,'Simulink.ConfigSet')
        schema.userdata.enabled='off';
    else
        schema.userdata.enabled='on';
    end

    schema.callback=@convertToRef_callback;
end

function convertToRef_callback(callbackInfo)
    cs=getActiveConfigSet(callbackInfo.uiObject);
    configset.internal.dastudio.convertToReference(cs);
end
