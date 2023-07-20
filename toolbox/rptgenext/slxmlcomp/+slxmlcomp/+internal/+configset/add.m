function newConfigSetName=add(sourceModelName,targetModelName,configSetName)



    configSet=getConfigSet(sourceModelName,configSetName);
    newConfigSet=attachConfigSetCopy(targetModelName,configSet,true);
    newConfigSetName=newConfigSet.Name;
end

