function showPrefs






    if rptgen.use_java
        com.mathworks.toolbox.rptgencore.tools.RptgenPrefsPanel.showPrefsDialog;
    else
        matlab.ui.internal.preferences.preferencePanels.RptgenPreferencePanel.showPrefsDialog;
    end
