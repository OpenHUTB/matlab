








function type=getLibraryBlockType(block)
    type=[];
    maskObj=get_param(block,'MaskObject');
    if~isempty(maskObj)
        type=maskObj.Type;
    end
end