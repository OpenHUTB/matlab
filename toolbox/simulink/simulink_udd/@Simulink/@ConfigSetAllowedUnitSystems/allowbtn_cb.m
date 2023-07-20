function allowbtn_cb(hObj,hDlg,availablelist_tag)



    selection=hDlg.getWidgetValue(availablelist_tag);
    if~isempty(selection)
        entries=hDlg.getUserData(availablelist_tag);
        selectedUnitSys=get(hObj,'selectedUnitSys');
        selectedUnitSys=union(selectedUnitSys,entries(selection+1));
        unitSysList=get(hObj,'unitSysList');
        availableUnitSys=setdiff(unitSysList,selectedUnitSys,'stable');
        set(hObj,'selectedUnitSys',selectedUnitSys);
        set(hObj,'availableUnitSys',availableUnitSys);
    end
