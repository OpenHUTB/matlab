function lockLinksToLibraryRF(cbinfo,action)
    bdType=get_param(cbinfo.model.handle,'BlockDiagramType');
    if(strcmpi(bdType,'library'))
        action.enabled=true;
    else
        action.enabled=false;
    end

    lockLinksToLibrary=strcmpi(get_param(cbinfo.model.handle,'LockLinksToLibrary'),'on');
    if lockLinksToLibrary
        action.text='simulink_ui:studio:resources:linksLockedText';
        action.selected=true;
        action.icon='libraryLinkLocked2';
    else
        action.text='simulink_ui:studio:resources:lockLinksToLibraryText';
        action.selected=false;
        action.icon='libraryLinkIndicator';
    end
    lockedLibrary=strcmpi(get_param(cbinfo.model.handle,'Lock'),'on');
    if lockedLibrary
        action.enabled=false;
    end
end

