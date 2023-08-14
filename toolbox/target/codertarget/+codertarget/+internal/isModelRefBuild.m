function ret=isModelRefBuild(modelName)





    mdlRefTgtType=get_param(modelName,'ModelReferenceTargetType');
    ret=~strcmp(mdlRefTgtType,'NONE');
end