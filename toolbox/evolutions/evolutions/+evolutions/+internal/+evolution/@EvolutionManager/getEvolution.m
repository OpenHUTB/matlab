function getEvolution(obj,ei)





    bfisToRemove=evolutions.internal.utils...
    .getBaseToArtifactsKeyValues(obj.WorkingEvolution);
    obj.WorkingEvolution.removeBaseFile(bfisToRemove);



    bfisToAdd=evolutions.internal.utils...
    .getBaseToArtifactsKeyValues(ei);
    obj.WorkingEvolution.addBaseFile(bfisToAdd);

    obj.WorkingEvolution.Description=char.empty;
end


