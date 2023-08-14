function openAndHiliteSystem(sysName)
    splitStrs=strsplit(sysName,'/');
    modelName=splitStrs{1};
    if~bdIsLoaded(modelName)
        load_system(modelName);
    end
    hilite_system(sysName);
end