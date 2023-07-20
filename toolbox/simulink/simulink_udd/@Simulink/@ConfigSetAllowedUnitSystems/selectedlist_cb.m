function selectedlist_cb(hObj,hDlg,tag)



    tag2='Tag_AllowedUnitSystems_';

    selection=hDlg.getWidgetValue(tag);
    if~isempty(selection)
        hDlg.setEnabled([tag2,'DisallowButton'],true);
        set(hObj,'selectedForDisallow',selection);
    else
        hDlg.setEnabled([tag2,'DisallowButton'],false);
        set(hObj,'selectedForDisallow',[]);
    end

