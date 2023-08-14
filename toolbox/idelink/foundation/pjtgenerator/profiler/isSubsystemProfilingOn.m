function ret=isSubsystemProfilingOn(modelName,~)





    modelName=convertStringsToChars(modelName);

    ret=isequal(get_param(modelName,'ProfileGenCode'),'on')...
    &&isequal(get_param(modelName,'profileBy'),'Atomic subsystems');
end