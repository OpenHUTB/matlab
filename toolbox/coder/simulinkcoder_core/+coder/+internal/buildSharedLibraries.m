function buildSharedLibs=buildSharedLibraries(targetType,topOfBuildModel,...
    model,xilTopModel)






    isTopModelInBuild=strcmp(topOfBuildModel,model);


    isNoneTarget=strcmp(targetType,'NONE');


    isTopOfModelBlockBuild=strcmp(model,xilTopModel);


    buildSharedLibs=isTopModelInBuild||isTopOfModelBlockBuild||isNoneTarget;
