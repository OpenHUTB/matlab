function cm=getContextMenu(h)



    cm='';
    if~isprop(h,'ParentDiagram')
        return;
    end
    assert(~isempty(h.ParentDiagram));
    modelName=h.ParentDiagram;
    me=DeploymentDiagram.getexplorer('name',modelName);
    actions={};
    switch(class(h))
    case 'Simulink.SoftwareTarget.TaskConfiguration'
        actions{end+1}='ADD_PERIODIC_TRIGGER';
        actions{end+1}='ADD_APERIODIC_TASKG';
        actions{end+1}='ADD_TASK';

    case 'Simulink.DistributedTarget.SoftwareNode'
        actions{end+1}='ADD_PERIODIC_TRIGGER';
        actions{end+1}='ADD_APERIODIC_TASKG';
        actions{end+1}='ADD_TASK';
        [hasMultipleNodes,~]=...
        Simulink.DistributedTarget.DistributedTargetUtils.hasMultipleSoftwareNodes(modelName);
        if hasMultipleNodes
            actions{end+1}='BUILD';
        end


    case 'Simulink.SoftwareTarget.PeriodicTrigger'
        actions{end+1}='ADD_TASK';
        if DeploymentDiagram.canDeletePeriodicTrigger(h)
            actions{end+1}='EDIT_DELETE';
        end

    case 'Simulink.SoftwareTarget.AperiodicTrigger'
        actions{end+1}='ADD_TASK';
        actions{end+1}='EDIT_DELETE';

    case 'Simulink.SoftwareTarget.Task'
        actions{end+1}='EDIT_DELETE';

    case 'Simulink.SoftwareTarget.BlockToTaskMapping_Explorer'
        actions{end+1}='ADD_MAPPED_TASK';
        actions{end+1}='EDIT_DELETE';
        if isa(h.Task,'Simulink.SoftwareTarget.AutogenTask')
            actions{end+1}='CREATE_TASK_FROM_AUTO';
        elseif isa(h.Task,'Simulink.SoftwareTarget.AutogenTrigger')
            actions{end+1}='CREATE_TRIGGER_FROM_AUTO';
        end

    case 'Simulink.DistributedTarget.Mapping'
        if~h.Active
            actions{end+1}='CONTEXT_ACTIVATE';
        end

    case 'Simulink.SoftwareTarget.AutogenTask'
        actions{end+1}='CONVERT_AUTO_TASK';

    case 'Simulink.SoftwareTarget.AutogenTrigger'
        actions{end+1}='CONVERT_AUTO_TRIGGER';

    otherwise


    end

    if~isempty(me)&&~isempty(actions)
        am=DAStudio.ActionManager;
        cm=am.createPopupMenu(me);
        for i=1:length(actions)
            cm.addMenuItem(me.getaction(actions{i}));
        end
    end


