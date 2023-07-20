function dlgStruct=getDialogSchema(this,str)





























    if isempty(this.DialogData)
        this.cacheDialogParams;
    end





    numItems=0;

    unitSysList={Simulink.UnitUtils.getFullList('','UnitSystems').Name};
    selected_entries=intersect(unitSysList,this.DialogData.UnitSystems,'stable');
    available_entries=setdiff(unitSysList,selected_entries,'stable');

    availableUnitSysList.Name=DAStudio.message('Simulink:dialog:UnitConfigurationUnitSystems');
    availableUnitSysList.Type='listbox';
    availableUnitSysList.MultiSelect=1;
    availableUnitSysList.Entries=available_entries;
    availableUnitSysList.UserData=availableUnitSysList.Entries;
    availableUnitSysList.RowSpan=[1,4];
    availableUnitSysList.ColSpan=[1,1];
    availableUnitSysList.Tag='availableUnitSysList';
    availableUnitSysList.ObjectMethod='availablelist_cb';
    availableUnitSysList.MethodArgs={'%dialog','%tag'};
    availableUnitSysList.ArgDataTypes={'handle','string'};
    availableUnitSysList.Value=this.DialogData.selectedForAllow;
    availableUnitSysList.Visible=1;
    availableUnitSysList.Enabled=~this.isHierarchySimulating&&...
    ~strcmp(this.DialogData.AllowAllUnitSystems,'on');
    availableUnitSysList.Source=this;
    numItems=numItems+1;
    items{1,numItems}=availableUnitSysList;

    selectedUnitSysList.Name=DAStudio.message('Simulink:dialog:UnitConfigurationAllowedUnitSystems');
    selectedUnitSysList.Type='listbox';
    selectedUnitSysList.MultiSelect=1;
    selectedUnitSysList.Entries=selected_entries;
    selectedUnitSysList.UserData=selectedUnitSysList.Entries;
    selectedUnitSysList.RowSpan=[1,4];
    selectedUnitSysList.ColSpan=[3,3];
    selectedUnitSysList.Tag='selectedUnitSysList';
    selectedUnitSysList.ObjectMethod='selectedlist_cb';
    selectedUnitSysList.MethodArgs={'%dialog','%tag'};
    selectedUnitSysList.ArgDataTypes={'handle','string'};
    selectedUnitSysList.Value=this.DialogData.selectedForDisallow;
    selectedUnitSysList.Visible=1;
    selectedUnitSysList.Enabled=~this.isHierarchySimulating&&...
    ~strcmp(this.DialogData.AllowAllUnitSystems,'on');
    selectedUnitSysList.Source=this;
    numItems=numItems+1;
    items{1,numItems}=selectedUnitSysList;

    allowButton.Name=DAStudio.message('Simulink:dialog:UnitConfigurationAllowButton');
    allowButton.Type='pushbutton';
    allowButton.RowSpan=[2,2];
    allowButton.ColSpan=[2,2];
    allowButton.Enabled=0;
    allowButton.Tag='AllowButton';
    allowButton.ObjectMethod='allowbtn_cb';
    allowButton.MethodArgs={'%dialog',availableUnitSysList.Tag};
    allowButton.ArgDataTypes={'handle','string'};
    allowButton.Visible=1;
    allowButton.Enabled=~this.isHierarchySimulating&&...
    ~strcmp(this.DialogData.AllowAllUnitSystems,'on')&&...
    ~isempty(availableUnitSysList.Value)&&...
    ~isempty(availableUnitSysList.Entries);
    allowButton.Source=this;
    allowButton.DialogRefresh=true;
    numItems=numItems+1;
    items{1,numItems}=allowButton;

    disallowButton.Name=DAStudio.message('Simulink:dialog:UnitConfigurationDisallowButton');
    disallowButton.Type='pushbutton';
    disallowButton.RowSpan=[3,3];
    disallowButton.ColSpan=[2,2];
    disallowButton.Enabled=0;
    disallowButton.Tag='DisallowButton';
    disallowButton.ObjectMethod='disallowbtn_cb';
    disallowButton.MethodArgs={'%dialog',selectedUnitSysList.Tag};
    disallowButton.ArgDataTypes={'handle','string'};
    disallowButton.Visible=1;
    disallowButton.Enabled=~this.isHierarchySimulating&&...
    ~strcmp(this.DialogData.AllowAllUnitSystems,'on')&&...
    ~isempty(selectedUnitSysList.Value)&&...
    ~isempty(selectedUnitSysList.Entries);
    disallowButton.Source=this;
    disallowButton.DialogRefresh=true;
    numItems=numItems+1;
    items{1,numItems}=disallowButton;

    block=this.getBlock;

    allUnitSystemsCheck.Name=DAStudio.message('Simulink:dialog:UnitConfigurationAllUnitSystems');
    allUnitSystemsCheck.Type='checkbox';
    allUnitSystemsCheck.RowSpan=[5,5];
    allUnitSystemsCheck.ColSpan=[1,3];
    allUnitSystemsCheck.Tag='_Allow_All_Unit_Systems_';
    allUnitSystemsCheck.Value=strcmp(this.DialogData.AllowAllUnitSystems,'on');
    allUnitSystemsCheck.Visible=1;
    allUnitSystemsCheck.Enabled=~this.isHierarchySimulating;
    allUnitSystemsCheck.ObjectMethod='allowallunitsystems_cb';
    allUnitSystemsCheck.MethodArgs={'%dialog','%value',availableUnitSysList.Tag,selectedUnitSysList.Tag,allowButton.Tag,disallowButton.Tag};
    allUnitSystemsCheck.ArgDataTypes={'handle','mxArray','string','string','string','string'};
    allUnitSystemsCheck.DialogRefresh=true;
    allUnitSystemsCheck.Source=this;
    numItems=numItems+1;
    items{1,numItems}=allUnitSystemsCheck;














































    descText.Name=block.BlockDescription;
    descText.Type='text';
    descText.WordWrap=true;
    descText.RowSpan=[1,1];
    descText.ColSpan=[1,3];

    descGroup.Name=DAStudio.message('Simulink:dialog:UnitConfigurationDescTitle');
    descGroup.Type='group';
    descGroup.Items={descText};
    descGroup.RowSpan=[1,1];
    descGroup.ColSpan=[1,3];
    descGroup.LayoutGrid=[1,3];
    descGroup.RowStretch=0;
    descGroup.ColStretch=[0,0,1];

    paramGroup.Name=DAStudio.message('Simulink:dialog:Parameters');
    paramGroup.Type='group';
    paramGroup.Items=items;
    paramGroup.LayoutGrid=[5,3];
    paramGroup.RowStretch=[zeros(1,4),1];
    paramGroup.ColStretch=[1,0,1];
    paramGroup.RowSpan=[2,2];
    paramGroup.ColSpan=[1,3];




    dlgStruct.DialogTitle=DAStudio.message('Simulink:dialog:UnitConfigurationDlgTitle',strrep(block.Name,sprintf('\n'),' '));
    dlgStruct.Items={descGroup,paramGroup};

    dlgStruct.LayoutGrid=[2,3];
    dlgStruct.RowStretch=[0,1];
    dlgStruct.ColStretch=[1,0,1];
    dlgStruct.ShowGrid=false;
    dlgStruct.HelpMethod='slhelp';
    dlgStruct.HelpArgs={block.Handle};

    dlgStruct.PreApplyMethod='PreApplyCallback';
    dlgStruct.PreApplyArgs={'%dialog'};
    dlgStruct.PreApplyArgsDT={'handle'};

    dlgStruct.CloseMethod='CloseCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};

    [~,isLocked]=this.isLibraryBlock(block);
    if isLocked
        dlgStruct.DisableDialog=1;
    else
        dlgStruct.DisableDialog=0;
    end

end
