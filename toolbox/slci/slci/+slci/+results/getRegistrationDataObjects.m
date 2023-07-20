





function dataObjects=getRegistrationDataObjects(datamgr)

    reader=datamgr.getReader('BLOCK');
    dataObjects=reader.getObjects(reader.getKeys());
    selectedIndxs=cellfun(@(x)isa(x,'slci.results.RegistrationDataObject'),dataObjects);
    dataObjects=dataObjects(selectedIndxs);

end
