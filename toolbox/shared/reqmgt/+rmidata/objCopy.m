function hasReqs=objCopy(objH,reqs,modelH,isSf,optArg)

    tempSidPrefix='';
    grps=[];
    if nargin==5
        if isSf
            tempSidPrefix=optArg;
        elseif~isempty(optArg)
            grps=optArg;
            if~isempty(reqs)
                grps=grps([reqs.linked]);
            end
        end
    end
    if~isempty(reqs)
        reqs=reqs([reqs.linked]);
    end
    hasReqs=~isempty(reqs);
    if~hasReqs&&isempty(rmidata.getReqs(objH))
        return;
    end

    if~isSf
        try
            copiedFromSid=get_param(objH,'BlockCopiedFrom');
            if~isempty(copiedFromSid)
                [~,backedBySid]=slreq.utils.slGetSource(false,objH);
                if~isempty(backedBySid)&&strcmp(backedBySid,copiedFromSid)
                    return;
                end
            end
        catch
        end
    end
    reqsCopied=setReqsInternalAPI(objH,reqs,grps,tempSidPrefix);
    if~isempty(modelH)&&strcmp(get_param(modelH,'ReqHilite'),'on')
        if isSf
            if sf('get',objH,'.isa')~=1
                if isempty(reqs)||~reqsCopied

                    sf_update_style(objH,'off');
                else
                    style=sf_style('req');
                    sf_set_style(objH,style);
                end
            end
        else
            if isempty(reqs)||~reqsCopied
                set_param(objH,'HiliteAncestors','off');
            else
                set_param(objH,'HiliteAncestors','reqHere');
            end
        end
    end
end


function success=setReqsInternalAPI(objH,reqs,grps,tempSidPrefix)

    if~isempty(grps)

        grpNum=unique(grps);
        for i=1:length(grpNum)
            grp=grpNum(i);
            subReqs=reqs(grps==grp);
            localSetReqs(objH,subReqs,grp,'');
        end
    else
        localSetReqs(objH,reqs,[],tempSidPrefix);
    end
    success=~isempty(reqs);

end





function localSetReqs(srcH,destInfo,grpIdx,tempSidPrefix)

    src=slreq.utils.getRmiStruct(srcH);
    if~isempty(grpIdx)

        src.id=sprintf('%s.%d',src.id,grpIdx);
    end
    if~isempty(tempSidPrefix)


        if startsWith(src.id,tempSidPrefix)
            prefixLength=length(tempSidPrefix);
            src.id(1:prefixLength-1)=[];
        end


    end


    rdata=slreq.data.ReqData.getInstance();
    linkSet=rdata.getLinkSet(src.artifact);
    if isempty(linkSet)
        linkSet=rdata.createLinkSet(src.artifact,src.domain);
    else

        linkedItem=linkSet.getLinkedItem(src.id);
        if~isempty(linkedItem)
            oldLinks=linkedItem.getLinks();
            for j=1:numel(oldLinks)
                linkSet.removeLink(oldLinks(j));
            end
        end
    end




    destInfo=slreq.uri.correctDestinationUriAndId(destInfo);


    for i=1:length(destInfo)
        linkSet.addLink(src,destInfo(i));
    end
end


