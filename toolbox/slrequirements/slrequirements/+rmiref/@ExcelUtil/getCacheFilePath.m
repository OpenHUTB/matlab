function htmlFilePath=getCacheFilePath(doc,itemId)


    myTempDir=fullfile(tempdir,'RMI','MSEXCEL');
    [~,docName]=fileparts(doc);

    if~isempty(regexp(itemId,'^@\w+$'))%#ok<RGXP1>
        itemName=itemId(2:end);
    elseif length(itemId)<20
        itemName=regexprep(itemId,'\W','_');
    else
        itemName=regexprep(itemId(1:20),'\W','_');
    end
    htmlFileName=[docName,'_',itemName,'.htm'];
    htmlFilePath=rmi.Informer.tmpExcerptFile(myTempDir,htmlFileName);

end
