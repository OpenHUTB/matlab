function[infoType,value]=getFileName(fileSource)





    infoType=message('comparisons:rptgen:FileName').getString;
    [~,value,~]=fileparts(fileSource.Path);
end
