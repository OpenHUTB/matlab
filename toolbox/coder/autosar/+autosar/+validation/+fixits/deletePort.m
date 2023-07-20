function out=deletePort(port)




    modelName=bdroot(port);

    mm=autosar.api.Utils.modelMapping(modelName);
    mmPorts=[mm.Inports,mm.Outports];
    mmPort=mmPorts(arrayfun(@(x)strcmp(x.Block,port),mmPorts));

    arProps=autosar.api.getAUTOSARProperties(modelName);
    arPort=arProps.find([],'Port','Name',mmPort.MappedTo.Port,'PathType','FullyQualified');

    arProps.delete(arPort{1});

    out='Port deleted';
end
