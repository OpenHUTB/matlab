function queryBase=getQueryBase(rdf)
    queryBase=oslc.parseValue(rdf,'oslc:queryBase rdf:resource=');
    if iscell(queryBase)


        serviceRoot=rmipref('OslcServerRMRoot');
        pattern=['/',serviceRoot,'/views?'];
        for i=1:length(queryBase)
            url=queryBase{i};
            if contains(url,pattern)
                queryBase=url;
                return;
            end
        end

        queryBase=queryBase{1};
    end
end
