function result=addLink(this,resourceURL,linkUrl,linkLabel,linkType)

    linkUrl=escapeAmpersand(linkUrl);


    [rdf,eTag]=this.get(resourceURL);


    if contains(rdf,linkUrl)
        result=getString(message('Slvnv:oslc:LinkExists',linkLabel));
        return;
    end


    rdf=oslc.matlab.RdfUtil.addLink(rdf,linkUrl,linkLabel,linkType);
    if isempty(rdf)


        result=getString(message('Slvnv:oslc:LinkExists',linkLabel));
        return;
    end


    try
        result=this.put(resourceURL,rdf,eTag);
    catch ex
        rmiut.warnNoBacktrace(ex.message);
        result=['ERROR: ',ex.message];
    end
end

function url=escapeAmpersand(url)
    amp=strfind(url,'&');
    escaped=strfind(url,'&amp;');
    todo=setdiff(amp,escaped);
    for i=numel(todo):-1:1
        pos=todo(i);
        url=[url(1:pos),'amp;',url(pos+1:end)];
    end
end
