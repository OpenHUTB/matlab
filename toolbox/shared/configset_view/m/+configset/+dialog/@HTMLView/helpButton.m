function helpButton(obj,dlg)


    topic=obj.evalJS('api.getHelpPageTopic()');
    map=['mapkey:Simulink.ConfigSet@',topic];
    try
        helpview(map,'help_button','CSHelpWindow');
    catch
        slprivate('configHelp',dlg,obj.Source.Host,'simprm','ConfigSet');
    end