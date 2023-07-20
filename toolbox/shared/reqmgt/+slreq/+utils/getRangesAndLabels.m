function data=getRangesAndLabels(varargin)




    linkedRanges=slreq.utils.getLinkedRanges(varargin{:});
    if isempty(linkedRanges)
        data=cell(0,5);
        return;
    else
        data=cell(numel(linkedRanges),5);
        isStale=false(numel(linkedRanges),1);
        filters=rmi.settings_mgr('get','filterSettings');
        for i=1:numel(linkedRanges)
            oneRange=linkedRanges(i);
            range=oneRange.getRange();
            if isempty(range)||range(2)==0

                isStale(i)=true;
            else
                data{i,1}=oneRange.id;
                data{i,2}=range(1);
                data{i,3}=range(2);
                links=oneRange.getLinks();
                if isempty(links)
                    data{i,4}=slreq.mleditor.ReqPluginHelper.NO_LINKS_TAG;
                    data{i,5}=[];
                else
                    [data{i,4},data{i,5}]=getLabelsAndFlags(links,filters);
                end
            end
        end
        data(isStale,:)=[];
    end

end

function[labels,flags]=getLabelsAndFlags(links,filters)
    labels='';
    flags=true(1,numel(links));
    for j=1:numel(links)
        link=links(j);
        description=link.getLinkLabel();
        if isempty(description)
            description=getString(message('Slvnv:reqmgt:NoDescriptionEntered'));
        else



            description(description==9)=' ';
            description(description==10)=' ';
        end
        description=strtrim(description);
        if filters.enabled&&~userTagMatch(link,filters.tagsRequire,filters.tagsExclude)
            flags(j)=false;

            description=[' ',description];%#ok<AGROW>
        end
        labels=sprintf('%s\n%s',labels,description);
    end
    if~isempty(labels)
        labels(1)=[];
    end
end

function result=userTagMatch(link,filter_in,filter_out)
    [~,keywords]=slreq.utils.getKeywords(link);
    if isempty(keywords)
        result=isempty(filter_in);
    else
        i=1;
        while i<=length(filter_out)
            if any(strcmp(keywords,filter_out{i}))
                result=false;
                return;
            else
                i=i+1;
            end
        end
        i=1;
        while i<=length(filter_in)
            if any(strcmp(keywords,filter_in{i}))
                i=i+1;
            else
                result=false;
                return;
            end
        end

        result=true;
    end
end

