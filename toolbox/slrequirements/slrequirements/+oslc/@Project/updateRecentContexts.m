
function updateRecentContexts(this,dngClient)

    displayProgress=rmiut.progressBarFcn('exists');

    historyQueryUrl=sprintf('%s/%s/view-history',rmipref('OslcServerAddress'),rmipref('OslcServerRMRoot'));
    history=dngClient.get(historyQueryUrl);
    changesets=cell(0,2);
    streams=cell(0,2);
    baselines=cell(0,2);
    for i=1:history.count
        if displayProgress
            rmiut.progressBarFcn('set',i/history.count,getString(message('Slvnv:oslc:CheckingConfigurations')));
        end
        item=history.items(i);
        if~strcmp(item.project,this.detailsURI)
            continue;
        end
        uri=item.uri;
        if contains(uri,'/cm/changeset/')
            changesets{end+1,1}=uri;%#ok<AGROW>
            changesets{end,2}=getConfigName(uri,dngClient);
        elseif contains(uri,'/cm/stream/')
            streams{end+1,1}=uri;%#ok<AGROW>
            streams{end,2}=getConfigName(uri,dngClient);
        elseif contains(uri,'/cm/baseline/')
            baselines{end+1,1}=uri;%#ok<AGROW>
            baselines{end,2}=getConfigName(uri,dngClient);
        end
    end

    this.history.changesets=changesets;
    this.history.streams=streams;
    this.history.baselines=baselines;
end

function name=getConfigName(uri,client)
    rdf=client.get(uri);
    name=oslc.getTitle(rdf,'dcterms');
end
