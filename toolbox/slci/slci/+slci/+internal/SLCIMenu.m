function schema=SLCIMenu(funcname,cbinfo)
    fnc=str2func(funcname);
    schema=fnc(cbinfo);
end

function state=loc_getSLCIToolMenuState(cbinfo)
    if license('test','Simulink_Code_Inspector')
        state='Enabled';
    else
        state='Disabled';
    end

    if Simulink.harness.isHarnessBD(cbinfo.model.Name)
        state='Disabled';
    end
end

function schema=SLCIToolMenu(cbinfo)%#ok
    schema=sl_action_schema;
    schema.label=DAStudio.message('Slci:ui:MenuSLCI');
    schema.state=loc_getSLCIToolMenuState(cbinfo);
    schema.tag='Simulink:SLCIConfigure';
    schema.callback=@SLCIConfigureCB;
    schema.autoDisableWhen='Busy';
end

function SLCIConfigureCB(cbinfo)
    mdlObj=cbinfo.uiObject;
    while~strcmpi(class(mdlObj.getParent),'Simulink.Root')
        mdlObj=mdlObj.getParent;
    end
    mdlName=mdlObj.getFullName;
    config=slci.Configuration.loadObjFromFile(mdlName);
    if isempty(config)
        config=slci.Configuration(mdlName);
    end
    config.show();
end
