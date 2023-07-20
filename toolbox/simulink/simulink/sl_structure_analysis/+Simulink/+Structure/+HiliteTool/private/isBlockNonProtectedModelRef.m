function bool=isBlockNonProtectedModelRef(block)

    bool=false;
    elementType=get_param(block,'type');
    if(strcmpi(elementType,'block'))
        blockType=get_param(block,'BlockType');
        if(strcmpi(blockType,'modelreference'))
            isProtected=get_param(block,'ProtectedModel');
            if(strcmpi(isProtected,'off'))
                bool=true;
            end
        end
    end

end
