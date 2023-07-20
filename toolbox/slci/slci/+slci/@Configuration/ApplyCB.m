function[success,msg]=ApplyCB(aObj,dlg,action)





    aObj.fViaGUI=true;
    success=true;
    try
        switch action
        case{'Ok','Apply'}

            aObj.updateObjFromDlg(dlg);
            slci.Configuration.saveObjToFile(aObj.getModelName(),aObj);
        otherwise

        end
    catch ME
        dlg.enableApplyButton(true);
        success=false;
        aObj.HandleException(ME);
    end
    msg='';
    aObj.fViaGUI=false;
end
