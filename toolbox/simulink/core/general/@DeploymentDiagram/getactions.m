function actions=getactions(h)





    actions={};
    if numel(h)>1
        h=h(1);
    end

    if isa(h,"DAStudio.DAObjectProxy")
        h=h.getMCOSObjectReference();
    end

    switch(class(h))

    case{'Simulink.DistributedTarget.SoftwareNode',...
        'Simulink.SoftwareTarget.TaskConfiguration'}
        actions{end+1}='ADD_MAPPED_TASK';
        actions{end+1}='EDIT_DELETE';

    case 'Simulink.DistributedTarget.Mapping'
        actions{end+1}='ADD_MAPPED_TASK';
        actions{end+1}='EDIT_DELETE';

    case{'Simulink.SoftwareTarget.AutogenTask',...
        'Simulink.SoftwareTarget.AutogenTrigger'}
        actions{end+1}='ADD_MAPPED_TASK';
        actions{end+1}='EDIT_DELETE';

    case{'Simulink.SoftwareTarget.AutogenInfo',...
        'Simulink.SoftwareTarget.ProfileReport'}
        actions{end+1}='ADD_MAPPED_TASK';
        actions{end+1}='EDIT_DELETE';

    case{'Simulink.SoftwareTarget.PeriodicTrigger'}
        actions{end+1}='ADD_MAPPED_TASK';
        if~DeploymentDiagram.canDeletePeriodicTrigger(h)
            actions{end+1}='EDIT_DELETE';
        end

    case{'Simulink.SoftwareTarget.AperiodicTrigger',...
        'Simulink.SoftwareTarget.Task'}
        actions{end+1}='ADD_MAPPED_TASK';
        if~canAddAperiodicTask(h)
            actions{end+1}='ADD_TASK';
        end

    case 'Simulink.SoftwareTarget.BlockToTaskMapping_Explorer'



        if DeploymentDiagram.isBlockAsyncMappable(h.Block)
            actions{end+1}='ADD_MAPPED_TASK';
        end
        if~h.canThisMapBeDeleted
            actions{end+1}='EDIT_DELETE';
        end

    case{'Simulink.MappingManager',...
        'Simulink.GlobalDataTransfer'}
        actions{end+1}='ADD_MAPPED_TASK';
        actions{end+1}='EDIT_DELETE';

    case{'Simulink.DistributedTarget.Architecture',...
        'Simulink.DistributedTarget.HardwareNode'}
        actions{end+1}='ADD_MAPPED_TASK';
        actions{end+1}='EDIT_DELETE';
        actions{end+1}='ADD_TASK';
        actions{end+1}='ADD_APERIODIC_TASKG';
        actions{end+1}='ADD_PERIODIC_TRIGGER';

    end

    function canAdd=canAddAperiodicTask(obj)




        canAdd=true;
        if isa(obj,'Simulink.SoftwareTarget.AperiodicTrigger')
            aeh=obj;
        elseif isa(obj,'Simulink.SoftwareTarget.Task')
            aeh=obj.ParentTaskGroup;
            if~isa(aeh,'Simulink.SoftwareTarget.AperiodicTrigger')
                return;
            end
        else
            return;
        end
        canAdd=isempty(aeh.Tasks);




