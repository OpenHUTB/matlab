function data=readMatData(reader,part,callback)





    tmpFile=[tempname,'.mat'];
    cleanup=onCleanup(@()delete(tmpFile));

    reader.readPartToFile(part,tmpFile);
    data=callback(tmpFile);

end

