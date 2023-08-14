function bool=isSubSystemAndInExclusionList(block)

    bool=false;
    type=get_param(block,'type');

    if(strcmpi(type,'block'))
        blockType=get_param(block,'BlockType');
        if(strcmpi(blockType,'subsystem')&&...
            isSubSystemBlockInExclusionList(block))
            bool=true;
        end
    end

end