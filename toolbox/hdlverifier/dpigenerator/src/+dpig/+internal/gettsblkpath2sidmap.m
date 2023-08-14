
function tsblkpath2sid=gettsblkpath2sidmap(ModelName,dpig_config)
    if dpig_config.IsTSVerifyPresent


        subsysPath=dpigenerator_getvariable('dpigSubsystemPath');
        subsysName=dpigenerator_getvariable('dpigSubsystemName');
        if(~isempty(subsysPath))
            TopLevelName=Simulink.ID.getModel(subsysPath);
        else
            TopLevelName=Simulink.ID.getModel(subsysName);
        end
        tsblkpath2sid=getSIDOfTSBlocksInModel(ModelName,TopLevelName);
    else
        tsblkpath2sid=containers.Map;
    end
end
