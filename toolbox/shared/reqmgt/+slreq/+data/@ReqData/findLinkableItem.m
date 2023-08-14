function item=findLinkableItem(this,linkset,src)






    if isstruct(src)

        if isfield(src,'parent')

            textItem=this.findTextItem(linkset,src.parent);
            if~isempty(textItem)

                srcId=slreq.utils.getLongIdFromShortId(textItem.id,src.id);
            else

                srcId=src.id;
            end
        else
            srcId=slreq.data.SourceItem.getLinkableId(src);
        end


        item=linkset.items{srcId};
    else
        error('slreq.data.ReqData:findLinkableItem(): wrong argument type "%s"',class(src));
    end
end
