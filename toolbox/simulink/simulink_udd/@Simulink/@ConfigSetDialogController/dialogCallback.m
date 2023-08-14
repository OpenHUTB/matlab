function dialogCallback(hController,hDlg,tag,~)









    hSrc=hController.getSourceObject;

    switch tag

    case 'Tag_ConfigSet_LaunchCS'
        hSrc.view;
        if~isempty(hController.DataDictionary)

            hController.ParentDialog=hDlg;
        end

    case 'Tag_ConfigSetRef_OpenSource'
        configset.internal.reference.openSource(hDlg,false);
    otherwise
        error(getString(message('RTW:configSet:unknownActionForTag',tag)));
    end
