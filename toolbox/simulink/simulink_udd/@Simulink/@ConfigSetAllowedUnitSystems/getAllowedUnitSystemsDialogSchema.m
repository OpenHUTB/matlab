function dlgstruct=getAllowedUnitSystemsDialogSchema(hObj)





    tag='Tag_AllowedUnitSystems_';


    dirty=get(hObj,'dirty');
    if~dirty
        dirty=1;
        set(hObj,'dirty',dirty);
        unitSysList={Simulink.UnitUtils.getFullList('','UnitSystems').Name};
        if(strcmp(get(hObj,'allUnitSysFlag'),'on'))

            unitSysStr=get(hObj,'unitSysCopy');
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
        else
            selectedUnitSys=get(hObj,'selectedUnitSys');
            availableUnitSys=get(hObj,'availableUnitSys');
            hasAllUnitSysFlag=get(hObj,'allUnitSysFlag');
        end

        set(hObj,'unitSysList',unitSysList);
        set(hObj,'selectedUnitSys',selectedUnitSys);
        set(hObj,'availableUnitSys',availableUnitSys);
        set(hObj,'selectedForAllow',[]);
        set(hObj,'selectedForDisallow',[]);
        set(hObj,'allUnitSysFlag',hasAllUnitSysFlag);
    end

    selectedUnitSys=get(hObj,'selectedUnitSys');
    availableUnitSys=get(hObj,'availableUnitSys');
    allUnitSysFlag=strcmp(get(hObj,'allUnitSysFlag'),'on');



    availableUnitSysList.Name=DAStudio.message('Simulink:dialog:UnitConfigurationUnitSystems');
    availableUnitSysList.Type='listbox';
    availableUnitSysList.MultiSelect=1;
    availableUnitSysList.Entries=availableUnitSys;
    availableUnitSysList.UserData=availableUnitSysList.Entries;
    availableUnitSysList.RowSpan=[1,4];
    availableUnitSysList.ColSpan=[1,1];
    availableUnitSysList.Tag=[tag,'availableUnitSysList'];
    availableUnitSysList.ObjectMethod='availablelist_cb';
    availableUnitSysList.MethodArgs={'%dialog','%tag'};
    availableUnitSysList.ArgDataTypes={'handle','string'};
    availableUnitSysList.Value=get(hObj,'selectedforAllow');
    availableUnitSysList.Visible=1;
    availableUnitSysList.Enabled=~allUnitSysFlag;
    availableUnitSysList.Source=hObj;



    selectedUnitSysList.Name=DAStudio.message('Simulink:dialog:UnitConfigurationAllowedUnitSystems');
    selectedUnitSysList.Type='listbox';
    selectedUnitSysList.MultiSelect=1;
    selectedUnitSysList.Entries=selectedUnitSys;
    selectedUnitSysList.UserData=selectedUnitSysList.Entries;
    selectedUnitSysList.RowSpan=[1,4];
    selectedUnitSysList.ColSpan=[3,3];
    selectedUnitSysList.Tag=[tag,'selectedUnitSysList'];
    selectedUnitSysList.ObjectMethod='selectedlist_cb';
    selectedUnitSysList.MethodArgs={'%dialog','%tag'};
    selectedUnitSysList.ArgDataTypes={'handle','string'};
    selectedUnitSysList.Value=get(hObj,'selectedForDisallow');
    selectedUnitSysList.Visible=1;
    selectedUnitSysList.Enabled=~allUnitSysFlag;
    selectedUnitSysList.Source=hObj;


    allowButton.Name=DAStudio.message('Simulink:dialog:UnitConfigurationAllowButton');
    allowButton.Type='pushbutton';
    allowButton.RowSpan=[2,2];
    allowButton.ColSpan=[2,2];
    allowButton.Tag=[tag,'AllowButton'];
    allowButton.ObjectMethod='allowbtn_cb';
    allowButton.MethodArgs={'%dialog',availableUnitSysList.Tag};
    allowButton.ArgDataTypes={'handle','string'};
    allowButton.Visible=1;
    allowButton.Enabled=~allUnitSysFlag&&...
    ~isempty(availableUnitSysList.Value)&&...
    ~isempty(availableUnitSysList.Entries);
    allowButton.Source=hObj;
    allowButton.DialogRefresh=true;

    disallowButton.Name=DAStudio.message('Simulink:dialog:UnitConfigurationDisallowButton');
    disallowButton.Type='pushbutton';
    disallowButton.RowSpan=[3,3];
    disallowButton.ColSpan=[2,2];
    disallowButton.Tag=[tag,'DisallowButton'];
    disallowButton.ObjectMethod='disallowbtn_cb';
    disallowButton.MethodArgs={'%dialog',selectedUnitSysList.Tag};
    disallowButton.ArgDataTypes={'handle','string'};
    disallowButton.Visible=1;
    disallowButton.Enabled=~allUnitSysFlag&&...
    ~isempty(selectedUnitSysList.Value)&&...
    ~isempty(selectedUnitSysList.Entries);
    disallowButton.DialogRefresh=true;
    disallowButton.Source=hObj;


    allUnitSystemsCheck.Name=DAStudio.message('Simulink:dialog:UnitConfigurationAllUnitSystems');
    allUnitSystemsCheck.Type='checkbox';
    allUnitSystemsCheck.RowSpan=[5,5];
    allUnitSystemsCheck.ColSpan=[1,3];
    allUnitSystemsCheck.Tag=[tag,'_Allow_All_Unit_Systems_'];
    allUnitSystemsCheck.Value=allUnitSysFlag;
    allUnitSystemsCheck.Visible=1;
    allUnitSystemsCheck.Enabled=1;
    allUnitSystemsCheck.ObjectMethod='allowallunitsystems_cb';
    allUnitSystemsCheck.MethodArgs={'%dialog','%value',availableUnitSysList.Tag,selectedUnitSysList.Tag,allowButton.Tag,disallowButton.Tag};
    allUnitSystemsCheck.ArgDataTypes={'handle','mxArray','string','string','string','string'};
    allUnitSystemsCheck.DialogRefresh=true;
    allUnitSystemsCheck.Source=hObj;

    dlgstruct.LayoutGrid=[5,4];
    dlgstruct.RowStretch=[0,1];
    dlgstruct.ColStretch=[1,0,1];
    dlgstruct.ShowGrid=false;
    dlgstruct.Items={availableUnitSysList,selectedUnitSysList,allowButton,disallowButton,allUnitSystemsCheck};
    dlgstruct.Source=hObj;
    dlgstruct.DialogRefresh=true;

end


