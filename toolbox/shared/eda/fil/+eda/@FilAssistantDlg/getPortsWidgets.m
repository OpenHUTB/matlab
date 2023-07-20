function WidgetGroup=getPortsWidgets(this)





    PortEditOption.Name='';
    PortEditOption.Type='radiobutton';
    PortEditOption.Tag='edaPortEditOption';
    PortEditOption.Entries={...
    this.getCatalogMsgStr('AutoGenOpt_RadioButton'),...
    this.getCatalogMsgStr('ManualGenOpt_RadioButton')};
    PortEditOption.ObjectProperty='PortEditOption';
    PortEditOption.Mode=1;
    PortEditOption.DialogRefresh=true;
    PortEditOption.RowSpan=[1,1];
    PortEditOption.ColSpan=[1,6];
    if this.PortEditOption~=this.SavedPortEditOption
        if(this.PortEditOption==0)

            this.Status=this.getCatalogMsgStr('SwitchToAuto_Msg');
        else

            this.Status=this.getCatalogMsgStr('SwitchToManual_Msg');
        end
        this.SavedPortEditOption=this.PortEditOption;
    end

    PortsTxt.Name=this.getCatalogMsgStr('PortTable_Text');
    PortsTxt.Type='text';
    PortsTxt.Tag='edaPortsTxt';
    PortsTxt.RowSpan=[2,2];
    PortsTxt.ColSpan=[1,1];


    PortsTbl.Tag='edaPortTable';
    PortsTbl.Type='table';
    PortsTbl.RowSpan=[3,8];
    PortsTbl.ColSpan=[1,6];
    PortsTbl.Size=size(this.PortTableData);
    PortsTbl.Data=this.PortTableData;
    PortsTbl.HeaderVisibility=[0,1];
    PortsTbl.ColHeader={this.getCatalogMsgStr('PortName_ColHeader'),...
    this.getCatalogMsgStr('PortDirection_ColHeader'),...
    this.getCatalogMsgStr('PortWidth_ColHeader'),...
    this.getCatalogMsgStr('PortType_ColHeader')};
    PortsTbl.RowHeader={};
    PortsTbl.ColumnHeaderHeight=2;
    PortsTbl.ColumnCharacterWidth=[30,10,7,17];
    PortsTbl.Enabled=true;
    PortsTbl.Editable=true;
    PortsTbl.Mode=1;
    PortsTbl.FontFamily='Courier';
    PortsTbl.ValueChangedCallback=@l_tableValueChangeCb;
    if(this.PortEditOption==0)
        PortsTbl.ReadOnlyColumns=[0,1,2];
    end

    AddPortBtn.Name=this.getCatalogMsgStr('Add_Button');
    AddPortBtn.Tag='edaAddPortBtn';
    AddPortBtn.Type='pushbutton';
    AddPortBtn.ObjectMethod='onAddNewPort';
    AddPortBtn.MethodArgs={'%dialog'};
    AddPortBtn.ArgDataTypes={'handle'};
    AddPortBtn.RowSpan=[1,1];
    AddPortBtn.ColSpan=[1,1];
    AddPortBtn.Enabled=true;

    RemovePortBtn.Name=this.getCatalogMsgStr('Remove_Button');
    RemovePortBtn.Tag='edaRemovePortBtn';
    RemovePortBtn.Type='pushbutton';
    RemovePortBtn.ObjectMethod='onRemovePort';
    RemovePortBtn.MethodArgs={'%dialog'};
    RemovePortBtn.ArgDataTypes={'handle'};
    RemovePortBtn.RowSpan=[2,2];
    RemovePortBtn.ColSpan=[1,1];
    RemovePortBtn.Enabled=(PortsTbl.Size(1)>0);
    RemovePortBtn.Visible=(this.PortEditOption==1);

    RegenerateBtn.Name=this.getCatalogMsgStr('Regenerate_Button');
    RegenerateBtn.Tag='edaRegenerateBtn';
    RegenerateBtn.Type='pushbutton';
    RegenerateBtn.ObjectMethod='onRegeneratePort';
    RegenerateBtn.MethodArgs={'%dialog'};
    RegenerateBtn.ArgDataTypes={'handle'};
    RegenerateBtn.RowSpan=[1,1];
    RegenerateBtn.ColSpan=[1,1];
    RegenerateBtn.Enabled=true;

    ButtonPanel1.Name='';
    ButtonPanel1.Tag='edaButtonPanel1';
    ButtonPanel1.Type='panel';
    ButtonPanel1.RowSpan=[3,4];
    ButtonPanel1.ColSpan=[7,7];
    ButtonPanel1.ColSpan=[7,7];
    ButtonPanel1.Items={RegenerateBtn};
    ButtonPanel1.LayoutGrid=[2,1];

    ButtonPanel2.Name='';
    ButtonPanel2.Tag='edaButtonPanel2';
    ButtonPanel2.Type='panel';
    ButtonPanel2.RowSpan=[3,4];
    ButtonPanel2.ColSpan=[7,7];
    ButtonPanel2.Items={AddPortBtn,RemovePortBtn};
    ButtonPanel2.LayoutGrid=[2,1];


    ButtonStack.Name='';
    ButtonStack.Tag='edaButtonStack';
    ButtonStack.Type='widgetstack';
    ButtonStack.RowSpan=[3,3];
    ButtonStack.ColSpan=[7,7];
    ButtonStack.Items={ButtonPanel1,ButtonPanel2};
    ButtonStack.ActiveWidget=this.PortEditOption;

    ResetLevelTxt.Name=this.getCatalogMsgStr('ResetLevel_Text');
    ResetLevelTxt.Tag='edaResetLevelTxt';
    ResetLevelTxt.Type='text';
    ResetLevelTxt.RowSpan=[1,1];
    ResetLevelTxt.ColSpan=[1,2];

    ResetLevelSel.Tag='edaResetAssertLevel';
    ResetLevelSel.Type='combobox';
    ResetLevelSel.RowSpan=[1,1];
    ResetLevelSel.ColSpan=[3,4];
    ResetLevelSel.Entries=this.BuildInfo.getAssertedLevels;
    ResetLevelSel.ObjectProperty='ResetAssertLevel';
    ResetLevelSel.Mode=1;

    ResetLevelSel.Enabled=l_hasReset(this);

    ClockLevelTxt.Name=this.getCatalogMsgStr('ClkEnLevel_Text');
    ClockLevelTxt.Tag='edaClockLevelTxt';
    ClockLevelTxt.Type='text';
    ClockLevelTxt.RowSpan=[1,1];
    ClockLevelTxt.ColSpan=[5,6];

    ClockLevelSel.Tag='edaClockEnableAssertLevel';
    ClockLevelSel.Type='combobox';
    ClockLevelSel.RowSpan=[1,1];
    ClockLevelSel.ColSpan=[7,8];
    ClockLevelSel.Entries=this.BuildInfo.getAssertedLevels;
    ClockLevelSel.ObjectProperty='ClockEnableAssertLevel';
    ClockLevelSel.Mode=1;

    ClockLevelSel.Enabled=l_hasClkEn(this);

    AssertLevelGroup.Tag='edaAssertLevelGroup';
    AssertLevelGroup.Type='panel';
    AssertLevelGroup.RowSpan=[9,9];
    AssertLevelGroup.ColSpan=[1,6];
    AssertLevelGroup.LayoutGrid=[1,8];
    AssertLevelGroup.ColStretch=ones(1,8);
    AssertLevelGroup.Items={ResetLevelTxt,ClockLevelTxt,...
    ResetLevelSel,ClockLevelSel};


    WidgetGroup=this.getWidgetGroup;
    WidgetGroup.Tag='edaWidgetGroupPorts';
    WidgetGroup.LayoutGrid=[9,7];
    WidgetGroup.RowStretch=[1,0,1,1,1,1,1,1,1];
    WidgetGroup.ColStretch=ones(1,7);
    WidgetGroup.Items={PortEditOption,PortsTxt,PortsTbl,...
    ButtonStack,AssertLevelGroup};

end

function l_tableValueChangeCb(dlg,row,col,value)
    src=dlg.getSource;
    if src.IsInHDLWA
        this=Advisor.Utils.convertMCOS(dlg.getSource);
    else
        this=src;
    end

    switch(col)
    case{0}
        this.PortTableData{row+1,1}=value;
    case{1}

        Direction=dlg.getTableItemValue('edaPortTable',row,1);
        this.PortTableData{row+1,2}.Value=value;
        this.PortTableData{row+1,4}.Entries=this.BuildInfo.getPortTypes(Direction);
        dlg.refresh;
    case{2}
        this.PortTableData{row+1,3}=value;
    case{3}
        this.PortTableData{row+1,4}.Value=value;
        dlg.setEnabled('edaResetAssertLevel',l_hasReset(this));
        dlg.setEnabled('edaClockEnableAssertLevel',l_hasClkEn(this));
    end
end

function hasReset=l_hasReset(this)
    [mrow,~]=size(this.PortTableData);
    hasReset=false;
    for m=1:mrow
        if(this.PortTableData{m,2}.Value==0)&&(this.PortTableData{m,4}.Value==3)
            hasReset=true;
            break;
        end
    end
end

function hasClkEn=l_hasClkEn(this)
    [mrow,~]=size(this.PortTableData);
    hasClkEn=false;
    for m=1:mrow
        if(this.PortTableData{m,2}.Value==0)&&(this.PortTableData{m,4}.Value==2)
            hasClkEn=true;
            break;
        end
    end
end