function dlgStruct=getDialogSchema(this,~)







    lprompt=1;
    rprompt=4;
    ledit=rprompt+1;
    redit=15;
    lunit=redit+1;
    runit=20;
    number_grid=20;



    rs=1;
    Source_linear_gain=simrfV2GetLeafWidgetBase('combobox','',...
    'Source_linear_gain',this,'Source_linear_gain');
    Source_linear_gain.Entries=set(this,'Source_linear_gain')';
    Source_linear_gain.RowSpan=[rs,rs];
    Source_linear_gain.ColSpan=[ledit,runit];
    Source_linear_gain.DialogRefresh=1;

    Source_linear_gainprompt=simrfV2GetLeafWidgetBase('text',...
    'Source of conversion gain:','Source_linear_gainPrompt',0);
    Source_linear_gainprompt.RowSpan=[rs,rs];
    Source_linear_gainprompt.ColSpan=[lprompt,rprompt];


    rs=rs+1;
    linear_gain=simrfV2GetLeafWidgetBase('edit','','linear_gain',this,...
    'linear_gain');
    linear_gain.RowSpan=[rs,rs];
    linear_gain.ColSpan=[ledit,redit];

    linear_gain_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'linear_gain_unit',this,'linear_gain_unit');
    linear_gain_unit.Entries=set(this,'linear_gain_unit')';
    linear_gain_unit.RowSpan=[rs,rs];
    linear_gain_unit.ColSpan=[lunit,runit];

    linear_gainprompt=simrfV2GetLeafWidgetBase('text',...
    [this.Source_linear_gain,':'],'linear_gainprompt',0);
    linear_gainprompt.RowSpan=[rs,rs];
    linear_gainprompt.ColSpan=[lprompt,rprompt];


    rs=rs+1;
    Poly_Coeffs=simrfV2GetLeafWidgetBase('edit','','Poly_Coeffs',...
    this,'Poly_Coeffs');
    Poly_Coeffs.RowSpan=[rs,rs];
    Poly_Coeffs.ColSpan=[ledit,runit];

    Poly_Coeffsprompt=simrfV2GetLeafWidgetBase('text',...
    'Polynomial coefficients:','Poly_Coeffsprompt',0);
    Poly_Coeffsprompt.RowSpan=[rs,rs];
    Poly_Coeffsprompt.ColSpan=[lprompt,rprompt];


    rs=rs+1;
    LOfreqprompt=simrfV2GetLeafWidgetBase('text',...
    'Local oscillator frequency:','LOfreqprompt',0);
    LOfreqprompt.RowSpan=[rs,rs];
    LOfreqprompt.ColSpan=[lprompt,rprompt];

    LOfreq=simrfV2GetLeafWidgetBase('edit','','LOFreq',0,'LOFreq');
    LOfreq.RowSpan=[rs,rs];
    LOfreq.ColSpan=[ledit,redit];

    LOfreq_unit=simrfV2GetLeafWidgetBase('combobox','','LOFreq_unit',...
    this,'LOFreq_unit');
    LOfreq_unit.Entries=set(this,'LOFreq_unit')';
    LOfreq_unit.RowSpan=[rs,rs];
    LOfreq_unit.ColSpan=[lunit,runit];


    rs=rs+1;
    Zin=simrfV2GetLeafWidgetBase('edit','','Zin',this,'Zin');
    Zin.RowSpan=[rs,rs];
    Zin.ColSpan=[ledit,runit];

    Zinprompt=simrfV2GetLeafWidgetBase('text','Input impedance (Ohm):',...
    'Zinprompt',0);
    Zinprompt.RowSpan=[rs,rs];
    Zinprompt.ColSpan=[lprompt,rprompt];


    rs=rs+1;
    Zout=simrfV2GetLeafWidgetBase('edit','','Zout',this,'Zout');
    Zout.RowSpan=[rs,rs];
    Zout.ColSpan=[ledit,runit];

    Zoutprompt=simrfV2GetLeafWidgetBase('text',...
    'Output impedance (Ohm):','Zoutprompt',0);
    Zoutprompt.RowSpan=[rs,rs];
    Zoutprompt.ColSpan=[lprompt,rprompt];


    rs_filt=1;
    addIRfilter=simrfV2GetLeafWidgetBase('checkbox',...
    'Add Image Reject filter','AddIRFilter',this,'AddIRFilter');
    addIRfilter.RowSpan=[rs_filt,rs_filt];
    addIRfilter.ColSpan=[lprompt,floor(number_grid/2)];
    addIRfilter.DialogRefresh=1;


    AddCSFilter=simrfV2GetLeafWidgetBase('checkbox',...
    'Add Channel Select filter','AddCSFilter',this,'AddCSFilter');
    AddCSFilter.RowSpan=[rs_filt,rs_filt];
    AddCSFilter.ColSpan=[floor(number_grid/2)+1,number_grid];
    AddCSFilter.DialogRefresh=1;


    rs=rs+1;
    filters.Type='group';
    filters.Name='Filters';
    filters.LayoutGrid=[rs_filt,number_grid];
    filters.RowStretch=ones(1,rs_filt);
    filters.ColStretch=[1,zeros(1,number_grid-1)];
    filters.RowSpan=[rs,rs];
    filters.ColSpan=[1,number_grid];
    filters.Items={addIRfilter,AddCSFilter};
    filters.Tag='FiltersContainer';


    rs=rs+1;
    grounding=simrfV2GetLeafWidgetBase('checkbox',...
    'Ground and hide negative terminals','InternalGrounding',this,...
    'InternalGrounding');
    grounding.RowSpan=[rs,rs];
    grounding.ColSpan=[lprompt,number_grid];
    grounding.DialogRefresh=1;


    rs=rs+1;
    spacerMain=simrfV2GetLeafWidgetBase('text',' ','',0);
    spacerMain.RowSpan=[rs,rs];
    spacerMain.ColSpan=[lprompt,rprompt];


    rs=rs+1;
    EditButton=simrfV2GetLeafWidgetBase('pushbutton',...
    'Edit System','EditButton',0,'EditButton');
    EditButton.RowSpan=[rs,rs];
    EditButton.ColSpan=[lunit-1,runit];
    EditButton.ObjectMethod='simrfV2expand';
    EditButton.MethodArgs={'%dialog'};
    EditButton.ArgDataTypes={'handle'};

    maxrows=spacerMain.RowSpan(1);



    hBlk=get_param(this,'Handle');
    idxMaskNames=simrfV2getblockmaskparamsindex(hBlk);
    slBlkVis=get_param(hBlk,'MaskVisibilities');

    Source_linear_gain.Visible=1;
    Source_linear_gainprompt.Visible=1;
    linear_gain.Visible=0;
    linear_gain_unit.Visible=0;
    linear_gainprompt.Visible=0;
    Poly_Coeffs.Visible=0;
    Poly_Coeffsprompt.Visible=0;
    Zin.Visible=1;
    Zinprompt.Visible=1;
    Zout.Visible=1;
    Zoutprompt.Visible=1;
    slBlkVis([idxMaskNames.linear_gain,idxMaskNames.linear_gain_unit...
    ,idxMaskNames.Poly_Coeffs])={'off'};
    slBlkVis([idxMaskNames.Zin,idxMaskNames.Zout,idxMaskNames.NF])={'on'};

    switch this.Source_linear_gain
    case 'Polynomial coefficients'
        Poly_Coeffs.Visible=1;
        Poly_Coeffsprompt.Visible=1;
        slBlkVis(idxMaskNames.Poly_Coeffs)={'on'};

    otherwise
        linear_gain.Visible=1;
        linear_gain_unit.Visible=1;
        linear_gainprompt.Visible=1;
        slBlkVis([idxMaskNames.linear_gain...
        ,idxMaskNames.linear_gain_unit])={'on'};
    end

    EditButton.Enabled=true;
    if(~strcmp(fileparts(get_param(hBlk,'ReferenceBlock')),'simrfV2systems'))
        EditButton.Enabled=false;
    end


    [impItems,impLayout,slBlkVis]=simrfV2create_rfmodimp_pane(this,...
    slBlkVis,idxMaskNames);


    [nlItems,nlLayout,slBlkVis]=simrfV2create_nldata_pane(this,...
    slBlkVis,idxMaskNames);


    [IRFItems,IRFLayout,slBlkVis]=simrfV2create_filtmain_pane(this,...
    slBlkVis,idxMaskNames,'IR',this.AddIRFilter);


    [CSFItems,CSFLayout,slBlkVis]=simrfV2create_filtmain_pane(this,...
    slBlkVis,idxMaskNames,'CS',this.AddCSFilter);


    if~strcmpi(get_param(bdroot(hBlk),'Lock'),'on')
        set_param(hBlk,'MaskVisibilities',slBlkVis);

        set_param(hBlk,'MaskVisibilities',slBlkVis);

    end







    mainItems={Zin,Zinprompt,Zout,Zoutprompt,filters,grounding,...
    spacerMain,EditButton,linear_gain,linear_gain_unit,...
    linear_gainprompt,LOfreqprompt,LOfreq,LOfreq_unit,...
    Source_linear_gain,Source_linear_gainprompt,Poly_Coeffs,...
    Poly_Coeffsprompt};

    mainLayout.LayoutGrid=[maxrows,number_grid];
    mainLayout.RowSpan=[2,2];
    mainLayout.ColSpan=[1,1];
    mainLayout.RowStretch=[zeros(1,maxrows-1),1];


    mainPane=simrfV2create_panel(this,'MainPane',mainItems,mainLayout);


    ImpairmentsPane=simrfV2create_panel(this,'ImpairmentsPane',...
    impItems,impLayout);


    nonlinearityPane=simrfV2create_panel(this,'NonlinearPane',nlItems,...
    nlLayout);


    IRfilterPane=simrfV2create_panel(this,'IRFPane',IRFItems,IRFLayout);


    CSfilterPane=simrfV2create_panel(this,'CSFPane',CSFItems,CSFLayout);



    mainTab.Name='Main';
    mainTab.Items={mainPane};
    mainTab.LayoutGrid=[1,1];
    mainTab.RowStretch=0;
    mainTab.ColStretch=0;


    impairmentsTab.Name='Impairments';
    impairmentsTab.Items={ImpairmentsPane};
    impairmentsTab.LayoutGrid=[1,1];
    impairmentsTab.RowStretch=0;
    impairmentsTab.ColStretch=0;


    nonlinearityTab.Name='Nonlinearity';
    nonlinearityTab.Items={nonlinearityPane};
    nonlinearityTab.LayoutGrid=[1,1];
    nonlinearityTab.RowStretch=0;
    nonlinearityTab.ColStretch=0;


    irfilterTab.Name='IR Filter';
    irfilterTab.Items={IRfilterPane};
    irfilterTab.LayoutGrid=[1,1];
    irfilterTab.RowStretch=0;
    irfilterTab.ColStretch=0;


    csfilterTab.Name='CS Filter';
    csfilterTab.Items={CSfilterPane};
    csfilterTab.LayoutGrid=[1,1];
    csfilterTab.RowStretch=0;
    csfilterTab.ColStretch=0;


    tabbedPane.Type='tab';
    tabbedPane.Name='';
    tabbedPane.Tag='TabPane';
    tabbedPane.RowSpan=[2,2];
    tabbedPane.ColSpan=[1,1];

    if strcmpi(this.Source_linear_gain,'Polynomial coefficients')
        tabbedPane.Tabs={mainTab,impairmentsTab};
    else
        tabbedPane.Tabs={mainTab,impairmentsTab,nonlinearityTab};
    end

    if(this.AddIRFilter)
        tabbedPane.Tabs=[tabbedPane.Tabs,{irfilterTab}];
    end

    if(this.AddCSFilter)
        tabbedPane.Tabs=[tabbedPane.Tabs,{csfilterTab}];
    end


    dlgStruct=getBaseSchemaStruct(this,tabbedPane);

