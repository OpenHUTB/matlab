function htmlFilePath=getCacheFilePath(doc,bookmarkName)

    [~,docName]=fileparts(doc);
    htmlFileName=[docName,'_',bookmarkName,'.htm'];
    htmlFileDir=fullfile(tempdir,'RMI','MSWORD');
    htmlFilePath=rmi.Informer.tmpExcerptFile(htmlFileDir,htmlFileName);

end
