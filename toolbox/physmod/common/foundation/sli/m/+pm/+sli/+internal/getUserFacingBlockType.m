function type=getUserFacingBlockType(block)






    narginchk(1,1);
    block=get_param(block,'Handle');



    maskType=get_param(block,'MaskType');
    if~isempty(maskType)
        type=strrep(maskType,newline,' ');
        return;
    end

    type=get_param(block,'BlockType');
end