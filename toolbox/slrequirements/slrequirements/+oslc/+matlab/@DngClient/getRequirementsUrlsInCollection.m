function urls=getRequirementsUrlsInCollection(this,collectionId,progressBarInfo)
    rdf=getRdfForUsesOf(this,collectionId);

    if(nargin==3)
        progressValue=progressBarInfo.range(1)+0.5*(progressBarInfo.range(2)-progressBarInfo.range(1));
        rmiut.progressBarFcn('set',progressValue,progressBarInfo.text,progressBarInfo.title);
    end

    urls=getMemberUrls(this,rdf);

end

function rdf=getRdfForUsesOf(this,collectionId)
    queryBase=this.getReqQueryCapability();
    oslc_rm=sprintf('oslc_rm=%s',urlencode(['<',oslc.matlab.Constants.OSLC_RM_V2,'>']));
    dcterms=sprintf('dcterms=%s',urlencode(['<',oslc.matlab.Constants.DC,'>']));
    namespaces=sprintf('oslc.prefix=%s&oslc.prefix=%s',oslc_rm,dcterms);
    select='oslc.select=oslc_rm:uses';
    where=sprintf('oslc.where=dcterms:identifier=%s',collectionId);
    queryUrl=sprintf('%s&%s&%s&%s',queryBase,namespaces,select,where);
    rdf=this.get(queryUrl);

end

function urls=getMemberUrls(this,rdf)
    urls={};

    if contains(rdf,'RequirementCollection rdf:about=')
        matchUrl=regexp(rdf,'RequirementCollection rdf:about="([^"]+)"','tokens');
        if~isempty(matchUrl)
            collectionUrl=matchUrl{1}{1};
            collectionUrlWithContext=oslc.matlab.DngClient.appendContextParam(collectionUrl);
            collectionRdf=this.get(collectionUrlWithContext);
            urls=getMemberUrls(this,collectionRdf);
        end
    else
        urls=regexp(rdf,'<oslc_rm:uses rdf:resource="([^"]+)"','tokens');
    end
end
