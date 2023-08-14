

function writeErrorToDD(msg,dm)
    errorReader=dm.getReader('ERROR');
    eObject=slci.results.ErrorObject(msg);
    errorReader.insertObject(eObject.getKey(),eObject);
end
