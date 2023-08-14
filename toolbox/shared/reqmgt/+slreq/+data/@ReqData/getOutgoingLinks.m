function links=getOutgoingLinks(this,src)






    links=slreq.data.Link.empty();
    item=[];
    switch class(src)
    case{'slreq.datamodel.LinkableItem','slreq.datamodel.TextRange'}
        item=src;
        linkset=src.artifact;
    case 'slreq.data.Requirement'


        [lFilePath,srcSid]=slreq.internal.LinkUtil.getLinkSetUri(src.getReqSet,src.sid);
        linkset=this.findLinkSet(lFilePath);
        if~isempty(linkset)
            srcStruct.id=srcSid;
            item=this.findLinkableItem(linkset,srcStruct);
        end
    case 'struct'
        linkset=this.findLinkSet(src.artifact);
        if~isempty(linkset)
            item=this.findLinkableItem(linkset,src);
        end
    otherwise
        error('unsupported argument type in a call to ReqData.getOutgoingLinks()');
    end
    if~isempty(item)
        outgoingLinks=item.outgoingLinks.toArray;
        numLinks=numel(outgoingLinks);
        for i=1:numLinks
            links(i)=this.wrap(outgoingLinks(i));
        end
        if~isempty(links)



            this.wrap(linkset);
            this.wrap(item);
        end
    end
end
