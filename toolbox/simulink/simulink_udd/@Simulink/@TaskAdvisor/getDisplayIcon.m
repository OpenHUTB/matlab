function val=getDisplayIcon(this)



    switch this.Type
    case 'Container'




        switch this.State
        case 'None'
            val='toolbox/simulink/simulink/modeladvisor/private/icon_folder.png';
        case{'WaivedPass','Pass'}
            val='toolbox/simulink/simulink/modeladvisor/private/folder_pass.png';
        case 'Fail'
            ch=this.getChildren;
            active_children=find(ch,'-depth',0,'Selected',true);
            if~isempty(find(active_children,'-depth',0,'State','Fail','Severity','Required'))
                val='toolbox/simulink/simulink/modeladvisor/private/folder_failed.png';
            else
                val='toolbox/simulink/simulink/modeladvisor/private/folder_warning.png';
            end
        otherwise
            val='toolbox/simulink/simulink/modeladvisor/private/icon_folder.png';
        end
    case 'Task'




        switch this.State
        case 'None'
            if~this.Enable
                val='toolbox/simulink/simulink/modeladvisor/private/icon_task_pselected.png';
                return
            end
            if strcmp(this.Severity,'Advisory')
                val='toolbox/simulink/simulink/modeladvisor/private/icon_task.png';
            else
                val='toolbox/simulink/simulink/modeladvisor/private/icon_task_required.png';
            end
        case 'WaivedPass'
            if strcmp(this.Severity,'Advisory')
                val='toolbox/simulink/simulink/modeladvisor/private/task_forcepass.png';
            else
                val='toolbox/simulink/simulink/modeladvisor/private/task_req_forcepassed.png';
            end
        case 'Pass'
            if strcmp(this.Severity,'Advisory')
                val='toolbox/simulink/simulink/modeladvisor/private/task_passed.png';
            else
                val='toolbox/simulink/simulink/modeladvisor/private/task_req_passed.png';
            end
        case 'Fail'
            if this.MAObj.CheckCellArray{this.MACIndex}.ErrorSeverity==0
                val='toolbox/simulink/simulink/modeladvisor/private/task_warning.png';
            else
                val='toolbox/simulink/simulink/modeladvisor/private/task_failed.png';
            end
        otherwise
            val='toolbox/simulink/simulink/modeladvisor/private/icon_task.png';
        end
    end




