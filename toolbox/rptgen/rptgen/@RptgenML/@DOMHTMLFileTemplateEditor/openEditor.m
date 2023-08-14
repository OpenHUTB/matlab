function openEditor(this)




    if rptgen.use_java
        editCmd=char(javaMethod('getEditHTMLCommand',...
        'com.mathworks.toolbox.rptgencore.tools.RptgenPrefsPanel',...
        this.TemplatePath));
    else
        editCmd=matlab.ui.internal.preferences.preferencePanels.RptgenPreferencePanel.getEditHTMLCommand(this.TemplatePath);
    end


    evalin('base',editCmd);
