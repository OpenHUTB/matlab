function success=buildFIL(this,dlg)



    filMgr=eda.internal.workflow.LegacyCodeFILManager(this.BuildInfo,dlg);

    if(isempty(this.buildOptions))
        success=filMgr.build('QuestionDialog','on');
    else
        success=filMgr.build(this.buildOptions{:});
    end
