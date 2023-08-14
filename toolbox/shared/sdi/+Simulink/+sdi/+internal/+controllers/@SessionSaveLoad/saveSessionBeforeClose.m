function saveSessionBeforeClose(this,varargin)









    webGUI=varargin{1};
    this.ActionInProgress=true;
    tmp=onCleanup(@()this.setActionInProgress(this.AppName,false));


    if~Simulink.sdi.getRunCount(this.AppName)
        this.cacheSessionInfo('','');
        saveBeforeCloseConfirmation(this,3,webGUI);
        return;
    end

    dirty=webGUI.getDirty();

    if dirty
        str='sdi';
        if strcmpi(this.AppName,'siganalyzer')
            str='sigAnalyzer';
            appStateCtrl=signal.analyzer.controllers.AppState.getController();
            if~appStateCtrl.getSignalAnalyzerActiveAppFlag()
                str='dialogsLabeler';
            end
        end
        appName='default';
        if~isempty(this.AppName)
            appName=this.AppName;
        end

        msgStr=getString(message(['SDI:',str,':mgClearRunsWarn']));
        titleStr=getString(message(['SDI:',str,':mgSaveSessionTitle']'));
        if strcmp(str,'dialogsLabeler')
            okStr=getString(message('SDI:sdi:OKShortcut'));
            cancelStr=getString(message('SDI:sdi:CancelShortcut'));

            Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
            appName,...
            titleStr,...
            msgStr,...
            {okStr,cancelStr},...
            1,...
            1,...
            @(x)this.saveBeforeCloseConfirmation(x+1,webGUI));
        else

            saveStr=getString(message('SDI:sdi:SaveShortcut'));
            dontSaveStr=getString(message('SDI:sdi:DontSaveShortcut'));
            cancelStr=getString(message('SDI:sdi:CancelShortcut'));

            Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
            appName,...
            titleStr,...
            msgStr,...
            {saveStr,dontSaveStr,cancelStr},...
            2,...
            2,...
            @(x)this.saveBeforeCloseConfirmation(x,webGUI));
        end
    else
        saveBeforeCloseConfirmation(this,1,webGUI);
    end
end
