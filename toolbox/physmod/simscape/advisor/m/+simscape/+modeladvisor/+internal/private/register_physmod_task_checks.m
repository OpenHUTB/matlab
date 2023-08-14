function register_physmod_task_checks(checks)







    messageCatalog='physmod:simscape:advisor:modeladvisor:modeladvisor';
    getMessage=@(id)DAStudio.message([messageCatalog,':',id]);

    mdlAdvisor=ModelAdvisor.Root;

    group=ModelAdvisor.FactoryGroup('Modeling_Physical_Systems');
    group.DisplayName=getMessage('ByTaskDisplayName');
    group.Description=getMessage('ByTaskDescription');

    for i=1:length(checks)
        group.addCheck(checks{i});
    end

    mdlAdvisor.publish(group);
end

