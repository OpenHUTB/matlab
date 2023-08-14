function disallowbtn_cb(hObj,hDlg,selectedlist_tag)



    selection=hDlg.getWidgetValue(selectedlist_tag);
    if~isempty(selection)
        entries=hDlg.getUserData(selectedlist_tag);
        selectedUnitSys=get(hObj,'selectedUnitSys');
        selectedUnitSys=setdiff(selectedUnitSys,entries(selection+1));
        unitSysList=get(hObj,'unitSysList');
        availableUnitSys=setdiff(unitSysList,selectedUnitSys,'stable');
        set(hObj,'selectedUnitSys',selectedUnitSys);
        set(hObj,'availableUnitSys',availableUnitSys);
    end
