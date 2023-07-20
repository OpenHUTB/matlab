function updateDeps=CodeCoverageConfigCallback(cs,msg)



    updateDeps=false;
    hDlg=msg.dialog;

    [toolNames,toolClasses,toolCompanies]=coder.coverage.CodeCoverageHelper.getTools(true);
    toolName=cs.getProp('CodeCoverageSettings').CoverageTool;
    toolNum=find(strcmp(toolNames,toolName));

    if strcmp(toolName,'None')
        configset.showParameterGroup(cs.getConfigSet,{DAStudio.message('RTW:configSet:configSetSlCov')});
    else
        toolClass=toolClasses{toolNum};
        toolCompany=toolCompanies{toolNum};
        model=cs.getModel;
        assert(~isempty(model),'Widget must be disabled if standalone config set');
        hCodeCoverage=get_param(model,'RTWCodeCoverage');
        if~isa(hCodeCoverage,'coder_coverage_ui.CodeCovDlg')
            hCodeCoverage=coder_coverage_ui.CodeCovDlg(...
            toolName,...
            toolClass,...
            toolCompany,...
            cs);
        end
        browserDlg=get(hCodeCoverage,'ViewWidget');
        if isempty(browserDlg)||~isa(browserDlg,'DAStudio.Dialog')
            browserDlg=DAStudio.Dialog(hCodeCoverage);
            set(hCodeCoverage,'ViewWidget',browserDlg);
        end
        browserDlg.show;



        hDlg.getDialogSource.enableApplyButton(true);
    end




