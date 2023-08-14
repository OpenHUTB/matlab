function InspectCB(aObj,dlg)





    aObj.fViaGUI=true;

    try
        aObj.updateObjFromDlg(dlg);
        slci.Configuration.saveObjToFile(aObj.getModelName(),aObj);
        aObj.inspect;
    catch ME
        aObj.HandleException(ME);
    end

    aObj.fViaGUI=false;
end
