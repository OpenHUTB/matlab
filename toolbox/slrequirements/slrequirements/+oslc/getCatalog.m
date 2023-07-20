function catalogDataTable=getCatalog(oslcConnection)



    persistent cachedCatalog





    if nargin==0

        if~isempty(cachedCatalog)
            catalogDataTable=cachedCatalog;
            return;
        else
            oslcConnection=oslc.connection();
        end
    else

    end



    usingJava=~isa(oslcConnection,'oslc.matlab.DngClient');

    if usingJava
        catalogURL=char(oslcConnection.getCatalogURL());
        catalogRDF=char(oslcConnection.get(catalogURL));
    else
        catalogRDF=oslcConnection.getCatalogRDF();
    end

    catalogDataTable=parseCatalogData(catalogRDF);

    if isempty(catalogDataTable)
        oslc.connection([]);
        oslc.server([]);
        if contains(catalogRDF,'Context Root Not Found')
            error('OSLC Client: Context Root Not Found');
        else
            error(catalogRDF);
        end
    end

    if~usingJava
        oslcConnection.storeCatalog(catalogDataTable);
    end

    cachedCatalog=catalogDataTable;
end

function projectsInfo=parseCatalogData(catalog)
    matched=regexp(catalog,'<oslc:serviceProvider>(.+?)</oslc:serviceProvider>','tokens');
    projectsInfo=cell(size(matched,2),3);
    for i=1:size(matched,2)
        match=matched{i}{1};






        matched2=regexp(match,'<oslc:ServiceProvider rdf:about="(\S+)">','tokens');
        matched3=regexp(match,'<dcterms:title rdf:parseType="Literal">([^<]+)</dcterms:title>','tokens');
        matched4=regexp(match,'<oslc:details rdf:resource="(\S+)"/>','tokens');
        if isempty(matched2)||isempty(matched3)||isempty(matched4)
            warning(message('Slvnv:oslc:FailedToParseProviderData',match));
        else
            projectsInfo{i,1}=oslc.unescapeHtml(matched3{1}{1});
            projectsInfo{i,2}=matched2{1}{1};
            projectsInfo{i,3}=matched4{1}{1};
        end
    end
end
