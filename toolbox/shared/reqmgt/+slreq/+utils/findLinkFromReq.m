function link=findLinkFromReq(reqObj,src)



    link=slreq.data.Link.empty();

    srcInfo=slreq.utils.getRmiStruct(src);

    if~isempty(reqObj)&&isa(reqObj,'slreq.das.Requirement')
        exlinks=reqObj.getLinks;
        for n=1:length(exlinks)
            exlink=exlinks(n);
            srcItem=exlink.source;
            if strcmp(srcItem.artifactUri,srcInfo.artifact)...
                &&strcmp(srcItem.id,srcInfo.id)...
                &&strcmp(srcItem.domain,srcInfo.domain)...
                &&~srcItem.isTextRange
                link=exlink;
                break;
            end
        end
    end
end