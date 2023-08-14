

function layout=getTranslatedLayout(layoutEnLocale)
    enLocale=matlab.internal.i18n.locale('en');
    switch layoutEnLocale
    case getString(message('SimulinkHMI:dialogs:DisplayBlockLayoutPreserveDimensions'),enLocale)
        layout=...
        DAStudio.message('SimulinkHMI:dialogs:DisplayBlockLayoutPreserveDimensions');
    case getString(message('SimulinkHMI:dialogs:DisplayBlockLayoutFillSpace'),enLocale)
        layout=...
        DAStudio.message('SimulinkHMI:dialogs:DisplayBlockLayoutFillSpace');
    otherwise
    end
end