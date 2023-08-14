function[streams,baselines,changesets]=getAllConfigurations(this,connectionObj)
    streams=cell(0,2);
    baselines=cell(0,2);
    changesets=cell(0,2);
    projUrlBase=urldecode(this.queryBase);
    matched=regexp(projUrlBase,'project-areas\/([_a-zA-Z0-9-]+)','tokens','once');
    if isempty(matched)
        rmiut.warnNoBacktrace('Slvnv:oslc:FailedToParseProjectID',this.name);
        return;
    end
    projId=matched{1};
    server=oslc.server;

    if nargin<2
        connectionObj=oslc.connection();
    end

    streams=getConfigsByType('stream');
    baselines=getConfigsByType('baseline');
    changesets=getConfigsByType('changeset');

    function url=getQueryURL(type)
        serviceRoot=rmipref('OslcServerRMRoot');
        url=[server,'/',serviceRoot,'/queryvvc/configurationsforcomponent',...
        '?configurationtype=',type,...
        '&component=',urlencode([server,'/',serviceRoot,'/process/project-areas/',projId])];
    end

    function items=getConfigsByType(type)
        queryUrl=getQueryURL(type);
        json=connectionObj.get(queryUrl);
        data=jsondecode(char(json));
        items=dataToCellArray(data.items,type);
    end

end

function items=dataToCellArray(dataItems,type)
    count=length(dataItems);
    items=cell(count,3);
    for i=1:count
        items(i,1:2)={dataItems(i).uri,dataItems(i).title};
        items{i,3}=type;
    end
end


