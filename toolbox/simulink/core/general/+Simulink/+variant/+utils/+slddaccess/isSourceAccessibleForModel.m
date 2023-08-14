function isSame=isSourceAccessibleForModel(modelName,modelSource,controlVarSource,referencedDDsOfModel)









    isSame=strcmp(modelSource,controlVarSource);
    if isSame

        return;
    end



    isBWSControlVarSource=strcmp(controlVarSource,slvariants.internal.config.utils.getGlobalWorkspaceName(''));
    if isBWSControlVarSource


        isSame=strcmp(get_param(modelName,'HasAccessToBaseWorkspace'),'on');
    else

        isSame=any(strcmp(referencedDDsOfModel,controlVarSource));
    end
end
