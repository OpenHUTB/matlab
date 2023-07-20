function dlgStruct=getDialogSchema(this,~)








    alignAuto=0;%#ok
    alignLeft=1;%#ok
    alignTopLeft=2;%#ok
    alignTopCenter=3;%#ok
    alignTopRight=4;%#ok
    alignCenterLeft=5;%#ok
    alignCenter=6;%#ok
    alignCenterRight=7;%#ok
    alignBottomLeft=8;%#ok
    alignBottomCenter=9;%#ok
    alignBottomRight=10;%#ok




    title=this.Block.Name;

    title(double(title)==10)=' ';
    dlgStruct.DialogTitle=['Block Parameters: ',title];
    dlgStruct.HelpMethod='eval';
    dlgStruct.HelpArgs={this.Block.MaskHelp};
    dlgStruct.DialogTag=this.Block.Name;
    dlgStruct.PreApplyMethod='PreApply';
    dlgStruct.PreApplyArgs={'%dialog'};
    dlgStruct.PreApplyArgsDT={'handle'};
    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};
    dlgStruct.DefaultOk=false;



    if any(strcmp(this.Root.SimulationStatus,{'running','paused'}))
        dlgStruct.DisableDialog=1;
    end




    mainC.Type='panel';
    mainC.Tag='mainC';
    mainC.LayoutGrid=[2,1];
    mainC.RowStretch=[0,1];
    mainC.RowSpan=[1,1];
    mainC.ColSpan=[1,1];




    descC.Type='group';
    descC.Name=this.Block.MaskType;
    descC.Tag='descC';
    descC.RowSpan=[1,1];
    descC.ColSpan=[1,1];
    descC.Items={l_CreateBlockDescriptionWidget(this)};


    tabC.Type='tab';
    tabC.Tag='tabC';
    tabC.RowSpan=[2,2];
    tabC.ColSpan=[1,1];


    blockInfoTab.Name='Block Info';
    blockInfoTabItemsC.Type='panel';
    blockInfoTabItemsC.Tag='BlockInfoPanel';
    blockInfoTabItemsC.LayoutGrid=[3,1];
    blockInfoTabItemsC.Items={l_CreateBlockInfoHeader(this)};
    blockInfoTabItemsC.Items(2)={l_CreateBlockInfoStatic(this)};
    blockInfoTabItemsC.Items(3)={l_CreateBlockInfoHowTo(this)};
    blockInfoTabItemsC.Items{1}.RowSpan=[1,1];
    blockInfoTabItemsC.Items{2}.RowSpan=[2,2];
    blockInfoTabItemsC.Items{3}.RowSpan=[3,3];
    blockInfoTab.Items={blockInfoTabItemsC};


    portsTab.Name='Ports';
    portsTabItemsC.Type='panel';
    portsTabItemsC.Tag='PortsPanel';
    portsTabItemsC.LayoutGrid=[3,1];
    portsTabItemsC.RowStretch=[0,0,1];
    portsTabItemsC.Items={l_CreateAllowDirectFeedthroughWidget(this)};
    portsTabItemsC.Items(2)={l_CreateAutofillWidget(this)};
    portsTabItemsC.Items(3)={l_CreatePortListWidget(this)};
    portsTabItemsC.Items{1}.RowSpan=[1,1];
    portsTabItemsC.Items{2}.RowSpan=[2,2];
    portsTabItemsC.Items{3}.RowSpan=[3,3];
    portsTab.Items={portsTabItemsC};


    clocksTab.Name='Clocks, Resets, Enables';
    clocksTabItemsC.Type='panel';
    clocksTabItemsC.Tag='ClocksPanel';
    clocksTabItemsC.LayoutGrid=[4,7];
    clocksTabItemsC.RowStretch=[0,0,0,1];
    clocksTabItemsC.Items={l_CreateClockDescriptionWidget(this)};
    clocksTabItemsC.Items(2)={l_CreateSpacer([2,2],[1,1]);};
    clocksTabItemsC.Items(3)={l_CreateCosimStartTimeWidget(this)};
    clocksTabItemsC.Items(4)={l_CreateClockListWidget(this)};
    clocksTabItemsC.Items{1}.RowSpan=[1,1];
    clocksTabItemsC.Items{2}.RowSpan=[2,2];
    clocksTabItemsC.Items{3}.RowSpan=[3,3];
    clocksTabItemsC.Items{4}.RowSpan=[4,4];
    if(strcmpi(this.ProductName,'EDA Simulator Link DS'))
        clocksTab.Visible=0;
    else
        clocksTab.Visible=1;
    end
    clocksTab.Items={clocksTabItemsC};


    tscaleTab.Name='Timescales';
    tscaleTabItemsC.Type='panel';
    tscaleTabItemsC.Tag='TimescalesPanel';
    tscaleTabItemsC.LayoutGrid=[3,1];
    tscaleTabItemsC.RowStretch=[0,0,1];
    tscaleTabItemsC.Items={l_CreateTimescaleDescriptionWidget(this)};
    tscaleTabItemsC.Items(2)={l_CreateTimescaleWidget(this)};
    tscaleTabItemsC.Items(3)={l_CreateSpacer([3,3],[1,1]);};
    tscaleTabItemsC.Items{1}.RowSpan=[1,1];
    tscaleTabItemsC.Items{2}.RowSpan=[2,2];
    tscaleTab.Items={tscaleTabItemsC};

...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
    tabC.Tabs={blockInfoTab,portsTab,clocksTab,tscaleTab};
    tabC.ActiveTab=this.CurrentTab;



    tabC.TabChangedCallback='cosimBlock_TabChangedCB';

    mainC.Items={descC,tabC};

    dlgStruct.Items={mainC};

end




function widget=l_CreateSpacer(rowSpan,colSpan)
    widget.Type='panel';
    widget.RowSpan=rowSpan;
    widget.ColSpan=colSpan;
end




function bdItem=l_CreateBlockDescriptionWidget(this)
    bdItem.Type='text';
    bdItem.Name=this.Block.MaskDescription;
    bdItem.Tag='description';
    bdItem.WordWrap=1;
end





function afGroup=l_CreateAutofillWidget(~)
    afGroup.Type='panel';
    afGroup.Tag='afGroup';
    afGroup.LayoutGrid=[1,3];
    afGroup.ColStretch=[0,0,1];

    autofill.Type='pushbutton';
    autofill.Name='Auto Fill';
    autofill.ObjectMethod='Autofill';
    autofill.MethodArgs={'%dialog'};
    autofill.ArgDataTypes={'handle'};
    autofill.RowSpan=[1,1];
    autofill.ColSpan=[1,1];
    autofill.Alignment=6;

    afSpacer=l_CreateSpacer([1,1],[2,2]);

    afDescr.Type='text';
    afDescr.Name=[...
    'Use the ''Auto Fill'' button to automatically create the ',...
    'signal interface from a specified HDL component instance.'];
    afDescr.Tag='afDescr';
    afDescr.WordWrap=1;
    afDescr.RowSpan=[1,1];
    afDescr.ColSpan=[3,3];

    autofill.Visible=0;
    afSpacer.Visible=0;
    afDescr.Visible=0;
    afGroup.Items={autofill,afSpacer,afDescr};
end


function dftGroup=l_CreateAllowDirectFeedthroughWidget(~)
    dftGroup.Type='panel';
    dftGroup.Tag='dftGroup';
    dftGroup.LayoutGrid=[1,3];
    dftGroup.ColStretch=[0,0,1];

    dftOption.Type='checkbox';

    dftOption.Name='';
    dftOption.RowSpan=[1,1];
    dftOption.ColSpan=[1,1];
    dftOption.Tag='AllowDirectFeedthrough';
    dftOption.ObjectProperty='AllowDirectFeedthrough';
    dftOption.Alignment=1;

    dftLabel.Type='text';
    dftLabel.Name='Enable direct feedthrough';
    dftLabel.RowSpan=[1,1];
    dftLabel.ColSpan=[2,3];
    dftLabel.Tag='dftLabel';
    dftLabel.ObjectProperty='dftLabel';
    dftLabel.Alignment=1;



    dftExp.Type='text';
    dftExp.Name='If this block is in a feedback loop and generates algebraic loop warning/error, uncheck this box';
    dftExp.RowSpan=[2,2];
    dftExp.ColSpan=[2,3];
    dftExp.Tag='dftExplanation';
    dftExp.Alignment=1;



    dftGroup.Items={dftOption,dftLabel,dftExp};

    dftGroup.Visible=1;
    dftGroup.Enabled=1;
end


function plGroup=l_CreatePortListWidget(this)
    plGroup.Type='panel';
    plGroup.Tag='plGroup';
    plGroup.LayoutGrid=[1,3];
    plGroup.ColStretch=[0,0,1];

    pbPanel=this.PortExtendedTableSource.CreateTableOperationsWidget;
    pbPanel.ColSpan=[1,1];
    ptTable=this.PortExtendedTableSource.CreateTableWidget;
    ptTable.ColSpan=[2,2];
    ptTable.ValueChangedCallback=@l_OnPortTableValueChangeCB;
    ptTable.CurrentItemChangedCallback=@l_OnPortTableFocusChangeCB;
    ptSpacer=l_CreateSpacer([1,1],[3,3]);

    pbPanel.Visible=0;
    plGroup.Items={pbPanel,ptTable,ptSpacer};
end






function l_OnPortTableValueChangeCB(dlg,row,col,value)
    srcObj=dlg.getDialogSource();
    srcObj.PortExtendedTableSource.OnTableValueChangeCB(dlg,row,col,value);
end
function l_OnPortTableFocusChangeCB(dlg,row,col)
    srcObj=dlg.getDialogSource();
    srcObj.PortExtendedTableSource.OnTableFocusChangeCB(dlg,row,col);
end





function widget=l_CreateClockDescriptionWidget(~)
    descrCell={
'Generate simple periodic and step waveforms to drive clocks, resets, or enables to your HDL design:'
'<ul><li> Active Rising Edge Clock: create a periodic signal with 50% duty cycle where the rising edge is offset from when Simulink drives the inputs.'
'<li> Active Falling Edge Clock: create a periodic signal with 50% duty cycle where the falling edge is offset from when Simulink drives the inputs. '
'<li> Step 0 to 1: create a step function that starts by driving a 0 for the specified duration, then transitions to 1.'
'<li> Step 1 to 0: create a step function that starts by driving a 1 for the specified duration, then transitions to 0.</ul>'
'<br>'
'<b>The periods and durations are HDL times</b>.  To relate Simulink times to HDL times, go to the ''Timescales'' tab.'
'<br>'
'You can change the list of clocks and resets by re-running the Cosimulation Wizard.'
    };
    descrStr=sprintf('%s ',descrCell{:});

    widget.Type='text';
    widget.Name=descrStr;
    widget.Tag='clkDescription';
    widget.WordWrap=1;
end

function prtGroup=l_CreateCosimStartTimeWidget(~)
    prtGroup.Type='panel';
    prtGroup.Name='Cosimulation Start Time';
    prtGroup.Tag='prtGroup';
    prtGroup.LayoutGrid=[1,7];
    prtGroup.ColStretch=[0,0,0,0,1,1,1];

    preRunTime.Name=getString(message('HDLLink:CoSimBlockDialog:PreRunTime'));
    preRunTime.Type='edit';
    preRunTime.Tag='PreRunTime';
    preRunTime.ObjectProperty='PreRunTime';
    preRunTime.RowSpan=[1,1];
    preRunTime.ColSpan=[1,3];

    preRunTimeUnit.Name='';
    preRunTimeUnit.Type='combobox';
    preRunTimeUnit.Tag='PreRunTimeUnit';
    preRunTimeUnit.ObjectProperty='PreRunTimeUnit';
    preRunTimeUnit.RowSpan=[1,1];
    preRunTimeUnit.ColSpan=[4,4];

    prtGroup.Items={preRunTime,preRunTimeUnit};
end


function clGroup=l_CreateClockListWidget(this)
    clGroup.Type='panel';
    clGroup.Tag='clGroup';
    clGroup.LayoutGrid=[1,3];
    clGroup.ColStretch=[0,0,1];

    cbPanel=this.ClockResetTableSource.CreateTableOperationsWidget;
    cbPanel.ColSpan=[1,1];
    ctTable=this.ClockResetTableSource.CreateTableWidget;
    ctTable.ColSpan=[2,2];
    ctTable.ValueChangedCallback=@l_OnClockTableValueChangeCB;
    ctTable.CurrentItemChangedCallback=@l_OnClockTableFocusChangeCB;
    ctSpacer=l_CreateSpacer([1,1],[3,3]);

    cbPanel.Visible=0;
    clGroup.Items={cbPanel,ctTable,ctSpacer};
end


function l_OnClockTableValueChangeCB(dlg,row,col,value)
    srcObj=dlg.getDialogSource();
    srcObj.ClockResetTableSource.OnTableValueChangeCB(dlg,row,col,value);
end
function l_OnClockTableFocusChangeCB(dlg,row,col)
    srcObj=dlg.getDialogSource();
    srcObj.ClockResetTableSource.OnTableFocusChangeCB(dlg,row,col);
end





function widget=l_CreateTimescaleDescriptionWidget(~)
    descrCell={
'Relate Simulink sample times to the HDL simulation time by specifying a scale factor.'
'A ''tick'' is the HDL simulator time resolution.  The Simulink sample time multiplied by the '
'scale factor must be a whole number of HDL ticks.<br><br>'
'You can see the relationship between the Simulink times and HDL times of all of'
'the input ports, output ports, clocks, resets, and enables by clicking the '
'button below.  This button will also automatically determine a usable timescale'
'if needed.<br><br>'
    };
    descrStr=sprintf('%s ',descrCell{:});

    widget.Type='text';
    widget.Name=descrStr;
    widget.Tag='timescaleDescription';
    widget.WordWrap=1;
end


function tsGroup=l_CreateTimescaleWidget(this)
    tsGroup.Type='panel';
    tsGroup.Tag='tsGroup';
    tsGroup.LayoutGrid=[3,8];















    autorun.Type='checkbox';
    autorun.Name='Automatically determine timescale at start of simulation';
    autorun.ObjectProperty='RunAutoTimescale';
    autorun.RowSpan=[1,1];
    autorun.ColSpan=[1,6];
    autorun.Tag='Autorun';
    autorun.DialogRefresh=true;
    autorun.Mode=1;



    autotimescale.Type='pushbutton';
    autotimescale.Name='Show Times and Suggest Timescale';
    autotimescale.ObjectMethod='AutotimescaleCb';
    autotimescale.MethodArgs={'%dialog'};
    autotimescale.ArgDataTypes={'handle'};
    autotimescale.RowSpan=[2,2];
    autotimescale.ColSpan=[1,2];
    autotimescale.Tag='Autotimescale';
    autotimescale.Enabled=~this.RunAutoTimescale;

    slText1.Type='text';
    slText1.Name='';
    slText1.Tag='slText1';
    slText1.RowSpan=[2,2];
    slText1.ColSpan=[3,8];
    slText1.Alignment=5;


    slText2.Type='text';
    slText2.Name='1 second in Simulink corresponds to';
    slText2.Tag='slText2';
    slText2.RowSpan=[3,3];
    slText2.ColSpan=[1,2];
    slText2.Alignment=7;
    slText2.Enabled=~this.RunAutoTimescale;

    tscale.Type='edit';
    tscale.Tag='TimingScaleFactor';
    tscale.RowSpan=[3,3];
    tscale.ColSpan=[3,3];
    tscale.ObjectProperty='TimingScaleFactor';
    tscale.Alignment=7;
    tscale.Enabled=~this.RunAutoTimescale;

    hdlUnit.Type='combobox';
    hdlUnit.Tag='TimingMode';
    hdlUnit.RowSpan=[3,3];
    hdlUnit.ColSpan=[4,4];
    hdlUnit.ObjectProperty='TimingMode';
    hdlUnit.Alignment=5;
    hdlUnit.Enabled=~this.RunAutoTimescale;

    hdlText.Type='text';
    hdlText.Name='in the HDL simulator';
    hdlText.Tag='hdlText';
    hdlText.RowSpan=[3,3];
    hdlText.ColSpan=[5,5];
    hdlText.Alignment=5;
    hdlText.Enabled=~this.RunAutoTimescale;







    tsGroup.Items={autorun,slText1,slText2,tscale,hdlUnit,hdlText,autotimescale};
    tsGroup.ColStretch=[0,0,0,0,0,0,0,1];
end

...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...

function widget=l_CreateBlockInfoHeader(~)
    descrCell={
'This block was created by the Cosimulation Wizard for a specifc HDL design.'
    };
    descrStr=sprintf('%s ',descrCell{:});

    widget.Type='text';
    widget.Name=descrStr;
    widget.Tag='blockInfoHeader';
    widget.WordWrap=1;
end
function widget=l_CreateBlockInfoStatic(this)
    ud=this.UserData;
    topinfo=sprintf('%-20s: %s\n',...
    'HDL Simulator','Vivado Simulator',...
    'HDL Design Library','./xsim.dir',...
    'HDL Language',l_langAsString(ud.Language),...
    'HDL Time Precision',l_precAsString(ud.TimePrecision),...
    'HDL Waveform File','hdlverifier_cosim_waves.wdb');
    widget.Type='text';
    widget.Name=topinfo;
    widget.Tag='blockInfoStatic';
    widget.WordWrap=1;
    widget.FontFamily='Courier';
end
function widget=l_CreateBlockInfoHowTo(~)
    descrCell={
'The following information cannot be changed on this block and requires reinvoking the wizard to create a new block:'
'<ul><li> All HDL signal names, directions, types, and dimensions.'
'<li> The list of signals designated as clocks, resets, or unused in the wizard.'
'<li> The HDL time precision.</ul>'
'<br>'
'The following information is changeable on this block:'
'<ul><li> Output signal Simulink sample times, data types, signed-ness, and fraction length.'
'<li> Clock active edges and periods and reset initial values and duration.'
'<li>HDL pre-run time before cosimulation starts.</ul>'
'<br>'
'To change the debug instrumentation of the HDL design DLL, edit the debug option in the ''hdlverifier_gendll.tcl'' script and double click the cyan block that was generated by the wizard.  Note that debug instrumentation will impact performance and could even lead to machine stability issues for very large designs.'
'<ul><li> off  : no debug instrumentation'
'<li> wave : data values for all ports and internal signals will be captured to the waveform db file </ul>'
    };

    descrStr=sprintf('%s ',descrCell{:});

    widget.Type='text';
    widget.Name=descrStr;
    widget.Tag='blockInfoHowTo';
    widget.WordWrap=1;
end




function str=l_langAsString(langAsInt)
    langInt2Str=containers.Map({0,1,2},{'Verilog','VHDL','SystemVerilog'});
    str=langInt2Str(langAsInt);
end
function str=l_precAsString(precAsInt)
    precIntToStr=containers.Map(...
    num2cell(-15:2),...
    {'1 fs','10 fs','100 fs','1 ps','10 ps','100 ps','1 ns','10 ns','100 ns','1 us','10 us','100 us','1 ms','10 ms','100 ms','1 s','10 s','100 s'});
    str=precIntToStr(precAsInt);
end




