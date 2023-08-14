
function[addonStruct]=createDialogForRoot(this)

    row=0;

    row=row+1;
    Line0.Name=DAStudio.message('Simulink:tools:MARootMsg0');
    Line0.Type='text';
    Line0.Tag='text_line0';
    Line0.WordWrap=true;
    Line0.RowSpan=[row,row];
    Line0.ColSpan=[1,10];
    Line0.Bold=true;
    Line0.FontPointSize=13;

    row=row+1;
    InstructionGroup.Type='group';
    InstructionGroup.Name=DAStudio.message('ModelAdvisor:engine:Tips');
    InstructionGroup.RowSpan=[row,row];
    InstructionGroup.ColSpan=[1,10];
    curRow=0;
    InstructionGroup.Items={};

    curRow=curRow+1;
    emptymsg4.Name='     ';
    emptymsg4.Type='text';
    emptymsg4.Tag='text_emptymsg4';
    emptymsg4.WordWrap=true;
    emptymsg4.RowSpan=[row,row];
    emptymsg4.ColSpan=[1,10];
    InstructionGroup.Items{end+1}=emptymsg4;

    curRow=curRow+1;
    Line2.Name=DAStudio.message('Simulink:tools:MARootNodeMsgLine2');
    Line2.Type='text';
    Line2.Tag='text_line2';
    Line2.WordWrap=true;
    Line2.RowSpan=[curRow,curRow];
    Line2.ColSpan=[1,10];
    InstructionGroup.Items{end+1}=Line2;

    curRow=curRow+1;
    Line3.Name=DAStudio.message('Simulink:tools:MARootNodeMsgLine3');
    Line3.Type='text';
    Line3.Tag='text_line3';
    Line3.WordWrap=true;
    Line3.RowSpan=[curRow,curRow];
    Line3.ColSpan=[1,10];
    InstructionGroup.Items{end+1}=Line3;

    curRow=curRow+1;
    Line5.Name=DAStudio.message('Simulink:tools:MARootNodeMsgLine6');
    Line5.Type='text';
    Line5.Tag='text_line5';
    Line5.WordWrap=true;
    Line5.RowSpan=[curRow,curRow];
    Line5.ColSpan=[1,10];
    InstructionGroup.Items{end+1}=Line5;

    curRow=curRow+1;
    Line6.Name=DAStudio.message('Simulink:tools:MARootNodeMsgLine5');
    Line6.Type='text';
    Line6.Tag='text_line6';
    Line6.WordWrap=true;
    Line6.RowSpan=[curRow,curRow];
    Line6.ColSpan=[1,10];
    InstructionGroup.Items{end+1}=Line6;

    curRow=curRow+1;
    Line7.Name=DAStudio.message('ModelAdvisor:engine:RootNodeMsgLine7');
    Line7.Type='text';
    Line7.Tag='text_line7';
    Line7.WordWrap=true;
    Line7.RowSpan=[curRow,curRow];
    Line7.ColSpan=[1,10];
    InstructionGroup.Items{end+1}=Line7;

    curRow=curRow+1;
    Line8.Name=DAStudio.message('ModelAdvisor:engine:RootNodeMsgLine8');
    Line8.Type='text';
    Line8.Tag='text_line8';
    Line8.WordWrap=true;
    Line8.RowSpan=[curRow,curRow];
    Line8.ColSpan=[1,10];
    InstructionGroup.Items{end+1}=Line8;

    curRow=curRow+1;
    emptymsg3.Name='     ';
    emptymsg3.Type='text';
    emptymsg3.Tag='text_emptymsg3';
    emptymsg3.WordWrap=true;
    emptymsg3.RowSpan=[row,row];
    emptymsg3.ColSpan=[1,10];
    InstructionGroup.Items{end+1}=emptymsg3;

    InstructionGroup.LayoutGrid=[curRow,10];
    InstructionGroup.RowStretch=[zeros(1,curRow-1),1];


    row=row+1;
    emptymsg6.Name='     ';
    emptymsg6.Type='text';
    emptymsg6.Tag='text_emptymsg6';
    emptymsg6.WordWrap=true;
    emptymsg6.RowSpan=[row,row];
    emptymsg6.ColSpan=[1,10];

    row=row+1;
    LegendGroup.Type='group';
    LegendGroup.Name=DAStudio.message('Simulink:tools:MALegend');
    LegendGroup.RowSpan=[row,row];
    LegendGroup.ColSpan=[1,10];
    curRow=1;

    curRow=curRow+1;
    SelectedCheck.Name=DAStudio.message('Simulink:tools:MANotRunMsg');
    SelectedCheck.Type='text';
    SelectedCheck.Tag='text_SelectedCheck';
    SelectedCheck.WordWrap=true;
    SelectedCheck.RowSpan=[curRow,curRow];
    SelectedCheck.ColSpan=[2,2];
    LegendGroup.Items={SelectedCheck};
    selectedIcon.Type='image';
    selectedIcon.Tag='image_selectedIcon';
    selectedIcon.RowSpan=[curRow,curRow];
    selectedIcon.ColSpan=[1,1];
    imagepath=fullfile(matlabroot,'toolbox/simulink/simulink/modeladvisor/private/');
    selectedIcon.FilePath=fullfile(imagepath,'icon_task.png');
    LegendGroup.Items{end+1}=selectedIcon;

    curRow=curRow+1;
    PassedCheck.Name=DAStudio.message('Simulink:tools:MAPassedMsg');
    PassedCheck.Type='text';
    PassedCheck.Tag='text_PassedCheck';
    PassedCheck.WordWrap=true;
    PassedCheck.RowSpan=[curRow,curRow];
    PassedCheck.ColSpan=[2,2];
    LegendGroup.Items{end+1}=PassedCheck;
    passedIcon.Type='image';
    passedIcon.Tag='image_passedIcon';
    passedIcon.RowSpan=[curRow,curRow];
    passedIcon.ColSpan=[1,1];
    passedIcon.FilePath=fullfile(imagepath,'task_passed.png');
    LegendGroup.Items{end+1}=passedIcon;

    curRow=curRow+1;
    FailedCheck.Name=DAStudio.message('Simulink:tools:MAFailedMsg');
    FailedCheck.Type='text';
    FailedCheck.Tag='text_FailedCheck';
    FailedCheck.WordWrap=true;
    FailedCheck.RowSpan=[curRow,curRow];
    FailedCheck.ColSpan=[2,2];
    LegendGroup.Items{end+1}=FailedCheck;
    failedIcon.Type='image';
    failedIcon.Tag='image_failedIcon';
    failedIcon.RowSpan=[curRow,curRow];
    failedIcon.ColSpan=[1,1];
    failedIcon.FilePath=fullfile(imagepath,'task_failed.png');
    LegendGroup.Items{end+1}=failedIcon;

    curRow=curRow+1;
    WarnCheck.Name=DAStudio.message('Simulink:tools:MAWarning');
    WarnCheck.Type='text';
    WarnCheck.Tag='text_WarnCheck';
    WarnCheck.WordWrap=true;
    WarnCheck.RowSpan=[curRow,curRow];
    WarnCheck.ColSpan=[2,2];
    LegendGroup.Items{end+1}=WarnCheck;
    WarnIcon.Type='image';
    WarnIcon.Tag='image_WarnIcon';
    WarnIcon.RowSpan=[curRow,curRow];
    WarnIcon.ColSpan=[1,1];
    WarnIcon.FilePath=fullfile(imagepath,'task_warning.png');
    LegendGroup.Items{end+1}=WarnIcon;

    if~this.MAObj.IsLibrary||modeladvisorprivate('modeladvisorutil2','FeatureControl','ForceRunOnLibrary')
        curRow=curRow+1;
        CompileCheck.Name=DAStudio.message('Simulink:tools:MARequiresCompileShort');
        CompileCheck.Type='text';
        CompileCheck.Tag='text_CompileCheck';
        CompileCheck.WordWrap=true;
        CompileCheck.RowSpan=[curRow,curRow];
        CompileCheck.ColSpan=[2,2];
        LegendGroup.Items{end+1}=CompileCheck;
        CompileFlag.Name=[' ',DAStudio.message('Simulink:tools:PrefixForCompileCheck'),' '];
        CompileFlag.Bold=1;
        CompileFlag.Type='text';
        CompileFlag.WordWrap=true;
        CompileFlag.RowSpan=[curRow,curRow];
        CompileFlag.ColSpan=[1,1];
        LegendGroup.Items{end+1}=CompileFlag;

        curRow=curRow+1;
        CompileCheck.Name=DAStudio.message('ModelAdvisor:engine:MAExtensiveAnalysisShort');
        CompileCheck.Type='text';
        CompileCheck.Tag='text_IntensiveCheck';
        CompileCheck.WordWrap=true;
        CompileCheck.RowSpan=[curRow,curRow];
        CompileCheck.ColSpan=[2,2];
        LegendGroup.Items{end+1}=CompileCheck;
        CompileFlag.Name=[' ',DAStudio.message('ModelAdvisor:engine:PrefixForExtensiveCheck'),' '];
        CompileFlag.Bold=1;
        CompileFlag.Type='text';
        CompileFlag.WordWrap=true;
        CompileFlag.RowSpan=[curRow,curRow];
        CompileFlag.ColSpan=[1,1];
        LegendGroup.Items{end+1}=CompileFlag;
    else
        curRow=curRow+1;
        NLibSupportCheck.Name=DAStudio.message('ModelAdvisor:engine:CheckNotSupportLibrary');
        NLibSupportCheck.Type='text';
        NLibSupportCheck.Tag='text_NLibSupportCheck';
        NLibSupportCheck.WordWrap=true;
        NLibSupportCheck.RowSpan=[curRow,curRow];
        NLibSupportCheck.ColSpan=[2,2];
        LegendGroup.Items{end+1}=NLibSupportCheck;
        CompileFlag.Name=[' ',DAStudio.message('ModelAdvisor:engine:PrefixForNSupportLibCheck'),' '];
        CompileFlag.Bold=1;
        CompileFlag.Type='text';
        CompileFlag.WordWrap=true;
        CompileFlag.RowSpan=[curRow,curRow];
        CompileFlag.ColSpan=[1,1];
        LegendGroup.Items{end+1}=CompileFlag;
    end
    LegendGroup.LayoutGrid=[curRow,2];

    row=row+1;
    emptymsg7.Name='     ';
    emptymsg7.Type='text';
    emptymsg7.Tag='text_emptymsg7';
    emptymsg7.WordWrap=true;
    emptymsg7.RowSpan=[row,row];
    emptymsg7.ColSpan=[1,10];

    addonStruct.Items={Line0,InstructionGroup,emptymsg6,LegendGroup,emptymsg7};
    addonStruct.LayoutGrid=[row,10];
    addonStruct.RowStretch=[zeros(1,row-1),1];
    addonStruct.ColStretch=[0,0,0,0,0,0,0,0,0,0];
    addonStruct.IsScrollable=false;