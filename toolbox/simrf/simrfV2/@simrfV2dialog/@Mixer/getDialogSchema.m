function dlgStruct=getDialogSchema(this,~)








    lprompt=1;
    rprompt=4;
    ledit=rprompt+1;
    redit=15;
    lunit=redit+1;
    runit=20;
    number_grid=20;



    Source_linear_gain=simrfV2GetLeafWidgetBase('combobox','',...
    'Source_linear_gain',this,'Source_linear_gain');
    Source_linear_gain.Entries=set(this,'Source_linear_gain')';
    Source_linear_gain.RowSpan=[1,1];
    Source_linear_gain.ColSpan=[ledit,runit];
    Source_linear_gain.DialogRefresh=1;

    Source_linear_gainprompt=simrfV2GetLeafWidgetBase('text',...
    'Source of conversion gain:','Source_linear_gainPrompt',0);
    Source_linear_gainprompt.RowSpan=[1,1];
    Source_linear_gainprompt.ColSpan=[lprompt,rprompt];


    linear_gain=simrfV2GetLeafWidgetBase('edit','','linear_gain',this,...
    'linear_gain');
    linear_gain.RowSpan=[2,2];
    linear_gain.ColSpan=[ledit,redit];

    linear_gain_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'linear_gain_unit',this,'linear_gain_unit');
    linear_gain_unit.Entries=set(this,'linear_gain_unit')';
    linear_gain_unit.RowSpan=[2,2];
    linear_gain_unit.ColSpan=[lunit,runit];

    linear_gainprompt=simrfV2GetLeafWidgetBase('text',...
    [this.Source_linear_gain,':'],'linear_gainprompt',0);
    linear_gainprompt.RowSpan=[2,2];
    linear_gainprompt.ColSpan=[lprompt,rprompt];


    Poly_Coeffs=simrfV2GetLeafWidgetBase('edit','','Poly_Coeffs',...
    this,'Poly_Coeffs');
    Poly_Coeffs.RowSpan=[2,2];
    Poly_Coeffs.ColSpan=[ledit,runit];

    Poly_Coeffsprompt=simrfV2GetLeafWidgetBase('text',...
    'Polynomial coefficients:','Poly_Coeffsprompt',0);
    Poly_Coeffsprompt.RowSpan=[2,2];
    Poly_Coeffsprompt.ColSpan=[lprompt,rprompt];


    Zin=simrfV2GetLeafWidgetBase('edit','','Zin',this,'Zin');
    Zin.RowSpan=[3,3];
    Zin.ColSpan=[ledit,runit];

    Zinprompt=simrfV2GetLeafWidgetBase('text','Input impedance (Ohm):',...
    'Zinprompt',0);
    Zinprompt.RowSpan=[3,3];
    Zinprompt.ColSpan=[lprompt,rprompt];


    Zout=simrfV2GetLeafWidgetBase('edit','','Zout',this,'Zout');
    Zout.RowSpan=[4,4];
    Zout.ColSpan=[ledit,runit];

    Zoutprompt=simrfV2GetLeafWidgetBase('text',...
    'Output impedance (Ohm):','Zoutprompt',0);
    Zoutprompt.RowSpan=[4,4];
    Zoutprompt.ColSpan=[lprompt,rprompt];


    ZLO=simrfV2GetLeafWidgetBase('edit','','ZLO',this,'ZLO');
    ZLO.RowSpan=[5,5];
    ZLO.ColSpan=[ledit,runit];

    ZLOprompt=simrfV2GetLeafWidgetBase('text','LO impedance (Ohm):',...
    'ZLOprompt',0);
    ZLOprompt.RowSpan=[5,5];
    ZLOprompt.ColSpan=[lprompt,rprompt];


    NF=simrfV2GetLeafWidgetBase('edit','','NF',this,'NF');
    NF.RowSpan=[6,6];
    NF.ColSpan=[ledit,runit];

    NFprompt=simrfV2GetLeafWidgetBase('text','Noise figure (dB):',...
    'NFprompt',0);
    NFprompt.RowSpan=[6,6];
    NFprompt.ColSpan=[lprompt,rprompt];


    grounding=simrfV2GetLeafWidgetBase('checkbox',...
    'Ground and hide negative terminals','InternalGrounding',this,...
    'InternalGrounding');
    grounding.RowSpan=[7,7];
    grounding.ColSpan=[lprompt,number_grid];


    spacerMain=simrfV2GetLeafWidgetBase('text',' ','',0);
    spacerMain.RowSpan=[8,8];
    spacerMain.ColSpan=[lprompt,rprompt];

    maxrows=spacerMain.RowSpan(1);



    hBlk=get_param(this,'Handle');
    idxMaskNames=simrfV2getblockmaskparamsindex(hBlk);
    slBlkVis=get_param(hBlk,'MaskVisibilities');

    Source_linear_gain.Visible=1;
    Source_linear_gainprompt.Visible=1;
    NFprompt.Visible=1;
    NF.Visible=1;
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


    [nlItems,nlLayout,slBlkVis]=simrfV2create_nldata_pane(this,...
    slBlkVis,idxMaskNames);


    if~strcmpi(get_param(bdroot(hBlk),'Lock'),'on')
        set_param(hBlk,'MaskVisibilities',slBlkVis);

        set_param(hBlk,'MaskVisibilities',slBlkVis);

    end







    mainItems={Zin,Zinprompt,Zout,Zoutprompt,ZLO,ZLOprompt,grounding,...
    spacerMain,linear_gain,linear_gain_unit,linear_gainprompt,NF,...
    NFprompt,Source_linear_gain,Source_linear_gainprompt,Poly_Coeffs,...
    Poly_Coeffsprompt};

    mainLayout.LayoutGrid=[maxrows,number_grid];
    mainLayout.RowSpan=[2,2];
    mainLayout.ColSpan=[1,1];
    mainLayout.RowStretch=[zeros(1,maxrows-1),1];


    mainPane=simrfV2create_panel(this,'MainPane',mainItems,mainLayout);


    nonlinearityPane=simrfV2create_panel(this,'NonlinearPane',nlItems,...
    nlLayout);



    mainTab.Name='Main';
    mainTab.Items={mainPane};
    mainTab.LayoutGrid=[1,1];
    mainTab.RowStretch=0;
    mainTab.ColStretch=0;


    nonlinearityTab.Name='Nonlinearity';
    nonlinearityTab.Items={nonlinearityPane};
    nonlinearityTab.LayoutGrid=[1,1];
    nonlinearityTab.RowStretch=0;
    nonlinearityTab.ColStretch=0;


    tabbedPane.Type='tab';
    tabbedPane.Name='';
    tabbedPane.Tag='TabPane';
    tabbedPane.RowSpan=[2,2];
    tabbedPane.ColSpan=[1,1];

    if strcmpi(this.Source_linear_gain,'Polynomial coefficients')
        tabbedPane.Tabs={mainTab};
    else
        tabbedPane.Tabs={mainTab,nonlinearityTab};
    end


    dlgStruct=getBaseSchemaStruct(this,tabbedPane);

