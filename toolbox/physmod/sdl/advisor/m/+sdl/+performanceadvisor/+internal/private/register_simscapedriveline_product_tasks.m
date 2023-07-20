function register_simscapedriveline_product_tasks(tasks)








    modelAdvisorRoot=ModelAdvisor.Root;



    messageCatalog='physmod:sdl:performanceadvisor:performanceadvisor';
    getMessage=@(msgId)DAStudio.message([messageCatalog,':',msgId]);

    MAP=ModelAdvisor.Group('com.mathworks.simscape.performanceadvisor.SimscapeDrivelineChecks');
    MAP.DisplayName=getMessage('SimscapeDrivelineChecks');
    MAP.Description=getMessage('SimscapeDrivelineChecksDesc');
    MAP.LicenseName={'SimDriveline'};
    MAP.CSHParameters.MapKey='ma.simscape';
    MAP.CSHParameters.TopicID=MAP.ID;
    MAP.Value=true;
    modelAdvisorRoot.register(MAP);



    for i=1:length(tasks)
        modelAdvisorRoot.register(tasks{i});
        MAP.addTask(tasks{i});
    end

end
