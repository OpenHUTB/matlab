function dlgStruct=getDialogSchema(this,~)









    lprompt=1;
    rprompt=4;
    ledit=rprompt+1;
    redit=18;
    lunit=redit+1;
    runit=20;
    number_grid=20;



    sourcetype=simrfV2GetLeafWidgetBase('combobox','','SineSourceType',...
    this,'SineSourceType');
    sourcetype.Entries=set(this,'SineSourceType')';
    sourcetype.RowSpan=[1,1];
    sourcetype.ColSpan=[ledit,runit];
    sourcetype.DialogRefresh=1;

    sourcetypeprompt=simrfV2GetLeafWidgetBase('text','Source type:',...
    'SourceTypePrompt',0);
    sourcetypeprompt.RowSpan=[1,1];
    sourcetypeprompt.ColSpan=[lprompt,rprompt];


    VO_I=simrfV2GetLeafWidgetBase('edit','','VO_I',this,'VO_I');
    VO_I.RowSpan=[2,2];
    VO_I.ColSpan=[ledit,redit];

    IO_I=simrfV2GetLeafWidgetBase('edit','','IO_I',this,'IO_I');
    IO_I.RowSpan=[2,2];
    IO_I.ColSpan=[ledit,redit];

    VO_I_unit=simrfV2GetLeafWidgetBase('combobox','','VO_I_unit',...
    this,'VO_I_unit');
    VO_I_unit.Entries=set(this,'VO_I_unit')';
    VO_I_unit.RowSpan=[2,2];
    VO_I_unit.ColSpan=[lunit,runit];

    IO_I_unit=simrfV2GetLeafWidgetBase('combobox','','IO_I_unit',...
    this,'IO_I_unit');
    IO_I_unit.Entries=set(this,'IO_I_unit')';
    IO_I_unit.RowSpan=[2,2];
    IO_I_unit.ColSpan=[lunit,runit];

    VO_I_prompt=simrfV2GetLeafWidgetBase('text','Offset in-phase:',...
    'VO_I_prompt',0);
    VO_I_prompt.RowSpan=[2,2];
    VO_I_prompt.ColSpan=[lprompt,rprompt];


    VA_I=simrfV2GetLeafWidgetBase('edit','','VA_I',this,'VA_I');
    VA_I.RowSpan=[4,4];
    VA_I.ColSpan=[ledit,redit];

    IA_I=simrfV2GetLeafWidgetBase('edit','','IA_I',this,'IA_I');
    IA_I.RowSpan=[4,4];
    IA_I.ColSpan=[ledit,redit];

    VA_I_unit=simrfV2GetLeafWidgetBase('combobox','','VA_I_unit',...
    this,'VA_I_unit');
    VA_I_unit.Entries=set(this,'VA_I_unit')';
    VA_I_unit.RowSpan=[4,4];
    VA_I_unit.ColSpan=[lunit,runit];

    IA_I_unit=simrfV2GetLeafWidgetBase('combobox','','IA_I_unit',...
    this,'IA_I_unit');
    IA_I_unit.Entries=set(this,'IA_I_unit')';
    IA_I_unit.RowSpan=[4,4];
    IA_I_unit.ColSpan=[lunit,runit];

    VA_I_prompt=simrfV2GetLeafWidgetBase('text','Sinusoidal amplitude in-phase:',...
    'VA_I_prompt',0);
    VA_I_prompt.RowSpan=[4,4];
    VA_I_prompt.ColSpan=[lprompt,rprompt];


    VO_Q=simrfV2GetLeafWidgetBase('edit','','VO_Q',this,'VO_Q');
    VO_Q.RowSpan=[3,3];
    VO_Q.ColSpan=[ledit,redit];

    IO_Q=simrfV2GetLeafWidgetBase('edit','','IO_Q',this,'IO_Q');
    IO_Q.RowSpan=[3,3];
    IO_Q.ColSpan=[ledit,redit];

    VO_Q_unit=simrfV2GetLeafWidgetBase('combobox','','VO_Q_unit',...
    this,'VO_Q_unit');
    VO_Q_unit.Entries=set(this,'VO_Q_unit')';
    VO_Q_unit.RowSpan=[3,3];
    VO_Q_unit.ColSpan=[lunit,runit];

    IO_Q_unit=simrfV2GetLeafWidgetBase('combobox','','IO_Q_unit',...
    this,'IO_Q_unit');
    IO_Q_unit.Entries=set(this,'IO_Q_unit')';
    IO_Q_unit.RowSpan=[3,3];
    IO_Q_unit.ColSpan=[lunit,runit];

    VO_Q_prompt=simrfV2GetLeafWidgetBase('text','Offset quadrature:',...
    'VO_Q_prompt',0);
    VO_Q_prompt.RowSpan=[3,3];
    VO_Q_prompt.ColSpan=[lprompt,rprompt];


    VA_Q=simrfV2GetLeafWidgetBase('edit','','VA_Q',this,'VA_Q');
    VA_Q.RowSpan=[5,5];
    VA_Q.ColSpan=[ledit,redit];

    IA_Q=simrfV2GetLeafWidgetBase('edit','','IA_Q',this,'IA_Q');
    IA_Q.RowSpan=[5,5];
    IA_Q.ColSpan=[ledit,redit];

    VA_Q_unit=simrfV2GetLeafWidgetBase('combobox','','VA_Q_unit',...
    this,'VA_Q_unit');
    VA_Q_unit.Entries=set(this,'VA_Q_unit')';
    VA_Q_unit.RowSpan=[5,5];
    VA_Q_unit.ColSpan=[lunit,runit];

    IA_Q_unit=simrfV2GetLeafWidgetBase('combobox','','IA_Q_unit',...
    this,'IA_Q_unit');
    IA_Q_unit.Entries=set(this,'IA_Q_unit')';
    IA_Q_unit.RowSpan=[5,5];
    IA_Q_unit.ColSpan=[lunit,runit];

    VA_Q_prompt=simrfV2GetLeafWidgetBase('text','Sinusoidal amplitude quadrature:',...
    'VA_Q_prompt',0);
    VA_Q_prompt.RowSpan=[5,5];
    VA_Q_prompt.ColSpan=[lprompt,rprompt];


    Fmod=simrfV2GetLeafWidgetBase('edit','','Fmod',this,'Fmod');
    Fmod.RowSpan=[6,6];
    Fmod.ColSpan=[ledit,redit];

    Fmod_unit=simrfV2GetLeafWidgetBase('combobox','','Fmod_unit',...
    this,'Fmod_unit');
    Fmod_unit.Entries=set(this,'Fmod_unit')';
    Fmod_unit.RowSpan=[6,6];
    Fmod_unit.ColSpan=[lunit,runit];

    Fmod_prompt=simrfV2GetLeafWidgetBase('text','Sinusoidal modulation frequency:',...
    'Fmod_prompt',0);
    Fmod_prompt.RowSpan=[6,6];
    Fmod_prompt.ColSpan=[lprompt,rprompt];


    TD=simrfV2GetLeafWidgetBase('edit','','TD',this,'TD');
    TD.RowSpan=[7,7];
    TD.ColSpan=[ledit,redit];

    TD_unit=simrfV2GetLeafWidgetBase('combobox','','TD_unit',...
    this,'TD_unit');
    TD_unit.Entries=set(this,'TD_unit')';
    TD_unit.RowSpan=[7,7];
    TD_unit.ColSpan=[lunit,runit];

    TD_prompt=simrfV2GetLeafWidgetBase('text','Time delay:',...
    'TD_prompt',0);
    TD_prompt.RowSpan=[7,7];
    TD_prompt.ColSpan=[lprompt,rprompt];


















    freqprompt=simrfV2GetLeafWidgetBase('text','Carrier frequencies:',...
    'CarrierFreqPrompt',0);
    freqprompt.RowSpan=[8,8];
    freqprompt.ColSpan=[lprompt,rprompt];

    freq=simrfV2GetLeafWidgetBase('edit','','CarrierFreq',0,'CarrierFreq');
    freq.RowSpan=[8,8];
    freq.ColSpan=[ledit,redit];

    frequnit=simrfV2GetLeafWidgetBase('combobox','','CarrierFreq_unit',...
    this,'CarrierFreq_unit');
    frequnit.Entries=set(this,'CarrierFreq_unit')';
    frequnit.RowSpan=[8,8];
    frequnit.ColSpan=[lunit,runit];


    grounding=simrfV2GetLeafWidgetBase('checkbox','Ground and hide negative terminal',...
    'InternalGrounding',this,'InternalGrounding');
    grounding.RowSpan=[9,9];
    grounding.ColSpan=[lprompt,runit];


    spacerMain=simrfV2GetLeafWidgetBase('text',' ','',0);
    spacerMain.RowSpan=[10,10];
    spacerMain.ColSpan=[lprompt,runit];

    maxrows=spacerMain.RowSpan(1);

    switch this.SineSourceType
    case 'Ideal voltage'
        VO_I.Visible=1;
        VO_I_unit.Visible=1;
        IO_I.Visible=0;
        IO_I_unit.Visible=0;
        VA_I.Visible=1;
        VA_I_unit.Visible=1;
        IA_I.Visible=0;
        IA_I_unit.Visible=0;

        VO_Q.Visible=1;
        VO_Q_unit.Visible=1;
        IO_Q.Visible=0;
        IO_Q_unit.Visible=0;
        VA_Q.Visible=1;
        VA_Q_unit.Visible=1;
        IA_Q.Visible=0;
        IA_Q_unit.Visible=0;

    case 'Ideal current'
        VO_I.Visible=0;
        VO_I_unit.Visible=0;
        IO_I.Visible=1;
        IO_I_unit.Visible=1;
        VA_I.Visible=0;
        VA_I_unit.Visible=0;
        IA_I.Visible=1;
        IA_I_unit.Visible=1;

        VO_Q.Visible=0;
        VO_Q_unit.Visible=0;
        IO_Q.Visible=1;
        IO_Q_unit.Visible=1;
        VA_Q.Visible=0;
        VA_Q_unit.Visible=0;
        IA_Q.Visible=1;
        IA_Q_unit.Visible=1;
    end




    mainParamsPanel.Type='group';
    mainParamsPanel.Name='Parameters';
    mainParamsPanel.Tag='mainParamsPanel';
    mainParamsPanel.Items={sourcetype,sourcetypeprompt,freqprompt,...
    freq,frequnit,VO_I,IO_I,VO_I_unit,IO_I_unit,VO_I_prompt,VO_Q,...
    IO_Q,VO_Q_unit,IO_Q_unit,VO_Q_prompt,VA_I,IA_I,VA_I_unit,...
    IA_I_unit,VA_I_prompt,VA_Q,IA_Q,VA_Q_unit,IA_Q_unit,VA_Q_prompt,...
    Fmod,Fmod_unit,Fmod_prompt,TD,TD_unit,TD_prompt,...
    grounding,spacerMain};
    mainParamsPanel.LayoutGrid=[maxrows,number_grid];
    mainParamsPanel.ColStretch=[0,0,0,0,ones(1,14),0,0];
    mainParamsPanel.RowSpan=[2,2];
    mainParamsPanel.ColSpan=[1,1];


    dlgStruct=getBaseSchemaStruct(this,mainParamsPanel);

