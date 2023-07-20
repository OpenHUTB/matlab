
function htmlFilePath=getCacheFilePath(htmlFileDir,docName,itemLabel)





    docName=slreq.utils.getMD5hash(docName);




    itemLabel=slreq.utils.getMD5hash(itemLabel);





    htmlFileName=[docName,'_',itemLabel,'.htm'];

    htmlFilePath=fullfile(htmlFileDir,htmlFileName);
end

