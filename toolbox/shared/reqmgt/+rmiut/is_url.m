function[is_url,varargout]=is_url(doc)



    doc=convertStringsToChars(doc);

    is_url=false;

    if nargout>1



        if~isempty(regexp(doc,'^\w\w+\.\w\w+\.\w\w+($|/)','once'))
            doc=['http://',doc];
            is_url=true;
        end
        varargout={doc,''};
    end

    if~is_url&&(...
        strncmp(doc,'http://',7)||...
        strncmp(doc,'file://',7)||...
        strncmp(doc,'https://',8)||...
        strncmp(doc,'ftp://',6))
        is_url=true;
    end

    if is_url&&nargout>1
        separators=strfind(doc,'#');
        if isempty(separators)||separators(length(separators))==length(doc)
            varargout={doc,''};
        else
            varargout={doc(1:separators(end)-1),doc(separators(end)+1:end)};
        end
    end

end
