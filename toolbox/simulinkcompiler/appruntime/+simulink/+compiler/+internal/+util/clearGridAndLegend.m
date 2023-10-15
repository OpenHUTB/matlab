function clearGridAndLegend( uiAxes )

arguments
    uiAxes( 1, 1 )matlab.ui.control.UIAxes
end

uiAxes.YGrid = 'off';
uiAxes.XGrid = 'off';
legend( uiAxes, 'off' );
drawnow;
end

