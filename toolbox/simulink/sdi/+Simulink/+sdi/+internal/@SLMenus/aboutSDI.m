function schema=aboutSDI(cbinfo)



    schema=sl_action_schema;
    schema.tag='Simulink:AboutSignalLogging';
    schema.icon='Simulink:AboutSignalLogging';
    schema.autoDisableWhen='Never';
    schema.callback=@aboutSDI_CB;
    if scopeAppsAvailable()

        schema.label=SLStudio.Utils.getMessage(cbinfo,'SDI:sdi:SLMenuSDIHelpLAFeatureOn');
    else
        schema.label=SLStudio.Utils.getMessage(cbinfo,'SDI:sdi:SLMenuSDIHelp');
    end
end


function aboutSDI_CB(~)
    if scopeAppsAvailable()

        helpview(fullfile(docroot,'simulink','helptargets.map'),'simulink_visualization_help');
    else
        helpview(fullfile(docroot,'mapfiles','simulink.map'),'logging_recording');
    end
end


function isAvailable=scopeAppsAvailable()



    isAvailable=dig.isProductInstalled('DSP System Toolbox')||...
    dig.isProductInstalled('Automated Driving Toolbox');
end
