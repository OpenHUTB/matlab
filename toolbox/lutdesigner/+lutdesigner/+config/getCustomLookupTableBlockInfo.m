function info=getCustomLookupTableBlockInfo(block)


    block=regexprep(getfullname(block),'\n',' ');
    assert(~isempty(get_param(block,'MaskType')),...
    message('lutdesigner:messages:invalidCustomLookupTableBlock'));

    dialogParameters=get_param(block,'DialogParameters');
    assert(~isempty(dialogParameters),...
    message('lutdesigner:messages:invalidCustomLookupTableBlock'));

    blockObject=get_param(block,'Object');
    availableParamNames=fieldnames(dialogParameters);
    availableParamNames(cellfun(@(name)~blockObject.isValidProperty(name),availableParamNames))=[];
    assert(~isempty(availableParamNames),...
    message('lutdesigner:messages:invalidCustomLookupTableBlock'));

    info=struct;
    info.BlockType=get_param(block,'BlockType');
    info.MaskType=get_param(block,'MaskType');
    info.Parameters=sort(availableParamNames);
end
