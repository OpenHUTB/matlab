function noUpdatesDialog(addOnType)











    validStrings={'hardware','software'};
    validatestring(addOnType,validStrings);
    title=message('supportpkgservices:matlabshared:CheckForUpdateDlgTitle').getString;
    if strcmp(addOnType,'hardware')
        msg=message('supportpkgservices:matlabshared:NoHSPUpdatesAvailable').getString;
    else
        msg=message('supportpkgservices:matlabshared:NoAddOnFeatureUpdatesAvailable').getString;
    end
    msgbox(msg,title);
end
