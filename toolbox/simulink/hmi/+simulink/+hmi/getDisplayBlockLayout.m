

function layout=getDisplayBlockLayout(msg)
    switch msg
    case DAStudio.message('SimulinkHMI:dialogs:DisplayBlockLayoutPreserveDimensions')
        layout=int32(0);
    case DAStudio.message('SimulinkHMI:dialogs:DisplayBlockLayoutFillSpace')
        layout=int32(1);
    otherwise
        warning(DAStudio.message('SimulinkHMI:errors:InvalidLayout'));
    end
end
