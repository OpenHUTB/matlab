function out=constructTargetRelationshipName(rootName,target)






    if~isempty(target)
        out=[rootName,'_',target];
    else
        out=rootName;
    end
end
