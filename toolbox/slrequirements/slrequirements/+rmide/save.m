function reqFilePath=save(dictName)




    dictName=convertStringsToChars(dictName);

    dictPath=rmide.getFilePath(dictName);

    if isempty(dictPath)
        error(message('Slvnv:rmide:ProvidePathToDictFile'));
    end

    reqFilePath=slreq.saveLinks(dictPath);

end

