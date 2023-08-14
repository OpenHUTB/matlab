function req=findExternalReq(this,group,itemInfo)%#ok<INUSL>





    req=[];

    switch class(itemInfo)

    case 'char'
        key=itemInfo;

    case 'slreq.datamodel.Reference'
        key=itemInfo.artifactId;

    otherwise
        error('Invalid argument type: %s. \n\t%s',class(itemInfo),...
        'Expected slreq.datamodel.Reference or artifactId as a character string.');
    end


    reqs=group.items{key};

    if~isempty(reqs)
        req=reqs(1);

        if numel(reqs)>1
            rmiut.warnNoBacktrace('Slvnv:rmiml:RepositoryCantChoose',key);
        end

    end
end
