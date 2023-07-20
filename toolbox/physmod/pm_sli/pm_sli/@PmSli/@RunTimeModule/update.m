function canDo=update(event,blockDiagram)





















    canDo=true;
    switch lower(event)
    case 'pre-activate'
    case 'activate'
        rtm=PmSli.RunTimeModule;
        rtm.canPerformOperation(blockDiagram,'CCC_ACTIVATE');
    case 'deactivate'
        rtm=PmSli.RunTimeModule;
        rtm.canPerformOperation(blockDiagram,'CCC_DEACTIVATE');
    otherwise

    end




