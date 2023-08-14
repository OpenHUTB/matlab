function action=getDelayedAction(block)

    blockType=lower(get_param(block,'BlockType'));

    switch blockType

    case 'subsystem'
        action='StepIn';

    case 'modelreference'
        action='StepIn';

    case 'inport'
        action='StepOut';

    case 'outport'
        action='StepOut';

    case 'goto'
        action='moveToFrom';

    case 'from'
        action='moveToFrom';

    case{'observerport','injectorinport'}
        action='moveToMappedPortForCoSimInport';

    case 'injectoroutport'
        action='moveToMappedPortForCoSimOutport';

    otherwise
        action=[];

    end

end
