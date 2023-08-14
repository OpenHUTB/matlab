function[infoType,value]=getLastModified(fileSource)





    infoType=message('comparisons:rptgen:LastModified').getString;
    fileStruct=dir(fileSource.Path);
    value=fileStruct.date;
end
