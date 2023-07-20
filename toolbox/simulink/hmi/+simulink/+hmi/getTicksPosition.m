

function ticksPosition=getTicksPosition(msg)
    switch msg
    case{DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogTicksPositionOutside'),'Outside'}
        ticksPosition='outside';
    case{DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogTicksPositionInside'),'Inside'}
        ticksPosition='inside';
    case{DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogTicksPositionNone'),'None'}
        ticksPosition='none';
    otherwise
        warning(DAStudio.message('SimulinkHMI:errors:InvalidTicksPosition'));
    end
end