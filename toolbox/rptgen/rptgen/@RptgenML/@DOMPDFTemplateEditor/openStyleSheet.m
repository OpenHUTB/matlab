function openStyleSheet(this)




    [tParentDir,tName,~]=fileparts(this.TemplatePath);
    tDir=fullfile(tParentDir,tName);

    if~exist(tDir,'dir')
        unzip(this.TemplatePath,tDir);
    end

    tSSPath=fullfile(tDir,'stylesheets','root.css');

    if rptgen.use_java
        editCmd=char(javaMethod('getEditHTMLCommand',...
        'com.mathworks.toolbox.rptgencore.tools.RptgenPrefsPanel',...
        tSSPath));
    else
        editCmd=matlab.ui.internal.preferences.preferencePanels.RptgenPreferencePanel.getEditHTMLCommand(tSSPath);
    end


    evalin('base',editCmd);
