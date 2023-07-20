function defineBlockUpgradeAdvisorTasks()




    checks={...
'mathworks.design.Update'...
    ,'mathworks.design.UpdateRequireCompile'...
    ,'mathworks.design.CaseSensitiveBlockDiagramNames'...
    };

    modelAdvisor=ModelAdvisor.Root;
    upgradeAdvisor=UpgradeAdvisor;

    for n=1:length(checks)
        task=ModelAdvisor.Task([checks{n},'.task']);
        task.setCheck(checks{n});

        modelAdvisor.register(task);
        upgradeAdvisor.addTask(task);
    end

end

