function addWaitBar( viewer, msg )





R36
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


% Decoded using De-pcode utility v1.2 from file /tmp/tmpovnuxf.p.
% Please follow local copyright laws when handling this file.

