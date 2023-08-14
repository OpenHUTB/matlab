











function links=inLinks(linkDest)

    links=slreq.Link.empty();

    if isempty(linkDest)
        rmiut.warnNoBacktrace('Slvnv:slreq:InvalidInputArgument');
        return;
    end

    switch class(linkDest)

    case 'struct'

        dataReq=slreq.data.ReqData.getInstance.getRequirementItem(linkDest,false);

    case 'slreq.data.Requirement'

        dataReq=linkDest;

    case{'slreq.Requirement','slreq.Reference'}



        reqSet=linkDest.reqSet;
        dataReqSet=slreq.data.ReqData.getInstance.getReqSet(reqSet.Name);
        sid=num2str(linkDest.SID);
        dataReq=dataReqSet.getRequirementById(sid);

    case 'slreq.Justification'
        rmiut.warnNoBacktrace('Slvnv:slreq:IncomingLinkToJustificationError');
        return;

    otherwise


        srcStruct=slreq.utils.resolveSrc(linkDest);

        dataReq=slreq.data.ReqData.getInstance.getRequirementItem(srcStruct,false);
    end

    if~isempty(dataReq)
        linksData=dataReq.getLinks();
        for i=1:numel(linksData)
            links(end+1)=slreq.utils.dataToApiObject(linksData(i));%#ok<AGROW>
        end
    end

end

