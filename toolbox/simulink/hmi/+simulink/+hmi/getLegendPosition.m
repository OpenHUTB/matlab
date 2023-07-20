

function legendPosition=getLegendPosition(msg)
    switch msg
    case{DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogLabelPositionTop'),'Top'}
        legendPosition='top';
    case{DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogLabelPositionRight'),'Right'}
        legendPosition='right';
    case{DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogLabelPositionInsideTopLegend'),'Inside top'}
        legendPosition='insideTop';
    case{DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogLabelPositionInsideRightLegend'),'Inside right'}
        legendPosition='insideRight';
    case{DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogLabelPositionHide'),'Hide'}
        legendPosition='hide';
    otherwise
        warning(DAStudio.message('SimulinkHMI:errors:InvalidLabelPosition'));
    end
end
