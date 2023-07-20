

function tickLabels=getTickLabels(msg)
    switch msg
    case{DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogTickLabelsAll'),'All'}
        tickLabels='all';
    case{DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogTickLabelsTAxis'),'T-Axis'}
        tickLabels='t-axis';
    case{DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogTickLabelsYAxis'),'Y-Axis'}
        tickLabels='y-axis';
    case{DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogTickLabelsNone'),'None'}
        tickLabels='none';
    otherwise
        warning(DAStudio.message('SimulinkHMI:errors:InvalidTickLabels'));
    end
end