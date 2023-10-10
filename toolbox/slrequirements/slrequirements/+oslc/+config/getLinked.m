function result=getLinked(srcInfo)
    streams=containers.Map('KeyType','char','ValueType','double');
    changesets=containers.Map('KeyType','char','ValueType','double');
    baselines=containers.Map('KeyType','char','ValueType','double');
    urls=containers.Map('KeyType','char','ValueType','char');

    if nargin>0


        linkSet=slreq.internal.getDataLinkSet(srcInfo);


        processLinkSet(linkSet);

    else



        linkSets=slreq.data.ReqData.getInstance.getLoadedLinkSets();
        for i=1:numel(linkSets)
            processLinkSet(linkSets(i));
        end

    end


    result.linkedStreams=streams;
    result.linkedChangesets=changesets;
    result.linkedBaselines=baselines;
    result.configUrls=urls;



    function processLinkSet(oneLinkSet)
        links=oneLinkSet.getAllLinks;
        for j=1:numel(links)
            link=links(j);
            if~strcmp(link.destDomain,'linktype_rmi_oslc')
                continue;
            end
            [confId,type]=parseConfigContextIdFromUrl(link.destUri);
            if isempty(confId)
                continue;
            end
            switch type
            case 'changeset'
                if isKey(changesets,confId)
                    changesets(confId)=changesets(confId)+1;
                else
                    changesets(confId)=1;
                    urls(confId)=queryBaseToConfigUrl(link.destUri);
                end
            case 'stream'
                if isKey(streams,confId)
                    streams(confId)=streams(confId)+1;
                else
                    streams(confId)=1;
                    urls(confId)=queryBaseToConfigUrl(link.destUri);
                end
            case 'baseline'
                if isKey(baselines,confId)
                    baselines(confId)=baselines(confId)+1;
                else
                    baselines(confId)=1;
                    urls(confId)=queryBaseToConfigUrl(link.destUri);
                end
            otherwise

            end
        end
    end

end




function[id,type]=parseConfigContextIdFromUrl(url)





    if contains(url,'%2Fstream%2F')
        tokens=regexp(url,'%2Fstream%2F([-\w]+)','tokens');
        id=tokens{1}{1};
        type='stream';
    elseif contains(url,'%2Fchangeset%2F')
        tokens=regexp(url,'%2Fchangeset%2F([-\w]+)','tokens');
        id=tokens{1}{1};
        type='changeset';
    elseif contains(url,'%2Fbaseline%2F')
        tokens=regexp(url,'%2Fbaseline%2F([-\w]+)','tokens');
        id=tokens{1}{1};
        type='baseline';
    else
        id='';
        type='';
    end
end


function url=queryBaseToConfigUrl(queryBaseUrl)
    unescaped=strrep(strrep(queryBaseUrl,'%3A',':'),'%2F','/');
    vvcStart=strfind(unescaped,'vvc.configuration=');
    if~isempty(vvcStart)
        tag='vvc.configuration';
    else
        vvcStart=strfind(unescaped,'oslc_config.context=');
        tag='oslc_config.context';
    end
    if isempty(vvcStart)
        url='';
    else
        configPart=unescaped(vvcStart(1)+length(tag)+1:end);
        nextArg=strfind(configPart,'&');
        if~isempty(nextArg)
            url=configPart(1:nextArg(1)-1);
        else
            nextSpace=strfind(configPart,' ');
            if~isempty(nextSpace)
                url=configPart(1:nextSpace(1)-1);
            else
                url=configPart;
            end
        end
    end
end


