function[Tab1]=getTgtDialogSchema(hSrc,schemaName)




    tag='Tag_ConfigSet_Target_';




    TargetSelGroup.Name='Link Automation';
    TargetSelGroup.Type='group';
    TargetSelGroup.LayoutGrid=[2,1];
    TargetSelGroup.RowStretch=[0,1];


    widget.Name='Maximum time allowed to complete IDE operation (s):';
    widget.Type='edit';
    widget.ObjectProperty='ideObjTimeout';
    widget.Tag=[tag,widget.ObjectProperty];
    widget.ObjectMethod='tgtDialogCallback';
    widget.MethodArgs={'%dialog',widget.Tag,''};
    widget.ArgDataTypes={'handle','string','string'};
    widget.RowSpan=[1,1];
    widget.ColSpan=[1,1];
    widget.Alignment=1;
    widget.Mode=1;
    widget.DialogRefresh=1;
    widget.ToolTip='Enter the time in seconds that the code generation build process waits for IDE operations to finish.';
    ideObjTimeout=widget;
    widget=[];

    widget.Name='Export IDE link handle to base workspace';
    widget.Type='checkbox';
    widget.ObjectProperty='exportIDEObj';
    widget.Tag=[tag,widget.ObjectProperty];
    widget.Enabled=getEnabledFlag(hSrc,widget.ObjectProperty);
    widget.ObjectMethod='tgtDialogCallback';
    widget.MethodArgs={'%dialog',widget.Tag,''};
    widget.ArgDataTypes={'handle','string','string'};
    widget.RowSpan=[2,2];
    widget.ColSpan=[1,1];
    widget.Alignment=1;
    widget.Mode=1;
    widget.DialogRefresh=1;
    widget.ToolTip='Place a copy of the IDE link handle into the MATLAB base workspace.';
    exportIDEObj=widget;
    widget=[];

    widget.Name='IDE link handle name:';
    widget.Type='edit';
    widget.ObjectProperty='ideObjName';
    widget.Tag=[tag,widget.ObjectProperty];
    widget.Visible=strcmp(hSrc.exportIDEObj,'on');
    widget.ObjectMethod='tgtDialogCallback';
    widget.MethodArgs={'%dialog',widget.Tag,''};
    widget.ArgDataTypes={'handle','string','string'};
    widget.RowSpan=[3,3];
    widget.ColSpan=[1,1];
    widget.Alignment=1;
    widget.Mode=1;
    widget.DialogRefresh=1;
    widget.ToolTip='Specify the name of the handle to the IDE object.';
    ideObjName=widget;
    widget=[];

    TargetSelGroup.Items={ideObjTimeout,exportIDEObj,ideObjName};




    CodeGenGroup.Name='Code Generation';
    CodeGenGroup.Type='group';
    CodeGenGroup.LayoutGrid=[4,1];
    CodeGenGroup.RowStretch=[0,0,0,1];


    widget.Name='Profile real-time execution';
    widget.Type='checkbox';
    widget.ObjectProperty='ProfileGenCode';
    widget.Mode=1;
    widget.DialogRefresh=1;
    widget.Enabled=getEnabledFlag(hSrc,widget.ObjectProperty);
    widget.Visible=getVisibleFlag(hSrc,widget.ObjectProperty);
    widget.Tag=[tag,widget.ObjectProperty];
    widget.ObjectMethod='tgtDialogCallback';
    widget.MethodArgs={'%dialog',widget.Tag,''};
    widget.ArgDataTypes={'handle','string','string'};
    widget.RowSpan=[1,1];
    widget.ColSpan=[1,1];
    widget.ToolTip='Incorporate profiling instrumentation in the generated code.';
    ProfileGenCode=widget;
    widget=[];


    widget.Name='Profile by:';
    widget.Type='combobox';
    widget.Entries={'Tasks','Atomic subsystems'};
    widget.Values=[0,1];
    widget.ObjectProperty='profileBy';
    widget.Tag=[tag,widget.ObjectProperty];
    widget.Visible=getVisibleFlag(hSrc,widget.ObjectProperty);
    widget.ToolTip='Select profiling by tasks or atomic subsystems.';
    widget.RowSpan=[2,2];
    widget.ColSpan=[1,1];
    widget.Alignment=1;
    widget.Mode=1;
    widget.DialogRefresh=1;
    ProfileBy=widget;
    widget=[];

    widget.Name='Number of profiling samples to collect:';
    widget.Type='edit';
    widget.ObjectProperty='ProfileNumSamples';
    widget.Mode=1;
    widget.DialogRefresh=1;
    widget.Visible=getVisibleFlag(hSrc,widget.ObjectProperty);
    widget.Tag=[tag,widget.ObjectProperty];
    widget.RowSpan=[3,3];
    widget.ColSpan=[1,1];
    widget.Alignment=1;
    widget.ToolTip=['Enter the total number of profiling samples to collect.',sprintf('\n')...
    ,'Once the buffer for profiling data is full, the samples',sprintf('\n')...
    ,'will not be collected anymore.'
    ];
    ProfileNumSamples=widget;
    widget=[];




    widget.Name='Inline run-time library functions';
    widget.Type='checkbox';
    widget.Visible=0;
    widget.ObjectProperty='InlineDSPBlks';
    widget.Mode=1;
    widget.DialogRefresh=1;
    widget.Enabled=getEnabledFlag(hSrc,widget.ObjectProperty);
    widget.Tag=[tag,widget.ObjectProperty];
    widget.RowSpan=[4,4];
    widget.ColSpan=[1,1];
    widget.Alignment=1;
    widget.ToolTip=...
    ['Mark run-time library functions of the Signal Processing Blockset and',sprintf('\n')...
    ,'Video and Image Processing Blockset algorithms with the "inline" keyword.'];
    InlineDSPBlks=widget;
    widget=[];

    CodeGenGroup.Items={ProfileGenCode,ProfileBy,ProfileNumSamples,InlineDSPBlks};


    CodeGenGroup.Visible=getVisibleFlag(hSrc,'group',CodeGenGroup);




    ProjectGroup.Name='Project Options';
    ProjectGroup.Type='group';
    ProjectGroup.LayoutGrid=[5,5];
    ProjectGroup.RowStretch=[0,0,0,0,1];


    widget.Name='Project options:                ';
    widget.Type='combobox';
    widget.Mode=1;
    widget.DialogRefresh=1;
    widget.Entries={'Debug','Release','Custom'};
    widget.Values=[0,1,2];
    widget.ObjectProperty='projectOptions';
    widget.Tag=[tag,widget.ObjectProperty];
    widget.Enabled=getEnabledFlag(hSrc,widget.ObjectProperty);
    widget.ObjectMethod='tgtDialogCallback';
    widget.MethodArgs={'%dialog',widget.Tag,''};
    widget.ArgDataTypes={'handle','string','string'};
    widget.RowSpan=[1,1];
    widget.ColSpan=[1,1];
    widget.Alignment=1;
    widget.ToolTip='Select the project options.';
    projectOptions=widget;
    widget=[];

    widget.Name='Compiler options string:    ';
    widget.Type='edit';
    widget.Mode=1;
    widget.DialogRefresh=1;
    widget.ObjectProperty='compilerOptionsStr';
    widget.Tag=[tag,widget.ObjectProperty];
    widget.ObjectMethod='tgtDialogCallback';
    widget.MethodArgs={'%dialog',widget.Tag,''};
    widget.ArgDataTypes={'handle','string','string'};
    widget.RowSpan=[2,2];
    widget.ColSpan=[1,1];
    widget.ToolTip='Specify the compiler options string.';
    compilerOptionsStr=widget;
    widget=[];

    getCompilerOptions.Name='Get From IDE';
    getCompilerOptions.Type='pushbutton';
    getCompilerOptions.Enabled=1;
    getCompilerOptions.Tag=[tag,'getCompilerOptions'];
    getCompilerOptions.ObjectMethod='tgtDialogCallback';
    getCompilerOptions.MethodArgs={'%dialog',getCompilerOptions.Tag,''};
    getCompilerOptions.ArgDataTypes={'handle','string','string'};
    getCompilerOptions.RowSpan=[2,2];
    getCompilerOptions.ColSpan=[2,2];
    getCompilerOptions.Mode=1;
    getCompilerOptions.DialogRefresh=1;
    getCompilerOptions.ToolTip='Retrieve the compiler options string from the IDE.';

    resetCompilerOptions.Name='Reset';
    resetCompilerOptions.Type='pushbutton';
    resetCompilerOptions.Enabled=~strcmpi(hSrc.projectOptions,'Custom');
    resetCompilerOptions.Tag=[tag,'resetCompilerOptions'];
    resetCompilerOptions.ObjectMethod='tgtDialogCallback';
    resetCompilerOptions.MethodArgs={'%dialog',resetCompilerOptions.Tag,''};
    resetCompilerOptions.ArgDataTypes={'handle','string','string'};
    resetCompilerOptions.RowSpan=[2,2];
    resetCompilerOptions.ColSpan=[3,3];
    resetCompilerOptions.Mode=1;
    resetCompilerOptions.DialogRefresh=1;
    resetCompilerOptions.ToolTip='Reset the compiler options string to its default.';

    widget.Name='Linker options string:        ';
    widget.Type='edit';
    widget.ObjectProperty='linkerOptionsStr';
    widget.Enabled=getEnabledFlag(hSrc,widget.ObjectProperty);
    widget.Visible=getVisibleFlag(hSrc,widget.ObjectProperty);
    widget.RowSpan=[3,3];
    widget.ColSpan=[1,1];
    widget.Mode=1;
    widget.DialogRefresh=1;
    widget.Tag=[tag,widget.ObjectProperty];
    widget.ObjectMethod='tgtDialogCallback';
    widget.MethodArgs={'%dialog',widget.Tag,''};
    widget.ArgDataTypes={'handle','string','string'};
    widget.ToolTip='Specify the linker options string.';
    linkerOptionsStr=widget;
    widget=[];

    getLinkerOptions.Name='Get From IDE';
    getLinkerOptions.Type='pushbutton';
    getLinkerOptions.Enabled=getEnabledFlag(hSrc,'getLinkerOptions');
    getLinkerOptions.Visible=getVisibleFlag(hSrc,'getLinkerOptions');
    getLinkerOptions.Tag=[tag,'getLinkerOptions'];
    getLinkerOptions.ObjectMethod='tgtDialogCallback';
    getLinkerOptions.MethodArgs={'%dialog',getLinkerOptions.Tag,''};
    getLinkerOptions.ArgDataTypes={'handle','string','string'};
    getLinkerOptions.RowSpan=[3,3];
    getLinkerOptions.ColSpan=[2,2];
    getLinkerOptions.Mode=1;
    getLinkerOptions.DialogRefresh=1;
    getLinkerOptions.ToolTip='Retrieve the linker options string from the IDE.';

    resetLinkerOptions.Name='Reset';
    resetLinkerOptions.Type='pushbutton';
    resetLinkerOptions.Enabled=~strcmpi(hSrc.projectOptions,'Custom');
    resetLinkerOptions.Visible=getVisibleFlag(hSrc,'resetLinkerOptions');
    resetLinkerOptions.Tag=[tag,'resetLinkerOptions'];
    resetLinkerOptions.ObjectMethod='tgtDialogCallback';
    resetLinkerOptions.MethodArgs={'%dialog',resetLinkerOptions.Tag,''};
    resetLinkerOptions.ArgDataTypes={'handle','string','string'};
    resetLinkerOptions.RowSpan=[3,3];
    resetLinkerOptions.ColSpan=[3,3];
    resetLinkerOptions.Mode=1;
    resetLinkerOptions.DialogRefresh=1;
    resetLinkerOptions.ToolTip='Reset the linker options string to its default.';

    systemStackSize.Name='System stack size (MAUs):';
    systemStackSize.Type='edit';
    systemStackSize.ObjectProperty='systemStackSize';
    systemStackSize.Enabled=getEnabledFlag(hSrc,systemStackSize.ObjectProperty);
    systemStackSize.Visible=getVisibleFlag(hSrc,systemStackSize.ObjectProperty);
    systemStackSize.RowSpan=[4,4];
    systemStackSize.ColSpan=[1,1];
    systemStackSize.Alignment=1;
    systemStackSize.Mode=1;
    systemStackSize.DialogRefresh=1;
    systemStackSize.Tag=[tag,'systemStackSize'];
    systemStackSize.ToolTip='Enter the size of the system stack in minimum addressable units (MAUs).';

    ProjectGroup.Items={projectOptions,...
    compilerOptionsStr,getCompilerOptions,resetCompilerOptions,...
    linkerOptionsStr,getLinkerOptions,resetLinkerOptions,systemStackSize};





    RuntimeGroup.Name='Runtime Options';
    RuntimeGroup.Type='group';
    RuntimeGroup.LayoutGrid=[4,1];
    RuntimeGroup.RowStretch=[0,0,0,1];


    widget.Name='Build action:         ';
    widget.Type='combobox';
    widget.Entries={'Create_project','Archive_library','Build','Build_and_execute','Create_Processor_In_the_Loop_project'};
    widget.Values=[0,1,2,3,4];
    widget.ObjectProperty='buildAction';
    widget.Tag=[tag,widget.ObjectProperty];
    widget.ObjectMethod='tgtDialogCallback';
    widget.MethodArgs={'%dialog',widget.Tag,''};
    widget.ArgDataTypes={'handle','string','string'};
    widget.Enabled=getEnabledFlag(hSrc,widget.ObjectProperty);
    widget.ToolTip='Select action to be performed after code generation.';
    widget.RowSpan=[1,1];
    widget.ColSpan=[1,1];
    widget.Alignment=1;
    widget.Mode=1;
    widget.DialogRefresh=1;
    buildAction=widget;
    widget=[];

    widget.Name='PIL block action:  ';
    widget.Type='combobox';
    widget.Entries={'Create_PIL_block_build_and_download','Create_PIL_block','None'};
    widget.Values=[2,1,0];
    widget.ObjectProperty='configPILBlockAction';
    widget.Tag=[tag,widget.ObjectProperty];
    widget.Visible=getVisibleFlag(hSrc,widget.ObjectProperty);
    widget.ToolTip='Select action to be performed for PIL block.';
    widget.RowSpan=[2,2];
    widget.ColSpan=[1,1];
    widget.Alignment=1;
    widget.Mode=1;
    widget.DialogRefresh=1;
    configPILblockAction=widget;
    widget=[];

    widget.Name='Interrupt overrun notification method:';
    widget.Type='combobox';
    widget.ObjectProperty='overrunNotificationMethod';
    widget.Entries={'None','Print_message','Call_custom_function'};
    widget.Values=[0,1,2];
    widget.Enabled=getEnabledFlag(hSrc,widget.ObjectProperty);
    widget.Visible=getVisibleFlag(hSrc,widget.ObjectProperty);
    widget.Tag=[tag,widget.ObjectProperty];
    widget.ToolTip='Select notification method in case of an interrupt overrun.';
    widget.RowSpan=[2,2];
    widget.ColSpan=[1,1];
    widget.Alignment=1;
    widget.Mode=1;
    widget.DialogRefresh=1;
    overrunNotificationMethod=widget;
    widget=[];

    widget.Name='Interrupt overrun notification function:';
    widget.Type='edit';
    widget.ObjectProperty='overrunNotificationFcn';
    widget.Enabled=getEnabledFlag(hSrc,widget.ObjectProperty);
    widget.Visible=getVisibleFlag(hSrc,widget.ObjectProperty)&&strcmpi(hSrc.overrunNotificationMethod,'Call_custom_function');
    widget.Tag=[tag,widget.ObjectProperty];
    widget.ObjectMethod='tgtDialogCallback';
    widget.MethodArgs={'%dialog',widget.Tag,''};
    widget.ArgDataTypes={'handle','string','string'};
    widget.ToolTip=['Specify custom notification function to call',sprintf('\n')...
    ,'in case of an interrupt overrun.'];
    widget.RowSpan=[3,3];
    widget.ColSpan=[1,1];
    widget.Alignment=1;
    widget.Mode=1;
    widget.DialogRefresh=1;
    overrunNotificationFcn=widget;
    widget=[];

    widget.Name='Maximum time allowed to build project (s):';
    widget.Type='edit';
    widget.ObjectProperty='ideObjBuildTimeout';
    widget.Tag=[tag,widget.ObjectProperty];
    widget.ObjectMethod='tgtDialogCallback';
    widget.MethodArgs={'%dialog',widget.Tag,''};
    widget.ArgDataTypes={'handle','string','string'};
    getEnabledFlag(hSrc,widget.ObjectProperty);
    widget.Visible=~strcmpi(hSrc.buildAction,'Create_project');
    widget.RowSpan=[4,4];
    widget.ColSpan=[1,1];
    widget.Alignment=1;
    widget.Mode=1;
    widget.DialogRefresh=1;
    widget.ToolTip='Enter the time in seconds that the code generation build process waits for compile and link operations to finish.';
    ideObjBuildTimeout=widget;
    widget=[];

    RuntimeGroup.Items={buildAction,configPILblockAction,overrunNotificationMethod,overrunNotificationFcn,ideObjBuildTimeout};





    DiagnosticGroup.Name='Diagnostic Options';
    DiagnosticGroup.Type='group';
    DiagnosticGroup.LayoutGrid=[2,1];
    DiagnosticGroup.RowStretch=[0,1];

    widget.Name='Source file replacement:';
    widget.Type='combobox';
    widget.Entries={'none','warning','error'};
    widget.Values=[0,1,2];
    widget.ObjectProperty='DiagnosticActions';
    widget.Tag=[tag,widget.ObjectProperty];
    widget.ToolTip='Select the diagnostic action to take when the build process detects problems replacing source code with custom code.';
    widget.RowSpan=[1,2];
    widget.ColSpan=[1,1];
    widget.Alignment=1;
    widget.Mode=1;
    widget.DialogRefresh=1;
    DiagnosticActions=widget;
    widget=[];%#ok<NASGU>

    DiagnosticGroup.Items={DiagnosticActions};





    RuntimeGroup.RowSpan=[1,1];
    ProjectGroup.RowSpan=[2,2];
    CodeGenGroup.RowSpan=[3,3];
    TargetSelGroup.RowSpan=[4,4];
    DiagnosticGroup.RowSpan=[5,5];

    Panel.Name=[hSrc.getIDEName,' Panel'];
    Panel.Type='panel';
    Panel.Tag='Tag_ConfigSet_RTW_Embedded_IDE_Link_CC';
    Panel.Items={RuntimeGroup,ProjectGroup,CodeGenGroup,TargetSelGroup,DiagnosticGroup};
    Panel.LayoutGrid=[6,1];
    Panel.RowStretch=[0,0,0,0,0,1];





    Tab1.Name=hSrc.getIDEName;
    Tab1.Items={Panel};
    Tab1.LayoutGrid=[1,1];

