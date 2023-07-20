

function alignment=getTranslatedAlignment(alignEnLocale)
    enLocale=matlab.internal.i18n.locale('en');
    switch alignEnLocale
    case getString(message('SimulinkHMI:dashboardblocks:DisplayBlockLeftAlignment'),enLocale)
        alignment=...
        DAStudio.message('SimulinkHMI:dashboardblocks:DisplayBlockLeftAlignment');
    case getString(message('SimulinkHMI:dashboardblocks:DisplayBlockCenterAlignment'),enLocale)
        alignment=...
        DAStudio.message('SimulinkHMI:dashboardblocks:DisplayBlockCenterAlignment');
    case getString(message('SimulinkHMI:dashboardblocks:DisplayBlockRightAlignment'),enLocale)
        alignment=...
        DAStudio.message('SimulinkHMI:dashboardblocks:DisplayBlockRightAlignment');
    otherwise
    end
end