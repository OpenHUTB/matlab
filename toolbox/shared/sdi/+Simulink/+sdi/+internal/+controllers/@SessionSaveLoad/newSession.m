function newSession(this,varargin)






    tmp=onCleanup(@()updateGUITitle(this));
    this.ActionInProgress=true;
    tmp2=onCleanup(@()this.setActionInProgress(this.AppName,false));


    if this.Dirty
        if~isempty(varargin)
            choice=varargin{1};
            newSessionConfirmation(this,choice);
        else
            str='sdi';
            if strcmpi(this.AppName,'siganalyzer')
                str='sigAnalyzer';
            end

            msgStr=getString(message(['SDI:',str,':mgClearRunsWarn']));
            titleStr=getString(message('SDI:sdi:NewSession'));
            saveStr=getString(message('SDI:sdi:SaveShortcut'));
            dontSaveStr=getString(message('SDI:sdi:DontSaveShortcut'));
            cancelStr=getString(message('SDI:sdi:CancelShortcut'));

            Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
            this.AppName,...
            titleStr,...
            msgStr,...
            {saveStr,dontSaveStr,cancelStr},...
            2,...
            2,...
            @(x)this.newSessionConfirmation(x));
        end
    else
        newSessionConfirmation(this,1);
    end
end
