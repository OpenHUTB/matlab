function[scalingTags,scalingTagTypes]=getScalingTagAndTypes(scalingMaxTag,scalingValueTags,scalingMinTag)











    scalingMinTagType=0;
    scalingMaxTagType=1;
    scalingValueTagType=2;

    scalingTags={scalingMaxTag{:},scalingValueTags{:},scalingMinTag{:}};
    numScalingTags=length(scalingTags);


    scalingTagTypes=scalingValueTagType*ones(1,numScalingTags);


    if~isempty(scalingMaxTag)
        scalingTagTypes(1)=scalingMaxTagType;
    end


    if~isempty(scalingMinTag)
        scalingTagTypes(end)=scalingMinTagType;
    end


