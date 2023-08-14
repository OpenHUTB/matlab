function ret=isLibCodeGeneration(modelName)




    modelName=convertStringsToChars(modelName);


    buildaction=get_param(modelName,'buildAction');
    ret=isequal(buildaction,'Archive_library');
