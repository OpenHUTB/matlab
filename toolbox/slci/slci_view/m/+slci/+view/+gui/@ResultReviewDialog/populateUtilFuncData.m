


function populateUtilFuncData(obj)


    dm=obj.getDataManager();
    if isempty(dm)
        return;
    end


    obj.fUtilFuncData={};

    utilFuncReader=dm.getReader('FUNCTIONCALL');
    utilFuncKeys=utilFuncReader.getKeys();

    id_idx=1;
    for i=1:numel(utilFuncKeys)
        data={};
        utilFuncKey=utilFuncKeys(i);
        utilFuncObj=utilFuncReader.getObjects(utilFuncKey);
        assert(iscell(utilFuncObj));
        assert(numel(utilFuncObj)==1);
        assert(iscell(utilFuncKey));

        codeKeys=utilFuncObj{1}.getCodeKeys();
        blockKeys=utilFuncObj{1}.getBlockKeys();
        status=utilFuncObj{1}.getStatus();

        if strcmpi(status,'UNKNOWN')
            status='-';
        end

        data.id=id_idx;
        data.name=utilFuncObj{1}.getCName();
        data.status=status;
        data.codelines=obj.getCodeLines(codeKeys);
        data.blocktrace=blockKeys;

        obj.fUtilFuncData{end+1}=data;

        id_idx=id_idx+1;
    end
