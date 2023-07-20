function linkedItems=getLinkedItems(artifact)



    if rmisl.isSidString(artifact)


        linkedItems=slreq.utils.getLinkedRanges(artifact);

    else
        linkSet=slreq.data.ReqData.getInstance.getLinkSet(artifact);
        if isempty(linkSet)
            linkedItems=[];
        else
            linkedItems=linkSet.getLinkedItems();
        end
    end

end


