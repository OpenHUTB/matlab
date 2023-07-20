

function ModelVersionRollback(obj)

    targetSimRel=obj.targetVersion.release;
    modelName=obj.modelName;


    modelVersionFormat=Simulink.ModelVersionFormat(modelName);
    modelVersionFormat.rollback(targetSimRel);
    obj.appendRule(sprintf('<ModelVersionFormat:repval "%s">',modelVersionFormat.ModelVersionFormat));



    if obj.targetVersion.isR2020bOrEarlier()
        obj.appendRule('<ModelVersionHistory:remove>');
    end
end


