function createToolstrip(this)





    import matlab.ui.internal.toolstrip.*

    this.Tabs=TabGroup();
    this.Tabs.Tag=this.Tabs_tag;
    this.App.add(this.Tabs);



    this.DesignerTab=Tab(this.Designer_msg);
    this.DesignerTab.Tag=this.TabDesigner_tag;
    this.Tabs.add(this.DesignerTab);



    this.FileSection=this.DesignerTab.addSection(this.File_msg);
    this.FileSection.Tag=this.TabDesignerSectionFile_tag;



    column=Column('HorizontalAlignment','center','Width',30);
    column.Tag=this.TabDesignerSectionFileColumnNew_tag;
    this.FileSection.add(column);
    popup=PopupList();
    item=ListItem(this.NewWithDots_msg,this.New_icon16);
    item.ItemPushedFcn=@(o,e)this.toolstripNewButtonCB();
    popup.add(item);

    list=ListItemWithPopup(this.RecentFiles_msg,this.RecentFiles_icon16);
    sub_popup=PopupList();
    sub_popup.add(PopupListHeader(this.RECENTFILES_msg));
    list.Popup=sub_popup;
    popup.add(list);

    this.NewButton=SplitButton(this.New_msg,this.New_icon24);
    this.NewButton.ButtonPushedFcn=@(o,e)this.toolstripNewButtonCB();
    this.NewButton.Popup=popup;
    column.add(this.NewButton);


    s=settings;
    try
        texts=s.slrealtime.slrtAppGenerator.newRecentFiles.text.ActiveValue();
        iconFiles=s.slrealtime.slrtAppGenerator.newRecentFiles.iconFile.ActiveValue();
        descriptions=s.slrealtime.slrtAppGenerator.newRecentFiles.description.ActiveValue();
        tags=s.slrealtime.slrtAppGenerator.newRecentFiles.tag.ActiveValue();
        numSavedFiles=numel(texts);
    catch
        numSavedFiles=0;
    end
    for nSavedFile=1:numSavedFiles
        item=ListItem(texts{nSavedFile},this.getIconFile(iconFiles{nSavedFile}));
        item.Tag=tags{nSavedFile};
        item.Description=descriptions{nSavedFile};
        item.ItemPushedFcn=@(o,e)this.toolstripNewRecentFileCB(texts{nSavedFile},tags{nSavedFile});
        sub_popup.add(item);
    end



    column=Column('HorizontalAlignment','center','Width',30);
    column.Tag=this.TabDesignerSectionFileColumnOpen_tag;
    this.FileSection.add(column);
    popup=PopupList();
    item=ListItem(this.OpenWithDots_msg,this.Open_icon16);
    item.ItemPushedFcn=@(o,e)this.toolstripOpenButtonCB();
    popup.add(item);

    list=ListItemWithPopup(this.RecentFiles_msg,this.RecentFiles_icon16);
    sub_popup=PopupList();
    sub_popup.add(PopupListHeader(this.RECENTFILES_msg));
    list.Popup=sub_popup;
    popup.add(list);

    this.OpenButton=SplitButton(this.Open_msg,this.Open_icon24);
    this.OpenButton.ButtonPushedFcn=@(o,e)this.toolstripOpenButtonCB();
    this.OpenButton.Popup=popup;
    column.add(this.OpenButton);


    s=settings;
    try
        texts=s.slrealtime.slrtAppGenerator.openRecentFiles.text.ActiveValue();
        iconFiles=s.slrealtime.slrtAppGenerator.openRecentFiles.iconFile.ActiveValue();
        descriptions=s.slrealtime.slrtAppGenerator.openRecentFiles.description.ActiveValue();
        tags=s.slrealtime.slrtAppGenerator.openRecentFiles.tag.ActiveValue();
        numSavedFiles=numel(texts);
    catch
        numSavedFiles=0;
    end
    for nSavedFile=1:numSavedFiles
        item=ListItem(texts{nSavedFile},this.getIconFile(iconFiles{nSavedFile}));
        item.Tag=tags{nSavedFile};
        item.Description=descriptions{nSavedFile};
        item.ItemPushedFcn=@(o,e)this.toolstripOpenRecentFileCB(texts{nSavedFile},tags{nSavedFile});
        sub_popup.add(item);
    end



    column=Column('HorizontalAlignment','center','Width',30);
    column.Tag=this.TabDesignerSectionFileColumnSave_tag;
    this.FileSection.add(column);
    popup=PopupList();
    item=ListItem(this.Save_msg,this.Save_icon16);
    item.ItemPushedFcn=@(o,e)this.toolstripSaveButtonCB();
    popup.add(item);
    item=ListItem(this.SaveAs_msg,this.SaveAs_icon16);
    item.ItemPushedFcn=@(o,e)this.toolstripSaveAsButtonCB();
    popup.add(item);
    item=ListItem(this.SaveCopyAs_msg,this.SaveCopyAs_icon16);
    item.ItemPushedFcn=@(o,e)this.toolstripSaveCopyAsButtonCB();
    popup.add(item);
    this.SaveButton=SplitButton(this.Save_msg,this.Save_icon24);
    this.SaveButton.ButtonPushedFcn=@(o,e)this.toolstripSaveButtonCB();
    this.SaveButton.Popup=popup;
    column.add(this.SaveButton);



    this.ConfigureSection=this.DesignerTab.addSection(this.Configure_msg);
    this.ConfigureSection.Tag=this.TabDesignerSectionConfigure_tag;



    column=Column('HorizontalAlignment','center','Width',75);
    column.Tag=this.TabDesignerSectionConfigureColumnOptions_tag;
    this.ConfigureSection.add(column);
    this.OptionsButton=DropDownButton(this.Options_msg,this.Settings_icon24);
    group=ButtonGroup;
    this.OptionsToolstripItem=ListItemWithRadioButton(group,this.OptionsToolstripName_msg);
    this.OptionsToolstripItem.Value=this.OptionsToolstripItemDefaultValue;
    this.OptionsToolstripItem.Description=this.OptionsToolstripDesc_msg;
    this.OptionsMenuItem=ListItemWithRadioButton(group,this.OptionsMenuName_msg);
    this.OptionsMenuItem.Value=this.OptionsMenuItemDefaultValue;
    this.OptionsMenuItem.Description=this.OptionsMenuDesc_msg;
    popup=PopupList();
    popup.add(this.OptionsToolstripItem);
    popup.add(this.OptionsMenuItem);

    popup.add(PopupListSeparator);
    this.OptionsStatusBarItem=ListItemWithCheckBox(...
    this.OptionsStatusBarName_msg,...
    this.OptionsStatusBarDesc_msg,...
    this.OptionsStatusBarItemDefaultValue);
    popup.add(this.OptionsStatusBarItem);
    this.OptionsTETMonitorItem=ListItemWithCheckBox(...
    this.OptionsTETName_msg,...
    this.OptionsTETDesc_msg,...
    this.OptionsTETMonitorItemDefaultValue);
    popup.add(this.OptionsTETMonitorItem);
    this.OptionsInstrumentedSignalsItem=ListItemWithCheckBox(...
    this.OptionsInstSignalsName_msg,...
    this.OptionsInstSignalsDesc_msg,...
    this.OptionsInstrumentedSignalsItemDefaultValue);
    popup.add(this.OptionsInstrumentedSignalsItem);
    this.OptionsDashboardItem=ListItemWithCheckBox(...
    this.OptionsDashboardName_msg,...
    this.OptionsDashboardDesc_msg,...
    this.OptionsDashboardItemDefaultValue);
    popup.add(this.OptionsDashboardItem);

    popup.add(PopupListSeparator);
    this.OptionsUseGridItem=ListItemWithCheckBox(...
    this.OptionsUseGridName_msg,...
    this.OptionsUseGridDesc_msg,...
    this.OptionsUseGridItemDefaultValue);
    popup.add(this.OptionsUseGridItem);
    this.OptionsButton.Popup=popup;
    column.add(this.OptionsButton);

    popup.add(PopupListSeparator);
    this.OptionsCallbackItem=ListItemWithCheckBox(...
    this.OptionsCallbackName_msg,...
    this.OptionsCallbackDesc_msg,...
    this.OptionsCallbackItemDefaultValue);
    popup.add(this.OptionsCallbackItem);
    this.OptionsButton.Popup=popup;
    column.add(this.OptionsButton);

    function sub_popup=createPopup(this)
        sub_popup=PopupList();
        popup.add(list);

        if this.OptionsToolstripItem.Value

            item=ListItem(this.OptionsTargetSelector_msg,this.TargetSelector_icon24);
            item.ItemPushedFcn=@(o,e)this.openPropertyInspector(this.PropsTargetSelector);
            sub_popup.add(item);
            item=ListItem(this.OptionsConnectButton_msg,this.Connect_icon24);
            item.ItemPushedFcn=@(o,e)this.openPropertyInspector(this.PropsConnectButton);
            sub_popup.add(item);
            item=ListItem(this.OptionsLoadButton_msg,this.Load_icon24);
            item.ItemPushedFcn=@(o,e)this.openPropertyInspector(this.PropsLoadButton);
            sub_popup.add(item);
            item=ListItem(this.OptionsStartStopButton_msg,this.Start_icon24);
            item.ItemPushedFcn=@(o,e)this.openPropertyInspector(this.PropsStartStopButton);
            sub_popup.add(item);
            item=ListItem(this.OptionsStopTime_msg,this.StopTime_icon24);
            item.ItemPushedFcn=@(o,e)this.openPropertyInspector(this.PropsStopTime);
            sub_popup.add(item);
            item=ListItem(this.OptionsSystemLog_msg,this.SystemLog_icon24);
            item.ItemPushedFcn=@(o,e)this.openPropertyInspector(this.PropsSystemLog);
            sub_popup.add(item);
        else
            item=ListItem(this.OptionsMenu_msg,this.Menu_icon24);
            item.ItemPushedFcn=@(o,e)this.openPropertyInspector(this.PropsMenu);
            sub_popup.add(item);
        end

        if this.OptionsStatusBarItem.Value
            item=ListItem(this.OptionsStatusBar_msg,this.StatusBar_icon24);
            item.ItemPushedFcn=@(o,e)this.openPropertyInspector(this.PropsStatusBar);
            sub_popup.add(item);
        end
    end
    popup.add(PopupListSeparator);
    list=ListItemWithPopup(this.ConfigureComps_msg,this.Settings_icon16);
    list.DynamicPopupFcn=@(o,e)createPopup(this);
    popup.add(list);



    this.BindingsSection=this.DesignerTab.addSection(this.Binding_msg);
    this.BindingsSection.Tag=this.TabDesignerSectionBindings_tag;



    if this.IsSimulinkAvailable
        column=Column('HorizontalAlignment','center','Width',75);
        column.Tag=this.TabDesignerSectionBindingsColumnAddFromModel_tag;
        this.BindingsSection.add(column);
        this.AddFromModelButton=Button(this.AddFromModel_msg,this.ModelFile_icon24);
        this.AddFromModelButton.ButtonPushedFcn=@(o,e)this.toolstripAddFromModelButtonCB();
        column.add(this.AddFromModelButton);
    end



    if this.IsSimulinkAvailable
        column=Column('HorizontalAlignment','center','Width',75);
        column.Tag=this.TabDesignerSectionBindingsColumnHighlight_tag;
        this.BindingsSection.add(column);
        this.HighlightInModelButton=Button(this.HiliteInModel_msg,this.HighlightInModel_icon24);
        this.HighlightInModelButton.ButtonPushedFcn=@(o,e)this.toolstripHighlightInModelCB();
        column.add(this.HighlightInModelButton);
    end



    column=Column('HorizontalAlignment','center','Width',75);
    column.Tag=this.TabDesignerSectionBindingsColumnRemove_tag;
    this.BindingsSection.add(column);
    this.RemoveButton=Button(this.Remove_msg,this.Remove_icon24);
    this.RemoveButton.ButtonPushedFcn=@(o,e)this.toolstripRemoveCB();
    column.add(this.RemoveButton);



    column=Column('HorizontalAlignment','center','Width',75);
    column.Tag=this.TabDesignerSectionBindingsColumnValidate_tag;
    this.BindingsSection.add(column);
    this.ValidateButton=Button(this.Validate_msg,this.Validate_icon24);
    this.ValidateButton.ButtonPushedFcn=@(o,e)this.toolstripValidateButtonCB();
    column.add(this.ValidateButton);



    this.InstrumentPanelSection=this.DesignerTab.addSection(this.InstrumentPanel_msg);
    this.InstrumentPanelSection.Tag=this.TabDesignerSectionInstrumentPanel_tag;



    function toolstripGenerateButtonCB(this)
        this.newInstrumentPanel();
    end
    column=Column('HorizontalAlignment','center','Width',75);
    column.Tag=this.TabDesignerSectionInstrumentPanelColumnGenerate_tag;
    this.InstrumentPanelSection.add(column);
    this.GenerateButton=Button(this.Generate_msg,this.NewInstrumentPanel_icon24);
    this.GenerateButton.ButtonPushedFcn=@(o,e)toolstripGenerateButtonCB(this);
    column.add(this.GenerateButton);



    function toolstripModifyButtonCB(this)
        this.modifyInstrumentPanel();
    end
    column=Column('HorizontalAlignment','center','Width',75);
    column.Tag=this.TabDesignerSectionInstrumentPanelColumnModify_tag;
    this.InstrumentPanelSection.add(column);
    this.ModifyButton=Button(this.Modify_msg,this.EditInstrumentPanel_icon24);
    this.ModifyButton.ButtonPushedFcn=@(o,e)toolstripModifyButtonCB(this);
    column.add(this.ModifyButton);
end
