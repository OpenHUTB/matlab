function initializeAndStart(this)






    modelHandle=this.ModelHandle;
    modelName=get_param(modelHandle,'Name');


    import coder.internal.CoderDataStaticAPI.*;


    isMigrated=migratedToCoderDictionary(modelHandle);

    if~isMigrated
        Simulink.CodeMapping.doMigrationFromGUI(modelName,true);
    end
    simulinkcoder.internal.app.entryPoint(modelHandle);


end

