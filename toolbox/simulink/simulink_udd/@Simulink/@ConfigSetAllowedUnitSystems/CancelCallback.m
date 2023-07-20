function CancelCallback(hObj,hDlg)


    set(hObj,'dirty',0);
    debugging=get(hObj,'myDebuggingCC');
    unitSysStr=debugging.get_param('AllowedUnitSystems');

    unitSysList={Simulink.UnitUtils.getFullList('','UnitSystems').Name};

    if(strcmp(unitSysStr,'all'))
        selUnitSys=unitSysList;
        hasAllUnitSysFlag='on';
    else
        selUnitSys=strsplit(unitSysStr,',');
        hasAllUnitSysFlag='off';
    end

    selUnitSys=cellfun(@strtrim,selUnitSys,'UniformOutput',false);

    selectedUnitSys=intersect(unitSysList,selUnitSys,'stable');
    availableUnitSys=setdiff(unitSysList,selectedUnitSys,'stable');

    set(hObj,'unitSysList',unitSysList);
    set(hObj,'selectedUnitSys',selectedUnitSys);
    set(hObj,'availableUnitSys',availableUnitSys);
    set(hObj,'selectedForAllow',[]);
    set(hObj,'selectedForDisallow',[]);
    set(hObj,'allUnitSysFlag',hasAllUnitSysFlag);

    delete(hDlg);
end
