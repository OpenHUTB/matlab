function dlgStruct=getDialogSchema(this,~)









    lprompt=1;
    rprompt=4;
    ledit=rprompt+1;
    redit=17;
    lunit=redit+1;
    runit=20;
    number_grid=20;

    hBlk=get_param(this,'Handle');
    fromLibrary=strcmpi(get_param(bdroot(hBlk),'BlockDiagramType'),'library');



    rs=1;
    sensortype=simrfV2GetLeafWidgetBase('combobox','','SensorType',...
    this,'SensorType');
    sensortype.Entries=set(this,'SensorType')';
    sensortype.RowSpan=[rs,rs];
    sensortype.ColSpan=[ledit,runit];
    sensortype.DialogRefresh=1;

    sensortypeprompt=simrfV2GetLeafWidgetBase('text','Sensor type:',...
    'SensorTypePrompt',0);
    sensortypeprompt.RowSpan=[rs,rs];
    sensortypeprompt.ColSpan=[lprompt,rprompt];


    rs=rs+1;
    ZLprompt=simrfV2GetLeafWidgetBase('text','Load impedance (Ohm):',...
    'ZLPrompt',0);
    ZLprompt.RowSpan=[rs,rs];
    ZLprompt.ColSpan=[lprompt,rprompt];

    ZL=simrfV2GetLeafWidgetBase('edit','','ZL',this,'ZL');
    ZL.RowSpan=[rs,rs];
    ZL.ColSpan=[ledit,redit];


    rs=rs+1;
    outputformat=simrfV2GetLeafWidgetBase('combobox','','OutputFormat',...
    this,'OutputFormat');
    outputformat.Entries=set(this,'OutputFormat')';
    outputformat.RowSpan=[rs,rs];
    outputformat.ColSpan=[ledit,runit];
    outputformat.DialogRefresh=1;

    outputformatprompt=simrfV2GetLeafWidgetBase('text','Output:',...
    'OutputFormatPrompt',0);
    outputformatprompt.RowSpan=[rs,rs];
    outputformatprompt.ColSpan=[lprompt,rprompt];


    rs=rs+1;
    freqprompt=simrfV2GetLeafWidgetBase('text','Carrier frequencies:',...
    'CarrierFreqPrompt',0);
    freqprompt.RowSpan=[rs,rs];
    freqprompt.ColSpan=[lprompt,rprompt];

    freq=simrfV2GetLeafWidgetBase('edit','','CarrierFreq',0,'CarrierFreq');
    freq.RowSpan=[rs,rs];
    freq.ColSpan=[ledit,redit];

    frequnit=simrfV2GetLeafWidgetBase('combobox','','CarrierFreq_unit',...
    this,'CarrierFreq_unit');
    frequnit.Entries=set(this,'CarrierFreq_unit')';
    frequnit.RowSpan=[rs,rs];
    frequnit.ColSpan=[lunit,runit];


    rs=rs+1;
    autostep=simrfV2GetLeafWidgetBase('checkbox','Automatically compute output step size',...
    'AutoStep',this,'AutoStep');
    autostep.RowSpan=[rs,rs];
    autostep.ColSpan=[lprompt,redit];
    autostep.DialogRefresh=1;


    rs=rs+1;
    stepsizeprompt=simrfV2GetLeafWidgetBase('text','Step size:',...
    'StepSizeprompt',0);
    stepsizeprompt.RowSpan=[rs,rs];
    stepsizeprompt.ColSpan=[lprompt,rprompt];

    stepsize=simrfV2GetLeafWidgetBase('edit','','StepSize',this,...
    'StepSize');
    stepsize.RowSpan=[rs,rs];
    stepsize.ColSpan=[ledit,redit];

    stepsizeunit=simrfV2GetLeafWidgetBase('combobox','',...
    'StepSize_unit',this,'StepSize_unit');
    stepsizeunit.Entries=set(this,'StepSize_unit')';
    stepsizeunit.RowSpan=[rs,rs];
    stepsizeunit.ColSpan=[lunit,runit];



    rs=rs+1;
    grounding=simrfV2GetLeafWidgetBase('checkbox','Ground and hide negative terminal',...
    'InternalGrounding',this,'InternalGrounding');
    grounding.RowSpan=[rs,rs];
    grounding.ColSpan=[lprompt,runit];



    rs=rs+1;
    spacerMain=simrfV2GetLeafWidgetBase('text',' ','',0);
    spacerMain.RowSpan=[rs,rs];
    spacerMain.ColSpan=[lprompt,runit];

    maxrows=spacerMain.RowSpan(1);

    switch lower(this.SensorType)
    case 'ideal voltage'
        grounding.Visible=1;
        this.ZL='Inf';
        ZLprompt.Visible=0;
        ZL.Visible=0;
    case 'ideal current'
        grounding.Visible=1;
        this.ZL='0';
        ZLprompt.Visible=0;
        ZL.Visible=0;
    case 'power'
        grounding.Visible=1;
        if isinf(str2double(this.ZL))||isequal(str2double(this.ZL),0)
            this.ZL='50';
        end
        ZLprompt.Visible=1;
        ZL.Visible=1;
    end


    show_step=strcmpi(this.OutputFormat,'Real Passband');
    stepsizeprompt.Visible=show_step;
    stepsize.Visible=show_step;
    stepsizeunit.Visible=show_step;
    autostep.Visible=show_step;

    allow_modify=~this.AutoStep;
    stepsizeprompt.Enabled=allow_modify;
    stepsize.Enabled=allow_modify;
    stepsizeunit.Enabled=allow_modify;


    if~fromLibrary&&show_step&&this.AutoStep
        if isfield(this.Block.UserData,'AutoStepValue')
            this.StepSize=num2str(this.Block.UserData.AutoStepValue);
        end
        if isfield(this.Block.UserData,'AutoStepValueUnit')
            this.StepSize_unit=this.Block.UserData.AutoStepValueUnit;
        end
    end



    mainParamsPanel.Type='group';
    mainParamsPanel.Name='Parameters';
    mainParamsPanel.Tag='mainParamsPanel';
    mainParamsPanel.Items={sensortype,sensortypeprompt,outputformat,...
    outputformatprompt,freqprompt,freq,frequnit,grounding,ZLprompt,ZL,...
    spacerMain,stepsizeprompt,stepsize,stepsizeunit,autostep};
    mainParamsPanel.LayoutGrid=[maxrows,number_grid];
    mainParamsPanel.RowSpan=[2,2];
    mainParamsPanel.ColSpan=[1,1];


    dlgStruct=getBaseSchemaStruct(this,mainParamsPanel);

