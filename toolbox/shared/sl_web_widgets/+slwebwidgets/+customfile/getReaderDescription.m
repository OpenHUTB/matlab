function readerDescrip=getReaderDescription(inReaderName)





    try
        readerDescrip=feval([inReaderName,'.getFileTypeDescription']);
    catch ME
        readerDescrip='';
    end
