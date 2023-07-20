function dlgStruct=getDialogSchema(this,~)








    lprompt=1;
    rprompt=4;
    ledit=rprompt+1;
    redit=18;
    lunit=redit+1;
    runit=20;




    rs=1;
    resistanceprompt=simrfV2GetLeafWidgetBase('text','Resistance:',...
    'resistanceprompt',0);
    resistanceprompt.RowSpan=[rs,rs];
    resistanceprompt.ColSpan=[lprompt,rprompt];

    resistance=simrfV2GetLeafWidgetBase('edit','','Resistance',this,...
    'Resistance');
    resistance.RowSpan=[rs,rs];
    resistance.ColSpan=[ledit,redit];

    resistanceunit=simrfV2GetLeafWidgetBase('combobox','',...
    'Resistance_unit',this,'Resistance_unit');
    resistanceunit.Entries=set(this,'Resistance_unit')';
    resistanceunit.RowSpan=[rs,rs];
    resistanceunit.ColSpan=[lunit,runit];


    rs=rs+1;
    addnoise=simrfV2GetLeafWidgetBase('checkbox','Simulate noise',...
    'AddNoise',this,'AddNoise');
    addnoise.RowSpan=[rs,rs];
    addnoise.ColSpan=[lprompt,rprompt];
    addnoise.DialogRefresh=1;



    mainParamsPanel.Type='group';
    mainParamsPanel.Name='Parameters';
    mainParamsPanel.Tag='mainParamsPanel';
    mainParamsPanel.Items={...
    resistanceprompt,resistance,resistanceunit,addnoise};
    mainParamsPanel.LayoutGrid=[rs,runit];
    mainParamsPanel.ColStretch=[0,0,0,0,ones(1,14),0,0];
    mainParamsPanel.RowSpan=[2,2];
    mainParamsPanel.ColSpan=[1,1];


    dlgStruct=getBaseSchemaStruct(this,mainParamsPanel);

