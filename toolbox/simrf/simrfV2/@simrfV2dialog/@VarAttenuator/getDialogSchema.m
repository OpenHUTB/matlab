function dlgStruct=getDialogSchema(this,~)







    lprompt=1;
    rprompt=4;
    ledit=rprompt+1;
    redit=20;




    rs=1;
    Attminprompt=simrfV2GetLeafWidgetBase('text',...
    'Minimum attenuation (dB):','Attminprompt',0);
    Attminprompt.RowSpan=[rs,rs];
    Attminprompt.ColSpan=[lprompt,rprompt];

    Attmin=simrfV2GetLeafWidgetBase('edit','','Attmin',this,'Attmin');
    Attmin.RowSpan=[rs,rs];
    Attmin.ColSpan=[ledit,redit];


    rs=rs+1;
    Attmaxprompt=simrfV2GetLeafWidgetBase('text',...
    'Maximum attenuation (dB):','Attmaxprompt',0);
    Attmaxprompt.RowSpan=[rs,rs];
    Attmaxprompt.ColSpan=[lprompt,rprompt];

    Attmax=simrfV2GetLeafWidgetBase('edit','','Attmax',this,'Attmax');
    Attmax.RowSpan=[rs,rs];
    Attmax.ColSpan=[ledit,redit];


    rs=rs+1;

    Zinprompt=simrfV2GetLeafWidgetBase('text','Input impedance (Ohm):',...
    'Zinprompt',0);
    Zinprompt.RowSpan=[rs,rs];
    Zinprompt.ColSpan=[lprompt,rprompt];

    Zin=simrfV2GetLeafWidgetBase('edit','','Zin',this,'Zin');
    Zin.RowSpan=[rs,rs];
    Zin.ColSpan=[ledit,redit];


    rs=rs+1;

    Zoutprompt=simrfV2GetLeafWidgetBase('text','Output impedance (Ohm):',...
    'Zoutprompt',0);
    Zoutprompt.RowSpan=[rs,rs];
    Zoutprompt.ColSpan=[lprompt,rprompt];

    Zout=simrfV2GetLeafWidgetBase('edit','','Zout',this,'Zout');
    Zout.RowSpan=[rs,rs];
    Zout.ColSpan=[ledit,redit];


    rs=rs+1;

    addnoise=simrfV2GetLeafWidgetBase('checkbox','Simulate noise',...
    'AddNoise',this,'AddNoise');
    addnoise.RowSpan=[rs,rs];
    addnoise.ColSpan=[lprompt,redit];
    addnoise.DialogRefresh=1;

    rs=rs+1;

    grounding=simrfV2GetLeafWidgetBase('checkbox',...
    'Ground and hide negative terminals','InternalGrounding',this,...
    'InternalGrounding');
    grounding.RowSpan=[rs,rs];
    grounding.ColSpan=[lprompt,redit];



    mainParamsPanel.Type='group';
    mainParamsPanel.Name='Parameters';
    mainParamsPanel.Tag='mainParamsPanel';
    mainParamsPanel.Items={Attminprompt,Attmin,...
    Attmaxprompt,Attmax,...
    Zinprompt,Zin,...
    Zoutprompt,Zout,...
    addnoise,...
    grounding};
    mainParamsPanel.LayoutGrid=[rs,redit];
    mainParamsPanel.ColStretch=[0,0,0,0,ones(1,16)];
    mainParamsPanel.RowSpan=[2,2];
    mainParamsPanel.ColSpan=[1,1];


    dlgStruct=getBaseSchemaStruct(this,mainParamsPanel);

