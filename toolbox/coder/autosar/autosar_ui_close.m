function autosar_ui_close(modelH)















    arExplorer=autosar.ui.utils.findExplorerForModel(modelH);
    if~isempty(arExplorer)
        autosar.ui.utils.closeUI(arExplorer);
    end


    validateDlg=findall(0,'Tag','TMWWaitbar');
    for ii=1:length(validateDlg)
        name=get(validateDlg(ii),'Name');
        if strcmp(name,autosar.ui.configuration.PackageString.ValAutosar)
            delete(validateDlg(ii));
            break;
        end
    end
end





