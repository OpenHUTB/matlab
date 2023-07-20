

function updateMode=getUpdateMode(msg)
    switch msg
    case{DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogUpdateModeWrap'),'Wrap'}
        updateMode='wrap';
    case{DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogUpdateModeScroll'),'Scroll'}
        updateMode='scroll';
    otherwise
        warning(DAStudio.message('SimulinkHMI:errors:InvalidUpdateMode'));
    end
end