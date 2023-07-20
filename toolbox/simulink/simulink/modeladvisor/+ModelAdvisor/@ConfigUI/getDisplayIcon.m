function val=getDisplayIcon(this)





    if isempty(this.ParentObj)
        if this.InLibrary
            val='toolbox/simulink/simulink/modeladvisor/resources/check_browser.png';
        else
            val='toolbox/simulink/simulink/modeladvisor/resources/mace.png';
        end
        return
    end

    if strcmp(this.Type,'Procedure')
        val='toolbox/simulink/simulink/modeladvisor/private/icon_procedure.png';
    elseif strcmp(this.Type,'Group')
        if slfeature('MACEConfigurationValidation')
            val=getGroupIcon(this);
            if strcmp(val,'toolbox/simulink/simulink/modeladvisor/resources/folder_failed_16.png')
                this.MACIndex=-3;
            end
        else
            val='toolbox/simulink/simulink/modeladvisor/resources/folder_16.png';
        end
    else
        if slfeature('MACEConfigurationValidation')&&this.MACIndex<0
            val='toolbox/simulink/simulink/modeladvisor/resources/resolveSymbols.svg';
        else
            val='toolbox/simulink/simulink/modeladvisor/private/icon_task.png';
        end
    end
end

function val=getGroupIcon(group)



    if isempty(group.ChildrenObj)
        val='toolbox/simulink/simulink/modeladvisor/private/icon_folder.png';
        return;
    end
    for i=1:length(group.ChildrenObj)

        if group.ChildrenObj{i}.MACIndex<0
            val='toolbox/simulink/simulink/modeladvisor/resources/folder_failed_16.png';
            return;
        elseif group.ChildrenObj{i}.MACIndex>0
            val='toolbox/simulink/simulink/modeladvisor/resources/folder_16.png';
        else
            val=getGroupIcon(group.ChildrenObj{i});
            if strcmp(val,'toolbox/simulink/simulink/modeladvisor/resources/folder_failed_16.png')
                return;
            end
        end
    end
end



