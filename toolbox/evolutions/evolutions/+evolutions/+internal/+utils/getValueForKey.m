function[isKey,val]=getValueForKey(evolution,bfiKey)




    [keys,vals]=evolutions.internal.utils...
    .getBaseToArtifactsKeyValues(evolution);

    val=string.empty;
    isKey=false;
    if~isempty(bfiKey)&&ismember(bfiKey,keys)
        idx=keys==bfiKey;
        if~isempty(vals)
            val=vals{idx};
        end
        isKey=true;
    end
end
