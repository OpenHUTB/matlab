function schemaFcns=getRTTToolsMenuItems(~)




    schemaFcns={@getRTTToolsMenu};
end


function schema=getRTTToolsMenu(callbackInfo)
    schema=sl_container_schema;
    schema.tag='Simulink:RealTimeHardware';
    label=DAStudio.message('realtime:build:ToolsMenuRunOnHardware');
    schema.label=label;
    if slfeature('UnifiedTargetHardwareSelection')
        modelName=callbackInfo.model.Name;
        cs=getActiveConfigSet(modelName);
        isResolved=isa(cs,'Simulink.ConfigSet')||isequal(cs.SourceResolved,'on');
        if isResolved&&...
            (isequal(get_param(modelName,'SystemTargetFile'),'realtime.tlc')||...
            codertarget.target.isCoderTarget(modelName))
            schema.childrenFcns={@getOptionsUnified,@getInstall};
        else
            schema.childrenFcns={@getPrepareToRunUnified,@getInstall};
        end
    else
        modelName=callbackInfo.model.Name;
        if isempty(realtime.getRegisteredTargets)
            schema.childrenFcns={@getInstall};
        elseif~isequal(get_param(modelName,'SystemTargetFile'),'realtime.tlc')
            schema.childrenFcns={@getPrepareToRun,@getInstall};
        else
            schema.childrenFcns={@getOptions,@getInstall};
        end
    end
end


function schema=getInstall(~)
    schema=sl_action_schema;
    schema.tag='Simulink:RealTimeToolboxInstall';
    label=DAStudio.message('realtime:build:ToolsMenuInstall');
    schema.label=label;
    schema.state='Enabled';
    schema.userdata='realtime.tlc';
    schema.callback=@myInstallCallback;
end


function schema=getOptions(~)
    locState='Enabled';
    schema=sl_action_schema;
    schema.tag='Simulink:RealTimeToolboxOptions';
    label=DAStudio.message('realtime:build:ToolsMenuOptions');
    schema.label=label;
    schema.state=locState;
    schema.userdata='realtime.tlc';
    schema.callback=@myOptionsCallback;
end


function schema=getPrepareToRun(~)
    schema=sl_action_schema;
    schema.tag='Simulink:RealTimeToolboxPrepareToRun';
    label=DAStudio.message('realtime:build:ToolsMenuPrepareToRun');
    schema.label=label;
    schema.state='Enabled';
    schema.userdata='realtime.tlc';
    schema.callback=@myConfigureCallback;
end


function schema=getOptionsUnified(~)
    locState='Enabled';
    schema=sl_action_schema;
    schema.tag='Simulink:RealTimeToolboxOptions';
    label=DAStudio.message('realtime:build:ToolsMenuOptions');
    schema.label=label;
    schema.state=locState;
    schema.userdata='realtime.tlc';
    schema.callback=@myOptionsUnifiedCallback;
end


function schema=getPrepareToRunUnified(~)
    locState='Enabled';
    schema=sl_action_schema;
    schema.tag='Simulink:RealTimeToolboxPrepareToRun';
    label=DAStudio.message('realtime:build:ToolsMenuPrepareToRun');
    schema.label=label;
    schema.state=locState;
    schema.userdata='realtime.tlc';
    schema.callback=@myPrepareToRunUnifiedCallback;
end


function myInstallCallback(~)
    matlab.addons.supportpackage.internal.explorer.showAllHardwareSupportPackages('simulinkToolsMenu');
end


function myConfigureCallback(callbackInfo)
    modelName=callbackInfo.model.Name;
    csname='Run on Hardware Configuration';
    rttcs=getConfigSet(modelName,csname);
    if isempty(rttcs)
        rttcs=Simulink.ConfigSet;
        rttcs.Name='Run on Hardware Configuration';
        attachConfigSet(modelName,rttcs);
        setActiveConfigSet(modelName,rttcs.Name);
    end
    cs=getActiveConfigSet(modelName);
    cs.switchTarget('realtime.tlc','');
    if~isequal(get_param(modelName,'TargetExtensionPlatform'),'None')
        info=realtime.getParameterTemplate(cs);
        realtime.initializeData(cs,info);
        realtime.setModelForRTT(cs,true);
    end
    page=DAStudio.message('realtime:build:ConfigRunOnHardware');
    configset.showParameterGroup(cs,{page});
end


function myOptionsCallback(callbackInfo)
    modelName=callbackInfo.model.Name;
    cs=getActiveConfigSet(modelName);
    page=DAStudio.message('realtime:build:ConfigRunOnHardware');
    configset.showParameterGroup(cs,{page});
end


function myPrepareToRunUnifiedCallback(callbackInfo)
    modelName=callbackInfo.model.Name;
    cs=getActiveConfigSet(modelName);
    configset.showParameterGroup(cs,{'Hardware Implementation'});
end


function myOptionsUnifiedCallback(callbackInfo)
    modelName=callbackInfo.model.Name;
    cs=getActiveConfigSet(modelName);
    configset.showParameterGroup(cs,{'Hardware Implementation'});
end


function i_unwindCauses(me)
    for i=1:length(me.cause)
        sldiagviewer.reportError(me.cause{i}.message,'Component','Simulink','Category','Model');
        i_unwindCauses(me.cause{i});
    end
end
