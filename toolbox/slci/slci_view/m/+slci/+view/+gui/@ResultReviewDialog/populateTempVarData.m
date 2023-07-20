


function populateTempVarData(obj)


    dm=obj.getDataManager();
    if isempty(dm)
        return;
    end


    obj.fTempVarData={};

    tempVarReader=dm.getReader('TEMPVAR');
    tempVarKeys=tempVarReader.getKeys();

    functionNames=containers.Map('KeyType','char','ValueType','any');


    funcBodyReader=dm.getReader('FUNCTIONBODY');
    funcBodyKeys=funcBodyReader.getKeys();
    for i=1:numel(funcBodyKeys)
        funcScope=funcBodyKeys(i);
        funcObj=funcBodyReader.getObjects(funcScope);
        assert(iscell(funcScope));
        assert(numel(funcObj)==1);
        assert(iscell(funcObj));
        functionNames(funcScope{1})=funcObj{1}.getName();
    end

    id_idx=1;
    for i=1:numel(tempVarKeys)
        data={};
        tempVarKey=tempVarKeys(i);
        tempVarObj=tempVarReader.getObjects(tempVarKey);
        assert(iscell(tempVarObj));
        assert(numel(tempVarObj)==1);
        assert(iscell(tempVarObj));

        codeObj=tempVarObj{1}.getCodeObject();
        codelines=obj.getCodeLines(codeObj);

        fscope=tempVarObj{1}.getFunctionScope();
        if isKey(functionNames,fscope)
            scope=functionNames(fscope);
        else
            scope='';
        end

        data.id=id_idx;
        data.name=tempVarObj{1}.getDispName();
        data.status=tempVarObj{1}.getStatus();
        data.parent=scope;
        data.scope=scope;
        data.codelines=codelines;

        obj.fTempVarData{end+1}=data;

        id_idx=id_idx+1;
    end


    kscope=keys(functionNames);
    for i=1:numel(kscope)
        data={};
        data.id=id_idx;
        ks=kscope{i};
        data.name=functionNames(ks);
        data.codelines='';
        data.status='';
        data.parent='';
        data.scope=functionNames(ks);

        obj.fTempVarData{end+1}=data;

        id_idx=id_idx+1;
    end
