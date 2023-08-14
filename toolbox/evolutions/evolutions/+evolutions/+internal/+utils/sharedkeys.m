function keys=sharedkeys(ev1,ev2)





    thisKeyIds=evolutions.internal.utils...
    .getBaseToArtifactsKeyValues(ev1);
    otherKeyIds=evolutions.internal.utils...
    .getBaseToArtifactsKeyValues(ev2);
    keys=intersect(thisKeyIds,otherKeyIds);
end
