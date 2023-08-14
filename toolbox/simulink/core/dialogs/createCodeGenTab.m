function tabCodeGen=createCodeGenTab(grpCodeGen)
    tabCodeGen.Name=DAStudio.message('Simulink:dialog:DataCodeGenOptionsPrompt');
    tabCodeGen.LayoutGrid=[1,2];
    tabCodeGen.ColStretch=[0,1];
    tabCodeGen.Tag='TabCodeGen';
    grpCodeGen.Type='panel';
    tabCodeGen.Items={grpCodeGen};
end