





function blkObjects=getBlockObjects(datamgr)

    reader=datamgr.getReader('BLOCK');
    dataObjects=reader.getObjects(reader.getKeys());
    excludedIndxs=cellfun(@(x)isa(x,'slci.results.RegistrationDataObject'),dataObjects);
    blkObjects=dataObjects(~excludedIndxs);

end
