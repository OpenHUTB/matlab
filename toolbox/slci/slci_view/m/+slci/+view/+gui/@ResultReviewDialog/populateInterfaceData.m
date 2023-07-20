


function populateInterfaceData(obj)


    dm=obj.getDataManager();
    if isempty(dm)
        return;
    end


    obj.fInterfaceData={};

    interfaceReader=dm.getReader('FUNCTIONINTERFACE');
    interfaceKeys=interfaceReader.getKeys();
    id_idx=1;
    for i=1:numel(interfaceKeys)
        interfaceKey=interfaceKeys(i);
        interfaceObj=interfaceReader.getObjects(interfaceKey);
        assert(iscell(interfaceObj));
        assert(numel(interfaceObj)==1);
        assert(iscell(interfaceKey));

        data.id=id_idx;
        data.name=interfaceObj{1}.getName();
        data.status=interfaceObj{1}.getStatus();

        traceArray=interfaceObj{1}.getTraceArray();

        data.codelines=obj.getCodeLines(traceArray);

        obj.fInterfaceData{end+1}=data;

        id_idx=id_idx+1;
    end