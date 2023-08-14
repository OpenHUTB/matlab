

function scaleType=getScaleType(msg)
    switch msg
    case{DAStudio.message('SimulinkHMI:dialogs:ScaleTypeLinear'),'Linear'}
        scaleType=int32(0);
    case{DAStudio.message('SimulinkHMI:dialogs:ScaleTypeLog'),'Log'}
        scaleType=int32(1);
    otherwise
        assert(0);
    end
end
