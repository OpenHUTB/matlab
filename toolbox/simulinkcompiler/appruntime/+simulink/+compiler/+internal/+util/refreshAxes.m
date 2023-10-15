function refreshAxes( uiAxes )

arguments
    uiAxes( 1, 1 )matlab.ui.control.UIAxes
end

legend( uiAxes );
uiAxes.XGrid = 'on';
uiAxes.YGrid = 'on';
uiAxes.Legend.Interpreter = 'none';
end

