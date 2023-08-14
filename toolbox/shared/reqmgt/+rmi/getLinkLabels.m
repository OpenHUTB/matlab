function[result,flags]=getLinkLabels(obj,index,count)


















    if nargin==2
        linkInfo=rmi.getReqs(obj,index);
    else
        linkInfo=rmi.getReqs(obj);
        if~isempty(linkInfo)&&nargin>2
            linkInfo=rmi.filterReqs(linkInfo,index,count);
        end
    end

    if isempty(linkInfo)
        result={};
        flags=[];
        return;
    else


        result=cell(1,numel(linkInfo));
        for i=1:numel(linkInfo)
            oneLinkInfo=linkInfo(i);
            if strcmp(oneLinkInfo.reqsys,'linktype_rmi_slreq')
                result{i}=slreq.internal.getReqItemSummary(oneLinkInfo);
            else
                result{i}=oneLinkInfo.description;
            end
            if isempty(result{i})
                result{i}=getString(message('Slvnv:reqmgt:NoDescriptionEntered'));
            end
        end
    end


    filters=rmi.settings_mgr('get','filterSettings');
    if filters.enabled&&filters.filterMenus
        [~,flags]=rmi.filterTags(linkInfo,filters.tagsRequire,filters.tagsExclude);
    else
        flags=true(length(linkInfo),1);
    end
    if filters.filterSurrogateLinks
        surr_links=([linkInfo.linked]==false);
        flags=flags&~surr_links';
    end




    docs={linkInfo.doc};
    isMacro=strcmp(docs,'$ModelName$');
    flags=flags&~isMacro';
end


