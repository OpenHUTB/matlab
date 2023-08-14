function saveBtnCB(this,dialogHandle)




    if isa(this.MAObj,'Simulink.ModelAdvisor')
        snapname=dialogHandle.getWidgetValue('edit_nameEdit');
        snapdescription=dialogHandle.getWidgetValue('edit_descriptionEdit');
        shlist=this.MAObj.getRestorePointList;
        nameDuplicate=false;
        for i=1:length(shlist)
            if strcmp(shlist{i}.name,snapname)
                nameDuplicate=true;
                break
            end
        end
        if nameDuplicate

            warnmsg=DAStudio.message('Simulink:tools:MAWarnOverwriteRestorePoint',snapname);
            response=questdlg(warnmsg,DAStudio.message('Simulink:tools:MAWarning'),...
            DAStudio.message('Simulink:tools:MAContinue'),...
            DAStudio.message('Simulink:tools:MACancel'),...
            DAStudio.message('Simulink:tools:MACancel'));
        else
            response=DAStudio.message('Simulink:tools:MAContinue');
        end
        if strcmp(response,DAStudio.message('Simulink:tools:MAContinue'))
            this.MAObj.saveRestorePoint(snapname,snapdescription);
            this.closeDialog(dialogHandle);
        end
    end