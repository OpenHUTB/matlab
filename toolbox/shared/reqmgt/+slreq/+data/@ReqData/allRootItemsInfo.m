function[sourceGroups,destinationGroups]=allRootItemsInfo(this)






    sourceGroups=cell(0,2);
    linkSets=this.repository.linkSets.toArray();
    for i=1:numel(linkSets)
        sourceGroups(end+1,:)={linkSets(i).artifactUri,linkSets(i).domain};%#ok<AGROW>
    end
    if nargout>1
        destinationGroups=cell(0,2);
        reqSets=this.repository.requirementSets.toArray();
        for i=1:numel(reqSets)
            groups=reqSets(i).groups.toArray();
            for j=1:numel(groups)
                destinationGroups(end+1,:)={groups(j).artifactUri,groups(j).domain};%#ok<AGROW>
            end
        end
    end
end
