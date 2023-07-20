function ret=removeSubsystemPartitionFixit(block)
















    handle=get_param(block,'handle');
    model=bdroot(block);
    editor=sltp.GraphEditor(model);
    node=sltp.mm.modelHierarchy.SubsystemNode.empty;


    if editor.hasOpened
        root=editor.getModelHierarchyRoot;
        node=root.nodes.getByKey(handle);
    end

    if~isempty(node)&&node.StaticMetaClass==...
        sltp.mm.modelHierarchy.SubsystemNode.StaticMetaClass&&...
        ~isempty(node.originalParams)

        cmdData=editor.createCommand(sltp.mm.command.UpdateSubsystemBlock.StaticMetaClass);
        cmdData.node=node.UUID;
        cmdData.params=node.originalParams;
        editor.processCommand(cmdData);
        ret='';
    else

        ret=set_param_action(block,'ScheduleAs','Sample time','SystemSampleTime','-1');
    end

end
