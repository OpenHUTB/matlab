function checkCloseMdl(~)







    model=bdroot;

    if strcmp(get_param(model,'IsHarness'),'on')
        return;
    end


    validateDlg=findall(0,'Tag','TMWWaitbar');
    for ii=1:length(validateDlg)
        name=get(validateDlg(ii),'Name');
        if strcmp(name,autosar.ui.configuration.PackageString.ValAutosar)
            delete(validateDlg(ii));
            break;
        end
    end


    autosarcore.destroyLoadedM3IModel(model);

end


