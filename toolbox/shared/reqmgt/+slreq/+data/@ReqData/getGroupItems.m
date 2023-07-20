function[grpItems,reqSetName]=getGroupItems(this,grpName)






    grpItems=slreq.data.Requirement.empty;
    reqSets=this.repository.requirementSets.toArray();
    group=[];
    for i=1:numel(reqSets)
        groups=reqSets(i).groups.toArray();
        for j=1:numel(groups)
            if strcmp(groups(j).artifactUri,grpName)
                group=groups(j);
                break;
            end
        end
        if~isempty(group)
            break;
        end
    end
    if isempty(group)
        reqSetName='';
    else
        reqSetName=group.requirementSet.name;
        items=group.items.toArray();
        for i=1:numel(items)
            grpItems(i)=this.wrap(items(i));
        end
    end
end
