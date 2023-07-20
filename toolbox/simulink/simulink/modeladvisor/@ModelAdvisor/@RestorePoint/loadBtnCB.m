function loadBtnCB(this,dialogHandle)




    if isa(this.MAObj,'Simulink.ModelAdvisor')
        shlist=this.MAObj.getRestorePointList;
        if isnumeric(this.SelectedLineIndex)&&~isempty(this.SelectedLineIndex)&&...
            (this.SelectedLineIndex+1<=length(shlist))
            selectedSnapshot=shlist{this.SelectedLineIndex+1};

            warnmsg=DAStudio.message('ModelAdvisor:engine:MAWarnLoadRestorePoint',selectedSnapshot.name);
            response=questdlg(warnmsg,DAStudio.message('Simulink:tools:MAWarning'),...
            DAStudio.message('Simulink:tools:MALoad'),...
            DAStudio.message('Simulink:tools:MACancel'),...
            DAStudio.message('Simulink:tools:MACancel'));
            if strcmp(response,DAStudio.message('Simulink:tools:MALoad'))
                this.MAObj.loadRestorePoint(selectedSnapshot.name);
                this.closeDialog(dialogHandle);
            end
        end
    end
