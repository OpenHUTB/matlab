function newEvolution=promoteWorkingEvolution(obj,evolutionName,bfiToAfi)








    obj.WorkingEvolution.setName(evolutionName);

    newEvolution=obj.WorkingEvolution;

    newEvolution.setName(evolutionName);
    newEvolution.IsWorking=false;

    ids=bfiToAfi.keys;
    for idx=1:numel(ids)
        val=bfiToAfi(ids{idx});
        newEvolution.BaseIdtoArtifactId.remove(ids{idx});
        newEvolution.BaseIdtoArtifactId.add(ids{idx},val);
    end

end
