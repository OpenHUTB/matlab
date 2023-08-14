function defineFileIntegrityTask




    task=Simulink.MdlAdvisorTask;
    task.TitleID='File Integrity';
    task.Title=DAStudio.message('Simulink:tools:ModelAdvisorFileIntegrityTaskTitle');
    task.TitleTips=DAStudio.message('Simulink:tools:ModelAdvisorFileIntegrityTaskTitleTips');
    task.CheckTitleIDs={'mathworks.design.SLXModelProperties'};


    modelAdvisor=ModelAdvisor.Root;
    modelAdvisor.register(task);
end




