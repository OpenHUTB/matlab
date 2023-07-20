function dlgStruct=getDialogSchema(this,~)







    lprompt=1;
    rprompt=4;
    ledit=rprompt+1;
    redit=15;
    lunit=redit+1;
    runit=20;
    number_grid=20;


    rs=1;
    ModelType_prompt=simrfV2GetLeafWidgetBase('text',...
    'Model type:','Model_type_prompt',0);
    ModelType_prompt.RowSpan=[rs,rs];
    ModelType_prompt.ColSpan=[lprompt,rprompt];

    ModelType=simrfV2GetLeafWidgetBase('combobox','','Model_type',...
    this,'Model_type');
    ModelType.Entries=set(this,'Model_type')';
    ModelType.RowSpan=[rs,rs];
    ModelType.ColSpan=[ledit,runit];
    ModelType.DialogRefresh=1;


    rs=rs+1;
    Structure_prompt=simrfV2GetLeafWidgetBase('text',...
    'Structure:','StructureMicrostrip_type_prompt',0);
    Structure_prompt.RowSpan=[rs,rs];
    Structure_prompt.ColSpan=[lprompt,rprompt];

    Structure=simrfV2GetLeafWidgetBase('combobox','',...
    'StructureMicrostrip',this,'StructureMicrostrip');
    Structure.Entries=set(this,'StructureMicrostrip')';
    Structure.RowSpan=[rs,rs];
    Structure.ColSpan=[ledit,runit];
    Structure.DialogRefresh=1;

    ParamType_prompt=simrfV2GetLeafWidgetBase('text',...
    'Parameterization:','Param_type_prompt',0);
    ParamType_prompt.RowSpan=[rs,rs];
    ParamType_prompt.ColSpan=[lprompt,rprompt];

    ParamType=simrfV2GetLeafWidgetBase('combobox','','Parameterization',...
    this,'Parameterization');
    ParamType.Entries=set(this,'Parameterization')';
    ParamType.RowSpan=[rs,rs];
    ParamType.ColSpan=[ledit,runit];
    ParamType.DialogRefresh=1;

    ConductorBack=simrfV2GetLeafWidgetBase('checkbox',...
    'Conductor backed:','ConductorBacked',this,'ConductorBacked');
    ConductorBack.RowSpan=[rs,rs];
    ConductorBack.ColSpan=[lprompt,number_grid];
    ConductorBack.DialogRefresh=1;

    rs=rs+1;

    ConductorWidth_prompt=simrfV2GetLeafWidgetBase('text',...
    'Conductor width:','ConductorWidthprompt',0);
    ConductorWidth_prompt.RowSpan=[rs,rs];
    ConductorWidth_prompt.ColSpan=[lprompt,rprompt];

    ConductorWidth=simrfV2GetLeafWidgetBase('edit','','ConductorWidth',...
    this,'ConductorWidth');
    ConductorWidth.RowSpan=[rs,rs];
    ConductorWidth.ColSpan=[ledit,redit];

    ConductorWidth_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'ConductorWidth_unit',this,'ConductorWidth_unit');

    ConductorWidth_unit.RowSpan=[rs,rs];
    ConductorWidth_unit.ColSpan=[lunit,runit];


    rs=rs+1;
    TransDelay_prompt=simrfV2GetLeafWidgetBase('text',...
    'Transmission delay:','TransDelayprompt',0);
    TransDelay_prompt.RowSpan=[rs,rs];
    TransDelay_prompt.ColSpan=[lprompt,rprompt];

    TransDelay=simrfV2GetLeafWidgetBase('edit','','TransDelay',...
    this,'TransDelay');
    TransDelay.RowSpan=[rs,rs];
    TransDelay.ColSpan=[ledit,redit];

    TransDelay_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'TransDelay_unit',this,'TransDelay_unit');
    TransDelay_unit.Entries=set(this,'TransDelay_unit')';
    TransDelay_unit.RowSpan=[rs,rs];
    TransDelay_unit.ColSpan=[lunit,runit];


    OuterRadius_prompt=simrfV2GetLeafWidgetBase('text',...
    'Outer radius:','OuterRadiusprompt',0);
    OuterRadius_prompt.RowSpan=[rs,rs];
    OuterRadius_prompt.ColSpan=[lprompt,rprompt];

    OuterRadius=simrfV2GetLeafWidgetBase('edit','','OuterRadius',...
    this,'OuterRadius');
    OuterRadius.RowSpan=[rs,rs];
    OuterRadius.ColSpan=[ledit,redit];

    OuterRadius_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'OuterRadius_unit',this,'OuterRadius_unit');
    OuterRadius_unit.Entries=set(this,'OuterRadius_unit')';
    OuterRadius_unit.RowSpan=[rs,rs];
    OuterRadius_unit.ColSpan=[lunit,runit];


    SWidth_prompt=simrfV2GetLeafWidgetBase('text',...
    'Strip width:','SWidthprompt',0);
    SWidth_prompt.RowSpan=[rs,rs];
    SWidth_prompt.ColSpan=[lprompt,rprompt];

    SWidth=simrfV2GetLeafWidgetBase('edit','','SWidth',...
    this,'SWidth');
    SWidth.RowSpan=[rs,rs];
    SWidth.ColSpan=[ledit,redit];

    SWidth_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'SWidth_unit',this,'SWidth_unit');

    SWidth_unit.RowSpan=[rs,rs];
    SWidth_unit.ColSpan=[lunit,runit];


    Radius_prompt=simrfV2GetLeafWidgetBase('text',...
    'Wire radius:','Radius_prompt',0);
    Radius_prompt.RowSpan=[rs,rs];
    Radius_prompt.ColSpan=[lprompt,rprompt];

    Radius=simrfV2GetLeafWidgetBase('edit','','Radius',...
    this,'Radius');
    Radius.RowSpan=[rs,rs];
    Radius.ColSpan=[ledit,redit];

    Radius_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'Radius_unit',this,'Radius_unit');

    Radius_unit.RowSpan=[rs,rs];
    Radius_unit.ColSpan=[lunit,runit];


    SlotWidth_prompt=simrfV2GetLeafWidgetBase('text',...
    'Slot width:','SlotWidthprompt',0);
    SlotWidth_prompt.RowSpan=[rs,rs];
    SlotWidth_prompt.ColSpan=[lprompt,rprompt];

    SlotWidth=simrfV2GetLeafWidgetBase('edit','','SlotWidth',...
    this,'SlotWidth');
    SlotWidth.RowSpan=[rs,rs];
    SlotWidth.ColSpan=[ledit,redit];

    SlotWidth_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'SlotWidth_unit',this,'SlotWidth_unit');

    SlotWidth_unit.RowSpan=[rs,rs];
    SlotWidth_unit.ColSpan=[lunit,runit];


    PWidth_prompt=simrfV2GetLeafWidgetBase('text',...
    'Plate width:','PWidthprompt',0);
    PWidth_prompt.RowSpan=[rs,rs];
    PWidth_prompt.ColSpan=[lprompt,rprompt];

    PWidth=simrfV2GetLeafWidgetBase('edit','','PWidth',...
    this,'PWidth');
    PWidth.RowSpan=[rs,rs];
    PWidth.ColSpan=[ledit,redit];

    PWidth_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'PWidth_unit',this,'PWidth_unit');

    PWidth_unit.RowSpan=[rs,rs];
    PWidth_unit.ColSpan=[lunit,runit];


    rs=rs+1;

    CharImped_prompt=simrfV2GetLeafWidgetBase('text',...
    'Characteristic impedance:','CharImpedprompt',0);
    CharImped_prompt.RowSpan=[rs,rs];
    CharImped_prompt.ColSpan=[lprompt,rprompt];

    CharImped=simrfV2GetLeafWidgetBase('edit','','CharImped',...
    this,'CharImped');
    CharImped.RowSpan=[rs,rs];
    CharImped.ColSpan=[ledit,redit];

    CharImped_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'CharImped_unit',this,'CharImped_unit');
    CharImped_unit.Entries=set(this,'CharImped_unit')';
    CharImped_unit.RowSpan=[rs,rs];
    CharImped_unit.ColSpan=[lunit,runit];


    InnerRadius_prompt=simrfV2GetLeafWidgetBase('text',...
    'Inner radius:','InnerRadiusprompt',0);
    InnerRadius_prompt.RowSpan=[rs,rs];
    InnerRadius_prompt.ColSpan=[lprompt,rprompt];

    InnerRadius=simrfV2GetLeafWidgetBase('edit','','InnerRadius',...
    this,'InnerRadius');
    InnerRadius.RowSpan=[rs,rs];
    InnerRadius.ColSpan=[ledit,redit];

    InnerRadius_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'InnerRadius_unit',this,'InnerRadius_unit');
    InnerRadius_unit.Entries=set(this,'InnerRadius_unit')';
    InnerRadius_unit.RowSpan=[rs,rs];
    InnerRadius_unit.ColSpan=[lunit,runit];


    Thickness_prompt=simrfV2GetLeafWidgetBase('text',...
    'Strip thickness:','Thicknessprompt',0);
    Thickness_prompt.RowSpan=[rs,rs];
    Thickness_prompt.ColSpan=[lprompt,rprompt];

    Thickness=simrfV2GetLeafWidgetBase('edit','','Thickness',...
    this,'Thickness');
    Thickness.RowSpan=[rs,rs];
    Thickness.ColSpan=[ledit,redit];

    Thickness_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'Thickness_unit',this,'Thickness_unit');

    Thickness_unit.RowSpan=[rs,rs];
    Thickness_unit.ColSpan=[lunit,runit];


    Separation_prompt=simrfV2GetLeafWidgetBase('text',...
    'Wire separation:','Separationprompt',0);
    Separation_prompt.RowSpan=[rs,rs];
    Separation_prompt.ColSpan=[lprompt,rprompt];

    Separation=simrfV2GetLeafWidgetBase('edit','','Separation',...
    this,'Separation');
    Separation.RowSpan=[rs,rs];
    Separation.ColSpan=[ledit,redit];

    Separation_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'Separation_unit',this,'Separation_unit');

    Separation_unit.RowSpan=[rs,rs];
    Separation_unit.ColSpan=[lunit,runit];


    PSeparation_prompt=simrfV2GetLeafWidgetBase('text',...
    'Plate separation:','PSeparationprompt',0);
    PSeparation_prompt.RowSpan=[rs,rs];
    PSeparation_prompt.ColSpan=[lprompt,rprompt];

    PSeparation=simrfV2GetLeafWidgetBase('edit','','PSeparation',...
    this,'PSeparation');
    PSeparation.RowSpan=[rs,rs];
    PSeparation.ColSpan=[ledit,redit];

    PSeparation_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'PSeparation_unit',this,'PSeparation_unit');

    PSeparation_unit.RowSpan=[rs,rs];
    PSeparation_unit.ColSpan=[lunit,runit];


    rs=rs+1;

    Resistance_prompt=simrfV2GetLeafWidgetBase('text',...
    'Resistance per unit length:','Resistanceprompt',0);
    Resistance_prompt.RowSpan=[rs,rs];
    Resistance_prompt.ColSpan=[lprompt,rprompt];

    Resistance=simrfV2GetLeafWidgetBase('edit','','Resistance',...
    this,'Resistance');
    Resistance.RowSpan=[rs,rs];
    Resistance.ColSpan=[ledit,redit];

    Resistance_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'Resistance_unit',this,'Resistance_unit');
    Resistance_unit.Entries=set(this,'Resistance_unit')';
    Resistance_unit.RowSpan=[rs,rs];
    Resistance_unit.ColSpan=[lunit,runit];


    StripHeight_prompt=simrfV2GetLeafWidgetBase('text',...
    'Strip height:','StripHeightprompt',0);
    StripHeight_prompt.RowSpan=[rs,rs];
    StripHeight_prompt.ColSpan=[lprompt,rprompt];

    StripHeight=simrfV2GetLeafWidgetBase('edit','','StripHeight',...
    this,'StripHeight');
    StripHeight.RowSpan=[rs,rs];
    StripHeight.ColSpan=[ledit,redit];

    StripHeight_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'StripHeight_unit',this,'StripHeight_unit');

    StripHeight_unit.RowSpan=[rs,rs];
    StripHeight_unit.ColSpan=[lunit,runit];


    Loss_prompt=simrfV2GetLeafWidgetBase('text','Loss (dB/m):',...
    'Lossprompt',0);
    Loss_prompt.RowSpan=[rs,rs];
    Loss_prompt.ColSpan=[lprompt,rprompt];

    Loss=simrfV2GetLeafWidgetBase('edit','','Loss',this,'Loss');
    Loss.RowSpan=[rs,rs];
    Loss.ColSpan=[ledit,runit];


    rs=rs+1;

    Inductance_prompt=simrfV2GetLeafWidgetBase('text',...
    'Inductance per unit length:','Inductanceprompt',0);
    Inductance_prompt.RowSpan=[rs,rs];
    Inductance_prompt.ColSpan=[lprompt,rprompt];

    Inductance=simrfV2GetLeafWidgetBase('edit','','Inductance',...
    this,'Inductance');
    Inductance.RowSpan=[rs,rs];
    Inductance.ColSpan=[ledit,redit];

    Inductance_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'Inductance_unit',this,'Inductance_unit');
    Inductance_unit.Entries=set(this,'Inductance_unit')';
    Inductance_unit.RowSpan=[rs,rs];
    Inductance_unit.ColSpan=[lunit,runit];


    SigmaCond_prompt=simrfV2GetLeafWidgetBase('text',...
    'Conductivity of conductor:','Conductivityprompt',0);
    SigmaCond_prompt.RowSpan=[rs,rs];
    SigmaCond_prompt.ColSpan=[lprompt,rprompt];

    SigmaCond=simrfV2GetLeafWidgetBase('edit','','SigmaCond',...
    this,'SigmaCond');
    SigmaCond.RowSpan=[rs,rs];
    SigmaCond.ColSpan=[ledit,redit];

    SigmaCond_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'SigmaCond_unit',this,'SigmaCond_unit');

    SigmaCond_unit.RowSpan=[rs,rs];
    SigmaCond_unit.ColSpan=[lunit,runit];


    rs=rs+1;

    Capacitance_prompt=simrfV2GetLeafWidgetBase('text',...
    'Capacitance per unit length:','Capacitanceprompt',0);
    Capacitance_prompt.RowSpan=[rs,rs];
    Capacitance_prompt.ColSpan=[lprompt,rprompt];

    Capacitance=simrfV2GetLeafWidgetBase('edit','','Capacitance',...
    this,'Capacitance');
    Capacitance.RowSpan=[rs,rs];
    Capacitance.ColSpan=[ledit,redit];

    Capacitance_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'Capacitance_unit',this,'Capacitance_unit');
    Capacitance_unit.Entries=set(this,'Capacitance_unit')';
    Capacitance_unit.RowSpan=[rs,rs];
    Capacitance_unit.ColSpan=[lunit,runit];


    Height_prompt=simrfV2GetLeafWidgetBase('text',...
    'Dielectric thickness:','Heightprompt',0);
    Height_prompt.RowSpan=[rs,rs];
    Height_prompt.ColSpan=[lprompt,rprompt];

    Height=simrfV2GetLeafWidgetBase('edit','','Height',...
    this,'Height');
    Height.RowSpan=[rs,rs];
    Height.ColSpan=[ledit,redit];

    Height_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'Height_unit',this,'Height_unit');

    Height_unit.RowSpan=[rs,rs];
    Height_unit.ColSpan=[lunit,runit];

    Height_inv=simrfV2GetLeafWidgetBase('edit','','Height_inv',...
    this,'Height_inv');
    Height_inv.RowSpan=[rs,rs];
    Height_inv.ColSpan=[ledit,redit];

    Height_inv_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'Height_inv_unit',this,'Height_inv_unit');

    Height_inv_unit.RowSpan=[rs,rs];
    Height_inv_unit.ColSpan=[lunit,runit];

    Height_spd=simrfV2GetLeafWidgetBase('edit','','Height_spd',...
    this,'Height_spd');
    Height_spd.RowSpan=[rs,rs];
    Height_spd.ColSpan=[ledit,redit];

    Height_spd_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'Height_spd_unit',this,'Height_spd_unit');

    Height_spd_unit.RowSpan=[rs,rs];
    Height_spd_unit.ColSpan=[lunit,runit];

    Height_emb=simrfV2GetLeafWidgetBase('edit','','Height_emb',...
    this,'Height_emb');
    Height_emb.RowSpan=[rs,rs];
    Height_emb.ColSpan=[ledit,redit];

    Height_emb_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'Height_emb_unit',this,'Height_emb_unit');

    Height_emb_unit.RowSpan=[rs,rs];
    Height_emb_unit.ColSpan=[lunit,runit];


    MuR_prompt=simrfV2GetLeafWidgetBase('text',...
    'Relative permeability of dielectric:','MuRprompt',0);
    MuR_prompt.RowSpan=[rs,rs];
    MuR_prompt.ColSpan=[lprompt,rprompt];

    MuR=simrfV2GetLeafWidgetBase('edit','','MuR',this,'MuR');
    MuR.RowSpan=[rs,rs];
    MuR.ColSpan=[ledit,runit];


    rs=rs+1;

    Conductance_prompt=simrfV2GetLeafWidgetBase('text',...
    'Conductance per unit length:','Conductanceprompt',0);
    Conductance_prompt.RowSpan=[rs,rs];
    Conductance_prompt.ColSpan=[lprompt,rprompt];

    Conductance=simrfV2GetLeafWidgetBase('edit','','Conductance',...
    this,'Conductance');
    Conductance.RowSpan=[rs,rs];
    Conductance.ColSpan=[ledit,redit];

    Conductance_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'Conductance_unit',this,'Conductance_unit');
    Conductance_unit.Entries=set(this,'Conductance_unit')';
    Conductance_unit.RowSpan=[rs,rs];
    Conductance_unit.ColSpan=[lunit,runit];


    EpsilonR_prompt=simrfV2GetLeafWidgetBase('text',...
    'Relative permittivity of dielectric:','EpsilonRprompt',0);
    EpsilonR_prompt.RowSpan=[rs,rs];
    EpsilonR_prompt.ColSpan=[lprompt,rprompt];

    EpsilonR=simrfV2GetLeafWidgetBase('edit','','EpsilonR',this,...
    'EpsilonR');
    EpsilonR.RowSpan=[rs,rs];
    EpsilonR.ColSpan=[ledit,runit];


    PV_prompt=simrfV2GetLeafWidgetBase('text','Phase velocity (m/s):',...
    'PVprompt',0);
    PV_prompt.RowSpan=[rs,rs];
    PV_prompt.ColSpan=[lprompt,rprompt];

    PV=simrfV2GetLeafWidgetBase('edit','','PV',this,'PV');
    PV.RowSpan=[rs,rs];
    PV.ColSpan=[ledit,runit];


    rs=rs+1;

    LossTangent_prompt=simrfV2GetLeafWidgetBase('text',...
    'Loss tangent of dielectric:','LossTangentprompt',0);
    LossTangent_prompt.RowSpan=[rs,rs];
    LossTangent_prompt.ColSpan=[lprompt,rprompt];

    LossTangent=simrfV2GetLeafWidgetBase('edit','','LossTangent',this,...
    'LossTangent');
    LossTangent.RowSpan=[rs,rs];
    LossTangent.ColSpan=[ledit,runit];


    Freq_prompt=simrfV2GetLeafWidgetBase('text','Frequency:',...
    'Freqprompt',0);
    Freq_prompt.RowSpan=[rs,rs];
    Freq_prompt.ColSpan=[lprompt,rprompt];

    Freq=simrfV2GetLeafWidgetBase('edit','','Freq',this,'Freq');
    Freq.RowSpan=[rs,rs];
    Freq.ColSpan=[ledit,runit];

    Freq_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'Freq_unit',this,'Freq_unit');
    Freq_unit.RowSpan=[rs,rs];
    Freq_unit.ColSpan=[lunit,runit];


    rs=rs+1;

    Interp_prompt=simrfV2GetLeafWidgetBase('text',...
    'Interpolation method:','Interp_type_prompt',0);
    Interp_prompt.RowSpan=[rs,rs];
    Interp_prompt.ColSpan=[lprompt,rprompt];

    InterpType=simrfV2GetLeafWidgetBase('combobox','','Interp_type',...
    this,'Interp_type');
    InterpType.Entries=set(this,'Interp_type')';
    InterpType.RowSpan=[rs,rs];
    InterpType.ColSpan=[ledit,runit];
    InterpType.DialogRefresh=1;


    rs=rs+1;

    LineLength_prompt=simrfV2GetLeafWidgetBase('text',...
    'Line length:','LineLengthprompt',0);
    LineLength_prompt.RowSpan=[rs,rs];
    LineLength_prompt.ColSpan=[lprompt,rprompt];

    LineLength=simrfV2GetLeafWidgetBase('edit','','LineLength',...
    this,'LineLength');
    LineLength.RowSpan=[rs,rs];
    LineLength.ColSpan=[ledit,redit];

    LineLength_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'LineLength_unit',this,'LineLength_unit');
    LineLength_unit.Entries=set(this,'LineLength_unit')';
    LineLength_unit.RowSpan=[rs,rs];
    LineLength_unit.ColSpan=[lunit,runit];


    rs=rs+1;

    NumSegments_prompt=simrfV2GetLeafWidgetBase('text',...
    'Number of segments:','NumSegmentsprompt',0);
    NumSegments_prompt.RowSpan=[rs,rs];
    NumSegments_prompt.ColSpan=[lprompt,rprompt];

    NumSegments=simrfV2GetLeafWidgetBase('edit','','NumSegments',...
    this,'NumSegments');
    NumSegments.RowSpan=[rs,rs];
    NumSegments.ColSpan=[ledit,redit];


    rs=rs+1;

    StubMode_prompt=simrfV2GetLeafWidgetBase('text',...
    'Stub mode:','StubMode_prompt',0);
    StubMode_prompt.RowSpan=[rs,rs];
    StubMode_prompt.ColSpan=[lprompt,rprompt];

    StubMode=simrfV2GetLeafWidgetBase('combobox','','StubMode',...
    this,'StubMode');

    StubMode.RowSpan=[rs,rs];
    StubMode.ColSpan=[ledit,runit];
    StubMode.DialogRefresh=1;


    rs=rs+1;

    Termination_prompt=simrfV2GetLeafWidgetBase('text',...
    'Termination of stub:','Termination_prompt',0);
    Termination_prompt.RowSpan=[rs,rs];
    Termination_prompt.ColSpan=[lprompt,rprompt];

    Termination=simrfV2GetLeafWidgetBase('combobox','','Termination',...
    this,'Termination');

    Termination.RowSpan=[rs,rs];
    Termination.ColSpan=[ledit,runit];
    Termination.DialogRefresh=1;




    rs=rs+1;
    subType='';
    switch this.Model_type
    case 'Coplanar waveguide'
        if this.ConductorBacked
            subType='cb';
        end
    case 'Microstrip'
        subType=lower(this.StructureMicrostrip(1:3));
    end

    fname=[lower(regexprep(this.Model_type,'[- ()=]','')),subType,'.png'];
    imagepath=fullfile(matlabroot,'toolbox','simrf','simrfV2',...
    '@simrfV2dialog','@Xline','private');
    xlineimage.Name='...';
    xlineimage.Type='image';
    xlineimage.Tag='xlineimage';
    xlineimage.RowSpan=[rs,rs+3];
    xlineimage.ColSpan=[lprompt,runit];
    xlineimage.Alignment=6;
    xlineimage.FilePath=fullfile(imagepath,fname);


    rs=rs+4;

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


    hBlk=get_param(this,'Handle');
    idxMaskNames=simrfV2getblockmaskparamsindex(hBlk);
    slBlkVis=get_param(hBlk,'MaskVisibilities');

    [visItems,visLayout,slBlkVis]=simrfV2create_vis_pane(this,...
    slBlkVis,idxMaskNames);
    visualizationPane=simrfV2create_panel(this,'VisualizationPane',...
    visItems,visLayout);
    visualizationPane.Items{1}.Entries={'User-specified'};


    [modItems,modLayout,slBlkVis]=simrfV2create_modeling_pane(this,...
    slBlkVis,idxMaskNames);
    modelingPane=simrfV2create_panel(this,'ModelingPane',modItems,...
    modLayout);




    slBlkVis([...
    idxMaskNames.StructureMicrostrip...
    ,idxMaskNames.ConductorBacked...
    ,idxMaskNames.TransDelay,idxMaskNames.TransDelay_unit...
    ,idxMaskNames.CharImped,idxMaskNames.CharImped_unit...
    ,idxMaskNames.Resistance,idxMaskNames.Resistance_unit...
    ,idxMaskNames.Inductance,idxMaskNames.Inductance_unit...
    ,idxMaskNames.Capacitance,idxMaskNames.Capacitance_unit...
    ,idxMaskNames.Conductance,idxMaskNames.Conductance_unit...
    ,idxMaskNames.LineLength,idxMaskNames.LineLength_unit...
    ,idxMaskNames.NumSegments,idxMaskNames.OuterRadius...
    ,idxMaskNames.OuterRadius_unit,idxMaskNames.InnerRadius...
    ,idxMaskNames.InnerRadius_unit,idxMaskNames.MuR...
    ,idxMaskNames.EpsilonR,idxMaskNames.LossTangent...
    ,idxMaskNames.SigmaCond,idxMaskNames.SigmaCond_unit...
    ,idxMaskNames.ConductorWidth,idxMaskNames.ConductorWidth_unit...
    ,idxMaskNames.SlotWidth,idxMaskNames.SlotWidth_unit...
    ,idxMaskNames.Height,idxMaskNames.Height_unit...
    ,idxMaskNames.Height_inv,idxMaskNames.Height_inv_unit...
    ,idxMaskNames.Height_spd,idxMaskNames.Height_spd_unit...
    ,idxMaskNames.Height_emb,idxMaskNames.Height_emb_unit...
    ,idxMaskNames.StripHeight,idxMaskNames.StripHeight_unit...
    ,idxMaskNames.Thickness,idxMaskNames.Thickness_unit...
    ,idxMaskNames.SWidth,idxMaskNames.SWidth_unit...
    ,idxMaskNames.Radius,idxMaskNames.Radius_unit...
    ,idxMaskNames.Separation,idxMaskNames.Separation_unit...
    ,idxMaskNames.PWidth,idxMaskNames.PWidth_unit...
    ,idxMaskNames.PSeparation,idxMaskNames.PV...
    ,idxMaskNames.PSeparation_unit,idxMaskNames.Loss...
    ,idxMaskNames.Freq,idxMaskNames.Parameterization...
    ,idxMaskNames.Interp_type,idxMaskNames.Freq_unit...
    ,idxMaskNames.StubMode,idxMaskNames.Termination])={'off'};

    Structure.Visible=0;
    Structure_prompt.Visible=0;
    ConductorBack.Visible=0;
    ParamType.Visible=0;
    ParamType_prompt.Visible=0;
    TransDelay_prompt.Visible=0;
    TransDelay.Visible=0;
    TransDelay_unit.Visible=0;
    CharImped_prompt.Visible=0;
    CharImped.Visible=0;
    CharImped_unit.Visible=0;
    Resistance_prompt.Visible=0;
    Resistance.Visible=0;
    Resistance_unit.Visible=0;
    Inductance_prompt.Visible=0;
    Inductance.Visible=0;
    Inductance_unit.Visible=0;
    Capacitance_prompt.Visible=0;
    Capacitance.Visible=0;
    Capacitance_unit.Visible=0;
    Conductance_prompt.Visible=0;
    Conductance.Visible=0;
    Conductance_unit.Visible=0;
    LineLength_prompt.Visible=0;
    LineLength.Visible=0;
    LineLength_unit.Visible=0;
    NumSegments_prompt.Visible=0;
    NumSegments.Visible=0;
    OuterRadius_prompt.Visible=0;
    OuterRadius.Visible=0;
    OuterRadius_unit.Visible=0;
    InnerRadius_prompt.Visible=0;
    InnerRadius.Visible=0;
    InnerRadius_unit.Visible=0;
    MuR_prompt.Visible=0;
    MuR.Visible=0;
    EpsilonR_prompt.Visible=0;
    EpsilonR.Visible=0;
    LossTangent_prompt.Visible=0;
    LossTangent.Visible=0;
    SigmaCond_prompt.Visible=0;
    SigmaCond.Visible=0;
    SigmaCond_unit.Visible=0;
    StubMode_prompt.Visible=0;
    StubMode.Visible=0;
    Termination_prompt.Visible=0;
    Termination.Visible=0;
    ConductorWidth_prompt.Visible=0;
    ConductorWidth.Visible=0;
    ConductorWidth_unit.Visible=0;
    SlotWidth_prompt.Visible=0;
    SlotWidth.Visible=0;
    SlotWidth_unit.Visible=0;
    Height_prompt.Visible=0;
    Height.Visible=0;
    Height_unit.Visible=0;
    Height_inv.Visible=0;
    Height_inv_unit.Visible=0;
    Height_spd.Visible=0;
    Height_spd_unit.Visible=0;
    Height_emb.Visible=0;
    Height_emb_unit.Visible=0;
    StripHeight_prompt.Visible=0;
    StripHeight.Visible=0;
    StripHeight_unit.Visible=0;
    Thickness_prompt.Visible=0;
    Thickness.Visible=0;
    Thickness_unit.Visible=0;
    SWidth_prompt.Visible=0;
    SWidth.Visible=0;
    SWidth_unit.Visible=0;
    Radius_prompt.Visible=0;
    Radius.Visible=0;
    Radius_unit.Visible=0;
    Separation_prompt.Visible=0;
    Separation.Visible=0;
    Separation_unit.Visible=0;
    PWidth_prompt.Visible=0;
    PWidth.Visible=0;
    PWidth_unit.Visible=0;
    PSeparation_prompt.Visible=0;
    PSeparation.Visible=0;
    PSeparation_unit.Visible=0;
    PV_prompt.Visible=0;
    PV.Visible=0;
    Loss_prompt.Visible=0;
    Loss.Visible=0;
    Freq_prompt.Visible=0;
    Freq.Visible=0;
    Freq_unit.Visible=0;
    Interp_prompt.Visible=0;
    InterpType.Visible=0;

    switch this.Model_type
    case 'Delay-based and lossless'
        TransDelay_prompt.Visible=1;
        TransDelay.Visible=1;
        TransDelay_unit.Visible=1;
        CharImped_prompt.Visible=1;
        CharImped.Visible=1;
        CharImped_unit.Visible=1;
        slBlkVis([...
        idxMaskNames.TransDelay,idxMaskNames.TransDelay_unit...
        ,idxMaskNames.CharImped,idxMaskNames.CharImped_unit])={'on'};
    case 'Delay-based and lossy'
        TransDelay_prompt.Visible=1;
        TransDelay.Visible=1;
        TransDelay_unit.Visible=1;
        CharImped_prompt.Visible=1;
        CharImped.Visible=1;
        CharImped_unit.Visible=1;
        Resistance_prompt.Visible=1;
        Resistance.Visible=1;
        Resistance_unit.Visible=1;
        LineLength_prompt.Visible=1;
        LineLength.Visible=1;
        LineLength_unit.Visible=1;
        NumSegments_prompt.Visible=1;
        NumSegments.Visible=1;
        slBlkVis([...
        idxMaskNames.TransDelay,idxMaskNames.TransDelay_unit...
        ,idxMaskNames.CharImped,idxMaskNames.CharImped_unit...
        ,idxMaskNames.Resistance,idxMaskNames.Resistance_unit...
        ,idxMaskNames.LineLength,idxMaskNames.LineLength_unit...
        ,idxMaskNames.NumSegments])={'on'};
    case 'Lumped parameter L-section'
        ParamType.Visible=1;
        ParamType_prompt.Visible=1;
        slBlkVis(idxMaskNames.Parameterization)={'on'};
        if strcmp('By inductance and capacitance',this.Parameterization)
            Inductance_prompt.Visible=1;
            Inductance.Visible=1;
            Inductance_unit.Visible=1;
            slBlkVis([...
            idxMaskNames.Resistance,idxMaskNames.Resistance_unit...
            ,idxMaskNames.Inductance,idxMaskNames.Inductance_unit...
            ,idxMaskNames.Capacitance,idxMaskNames.Capacitance_unit...
            ,idxMaskNames.Conductance,idxMaskNames.Conductance_unit...
            ,idxMaskNames.LineLength,idxMaskNames.LineLength_unit...
            ,idxMaskNames.NumSegments])={'on'};
        else
            CharImped_prompt.Visible=1;
            CharImped.Visible=1;
            CharImped_unit.Visible=1;
            slBlkVis([...
            idxMaskNames.CharImped,idxMaskNames.CharImped_unit...
            ,idxMaskNames.Resistance,idxMaskNames.Resistance_unit...
            ,idxMaskNames.Capacitance,idxMaskNames.Capacitance_unit...
            ,idxMaskNames.Conductance,idxMaskNames.Conductance_unit...
            ,idxMaskNames.LineLength,idxMaskNames.LineLength_unit...
            ,idxMaskNames.NumSegments])={'on'};
        end
        Resistance_prompt.Visible=1;
        Resistance.Visible=1;
        Resistance_unit.Visible=1;
        Capacitance_prompt.Visible=1;
        Capacitance.Visible=1;
        Capacitance_unit.Visible=1;
        Conductance_prompt.Visible=1;
        Conductance.Visible=1;
        Conductance_unit.Visible=1;
        LineLength_prompt.Visible=1;
        LineLength.Visible=1;
        LineLength_unit.Visible=1;
        NumSegments_prompt.Visible=1;
        NumSegments.Visible=1;
    case 'Lumped parameter Pi-section'
        ParamType.Visible=1;
        ParamType_prompt.Visible=1;
        slBlkVis(idxMaskNames.Parameterization)={'on'};
        if strcmp('By inductance and capacitance',this.Parameterization)
            Inductance_prompt.Visible=1;
            Inductance.Visible=1;
            Inductance_unit.Visible=1;
            slBlkVis([...
            idxMaskNames.Resistance,idxMaskNames.Resistance_unit...
            ,idxMaskNames.Inductance,idxMaskNames.Inductance_unit...
            ,idxMaskNames.Capacitance,idxMaskNames.Capacitance_unit...
            ,idxMaskNames.Conductance,idxMaskNames.Conductance_unit...
            ,idxMaskNames.LineLength,idxMaskNames.LineLength_unit...
            ,idxMaskNames.NumSegments])={'on'};
        else
            CharImped_prompt.Visible=1;
            CharImped.Visible=1;
            CharImped_unit.Visible=1;
            slBlkVis([...
            idxMaskNames.CharImped,idxMaskNames.CharImped_unit...
            ,idxMaskNames.Resistance,idxMaskNames.Resistance_unit...
            ,idxMaskNames.Capacitance,idxMaskNames.Capacitance_unit...
            ,idxMaskNames.Conductance,idxMaskNames.Conductance_unit...
            ,idxMaskNames.LineLength,idxMaskNames.LineLength_unit...
            ,idxMaskNames.NumSegments])={'on'};
        end
        Resistance_prompt.Visible=1;
        Resistance.Visible=1;
        Resistance_unit.Visible=1;
        Capacitance_prompt.Visible=1;
        Capacitance.Visible=1;
        Capacitance_unit.Visible=1;
        Conductance_prompt.Visible=1;
        Conductance.Visible=1;
        Conductance_unit.Visible=1;
        LineLength_prompt.Visible=1;
        LineLength.Visible=1;
        LineLength_unit.Visible=1;
        NumSegments_prompt.Visible=1;
        NumSegments.Visible=1;
    case 'Coaxial'
        OuterRadius_prompt.Visible=1;
        OuterRadius.Visible=1;
        OuterRadius_unit.Visible=1;
        InnerRadius_prompt.Visible=1;
        InnerRadius.Visible=1;
        InnerRadius_unit.Visible=1;
        MuR_prompt.Visible=1;
        MuR.Visible=1;
        EpsilonR_prompt.Visible=1;
        EpsilonR.Visible=1;
        LossTangent_prompt.Visible=1;
        LossTangent.Visible=1;
        SigmaCond_prompt.Visible=1;
        SigmaCond.Visible=1;
        SigmaCond_unit.Visible=1;
        LineLength_prompt.Visible=1;
        LineLength.Visible=1;
        LineLength_unit.Visible=1;
        StubMode_prompt.Visible=1;
        StubMode.Visible=1;
        Termination_prompt.Visible=1;
        Termination.Visible=1;
        slBlkVis([...
        idxMaskNames.OuterRadius,idxMaskNames.OuterRadius_unit...
        ,idxMaskNames.InnerRadius,idxMaskNames.InnerRadius_unit...
        ,idxMaskNames.SigmaCond,idxMaskNames.SigmaCond_unit...
        ,idxMaskNames.MuR...
        ,idxMaskNames.EpsilonR...
        ,idxMaskNames.LossTangent...
        ,idxMaskNames.LineLength,idxMaskNames.LineLength_unit...
        ,idxMaskNames.StubMode...
        ,idxMaskNames.Termination])={'on'};
    case 'Coplanar waveguide'
        ConductorBack.Visible=1;
        ConductorWidth_prompt.Visible=1;
        ConductorWidth.Visible=1;
        ConductorWidth_unit.Visible=1;
        SlotWidth_prompt.Visible=1;
        SlotWidth.Visible=1;
        SlotWidth_unit.Visible=1;
        Height_prompt.Visible=1;
        Height.Visible=1;
        Height_unit.Visible=1;
        Thickness_prompt.Visible=1;
        Thickness.Visible=1;
        Thickness_unit.Visible=1;
        EpsilonR_prompt.Visible=1;
        EpsilonR.Visible=1;
        LossTangent_prompt.Visible=1;
        LossTangent.Visible=1;
        SigmaCond_prompt.Visible=1;
        SigmaCond.Visible=1;
        SigmaCond_unit.Visible=1;
        LineLength_prompt.Visible=1;
        LineLength.Visible=1;
        LineLength_unit.Visible=1;
        StubMode_prompt.Visible=1;
        StubMode.Visible=1;
        Termination_prompt.Visible=1;
        Termination.Visible=1;
        slBlkVis([...
        idxMaskNames.ConductorBacked...
        ,idxMaskNames.ConductorWidth,idxMaskNames.ConductorWidth_unit...
        ,idxMaskNames.SlotWidth,idxMaskNames.SlotWidth_unit...
        ,idxMaskNames.Thickness,idxMaskNames.Thickness_unit...
        ,idxMaskNames.SigmaCond,idxMaskNames.SigmaCond_unit...
        ,idxMaskNames.Height,idxMaskNames.Height_unit...
        ,idxMaskNames.EpsilonR...
        ,idxMaskNames.LossTangent...
        ,idxMaskNames.LineLength,idxMaskNames.LineLength_unit...
        ,idxMaskNames.StubMode...
        ,idxMaskNames.Termination])={'on'};
    case 'Microstrip'
        Structure_prompt.Visible=1;
        Structure.Visible=1;
        SWidth_prompt.Visible=1;
        SWidth.Visible=1;
        SWidth_unit.Visible=1;
        Height_prompt.Visible=1;
        Thickness_prompt.Visible=1;
        Thickness.Visible=1;
        Thickness_unit.Visible=1;
        EpsilonR_prompt.Visible=1;
        EpsilonR.Visible=1;
        LossTangent_prompt.Visible=1;
        LossTangent.Visible=1;
        SigmaCond_prompt.Visible=1;
        SigmaCond.Visible=1;
        SigmaCond_unit.Visible=1;
        LineLength_prompt.Visible=1;
        LineLength.Visible=1;
        LineLength_unit.Visible=1;
        StubMode_prompt.Visible=1;
        StubMode.Visible=1;
        Termination_prompt.Visible=1;
        Termination.Visible=1;
        slBlkVis([...
        idxMaskNames.StructureMicrostrip...
        ,idxMaskNames.SWidth,idxMaskNames.SWidth_unit...
        ,idxMaskNames.Thickness,idxMaskNames.Thickness_unit...
        ,idxMaskNames.SigmaCond,idxMaskNames.SigmaCond_unit...
        ,idxMaskNames.Height,idxMaskNames.Height_unit...
        ,idxMaskNames.EpsilonR...
        ,idxMaskNames.LossTangent...
        ,idxMaskNames.LineLength,idxMaskNames.LineLength_unit...
        ,idxMaskNames.StubMode...
        ,idxMaskNames.Termination])={'on'};
        if~strcmp('Standard',this.StructureMicrostrip)
            StripHeight_prompt.Visible=1;
            StripHeight.Visible=1;
            StripHeight_unit.Visible=1;
            slBlkVis([...
            idxMaskNames.StripHeight...
            ,idxMaskNames.StripHeight_unit])={'on'};
        end
        switch this.StructureMicrostrip
        case 'Inverted'
            Height_inv.Visible=1;
            Height_inv_unit.Visible=1;
            slBlkVis([
            idxMaskNames.Height_inv...
            ,idxMaskNames.Height_inv_unit])={'on'};
        case 'Suspended'
            Height_spd.Visible=1;
            Height_spd_unit.Visible=1;
            slBlkVis([
            idxMaskNames.Height_spd...
            ,idxMaskNames.Height_spd_unit])={'on'};
        case 'Embedded'
            Height_emb.Visible=1;
            Height_emb_unit.Visible=1;
            slBlkVis([
            idxMaskNames.Height_emb...
            ,idxMaskNames.Height_emb_unit])={'on'};
        otherwise
            Height.Visible=1;
            Height_unit.Visible=1;
            slBlkVis([
            idxMaskNames.Height...
            ,idxMaskNames.Height_unit])={'on'};
        end
    case 'Stripline'
        SWidth_prompt.Visible=1;
        SWidth.Visible=1;
        SWidth_unit.Visible=1;
        Height_prompt.Visible=1;
        Height.Visible=1;
        Height_unit.Visible=1;
        Thickness_prompt.Visible=1;
        Thickness.Visible=1;
        Thickness_unit.Visible=1;
        EpsilonR_prompt.Visible=1;
        EpsilonR.Visible=1;
        LossTangent_prompt.Visible=1;
        LossTangent.Visible=1;
        SigmaCond_prompt.Visible=1;
        SigmaCond.Visible=1;
        SigmaCond_unit.Visible=1;
        LineLength_prompt.Visible=1;
        LineLength.Visible=1;
        LineLength_unit.Visible=1;
        StubMode_prompt.Visible=1;
        StubMode.Visible=1;
        Termination_prompt.Visible=1;
        Termination.Visible=1;
        slBlkVis([...
        idxMaskNames.SWidth,idxMaskNames.SWidth_unit...
        ,idxMaskNames.Thickness,idxMaskNames.Thickness_unit...
        ,idxMaskNames.SigmaCond,idxMaskNames.SigmaCond_unit...
        ,idxMaskNames.Height,idxMaskNames.Height_unit...
        ,idxMaskNames.EpsilonR...
        ,idxMaskNames.LossTangent...
        ,idxMaskNames.LineLength,idxMaskNames.LineLength_unit...
        ,idxMaskNames.StubMode...
        ,idxMaskNames.Termination])={'on'};
    case 'Two-wire'
        Radius_prompt.Visible=1;
        Radius.Visible=1;
        Radius_unit.Visible=1;
        Separation_prompt.Visible=1;
        Separation.Visible=1;
        Separation_unit.Visible=1;
        MuR_prompt.Visible=1;
        MuR.Visible=1;
        EpsilonR_prompt.Visible=1;
        EpsilonR.Visible=1;
        LossTangent_prompt.Visible=1;
        LossTangent.Visible=1;
        SigmaCond_prompt.Visible=1;
        SigmaCond.Visible=1;
        SigmaCond_unit.Visible=1;
        LineLength_prompt.Visible=1;
        LineLength.Visible=1;
        LineLength_unit.Visible=1;
        StubMode_prompt.Visible=1;
        StubMode.Visible=1;
        Termination_prompt.Visible=1;
        Termination.Visible=1;
        slBlkVis([...
        idxMaskNames.Radius,idxMaskNames.Radius_unit...
        ,idxMaskNames.Separation,idxMaskNames.Separation_unit...
        ,idxMaskNames.SigmaCond,idxMaskNames.SigmaCond_unit...
        ,idxMaskNames.MuR...
        ,idxMaskNames.EpsilonR...
        ,idxMaskNames.LossTangent...
        ,idxMaskNames.LineLength,idxMaskNames.LineLength_unit...
        ,idxMaskNames.StubMode...
        ,idxMaskNames.Termination])={'on'};
    case 'Parallel-plate'
        PWidth_prompt.Visible=1;
        PWidth.Visible=1;
        PWidth_unit.Visible=1;
        PSeparation_prompt.Visible=1;
        PSeparation.Visible=1;
        PSeparation_unit.Visible=1;
        MuR_prompt.Visible=1;
        MuR.Visible=1;
        EpsilonR_prompt.Visible=1;
        EpsilonR.Visible=1;
        LossTangent_prompt.Visible=1;
        LossTangent.Visible=1;
        SigmaCond_prompt.Visible=1;
        SigmaCond.Visible=1;
        SigmaCond_unit.Visible=1;
        LineLength_prompt.Visible=1;
        LineLength.Visible=1;
        LineLength_unit.Visible=1;
        StubMode_prompt.Visible=1;
        StubMode.Visible=1;
        Termination_prompt.Visible=1;
        Termination.Visible=1;
        slBlkVis([...
        idxMaskNames.PWidth,idxMaskNames.PWidth_unit...
        ,idxMaskNames.PSeparation,idxMaskNames.PSeparation_unit...
        ,idxMaskNames.SigmaCond,idxMaskNames.SigmaCond_unit...
        ,idxMaskNames.MuR...
        ,idxMaskNames.EpsilonR...
        ,idxMaskNames.LossTangent...
        ,idxMaskNames.LineLength,idxMaskNames.LineLength_unit...
        ,idxMaskNames.StubMode...
        ,idxMaskNames.Termination])={'on'};
    case 'Equation-based'
        CharImped_prompt.Visible=1;
        CharImped.Visible=1;
        CharImped_unit.Visible=1;
        PV_prompt.Visible=1;
        PV.Visible=1;
        Loss_prompt.Visible=1;
        Loss.Visible=1;
        Freq_prompt.Visible=1;
        Freq.Visible=1;
        Freq_unit.Visible=1;
        Interp_prompt.Visible=1;
        InterpType.Visible=1;
        LineLength_prompt.Visible=1;
        LineLength.Visible=1;
        LineLength_unit.Visible=1;
        StubMode_prompt.Visible=1;
        StubMode.Visible=1;
        Termination_prompt.Visible=1;
        Termination.Visible=1;
        slBlkVis([...
        idxMaskNames.CharImped,idxMaskNames.CharImped_unit...
        ,idxMaskNames.LineLength,idxMaskNames.LineLength_unit...
        ,idxMaskNames.PV,idxMaskNames.Loss...
        ,idxMaskNames.Freq,idxMaskNames.Interp_type...
        ,idxMaskNames.Termination,idxMaskNames.Freq_unit...
        ,idxMaskNames.StubMode])={'on'};
    case 'RLCG'
        Resistance_prompt.Visible=1;
        Resistance.Visible=1;
        Resistance_unit.Visible=1;
        Inductance_prompt.Visible=1;
        Inductance.Visible=1;
        Inductance_unit.Visible=1;
        Capacitance_prompt.Visible=1;
        Capacitance.Visible=1;
        Capacitance_unit.Visible=1;
        Conductance_prompt.Visible=1;
        Conductance.Visible=1;
        Conductance_unit.Visible=1;
        Freq_prompt.Visible=1;
        Freq.Visible=1;
        Freq_unit.Visible=1;
        Interp_prompt.Visible=1;
        InterpType.Visible=1;
        LineLength_prompt.Visible=1;
        LineLength.Visible=1;
        LineLength_unit.Visible=1;
        StubMode_prompt.Visible=1;
        StubMode.Visible=1;
        Termination_prompt.Visible=1;
        Termination.Visible=1;
        slBlkVis([...
        idxMaskNames.LineLength,idxMaskNames.LineLength_unit...
        ,idxMaskNames.Freq,idxMaskNames.Resistance...
        ,idxMaskNames.Resistance_unit,idxMaskNames.Inductance...
        ,idxMaskNames.Inductance_unit,idxMaskNames.Capacitance...
        ,idxMaskNames.Capacitance_unit,idxMaskNames.Conductance...
        ,idxMaskNames.Conductance_unit,idxMaskNames.Termination...
        ,idxMaskNames.Freq_unit,idxMaskNames.Interp_type...
        ,idxMaskNames.StubMode])={'on'};
    end

    if strcmpi(this.StubMode,'Not a stub')
        Termination_prompt.Visible=0;
        Termination.Visible=0;
        slBlkVis(idxMaskNames.Termination)={'off'};
    end


    if~strcmpi(get_param(bdroot(hBlk),'Lock'),'on')
        set_param(hBlk,'MaskVisibilities',slBlkVis);

        set_param(hBlk,'MaskVisibilities',slBlkVis);

    end






    mainParamsPanel.Type='group';
    mainParamsPanel.Name='Parameters';
    mainParamsPanel.Tag='mainParamsPanel';
    mainParamsPanel.Items={...
    ModelType,ModelType_prompt,...
    Structure,Structure_prompt,...
    ParamType,ParamType_prompt,...
    ConductorBack,...
    TransDelay_prompt,TransDelay,TransDelay_unit,...
    CharImped_prompt,CharImped,CharImped_unit,...
    Resistance_prompt,Resistance,Resistance_unit,...
    Inductance,Inductance_unit,Inductance_prompt,...
    Capacitance,Capacitance_unit,Capacitance_prompt,...
    Conductance,Conductance_unit,Conductance_prompt,...
    LineLength,LineLength_unit,LineLength_prompt,...
    NumSegments,NumSegments_prompt,...
    OuterRadius_prompt,OuterRadius,OuterRadius_unit,...
    InnerRadius_prompt,InnerRadius,InnerRadius_unit,...
    MuR_prompt,MuR,EpsilonR_prompt,EpsilonR,...
    LossTangent_prompt,LossTangent,...
    SigmaCond_prompt,SigmaCond,SigmaCond_unit,...
    ConductorWidth_prompt,ConductorWidth,ConductorWidth_unit,...
    SlotWidth_prompt,SlotWidth,SlotWidth_unit,...
    Height_prompt,Height,Height_unit,...
    Height_inv,Height_inv_unit,...
    Height_spd,Height_spd_unit,...
    Height_emb,Height_emb_unit,...
    StripHeight_prompt,StripHeight,StripHeight_unit,...
    Thickness_prompt,Thickness,Thickness_unit,...
    SWidth_prompt,SWidth,SWidth_unit,...
    Radius_prompt,Radius,Radius_unit,...
    Separation_prompt,Separation,Separation_unit,...
    PWidth_prompt,PWidth,PWidth_unit,...
    PSeparation_prompt,PSeparation,PSeparation_unit,...
    PV_prompt,PV,Loss_prompt,Loss,Freq_prompt,Freq,Freq_unit...
    ,StubMode_prompt,StubMode,Interp_prompt,InterpType...
    ,Termination_prompt,Termination,xlineimage,grounding,spacerMain};

    mainParamsPanel.LayoutGrid=[maxrows,number_grid];
    mainParamsPanel.RowSpan=[2,2];
    mainParamsPanel.ColSpan=[1,1];



    mainTab.Name='Main';
    mainTab.Items={mainParamsPanel};
    mainTab.LayoutGrid=[1,1];
    mainTab.RowStretch=0;
    mainTab.ColStretch=0;


    modelingTab.Name='Modeling';
    modelingTab.Items={modelingPane};
    modelingTab.LayoutGrid=[1,1];
    modelingTab.RowStretch=0;
    modelingTab.ColStretch=0;


    visualizationTab.Name='Visualization';
    visualizationTab.Items={visualizationPane};
    visualizationTab.LayoutGrid=[1,1];
    visualizationTab.RowStretch=0;
    visualizationTab.ColStretch=0;


    tabbedPane.Type='tab';
    tabbedPane.Name='';
    tabbedPane.Tag='TabPane';
    tabbedPane.RowSpan=[2,2];
    tabbedPane.ColSpan=[1,1];
    if(strcmpi(this.Model_type,'Delay-based and lossless')||...
        strcmpi(this.Model_type,'Delay-based and lossy')||...
        strcmpi(this.Model_type,'Lumped parameter L-section')||...
        strcmpi(this.Model_type,'Lumped parameter Pi-section'))
        tabbedPane.Tabs={mainTab};
    else
        blk=this.getBlock;
        blkName=blk.getFullName;
        auxData=get_param([blkName,'/AuxData'],'UserData');
        if isfield(auxData,'Ckt')
            tabbedPane.Tabs={mainTab,modelingTab,visualizationTab};
        else
            tabbedPane.Tabs={mainTab,modelingTab};
        end
    end



    dlgStruct=getBaseSchemaStruct(this,tabbedPane);

