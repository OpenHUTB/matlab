function loadModel(obj)

    fileToLoad=obj.ModelFile;
    if obj.IsTestHarness


        fileToLoad=obj.OwnerFileName;
    end
    if exist(fileToLoad,'file')

        load_system(fileToLoad);
    else


        load_system(obj.getActiveModelName);
    end
    if obj.IsTestHarness

        Simulink.harness.load(obj.HarnessOwner,obj.ModelName);
    end
end
