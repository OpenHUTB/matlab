function allowallunitsystems_cb(hObj,hDlg,value,availablelist_tag,selectedlist_tag,allow_tag,disallow_tag)



    if value==true
        set(hObj,'selectedForAllow',[]);
        set(hObj,'selectedForDisallow',[]);
        set(hObj,'allUnitSysFlag','on');
        unitSysList={Simulink.UnitUtils.getFullList('','UnitSystems').Name};
        selectedUnitSys=cellfun(@strtrim,unitSysList,'UniformOutput',false);
        availableUnitSys=setdiff(unitSysList,selectedUnitSys,'stable');
        set(hObj,'unitSysList',unitSysList);
        set(hObj,'selectedUnitSys',selectedUnitSys);
        set(hObj,'availableUnitSys',availableUnitSys);

        hDlg.setEnabled(availablelist_tag,false);
        hDlg.setEnabled(selectedlist_tag,false);
        hDlg.setEnabled(allow_tag,false);
        hDlg.setEnabled(disallow_tag,false);
    else
        hDlg.setEnabled(availablelist_tag,true);
        hDlg.setEnabled(selectedlist_tag,true);
        set(hObj,'allUnitSysFlag','off');
    end
