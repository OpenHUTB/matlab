function result=docListToString(docsArray,ref,stripHtml)




    result='';

    for i=1:length(docsArray)
        doc=docsArray{i};
        if stripHtml
            doc=regexprep(doc,'<[^>]+>','');
        end

        [~,~,ext]=fileparts(doc);
        if~isempty(ext)
            resolved=rmi.locateFile(doc,ref);
            if~isempty(resolved)
                doesExist=exist(resolved,'file');
                if doesExist==2||doesExist==4

                    doc=resolved;
                end
            end
        end
        result=[result,newline,doc];%#ok<AGROW>
    end
    result=strtrim(result);
end