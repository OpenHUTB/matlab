function sourceItems=getLinkedItems(this,linkSet,filter)






    if nargin<3
        filter={};
    end
    sourceItems=[];

    if ischar(linkSet)
        modelLinkSet=this.findLinkSet(linkSet);
    else
        modelLinkSet=this.getModelObj(linkSet);
    end

    if~isempty(modelLinkSet)
        items=modelLinkSet.items.toArray;
        sourceItems=slreq.data.SourceItem.empty();
        for i=1:numel(items)
            if items(i).outgoingLinks.Size==0





                continue;
            end
            if~isempty(filter)&&~slreq.data.ReqData.isMatch(items(i),filter)
                continue;
            end







            sourceItems(end+1)=slreq.data.SourceItem(items(i));%#ok<AGROW>



        end
    end
end
