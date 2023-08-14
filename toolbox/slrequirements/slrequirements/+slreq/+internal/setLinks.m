function oldReqs=setLinks(varargin)




    src=varargin{1};
    if~isstruct(src)
        error('slreq.internal.setLinks() expects source info structure as the first argument');
    end
    linkInfo=varargin{2};

    if builtin('_license_checkout','Simulink_Requirements','quiet')


        if strcmp(src.domain,'linktype_rmi_simulink')
            [~,mdlName]=fileparts(src.artifact);
            if rmisl.modelHasEmbeddedReqInfo(mdlName)

            else
                error(message('Slvnv:reqmgt:setReqs:NoLicense'));
            end
        else
            error(message('Slvnv:reqmgt:setReqs:NoLicense'));
        end
    end

    oldReqs=[];

    linkSet=slreq.utils.getLinkSet(src.artifact,src.domain,~isempty(linkInfo));
    if isempty(linkSet)
        if isempty(linkInfo)
            return;
        else
            error('Failed to get existing or new LinkSet for %s',src.artifact);
        end
    end




















    oldLinks=linkSet.getLinks(src);
    if nargout>0

        oldReqs=slreq.utils.linkToStruct(oldLinks);
    end


    for i=1:length(linkInfo)
        if strcmp(linkInfo(i).reqsys,'other')||strcmp(linkInfo(i).doc,'UNSPECIFIED_ARTIFACT.txt')

            continue;
        elseif slreq.utils.isLocalFile(linkInfo(i))
            resolved=slreq.uri.getPreferredPath(linkInfo(i).doc,src.artifact);
            if~isempty(resolved)
                linkInfo(i).doc=resolved;
            end
        end
    end






    if nargin==4
        if varargin{3}<0

        elseif varargin{3}==1&&varargin{4}==numel(oldLinks)

        elseif varargin{4}==1&&length(linkInfo)==1

            updateLink(oldLinks(varargin{3}),linkInfo);
            return;
        elseif isempty(linkInfo)&&varargin{3}>0&&varargin{4}>0

            offset=varargin{3};
            count=varargin{4};
            if offset+count-1>numel(oldLinks)
                error(message('Slvnv:rmi:deleteReqsPrim:BadIndices'));
            else
                doDelete=false(1,numel(oldLinks));
                doDelete(offset:offset+count-1)=true;
                removeLinks(linkSet,oldLinks(doDelete));
                return;
            end
        else
            error('invalid 4-argument call of slreq.internal.setLinks();');
        end
    end



    if isempty(oldLinks)

        for i=1:length(linkInfo)
            linkSet.addLink(src,linkInfo(i));
        end

    elseif isempty(linkInfo)

        removeLinks(linkSet,oldLinks);

    else

        matchedIdx=matchLinks(oldLinks,linkInfo);

        linksToRemove=oldLinks(matchedIdx==0);
        if~isempty(linksToRemove)
            removeLinks(linkSet,linksToRemove);
        end

        for i=1:length(linkInfo)
            oldIdx=find(matchedIdx==i);
            if isempty(oldIdx)


                newLink=linkSet.addLink(src,linkInfo(i));
                slreq.data.ReqData.getInstance.moveLink(newLink,i);
            else

                newLink=updateLink(oldLinks(oldIdx),linkInfo(i));
                if oldIdx~=i
                    slreq.data.ReqData.getInstance.moveLink(newLink,i);
                end
            end
        end
    end

end

function idx=matchLinks(oldLinks,linkInfo)




    idx=zeros(1,numel(oldLinks));

    for i=1:numel(oldLinks)
        if~isempty(oldLinks(i).description)
            matchIdx=find(strcmp({linkInfo.description},oldLinks(i).description));
            if length(matchIdx)==1

                if isDomainTypeMatched(linkInfo(matchIdx),oldLinks(i).destDomain)
                    if~any(idx==matchIdx)
                        idx(i)=matchIdx;
                    end
                end
            end
        end
    end

    if all(idx>0)
        return;
    elseif sum(idx>0)==length(linkInfo)
        return;
    else
        for i=find(idx==0)


            if strcmp(oldLinks(i).destId,'UNSPECIFIED_ARTIFACT.txt')
                continue;
            end
            isMatchId=strcmp({linkInfo.id},oldLinks(i).destId);
            if any(isMatchId)
                isMatchDest=strcmp({linkInfo.doc},oldLinks(i).destUri);
                matchIdx=find(isMatchDest&isMatchId);
                if length(matchIdx)==1&&~any(idx==matchIdx)
                    if isDomainTypeMatched(linkInfo(matchIdx),oldLinks(i).destDomain)
                        idx(i)=matchIdx;
                    end
                end
            end
        end
    end

    function tf=isDomainTypeMatched(oneLinkInfo,existingLinkDestDomain)
        if strcmp(oneLinkInfo.reqsys,existingLinkDestDomain)
            tf=true;
        elseif strcmp(oneLinkInfo.reqsys,'other')
            legacyOtherTypes={'linktype_rmi_word','linktype_rmi_excel',...
            'linktype_rmi_text','linktype_rmi_pdf','linktype_rmi_html'};
            tf=any(strcmp(existingLinkDestDomain,legacyOtherTypes));
        else
            tf=false;
        end
    end
end

function removeLinks(linkSet,oldLinks)
    for i=1:numel(oldLinks)
        linkSet.removeLink(oldLinks(i));
    end
end

function link=updateLink(link,linkInfo)




    docMatched=strcmp(linkInfo.doc,link.destUri);
    idMatched=any(strcmp(linkInfo.id,{link.destId,link.dest.id}));



    if~docMatched||~idMatched

        destStruct=slreq.utils.getRmiStruct(linkInfo);
        slreq.data.ReqData.getInstance.updateLinkDestination(link,destStruct);
    end
    if~strcmp(link.description,linkInfo.description)
        link.description=linkInfo.description;
    end
    if~strcmp(slreq.utils.getKeywords(link),linkInfo.keywords)
        link.keywords=linkInfo.keywords;
    end

    if isfield(linkInfo,'linked')
        if~linkInfo.linked
            link.setProperty('isSurrogateLink','1');
        elseif link.getProperty('isSurrogateLink')
            link.setProperty('isSurrogateLink','0');
        end
    end
end















