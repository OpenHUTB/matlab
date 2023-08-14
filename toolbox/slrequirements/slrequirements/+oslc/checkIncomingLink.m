function[tf,linkTargetInfo]=checkIncomingLink(mwArtifact,mwId,queryBase,itemUrl)




    try
        resourceUrl=oslc.getNavURL(queryBase,itemUrl);
        connection=oslc.connection();
        resourceRDF=connection.get(resourceUrl);
        slLinks=parseSLLinks(char(resourceRDF));
        if isempty(slLinks)
            tf=false;
        else
            tf=matchMWItem(slLinks,mwArtifact,mwId);
        end
        linkTargetInfo.domain='linktype_rmi_slreq';
        linkTargetInfo.doc=queryBase;
        linkTargetInfo.id=itemUrl;
    catch
        tf=false;
        linkTargetInfo='';
    end
end

function slLinks=parseSLLinks(rdf)


    matched=regexp(rdf,'<j\.\d+:Link rdf:resource="([^"]+)"/>','tokens');
    slLinks=cell(size(matched));
    if~isempty(matched)
        for i=1:size(matched,2)
            slLinks{i}=strrep(matched{i}{1},'&amp;','&');
        end
    end
end

function tf=matchMWItem(urls,mwArtifact,mwId)
    tf=false;
    for i=1:numel(urls)
        if matchInUrl(urls{i},mwArtifact,mwId)
            tf=true;
            return;
        end
    end
end

function tf=matchInUrl(url,mwArtifact,mwId)
    if startsWith(url,'http://')
        tf=matchUnsecureUrl(url,mwArtifact,mwId);
    else
        tf=matchSecureUrl(url,mwArtifact,mwId);
    end
end

function tf=matchUnsecureUrl(url,mwArtifact,mwId)
    tf=false;

    matched=regexp(url,'%22([^%]+)%22','tokens');
    if isempty(matched)
        return;
    end
    for i=numel(matched):-1:2
        param=matched{i}{1};
        if~strcmp(param,mwId)
            continue;
        else

            prevParam=matched{i-1}{1};
            if contains(mwArtifact,prevParam)
                tf=true;
            elseif ispc


                tf=strcmp(prevParam,strrep(mwArtifact,filesep,'/'));
            end
            return;
        end
    end
end

function tf=matchSecureUrl(url,mwArtifact,mwId)
    tf=false;


    if~contains(url,'matlab/oslc/navigate?domain=')
        return;
    end
    matched=regexp(url,'artifact=([^&]+)&id=(\S+)','tokens');
    if isempty(matched)||numel(matched{1})<2
        return;
    end
    tf=strcmp(mwId,matched{1}{2})&&contains(mwArtifact,matched{1}{1});
end
