function req=searchRequirementByCustomId(this,reqSet,customId)









    req=slreq.datamodel.RequirementItem.empty();

    items=reqSet.items.toArray;



    for i=1:length(items)
        item=items(i);
        if strcmp(item.customId,customId)
            req=item;
            break;
        end
    end

    if isempty(req)&&startsWith(customId,'#')

        req=this.findRequirement(reqSet,customId);
    end




end

