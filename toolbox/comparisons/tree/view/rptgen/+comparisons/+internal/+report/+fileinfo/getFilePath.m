function[infoType,value]=getFilePath(fileSource)





    infoType=message('comparisons:rptgen:FilePath').getString;
    [value,~,~]=fileparts(fileSource.Path);
end
