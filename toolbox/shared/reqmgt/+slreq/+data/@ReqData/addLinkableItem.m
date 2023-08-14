function item=addLinkableItem(this,mfLinkSet,src)






    if isstruct(src)
        if isfield(src,'parent')

            parentId=src.parent;
            if~isfield(src,'range')
                error('slreq.data.ReqData.addLinkableItem(): items with .parent should provide .range');
            end
            mfTextItem=this.findTextItem(mfLinkSet,parentId);

            if isempty(mfTextItem)
                if isempty(parentId)
                    fullId=mfLinkSet.artifactUri;
                else
                    [~,mdlName]=fileparts(mfLinkSet.artifactUri);
                    fullId=[mdlName,parentId];
                end
                content=rmiml.getText(fullId);
                [~,mfTextItem]=this.addTextItem(mfLinkSet,parentId,content);
            end
            item=this.addRangeItem(mfLinkSet,mfTextItem,src.id,src.range);
        else

            item=slreq.datamodel.LinkableItem(this.model);
            item.id=slreq.data.SourceItem.getLinkableId(src);
            mfLinkSet.items.add(item);
        end
    else
        error('slreq.data.ReqData.addLinkableItem(): unsupported input type "%"',class(src));
    end
end
