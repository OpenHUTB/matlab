function val=getDisplayIcon(this)




    if isa(this,'ModelAdvisor.Procedure')
        val=ModelAdvisor.CheckStatusUtil.getIcon(this.State,'procedure');

    elseif isa(this,'ModelAdvisor.Group')
        if strcmp(this.ID,'SysRoot')

            val=' ';
        else
            val=ModelAdvisor.CheckStatusUtil.getIcon(this.State,'group');
        end

    elseif isa(this,'ModelAdvisor.Task')
        val=ModelAdvisor.CheckStatusUtil.getIcon(this.State,'task');
        switch this.State
        case ModelAdvisor.CheckStatus.NotRun
            if~strcmp(this.Severity,'Optional')
                val='toolbox/simulink/simulink/modeladvisor/private/icon_task_required.png';
                return;
            end



            if modeladvisorprivate('modeladvisorutil2','NeedGrayoutEffect',this)
                val='toolbox/simulink/simulink/modeladvisor/private/task_disabled.png';
                return;
            end
            if isa(this.Check,'ModelAdvisor.Check')
                if any(strcmp(this.Check.CallbackContext,{'SLDV','CGIR'}))
                    val='toolbox/simulink/simulink/modeladvisor/private/larger_compile_16.png';
                elseif(~isempty(strfind(this.Check.CallbackContext,'Compile'))||strcmpi(this.Check.CallbackContext,'DIY'))
                    val='toolbox/simulink/simulink/modeladvisor/private/compile_16.png';
                end
            end
        case ModelAdvisor.CheckStatus.Passed
            if~strcmp(this.Severity,'Optional')
                val='toolbox/simulink/simulink/modeladvisor/private/task_req_passed.png';
            end
        case ModelAdvisor.CheckStatus.Failed
            if isa(this.MAObj.ResultGUI,'DAStudio.Informer')&&isa(this.Check,'ModelAdvisor.Check')&&~isempty(this.Check.ProjectResultData)
                val='toolbox/simulink/simulink/modeladvisor/private/task_failed_h.png';
            end
        case ModelAdvisor.CheckStatus.Warning
            if isa(this.MAObj.ResultGUI,'DAStudio.Informer')&&isa(this.Check,'ModelAdvisor.Check')&&~isempty(this.Check.ProjectResultData)
                val='toolbox/simulink/simulink/modeladvisor/private/task_warning_h.png';
            end
        end
    end


