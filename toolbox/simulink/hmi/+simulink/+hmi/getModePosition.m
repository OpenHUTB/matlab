

function mode=getModePosition(msg)



    enLocale=matlab.internal.i18n.locale('en');
    switch msg
    case{DAStudio.message('SimulinkHMI:dialogs:ScaleModeFixed'),...
        getString(message('SimulinkHMI:dialogs:ScaleModeFixed'),enLocale)}
        mode=int32(0);
    case{DAStudio.message('SimulinkHMI:dialogs:ScaleModeFill'),...
        getString(message('SimulinkHMI:dialogs:ScaleModeFill'),enLocale)}
        mode=int32(1);
    case{DAStudio.message('SimulinkHMI:dialogs:ScaleModeFillAspectRatio'),...
        getString(message('SimulinkHMI:dialogs:ScaleModeFillAspectRatio'),enLocale)}
        mode=int32(2);
    otherwise

    end
end