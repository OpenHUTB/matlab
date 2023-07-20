function setTag(blk,tagParamName,tagParamValue)




    if~strcmpi(tagParamName,'PLCOperandTag')
        error('slplc:invalidTagParam',...
        'Invalid tag parameter name %s that should be ''PLCOperandTag''.',...
        tagParamName);
    end


    tagParamValue=regexprep(tagParamValue,'[\s+','[');
    tagParamValue=regexprep(tagParamValue,'\s+]',']');

    set_param(blk,tagParamName,tagParamValue);
end
