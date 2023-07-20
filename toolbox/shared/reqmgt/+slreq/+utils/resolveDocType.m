function docType=resolveDocType(docName)
    [~,~,fExt]=fileparts(docName);

    fExt=lower(fExt);
    switch fExt
    case{'.xlsx','.xls'}
        docType='excel';
    case{'.docx','.doc'}
        docType='word';
    otherwise

        docId=strtok(docName);
        if length(docId)==8&&~isempty(regexp(docId,'^[0-9a-f]+$','once'))
            docType='doors';
        else
            docType='';
        end
    end
end
