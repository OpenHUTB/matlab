function register_simscapefluids_product_tasks(tasks)







    modelAdvisorRoot=ModelAdvisor.Root;



    messageCatalog='physmod:sh:performanceadvisor:performanceadvisor';
    getMessage=@(msgId)DAStudio.message([messageCatalog,':',msgId]);

    MAP=ModelAdvisor.Group('com.mathworks.simscape.performanceadvisor.SimscapeFluidsChecks');
    MAP.DisplayName=getMessage('SimscapeFluidsChecks');
    MAP.Description=getMessage('SimscapeFluidsChecksDesc');
    MAP.LicenseName={'SimHydraulics'};
    MAP.CSHParameters.MapKey='ma.simscape';
    MAP.CSHParameters.TopicID=MAP.ID;
    MAP.Value=true;
    modelAdvisorRoot.register(MAP);



    for i=1:length(tasks)
        modelAdvisorRoot.register(tasks{i});
        MAP.addTask(tasks{i});
    end

end
