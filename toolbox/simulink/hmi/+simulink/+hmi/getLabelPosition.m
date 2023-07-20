

function labelPosition=getLabelPosition(msg)
    switch msg
    case{DAStudio.message('SimulinkHMI:dialogs:LabelPositionTop'),'Top'}
        labelPosition=int32(0);
    case{DAStudio.message('SimulinkHMI:dialogs:LabelPositionBottom'),'Bottom'}
        labelPosition=int32(1);
    case{DAStudio.message('SimulinkHMI:dialogs:LabelPositionHide'),'Hide'}
        labelPosition=int32(2);
    otherwise
        warning(DAStudio.message('SimulinkHMI:errors:InvalidLabelPosition'));
    end
end
