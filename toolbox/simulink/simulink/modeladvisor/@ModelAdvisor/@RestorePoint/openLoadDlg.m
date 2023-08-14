function openLoadDlg




    MAObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;

    if isa(MAObj.RPDialog,'DAStudio.Dialog')
        if MAObj.RPObj.IsSaveDlg

            MAObj.RPObj.delete;
        else
            MAObj.RPDialog.show;
            return
        end
    end
    ssObj=ModelAdvisor.RestorePoint;
    ssObj.MAObj=MAObj;
    ssObj.IsSaveDlg=false;
    MAObj.RPObj=ssObj;
    MAObj.RPDialog=DAStudio.Dialog(ssObj,'','DLG_STANDALONE');
