function releaseReferences(obj)






    entryInfos=obj.Infos;


    for infoIdx=1:numel(entryInfos)
        curEi=entryInfos(infoIdx);
        curEi.releaseReferences;
    end

    obj.RootEvolution=evolutions.model.EvolutionInfo.empty(0,1);

end
