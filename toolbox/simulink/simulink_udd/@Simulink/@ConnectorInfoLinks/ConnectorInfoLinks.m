function sObj=ConnectorInfoLinks(connType,origOwners,origReaders,origWriters,origReaderWriters)





    sObj=Simulink.ConnectorInfoLinks;
    sObj.ConnectorType=connType;
    sObj.OriginalOwners=origOwners;
    sObj.OriginalReaders=origReaders;
    sObj.OriginalWriters=origWriters;
    sObj.OriginalReaderWriters=origReaderWriters;
