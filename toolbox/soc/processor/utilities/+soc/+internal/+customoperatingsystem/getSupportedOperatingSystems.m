function[validOS,validOSSWInfo]=getSupportedOperatingSystems()



    validOS={};
    validOSSWInfo={};
    factoryOS=embedded.OperatingSystem.LISTOFFACTORYOS;
    for i=1:numel(factoryOS)
        thisOS=factoryOS{i};

        swRegistryFile=[lower(thisOS),'softwareregistry.json'];
        if isequal(exist(swRegistryFile,'file'),2)
            validOS{end+1}=thisOS;
            validOSSWInfo{end+1}=jsondecode(fileread(swRegistryFile));
        end
    end
