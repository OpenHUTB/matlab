function allIds=getCollectionsIds(this,doRefresh,progressBarInfo)

    if nargin<2
        doRefresh=true;
    end
    if nargin<3
        progressBarInfo=[];
    end

    if~doRefresh
        allIds=oslc.matlab.CollectionsMgr.getInstance.getCollectionIds(this.projectName);
        return;
    end

    if~isempty(progressBarInfo)
        progressValue=progressBarInfo.range(1)+0.3*(progressBarInfo.range(2)-progressBarInfo.range(1));
        rmiut.progressBarFcn('set',progressValue,progressBarInfo.text,progressBarInfo.title);
    end


    rdf=getCollectionsListRdf(this);

    if~isempty(progressBarInfo)
        progressValue=progressBarInfo.range(1)+0.7*(progressBarInfo.range(2)-progressBarInfo.range(1));
        rmiut.progressBarFcn('set',progressValue,progressBarInfo.text,progressBarInfo.title);
    end


    allIds=oslc.matlab.CollectionsMgr.getInstance.parseCollectionsData(this.projectName,rdf);

end

function result=getCollectionsListRdf(this)
    queryBase=this.getCollectionQueryCapability();
    rdfterms=sprintf('rdf=%s',urlencode(['<',oslc.matlab.Constants.RDF,'>']));
    namespaces=sprintf('oslc.prefix=%s',rdfterms);
    select='oslc.select=*';
    where=sprintf('oslc.where=rdf:type=%s',urlencode(['<',oslc.matlab.Constants.RM_REQUIREMENT_COLLECTION_TYPE,'>']));
    queryUrl=sprintf('%s&%s&%s&%s',queryBase,namespaces,select,where);
    result=this.get(queryUrl);
end

