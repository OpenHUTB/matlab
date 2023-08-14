function updateCurrentEvolution(obj,bfiToAfi)





    workingEvolution=obj.WorkingEvolution;
    currentEvolution=obj.CurrentEvolution;


    deletedBfis=evolutions.internal.utils.keydiff(currentEvolution,workingEvolution);
    currentEvolution.removeBaseFile(deletedBfis);


    addedBfis=evolutions.internal.utils.keydiff(workingEvolution,currentEvolution);
    currentEvolution.addBaseFile(addedBfis);


    addBaseFilesToEvolution(currentEvolution,bfiToAfi);
end

function addBaseFilesToEvolution(evolution,bfiToAfi)


    ids=bfiToAfi.keys;
    for idx=1:numel(ids)
        val=bfiToAfi(ids{idx});
        evolution.BaseIdtoArtifactId.remove(ids{idx});
        evolution.BaseIdtoArtifactId.add(ids{idx},val);
    end

end

