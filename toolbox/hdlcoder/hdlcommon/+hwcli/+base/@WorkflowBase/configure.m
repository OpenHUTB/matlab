function configure(obj,hDI)





    hDI.setProjectFolder(obj.ProjectFolder);
    hDI.set('Workflow',obj.TargetWorkflow);
    hDI.set('Tool',obj.SynthesisTool);

    if~hDI.hAvailableToolList.isToolVersionSupported(obj.SynthesisTool)
        hDI.setAllowUnsupportedToolVersion(obj.AllowUnsupportedToolVersion);
    end


    if(obj.RunTaskCreateProject)
        hDI.setObjectiveFromObject(obj.Objective);
        hDI.setCustomTclFile(obj.AdditionalProjectCreationTclFiles);
    end

end
