


function codeMap=groupCode(keyList,fileNames,datamgr)

    codeReader=datamgr.getReader('CODE');
    objects=codeReader.getObjects(keyList);


    codeMap=containers.Map;

    numFiles=numel(fileNames);
    for k=1:numFiles

        thisFile=fileNames{k};

        matchIdx=cellfun(@(x)matchesFileName(x,thisFile),objects);
        codeMap(thisFile)=objects(matchIdx);
    end

end

function match=matchesFileName(cObject,fileName)
    file=[cObject.getFilePath(),filesep,cObject.getFileName()];
    match=strcmp(file,fileName);
end
