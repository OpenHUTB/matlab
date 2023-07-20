function[out,linkTypeObj]=getLinkTypeStr(linkType,linkPropagation)
    linkTypeObj='';
    out='';

    allLinkTypes=slreq.utils.getAllLinkTypes;
    for index=1:length(allLinkTypes)
        cLinkType=allLinkTypes(index);
        if strcmpi(cLinkType.typeName,linkType)
            if strcmp(linkPropagation,'incoming')
                out=slreq.app.LinkTypeManager.getBackwardName(cLinkType.typeName);
            elseif strcmp(linkPropagation,'outgoing')
                out=slreq.app.LinkTypeManager.getForwardName(cLinkType.typeName);
            end
            linkTypeObj=cLinkType;
            return;
        end
    end

end

