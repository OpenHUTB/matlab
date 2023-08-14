function updateGUITitle(this)

    appName=this.AppName;
    if strcmpi(appName,'siganalyzer')
        if signal.analyzer.Instance.isSDIRunning()
            gui=signal.analyzer.Instance.gui();
            gui.updateSessionInfo();
        else
            Simulink.sdi.internal.WebGUI.sendSessionInfo(appName);
        end
    else
        if Simulink.sdi.Instance.isSDIRunning()
            gui=Simulink.sdi.Instance.gui();
            gui.updateSessionInfo();
        else
            Simulink.sdi.internal.WebGUI.sendSessionInfo(appName);
        end
    end
