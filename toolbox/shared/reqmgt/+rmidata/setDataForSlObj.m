function setDataForSlObj(objH,reqs,grps)





    if~isempty(grps)

        grpNum=unique(grps);
        for i=1:length(grpNum)
            grp=grpNum(i);
            subReqs=reqs(grps==grp);
            slreqInternalSetReqs(objH,subReqs,grp)
        end
    else
        slreqInternalSetReqs(objH,reqs);
    end

end

function slreqInternalSetReqs(objH,reqs,grp)

    src=slreq.utils.getRmiStruct(objH);
    if nargin==3

        src.id=sprintf('%s.%d',src.id,grp);
    end





    reqs=slreq.uri.correctDestinationUriAndId(reqs);

    slreqInternalSetLinks(src,reqs);
end

function slreqInternalSetLinks(src,linkInfo)
    r=slreq.data.ReqData.getInstance;
    linkSet=r.getLinkSet(src.artifact);

    if isempty(linkSet)
        if isempty(linkInfo)

            return;
        else
            linkSet=r.createLinkSet(src.artifact,src.domain);
        end
    else


        oldLinks=linkSet.getLinks(src);
        for i=1:length(oldLinks)
            linkSet.removeLink(oldLinks(i));
        end
    end


    if~isempty(linkInfo)
        for i=1:length(linkInfo)
            linkSet.addLink(src,linkInfo(i));
        end
    end

end

