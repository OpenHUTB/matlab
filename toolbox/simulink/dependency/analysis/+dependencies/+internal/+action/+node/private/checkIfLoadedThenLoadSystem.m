function[wasLoaded,handle]=checkIfLoadedThenLoadSystem(fullPath)








    [~,bdName,~]=fileparts(fullPath);
    wasLoaded=bdIsLoaded(bdName);
    handle=load_system(fullPath);
end
