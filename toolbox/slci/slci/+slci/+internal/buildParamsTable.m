function[mdlRefParamsTable]=buildParamsTable(mdl)



    blks=slci.internal.getFullBlockList(mdl);

    mdlRefParamsTable=containers.Map('KeyType','double',...
    'ValueType','any');

    mdlRefBlks=blks(strcmpi(get_param(blks,'BlockType'),'ModelReference'));

    for i=1:numel(mdlRefBlks)
        blk=mdlRefBlks(i);
        assert(strcmpi(get_param(blk,'BlockType'),'ModelReference'),...
        'Model should be a model reference block');
        mdlRefParamsTable=buildMldRefParamsTablePerBlock(...
        mdlRefParamsTable,blk);
    end

end



function out=buildMldRefParamsTablePerBlock(...
    mdlRefParamsTable,blkH)

    out=mdlRefParamsTable;

    assert(strcmpi(get_param(blkH,'BlockType'),'ModelReference'));

    params=get_param(blkH,'ParameterArgumentValues');

    if isempty(params)
        return;
    end

    assert(isstruct(params));
    paramNamesCell=fieldnames(params);

    nameValueMap=containers.Map;

    for i=1:numel(paramNamesCell)
        assert(~isKey(nameValueMap,paramNamesCell{i}),...
        'Parameter Names in Model Reference block are unique');
        nameValueMap(paramNamesCell{i})=params.(paramNamesCell{i});

    end

    key=slci.internal.constructKeyForParamsTable(blkH);

    out(key)=nameValueMap;


end
