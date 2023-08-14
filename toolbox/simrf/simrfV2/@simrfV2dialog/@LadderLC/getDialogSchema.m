function dlgStruct=getDialogSchema(this,~)







    lprompt=1;
    rprompt=4;
    ledit=rprompt+1;
    redit=18;
    lunit=redit+1;
    runit=20;





    rs=1;
    lcladdertypeoptionprompt=simrfV2GetLeafWidgetBase('text',...
    'Ladder topology:','LadderTypeOptionprompt',0);
    lcladdertypeoptionprompt.RowSpan=[rs,rs];
    lcladdertypeoptionprompt.ColSpan=[lprompt,rprompt];

    lcladdertypeoption=simrfV2GetLeafWidgetBase('combobox','',...
    'LadderType',this,'LadderType');
    lcladdertypeoption.Entries=set(this,'LadderType')';
    lcladdertypeoption.RowSpan=[rs,rs];
    lcladdertypeoption.ColSpan=[ledit,runit];
    lcladdertypeoption.DialogRefresh=1;




    rs=2;
    inductanceprompt=simrfV2GetLeafWidgetBase('text','Inductance:',...
    'Inductanceprompt',0);
    inductanceprompt.RowSpan=[rs,rs];
    inductanceprompt.ColSpan=[lprompt,rprompt];

    inductance_lpt=simrfV2GetLeafWidgetBase('edit','','Inductance_lpt',...
    this,'Inductance_lpt');
    inductance_lpt.RowSpan=[rs,rs];
    inductance_lpt.ColSpan=[ledit,redit];

    inductanceunit_lpt=simrfV2GetLeafWidgetBase('combobox','',...
    'Inductance_lpt_unit',this,'Inductance_lpt_unit');
    inductanceunit_lpt.Entries=set(this,'Inductance_lpt_unit')';
    inductanceunit_lpt.RowSpan=[rs,rs];
    inductanceunit_lpt.ColSpan=[lunit,runit];

    inductance_hpp=simrfV2GetLeafWidgetBase('edit','','Inductance_hpp',...
    this,'Inductance_hpp');
    inductance_hpp.RowSpan=[rs,rs];
    inductance_hpp.ColSpan=[ledit,redit];

    inductanceunit_hpp=simrfV2GetLeafWidgetBase('combobox','',...
    'Inductance_hpp_unit',this,'Inductance_hpp_unit');
    inductanceunit_hpp.Entries=set(this,'Inductance_hpp_unit')';
    inductanceunit_hpp.RowSpan=[rs,rs];
    inductanceunit_hpp.ColSpan=[lunit,runit];

    inductance_lpp=simrfV2GetLeafWidgetBase('edit','','Inductance_lpp',...
    this,'Inductance_lpp');
    inductance_lpp.RowSpan=[rs,rs];
    inductance_lpp.ColSpan=[ledit,redit];

    inductanceunit_lpp=simrfV2GetLeafWidgetBase('combobox','',...
    'Inductance_lpp_unit',this,'Inductance_lpp_unit');
    inductanceunit_lpp.Entries=set(this,'Inductance_lpp_unit')';
    inductanceunit_lpp.RowSpan=[rs,rs];
    inductanceunit_lpp.ColSpan=[lunit,runit];

    inductance_hpt=simrfV2GetLeafWidgetBase('edit','','Inductance_hpt',...
    this,'Inductance_hpt');
    inductance_hpt.RowSpan=[rs,rs];
    inductance_hpt.ColSpan=[ledit,redit];

    inductanceunit_hpt=simrfV2GetLeafWidgetBase('combobox','',...
    'Inductance_hpt_unit',this,'Inductance_hpt_unit');
    inductanceunit_hpt.Entries=set(this,'Inductance_hpt_unit')';
    inductanceunit_hpt.RowSpan=[rs,rs];
    inductanceunit_hpt.ColSpan=[lunit,runit];

    inductance_bpt=simrfV2GetLeafWidgetBase('edit','','Inductance_bpt',...
    this,'Inductance_bpt');
    inductance_bpt.RowSpan=[rs,rs];
    inductance_bpt.ColSpan=[ledit,redit];

    inductanceunit_bpt=simrfV2GetLeafWidgetBase('combobox','',...
    'Inductance_bpt_unit',this,'Inductance_bpt_unit');
    inductanceunit_bpt.Entries=set(this,'Inductance_bpt_unit')';
    inductanceunit_bpt.RowSpan=[rs,rs];
    inductanceunit_bpt.ColSpan=[lunit,runit];

    inductance_bpp=simrfV2GetLeafWidgetBase('edit','','Inductance_bpp',...
    this,'Inductance_bpp');
    inductance_bpp.RowSpan=[rs,rs];
    inductance_bpp.ColSpan=[ledit,redit];

    inductanceunit_bpp=simrfV2GetLeafWidgetBase('combobox','',...
    'Inductance_bpp_unit',this,'Inductance_bpp_unit');
    inductanceunit_bpp.Entries=set(this,'Inductance_bpp_unit')';
    inductanceunit_bpp.RowSpan=[rs,rs];
    inductanceunit_bpp.ColSpan=[lunit,runit];

    inductance_bst=simrfV2GetLeafWidgetBase('edit','','Inductance_bst',...
    this,'Inductance_bst');
    inductance_bst.RowSpan=[rs,rs];
    inductance_bst.ColSpan=[ledit,redit];

    inductanceunit_bst=simrfV2GetLeafWidgetBase('combobox','',...
    'Inductance_bst_unit',this,'Inductance_bst_unit');
    inductanceunit_bst.Entries=set(this,'Inductance_bst_unit')';
    inductanceunit_bst.RowSpan=[rs,rs];
    inductanceunit_bst.ColSpan=[lunit,runit];

    inductance_bsp=simrfV2GetLeafWidgetBase('edit','','Inductance_bsp',...
    this,'Inductance_bsp');
    inductance_bsp.RowSpan=[rs,rs];
    inductance_bsp.ColSpan=[ledit,redit];

    inductanceunit_bsp=simrfV2GetLeafWidgetBase('combobox','',...
    'Inductance_bsp_unit',this,'Inductance_bsp_unit');
    inductanceunit_bsp.Entries=set(this,'Inductance_bsp_unit')';
    inductanceunit_bsp.RowSpan=[rs,rs];
    inductanceunit_bsp.ColSpan=[lunit,runit];




    rs=3;
    capacitanceprompt=simrfV2GetLeafWidgetBase('text','Capacitance:',...
    'Capacitanceprompt',0);
    capacitanceprompt.RowSpan=[rs,rs];
    capacitanceprompt.ColSpan=[lprompt,rprompt];

    capacitance_lpt=simrfV2GetLeafWidgetBase('edit','',...
    'Capacitance_lpt',this,'Capacitance_lpt');
    capacitance_lpt.RowSpan=[rs,rs];
    capacitance_lpt.ColSpan=[ledit,redit];

    capacitanceunit_lpt=simrfV2GetLeafWidgetBase('combobox','',...
    'Capacitance_lpt_unit',this,'Capacitance_lpt_unit');
    capacitanceunit_lpt.Entries=set(this,'Capacitance_lpt_unit')';
    capacitanceunit_lpt.RowSpan=[rs,rs];
    capacitanceunit_lpt.ColSpan=[lunit,runit];

    capacitance_hpp=simrfV2GetLeafWidgetBase('edit','',...
    'Capacitance_hpp',this,'Capacitance_hpp');
    capacitance_hpp.RowSpan=[rs,rs];
    capacitance_hpp.ColSpan=[ledit,redit];

    capacitanceunit_hpp=simrfV2GetLeafWidgetBase('combobox','',...
    'Capacitance_hpp_unit',this,'Capacitance_hpp_unit');
    capacitanceunit_hpp.Entries=set(this,'Capacitance_hpp_unit')';
    capacitanceunit_hpp.RowSpan=[rs,rs];
    capacitanceunit_hpp.ColSpan=[lunit,runit];

    capacitance_lpp=simrfV2GetLeafWidgetBase('edit','',...
    'Capacitance_lpp',this,'Capacitance_lpp');
    capacitance_lpp.RowSpan=[rs,rs];
    capacitance_lpp.ColSpan=[ledit,redit];

    capacitanceunit_lpp=simrfV2GetLeafWidgetBase('combobox','',...
    'Capacitance_lpp_unit',this,'Capacitance_lpp_unit');
    capacitanceunit_lpp.Entries=set(this,'Capacitance_lpp_unit')';
    capacitanceunit_lpp.RowSpan=[rs,rs];
    capacitanceunit_lpp.ColSpan=[lunit,runit];

    capacitance_hpt=simrfV2GetLeafWidgetBase('edit','',...
    'Capacitance_hpt',this,'Capacitance_hpt');
    capacitance_hpt.RowSpan=[rs,rs];
    capacitance_hpt.ColSpan=[ledit,redit];

    capacitanceunit_hpt=simrfV2GetLeafWidgetBase('combobox','',...
    'Capacitance_hpt_unit',this,'Capacitance_hpt_unit');
    capacitanceunit_hpt.Entries=set(this,'Capacitance_hpt_unit')';
    capacitanceunit_hpt.RowSpan=[rs,rs];
    capacitanceunit_hpt.ColSpan=[lunit,runit];

    capacitance_bpt=simrfV2GetLeafWidgetBase('edit','',...
    'Capacitance_bpt',this,'Capacitance_bpt');
    capacitance_bpt.RowSpan=[rs,rs];
    capacitance_bpt.ColSpan=[ledit,redit];

    capacitanceunit_bpt=simrfV2GetLeafWidgetBase('combobox','',...
    'Capacitance_bpt_unit',this,'Capacitance_bpt_unit');
    capacitanceunit_bpt.Entries=set(this,'Capacitance_bpt_unit')';
    capacitanceunit_bpt.RowSpan=[rs,rs];
    capacitanceunit_bpt.ColSpan=[lunit,runit];

    capacitance_bpp=simrfV2GetLeafWidgetBase('edit','',...
    'Capacitance_bpp',this,'Capacitance_bpp');
    capacitance_bpp.RowSpan=[rs,rs];
    capacitance_bpp.ColSpan=[ledit,redit];

    capacitanceunit_bpp=simrfV2GetLeafWidgetBase('combobox','',...
    'Capacitance_bpp_unit',this,'Capacitance_bpp_unit');
    capacitanceunit_bpp.Entries=set(this,'Capacitance_bpp_unit')';
    capacitanceunit_bpp.RowSpan=[rs,rs];
    capacitanceunit_bpp.ColSpan=[lunit,runit];

    capacitance_bst=simrfV2GetLeafWidgetBase('edit','',...
    'Capacitance_bst',this,'Capacitance_bst');
    capacitance_bst.RowSpan=[rs,rs];
    capacitance_bst.ColSpan=[ledit,redit];

    capacitanceunit_bst=simrfV2GetLeafWidgetBase('combobox','',...
    'Capacitance_bst_unit',this,'Capacitance_bst_unit');
    capacitanceunit_bst.Entries=set(this,'Capacitance_bst_unit')';
    capacitanceunit_bst.RowSpan=[rs,rs];
    capacitanceunit_bst.ColSpan=[lunit,runit];

    capacitance_bsp=simrfV2GetLeafWidgetBase('edit','',...
    'Capacitance_bsp',this,'Capacitance_bsp');
    capacitance_bsp.RowSpan=[rs,rs];
    capacitance_bsp.ColSpan=[ledit,redit];

    capacitanceunit_bsp=simrfV2GetLeafWidgetBase('combobox','',...
    'Capacitance_bsp_unit',this,'Capacitance_bsp_unit');
    capacitanceunit_bsp.Entries=set(this,'Capacitance_bsp_unit')';
    capacitanceunit_bsp.RowSpan=[rs,rs];
    capacitanceunit_bsp.ColSpan=[lunit,runit];


    rs=rs+1;







    fname=[lower(regexprep(this.LadderType,' +','')),'.png'];
    imagepath=fullfile(matlabroot,'toolbox','simrf','simrfV2',...
    '@simrfV2dialog','@LadderLC','private');
    filterimage.Name='...';
    filterimage.Type='image';
    filterimage.Tag='filterimage';
    filterimage.RowSpan=[rs,rs+3];
    filterimage.ColSpan=[lprompt,runit];
    filterimage.Alignment=6;
    filterimage.FilePath=fullfile(imagepath,fname);


    rs=rs+4;
    grounding=simrfV2GetLeafWidgetBase('checkbox',...
    'Ground and hide negative terminals','InternalGrounding',...
    this,'InternalGrounding');
    grounding.RowSpan=[rs,rs];
    grounding.ColSpan=[lprompt,runit];



    hBlk=get_param(this,'Handle');
    idxMaskNames=simrfV2getblockmaskparamsindex(hBlk);
    slBlkVis=get_param(hBlk,'MaskVisibilities');
    slBlkVis([idxMaskNames.LadderType...
    ,idxMaskNames.Inductance_lpt,idxMaskNames.Inductance_lpt_unit...
    ,idxMaskNames.Capacitance_lpt,idxMaskNames.Capacitance_lpt_unit...
    ,idxMaskNames.Inductance_hpp,idxMaskNames.Inductance_hpp_unit...
    ,idxMaskNames.Capacitance_hpp,idxMaskNames.Capacitance_hpp_unit...
    ,idxMaskNames.Inductance_lpp,idxMaskNames.Inductance_lpp_unit...
    ,idxMaskNames.Capacitance_lpp,idxMaskNames.Capacitance_lpp_unit...
    ,idxMaskNames.Inductance_hpt,idxMaskNames.Inductance_hpt_unit...
    ,idxMaskNames.Capacitance_hpt,idxMaskNames.Capacitance_hpt_unit...
    ,idxMaskNames.Inductance_bpt,idxMaskNames.Inductance_bpt_unit...
    ,idxMaskNames.Capacitance_bpt,idxMaskNames.Capacitance_bpt_unit...
    ,idxMaskNames.Inductance_bpp,idxMaskNames.Inductance_bpp_unit...
    ,idxMaskNames.Capacitance_bpp,idxMaskNames.Capacitance_bpp_unit...
    ,idxMaskNames.Inductance_bst,idxMaskNames.Inductance_bst_unit...
    ,idxMaskNames.Capacitance_bst,idxMaskNames.Capacitance_bst_unit...
    ,idxMaskNames.Inductance_bsp,idxMaskNames.Inductance_bsp_unit...
    ,idxMaskNames.Capacitance_bsp,idxMaskNames.Capacitance_bsp_unit])=...
    {'off'};

    lcladdertypeoptionprompt.Visible=1;
    lcladdertypeoption.Visible=1;
    inductanceprompt.Visible=1;
    capacitanceprompt.Visible=1;
    inductance_lpt.Visible=0;
    capacitance_lpt.Visible=0;
    inductanceunit_lpt.Visible=0;
    capacitanceunit_lpt.Visible=0;
    inductance_hpp.Visible=0;
    capacitance_hpp.Visible=0;
    inductanceunit_hpp.Visible=0;
    capacitanceunit_hpp.Visible=0;
    inductance_lpp.Visible=0;
    capacitance_lpp.Visible=0;
    inductanceunit_lpp.Visible=0;
    capacitanceunit_lpp.Visible=0;
    inductance_hpt.Visible=0;
    capacitance_hpt.Visible=0;
    inductanceunit_hpt.Visible=0;
    capacitanceunit_hpt.Visible=0;
    inductance_bpt.Visible=0;
    capacitance_bpt.Visible=0;
    inductanceunit_bpt.Visible=0;
    capacitanceunit_bpt.Visible=0;
    inductance_bpp.Visible=0;
    capacitance_bpp.Visible=0;
    inductanceunit_bpp.Visible=0;
    capacitanceunit_bpp.Visible=0;
    inductance_bst.Visible=0;
    capacitance_bst.Visible=0;
    inductanceunit_bst.Visible=0;
    capacitanceunit_bst.Visible=0;
    inductance_bsp.Visible=0;
    capacitance_bsp.Visible=0;
    inductanceunit_bsp.Visible=0;
    capacitanceunit_bsp.Visible=0;

    switch this.LadderType
    case 'LC Lowpass Tee'
        inductance_lpt.Visible=1;
        capacitance_lpt.Visible=1;
        inductanceunit_lpt.Visible=1;
        capacitanceunit_lpt.Visible=1;
        slBlkVis([idxMaskNames.Inductance_lpt...
        ,idxMaskNames.Inductance_lpt_unit...
        ,idxMaskNames.Capacitance_lpt...
        ,idxMaskNames.Capacitance_lpt_unit])={'on'};

    case 'LC Highpass Pi'
        inductance_hpp.Visible=1;
        capacitance_hpp.Visible=1;
        inductanceunit_hpp.Visible=1;
        capacitanceunit_hpp.Visible=1;
        slBlkVis([idxMaskNames.Inductance_hpp...
        ,idxMaskNames.Inductance_hpp_unit...
        ,idxMaskNames.Capacitance_hpp...
        ,idxMaskNames.Capacitance_hpp_unit])={'on'};

    case 'LC Lowpass Pi'
        inductance_lpp.Visible=1;
        capacitance_lpp.Visible=1;
        inductanceunit_lpp.Visible=1;
        capacitanceunit_lpp.Visible=1;
        slBlkVis([idxMaskNames.Inductance_lpp...
        ,idxMaskNames.Inductance_lpp_unit...
        ,idxMaskNames.Capacitance_lpp...
        ,idxMaskNames.Capacitance_lpp_unit])={'on'};

    case 'LC Highpass Tee'
        inductance_hpt.Visible=1;
        capacitance_hpt.Visible=1;
        inductanceunit_hpt.Visible=1;
        capacitanceunit_hpt.Visible=1;
        slBlkVis([idxMaskNames.Inductance_hpt...
        ,idxMaskNames.Inductance_hpt_unit...
        ,idxMaskNames.Capacitance_hpt...
        ,idxMaskNames.Capacitance_hpt_unit])={'on'};

    case 'LC Bandpass Tee'
        inductance_bpt.Visible=1;
        capacitance_bpt.Visible=1;
        inductanceunit_bpt.Visible=1;
        capacitanceunit_bpt.Visible=1;
        slBlkVis([idxMaskNames.Inductance_bpt...
        ,idxMaskNames.Inductance_bpt_unit...
        ,idxMaskNames.Capacitance_bpt...
        ,idxMaskNames.Capacitance_bpt_unit])={'on'};

    case 'LC Bandpass Pi'
        inductance_bpp.Visible=1;
        capacitance_bpp.Visible=1;
        inductanceunit_bpp.Visible=1;
        capacitanceunit_bpp.Visible=1;
        slBlkVis([idxMaskNames.Inductance_bpp...
        ,idxMaskNames.Inductance_bpp_unit...
        ,idxMaskNames.Capacitance_bpp...
        ,idxMaskNames.Capacitance_bpp_unit])={'on'};

    case 'LC Bandstop Tee'
        inductance_bst.Visible=1;
        capacitance_bst.Visible=1;
        inductanceunit_bst.Visible=1;
        capacitanceunit_bst.Visible=1;
        slBlkVis([idxMaskNames.Inductance_bst...
        ,idxMaskNames.Inductance_bst_unit...
        ,idxMaskNames.Capacitance_bst...
        ,idxMaskNames.Capacitance_bst_unit])={'on'};

    case 'LC Bandstop Pi'
        inductance_bsp.Visible=1;
        capacitance_bsp.Visible=1;
        inductanceunit_bsp.Visible=1;
        capacitanceunit_bsp.Visible=1;
        slBlkVis([idxMaskNames.Inductance_bsp...
        ,idxMaskNames.Inductance_bsp_unit...
        ,idxMaskNames.Capacitance_bsp...
        ,idxMaskNames.Capacitance_bsp_unit])={'on'};
    end


    if~strcmpi(get_param(bdroot(hBlk),'Lock'),'on')
        set_param(hBlk,'MaskVisibilities',slBlkVis);
    end



    mainParamsPanel.Type='group';
    mainParamsPanel.Name='Parameters';
    mainParamsPanel.Tag='mainParamsPanel';
    mainParamsPanel.Items={...
    inductanceprompt,...
    inductance_lpt,inductanceunit_lpt,...
    inductance_hpp,inductanceunit_hpp,...
    inductance_lpp,inductanceunit_lpp,...
    inductance_hpt,inductanceunit_hpt,...
    inductance_bpt,inductanceunit_bpt,...
    inductance_bpp,inductanceunit_bpp,...
    inductance_bst,inductanceunit_bst,...
    inductance_bsp,inductanceunit_bsp,...
    capacitanceprompt,...
    capacitance_lpt,capacitanceunit_lpt,...
    capacitance_hpp,capacitanceunit_hpp,...
    capacitance_lpp,capacitanceunit_lpp,...
    capacitance_hpt,capacitanceunit_hpt,...
    capacitance_bpt,capacitanceunit_bpt,...
    capacitance_bpp,capacitanceunit_bpp,...
    capacitance_bst,capacitanceunit_bst,...
    capacitance_bsp,capacitanceunit_bsp,...
    lcladdertypeoptionprompt,lcladdertypeoption,...
    filterimage,grounding};
    mainParamsPanel.LayoutGrid=[rs,runit];
    mainParamsPanel.ColStretch=[0,0,0,0,ones(1,14),0,0];
    mainParamsPanel.RowSpan=[2,2];
    mainParamsPanel.ColSpan=[1,1];


    dlgStruct=getBaseSchemaStruct(this,mainParamsPanel);

