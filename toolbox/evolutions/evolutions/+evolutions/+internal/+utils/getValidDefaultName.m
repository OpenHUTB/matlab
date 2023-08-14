function defaultName=getValidDefaultName(info)






    if isa(info,'evolutions.model.ProjectInfo')
        infos=info.EvolutionTreeManager.Infos;
    else
        assert(isa(info,'evolutions.model.EvolutionTreeInfo'));
        infos=info.EvolutionManager.Infos;
    end

    names=getExistingNames(infos);

    defaultName=generateDefaultName(names);

end


function names=getExistingNames(infos)

    names=containers.Map;

    for infoIdx=1:numel(infos)
        names(infos(infoIdx).getName)=true;
    end

end


function defaultName=generateDefaultName(names)
    defaultName=getString(message('evolutions:ui:DefaultName'));
    tempDefaultName=defaultName;
    suffix=1;
    while names.isKey(tempDefaultName)
        tempDefaultName=sprintf('%s%i',defaultName,suffix);
        suffix=suffix+1;
    end
    defaultName=tempDefaultName;
end
