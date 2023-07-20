function bool=isBlockAssociatedWithDelayedAction(block,isHiliteToSrc)

    blockType=lower(get_param(block,'BlockType'));

    switch blockType

    case 'subsystem'

        bool=~isSubSystemBlockInExclusionList(block);

    case 'modelreference'

        bool=isBlockNonProtectedModelRef(block);

    case 'inport'
        bool=isHiliteToSrc;

    case 'outport'
        bool=~isHiliteToSrc;

    case 'goto'
        bool=~isHiliteToSrc;

    case 'from'
        bool=isHiliteToSrc;

    case{'observerport','injectorinport'}
        bool=isHiliteToSrc;

    case 'injectoroutport'
        bool=~isHiliteToSrc;

    otherwise
        bool=false;

    end

end
