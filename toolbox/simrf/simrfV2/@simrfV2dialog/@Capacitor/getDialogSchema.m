function dlgStruct=getDialogSchema(this,~)








    lprompt=1;
    rprompt=4;
    ledit=rprompt+1;
    redit=18;
    lunit=redit+1;
    runit=20;




    rs=1;
    capacitanceprompt=simrfV2GetLeafWidgetBase('text','Capacitance:',...
    'capacitanceprompt',0);
    capacitanceprompt.RowSpan=[rs,rs];
    capacitanceprompt.ColSpan=[lprompt,rprompt];

    capacitance=simrfV2GetLeafWidgetBase('edit','','Capacitance',this,...
    'Capacitance');
    capacitance.RowSpan=[rs,rs];
    capacitance.ColSpan=[ledit,redit];

    capacitance_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'Capacitance_unit',this,'Capacitance_unit');
    capacitance_unit.Entries=set(this,'Capacitance_unit')';
    capacitance_unit.RowSpan=[rs,rs];
    capacitance_unit.ColSpan=[lunit,runit];



    mainParamsPanel.Type='group';
    mainParamsPanel.Name='Parameters';
    mainParamsPanel.Tag='mainParamsPanel';
    mainParamsPanel.Items={capacitanceprompt,capacitance,capacitance_unit};
    mainParamsPanel.LayoutGrid=[rs,runit];
    mainParamsPanel.RowSpan=[2,2];
    mainParamsPanel.ColSpan=[1,1];


    dlgStruct=getBaseSchemaStruct(this,mainParamsPanel);

