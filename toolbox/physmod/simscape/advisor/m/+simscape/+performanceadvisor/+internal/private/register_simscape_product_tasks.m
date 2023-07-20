function register_simscape_product_tasks(tasks)







    modelAdvisorRoot=ModelAdvisor.Root;



    messageCatalog='physmod:simscape:advisor:performanceadvisor:performanceadvisor';
    getMessage=@(msgId)DAStudio.message([messageCatalog,':',msgId]);

    MAP=ModelAdvisor.Group('com.mathworks.Simulink.AdvisorRealTime.SimscapeChecks');
    MAP.DisplayName=getMessage('SimscapeChecks');
    MAP.Description=getMessage('SimscapeChecksDesc');
    MAP.LicenseName={'Simscape'};
    MAP.CSHParameters.MapKey='ma.simscape';
    MAP.CSHParameters.TopicID='com.mathworks.simscape.performanceadvisor.SimscapeChecks';
    MAP.Value=true;
    modelAdvisorRoot.register(MAP);



    for i=1:length(tasks)
        modelAdvisorRoot.register(tasks{i});
        MAP.addTask(tasks{i});
    end


    MAP.Children{end+1}='com.mathworks.simscape.performanceadvisor.SimscapeDrivelineChecks';
    MAP.Children{end+1}='com.mathworks.simscape.performanceadvisor.SimscapeElectricalChecks';
    MAP.Children{end+1}='com.mathworks.simscape.performanceadvisor.SimscapeFluidsChecks';

end
