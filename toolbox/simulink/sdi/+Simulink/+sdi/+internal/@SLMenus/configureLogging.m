function schema=configureLogging(cbinfo)




    schema=sl_action_schema;
    schema.tag='Simulink:ConfigureSignalLogging';
    schema.autoDisableWhen='Busy';
    schema.callback=@configureLoggingCB;
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label='simulink_ui:studio:resources:configureLoggingActionLabel';
    else
        schema.label=DAStudio.message('SDI:sdi:SLMenuJetstreamConfigParams');
    end
    schema.icon='Simulink:ConfigureJetstreamLogging';
end


function configureLoggingCB(cbinfo)
    modelName=cbinfo.model.Name;
    configset.showParameterGroup(modelName,{'Data Import/Export'});
end
