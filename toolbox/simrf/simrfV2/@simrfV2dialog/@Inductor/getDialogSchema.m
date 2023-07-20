function dlgStruct=getDialogSchema(this,~)








    lprompt=1;
    rprompt=4;
    ledit=rprompt+1;
    redit=18;
    lunit=redit+1;
    runit=20;




    rs=1;
    inductanceprompt=simrfV2GetLeafWidgetBase('text','Inductance:',...
    'inductanceprompt',0);
    inductanceprompt.RowSpan=[rs,rs];
    inductanceprompt.ColSpan=[lprompt,rprompt];

    inductance=simrfV2GetLeafWidgetBase('edit','','Inductance',this,...
    'Inductance');
    inductance.RowSpan=[rs,rs];
    inductance.ColSpan=[ledit,redit];

    inductance_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'Inductance_unit',this,'Inductance_unit');
    inductance_unit.Entries=set(this,'Inductance_unit')';
    inductance_unit.RowSpan=[rs,rs];
    inductance_unit.ColSpan=[lunit,runit];



    mainParamsPanel.Type='group';
    mainParamsPanel.Name='Parameters';
    mainParamsPanel.Tag='mainParamsPanel';
    mainParamsPanel.Items={inductanceprompt,inductance,inductance_unit};
    mainParamsPanel.LayoutGrid=[rs,runit];
    mainParamsPanel.RowSpan=[2,2];
    mainParamsPanel.ColSpan=[1,1];


    dlgStruct=getBaseSchemaStruct(this,mainParamsPanel);

