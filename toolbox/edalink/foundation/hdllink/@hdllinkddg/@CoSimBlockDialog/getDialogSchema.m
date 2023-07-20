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


    clocksTab.Name='Clocks';
    clocksTabItemsC.Type='panel';
    clocksTabItemsC.Tag='ClocksPanel';
    clocksTabItemsC.LayoutGrid=[2,1];
    clocksTabItemsC.RowStretch=[0,1];
    clocksTabItemsC.Items={l_CreateClockDescriptionWidget(this)};
    clocksTabItemsC.Items(2)={l_CreateClockListWidget(this)};
    clocksTabItemsC.Items{1}.RowSpan=[1,1];
    clocksTabItemsC.Items{2}.RowSpan=[2,2];
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


    connTab.Name='Connection';
    connTabItemsC.Type='panel';
    connTabItemsC.Tag='ConnectionPanel';
    connTabItemsC.LayoutGrid=[3,1];
    connTabItemsC.RowStretch=[0,1];
    connTabItemsC.Items={l_CreateConnectionDescription(this)};
    connTabItemsC.Items(2)={l_CreateConnectionWidget(this)};
    connTabItemsC.Items(3)={l_CreateSpacer([3,3],[1,1]);};
    connTabItemsC.Items{1}.RowSpan=[1,1];
    connTabItemsC.Items{2}.RowSpan=[2,2];
    connTab.Items={connTabItemsC};



    tclTab.Name=getString(message('HDLLink:CoSimBlockDialog:Simulation'));
    tclTabItemsC.Type='panel';
    tclTabItemsC.Tag='TclPanel';

    preRuntTme.Name=getString(message('HDLLink:CoSimBlockDialog:PreRunTime'));
    preRuntTme.Type='edit';
    preRuntTme.Tag='PreRunTime';
    preRuntTme.ObjectProperty='PreRunTime';

    preRuntTmeUnit.Name='';
    preRuntTmeUnit.Type='combobox';
    preRuntTmeUnit.Tag='PreRunTimeUnit';
    preRuntTmeUnit.ObjectProperty='PreRunTimeUnit';

    tclTabItemsC.LayoutGrid=[9,7];
    tclTabItemsC.Items={preRuntTme};
    tclTabItemsC.Items{end}.RowSpan=[1,1];
    tclTabItemsC.Items{end}.ColSpan=[1,3];

    tclTabItemsC.Items{end+1}=preRuntTmeUnit;
    tclTabItemsC.Items{end}.RowSpan=[1,1];
    tclTabItemsC.Items{end}.ColSpan=[4,4];

    tclTabItemsC.Items{end+1}=...
    l_CreateTclWidget('Pre-simulation Tcl commands:','TclPreSimCommand');
    tclTabItemsC.Items{end}.RowSpan=[2,5];
    tclTabItemsC.Items{end}.ColSpan=[1,7];

    tclTabItemsC.Items{end+1}=...
    l_CreateTclWidget('Post-simulation Tcl commands:','TclPostSimCommand');
    tclTabItemsC.Items{end}.RowSpan=[6,9];
    tclTabItemsC.Items{end}.ColSpan=[1,7];

    if(strcmpi(this.ProductName,'EDA Simulator Link DS'))
        tclTab.Visible=0;
    else
        tclTab.Visible=1;
    end
    tclTab.Items={tclTabItemsC};

    tabC.Tabs={portsTab,clocksTab,tscaleTab,connTab,tclTab};
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

    pbPanel=this.PortTableSource.CreateTableOperationsWidget;
    pbPanel.ColSpan=[1,1];
    ptTable=this.PortTableSource.CreateTableWidget;
    ptTable.ColSpan=[2,2];
    ptTable.ValueChangedCallback=@l_OnPortTableValueChangeCB;
    ptTable.CurrentItemChangedCallback=@l_OnPortTableFocusChangeCB;
    ptSpacer=l_CreateSpacer([1,1],[3,3]);

    plGroup.Items={pbPanel,ptTable,ptSpacer};
end






function l_OnPortTableValueChangeCB(dlg,row,col,value)
    srcObj=dlg.getDialogSource();
    srcObj.PortTableSource.OnTableValueChangeCB(dlg,row,col,value);
end
function l_OnPortTableFocusChangeCB(dlg,row,col)
    srcObj=dlg.getDialogSource();
    srcObj.PortTableSource.OnTableFocusChangeCB(dlg,row,col);
end





function widget=l_CreateClockDescriptionWidget(~)
    widget.Type='text';
    widget.Name=[...
    'You can generate your HDL clocks in this tab. The edge specifies the active ',...
    'edge in your HDL design. In order to avoid race conditions between ',...
    'the generated clock and the input and output signals, the first active ',...
    'edge will be placed at time Period/2. ',...
    'Other options to generate clocks, resets, and enables include:',...
    '<ul><li>Use Simulink blocks and add the signals to the Ports tab.',...
    '<li> Create waveforms using HDL simulator Tcl commands in the Simulation tab.',...
    '<li> Code them in HDL.',...
    '</ul>'];
    widget.Tag='clkDescription';
    widget.WordWrap=1;
end


function clGroup=l_CreateClockListWidget(this)
    clGroup.Type='panel';
    clGroup.Tag='clGroup';
    clGroup.LayoutGrid=[1,3];
    clGroup.ColStretch=[0,0,1];

    cbPanel=this.ClockTableSource.CreateTableOperationsWidget;
    cbPanel.ColSpan=[1,1];
    ctTable=this.ClockTableSource.CreateTableWidget;
    ctTable.ColSpan=[2,2];
    ctTable.ValueChangedCallback=@l_OnClockTableValueChangeCB;
    ctTable.CurrentItemChangedCallback=@l_OnClockTableFocusChangeCB;
    ctSpacer=l_CreateSpacer([1,1],[3,3]);

    clGroup.Items={cbPanel,ctTable,ctSpacer};
end


function l_OnClockTableValueChangeCB(dlg,row,col,value)
    srcObj=dlg.getDialogSource();
    srcObj.ClockTableSource.OnTableValueChangeCB(dlg,row,col,value);
end
function l_OnClockTableFocusChangeCB(dlg,row,col)
    srcObj=dlg.getDialogSource();
    srcObj.ClockTableSource.OnTableFocusChangeCB(dlg,row,col);
end





function widget=l_CreateTimescaleDescriptionWidget(~)
    widget.Type='text';
    widget.Name=[...
    'Relate Simulink sample times to the HDL simulation time by ',...
    'specifying a scalefactor.  A ''tick'' is the HDL simulator ',...
    'time resolution.  The Simulink sample time multiplied by the ',...
'scale factor must be a whole number of HDL ticks.<br><br>'...
    ];
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
    autotimescale.Name='Determine Timescale Now';
    autotimescale.ObjectMethod='AutotimescaleCb';
    autotimescale.MethodArgs={'%dialog'};
    autotimescale.ArgDataTypes={'handle'};
    autotimescale.RowSpan=[2,2];
    autotimescale.ColSpan=[1,2];
    autotimescale.Tag='Autotimescale';
    autotimescale.Enabled=~this.RunAutoTimescale;

    slText1.Type='text';
    slText1.Name='Automatically calculates a timescale. Click on the help button for more information.';
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




function widget=l_CreateConnectionDescription(~)
    widget.Visible=0;
    widget.Type='text';







    widget.Tag='connDescription';
    widget.WordWrap=1;
end

function connGroup=l_CreateConnectionWidget(this)
    connGroup.Type='panel';
    connGroup.Tag='connGroup';
    connGroup.LayoutGrid=[1,2];
    connGroup.ColStretch=[0,1];

    cgPanel=this.CommSource.CreateCommWidget;
    cgPanel.RowSpan=[1,1];
    cgPanel.ColSpan=[1,1];
    cgColSpacer=l_CreateSpacer([1,1],[2,2]);

    connGroup.Items={cgPanel,cgColSpacer};

end




function widget=l_CreateTclWidget(nameText,objProp)
    widget.Type='editarea';
    widget.Name=nameText;
    widget.Tag=objProp;
    widget.ObjectProperty=objProp;
end




