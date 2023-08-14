function openEditor(this)




    [tParentDir,tName,~]=fileparts(this.TemplatePath);
    tDir=fullfile(tParentDir,tName);

    if~exist(tDir,'dir')
        unzip(this.TemplatePath,tDir);
    end

    mainPart=mlreportgen.dom.Document.getOPCMainPart(this.TemplatePath,'html');
    tDocPath=fullfile(tDir,mainPart);


    if rptgen.use_java
        editCmd=char(javaMethod('getEditHTMLCommand',...
        'com.mathworks.toolbox.rptgencore.tools.RptgenPrefsPanel',...
        tDocPath));
    else
        editCmd=matlab.ui.internal.preferences.preferencePanels.RptgenPreferencePanel.getEditHTMLCommand(tDocPath);
    end


    evalin('base',editCmd);


    libPath=fullfile(tDir,'docpart_templates.html');

    if rptgen.use_java
        editCmd=char(javaMethod('getEditHTMLCommand',...
        'com.mathworks.toolbox.rptgencore.tools.RptgenPrefsPanel',...
        libPath));
    else
        editCmd=matlab.ui.internal.preferences.preferencePanels.RptgenPreferencePanel.getEditHTMLCommand(libPath);
    end


    evalin('base',editCmd);
