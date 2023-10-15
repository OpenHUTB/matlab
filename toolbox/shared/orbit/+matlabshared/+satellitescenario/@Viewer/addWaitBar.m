function addWaitBar( viewer, msg )

arguments
    viewer
    msg{ mustBeMember( msg, { 'simulating', 'plotting' } ) } = 'simulating'
end


uiFigure = viewer.UIFigure;

if strcmp( msg, 'simulating' )
    msg = message( 'shared_orbit:orbitPropagator:SatelliteScenarioViewerSimulatingDialog' ).getString(  );
else
    msg = message( 'shared_orbit:orbitPropagator:SatelliteScenarioViewerPlottingDialog' ).getString(  );
end


if isa( uiFigure, 'matlab.ui.Figure' ) && isvalid( uiFigure )
    if ( isempty( viewer.UIWaitBar ) || ~isvalid( viewer.UIWaitBar ) )
        if ~uiFigure.Visible
            uiFigure.Visible = 'on';
        end
        uiWaitBar = uiprogressdlg( uiFigure, "Indeterminate", "on", "Message", msg );
        viewer.UIWaitBar = uiWaitBar;
    else
        viewer.UIWaitBar.Message = msg;
    end
end
end

