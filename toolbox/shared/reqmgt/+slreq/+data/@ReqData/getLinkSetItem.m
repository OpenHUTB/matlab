

function out=getLinkSetItem(this,linkSet,itemId)






    out=slreq.data.SourceItem.empty();


    if ischar(linkSet)
        modelLinkSet=this.findLinkSet(linkSet);
    else
        modelLinkSet=this.getModelObj(linkSet);
    end

    if~isempty(modelLinkSet)
        items=modelLinkSet.items;


        item=items{itemId};
        if~isempty(item)

            out=this.wrap(item);
        end
    end
end
