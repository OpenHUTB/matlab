function grpCodeGen=createCodeGenBtn(hProxy,groupNameId,tooltipId,type)




    grpCodeGen.Items={};

    if slprivate('createCodeGenBtn_isValid',hProxy)
        codeGenBtn.Name=DAStudio.message('Simulink:dialog:ConfigureText');
        codeGenBtn.Type='pushbutton';
        codeGenBtn.RowSpan=[1,1];
        codeGenBtn.ColSpan=[1,1];
        codeGenBtn.MatlabMethod='slprivate';
        codeGenBtn.MatlabArgs={'switchToCodeMappingView',hProxy,type};
        codeGenBtn.ToolTip=DAStudio.message(tooltipId);
        codeGenBtn.Tag='ConfigureCodeBtn';

        codeGenSpr.Type='panel';
        codeGenSpr.RowSpan=[1,1];

        codeGenSpr.ColSpan=[2,2];
        grpCodeGen.ColSpan=[1,2];

        grpCodeGen.Items={codeGenBtn,codeGenSpr};
        grpCodeGen.LayoutGrid=[2,2];
        grpCodeGen.RowStretch=[0,1];
        grpCodeGen.ColStretch=[0,1];

        grpCodeGen.Name=DAStudio.message(groupNameId);
        grpCodeGen.Type='group';
        grpCodeGen.RowSpan=[2,2];
        grpCodeGen.Tag='GrpCodeGen';
    end
end


