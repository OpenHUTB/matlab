




















function reqs=getReqs(fPath,id,sourceType)



    if strcmp(sourceType,'linktype_rmi_matlab')&&~any(fPath=='.')


        src=slreq.utils.getRmiStruct([fPath,'|',id]);
    else
        src.artifact=fPath;
        src.id=id;
        src.domain=sourceType;
    end
    links=slreq.utils.getLinks(src);
    if isempty(links)
        reqs=[];
    else
        reqs=slreq.utils.linkToStruct(links);
    end
end
