function ranges=getLinkedRanges(src,id)




    ranges=[];
    if rmisl.isSidString(src)
        [mdl,sid]=strtok(src,':');
        srcName=get_param(mdl,'FileName');
    elseif any(src=='.')
        srcName=src;
        sid='';
    else
        srcName=which(src);
        sid='';
    end
    if isempty(srcName)

        return;
    end

    if slreq.data.ReqData.exists()
        linkSet=slreq.data.ReqData.getInstance.getLinkSet(srcName);
    else
        linkSet=[];
    end

    if isempty(linkSet)
        if nargin<2&&exist(srcName,'file')==2


            if slreq.utils.loadLinkSet(srcName)
                linkSet=slreq.data.ReqData.getInstance.getLinkSet(srcName);
            end
        end
    end

    if~isempty(linkSet)
        textItem=linkSet.getTextItem(sid);
        if~isempty(textItem)
            if nargin<2
                ranges=textItem.getRanges;
            else
                ranges=textItem.getRange(id);
            end
        end
    end
end
