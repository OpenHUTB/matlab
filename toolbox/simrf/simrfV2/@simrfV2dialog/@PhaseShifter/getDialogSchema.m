function dlgStruct=getDialogSchema(this,~)







    lprompt=1;
    rprompt=4;
    ledit=rprompt+1;
    redit=15;
    lunit=redit+1;
    runit=20;
    number_grid=20;



    rs=1;
    PhaseShiftprompt=simrfV2GetLeafWidgetBase('text','Phase shift:',...
    'PhaseShiftprompt',0);
    PhaseShiftprompt.RowSpan=[rs,rs];
    PhaseShiftprompt.ColSpan=[lprompt,rprompt];

    PhaseShift=simrfV2GetLeafWidgetBase('edit','','PhaseShift',...
    this,'PhaseShift');
    PhaseShift.RowSpan=[rs,rs];
    PhaseShift.ColSpan=[ledit,redit];


    PhaseShift_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'PhaseShift_unit',this,'PhaseShift_unit');
    PhaseShift_unit.Entries=set(this,'PhaseShift_unit')';
    PhaseShift_unit.RowSpan=[rs,rs];
    PhaseShift_unit.ColSpan=[lunit,runit];


    rs=rs+1;
    grounding=simrfV2GetLeafWidgetBase('checkbox',...
    'Ground and hide negative terminals','InternalGrounding',...
    this,'InternalGrounding');
    grounding.RowSpan=[rs,rs];
    grounding.ColSpan=[lprompt,number_grid];


    rs=rs+1;
    spacerMain=simrfV2GetLeafWidgetBase('text',' ','',0);
    spacerMain.RowSpan=[rs,rs];
    spacerMain.ColSpan=[lprompt,rprompt];

    maxrows=spacerMain.RowSpan(1);



    mainParamsPanel.Type='group';
    mainParamsPanel.Name='Parameters';
    mainParamsPanel.Tag='mainParamsPanel';
    mainParamsPanel.Items={PhaseShiftprompt,PhaseShift,PhaseShift_unit,...
    grounding,spacerMain};
    mainParamsPanel.LayoutGrid=[maxrows,number_grid];
    mainParamsPanel.RowSpan=[2,2];
    mainParamsPanel.ColSpan=[1,1];


    dlgStruct=getBaseSchemaStruct(this,mainParamsPanel);

