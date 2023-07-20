function availablelist_cb(hObj,hDlg,tag)



    tag2='Tag_AllowedUnitSystems_';

    selection=hDlg.getWidgetValue(tag);
    if~isempty(selection)
        hDlg.setEnabled([tag2,'AllowButton'],true);
        set(hObj,'selectedForAllow',selection);
    else
        hDlg.setEnabled([tag2,'AllowButton'],false);
        set(hObj,'selectedForAllow',[]);
    end

