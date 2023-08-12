function cameratoolbarHelper( fig, option, isSelected )



if isprop( fig, 'MOLToolstripMggId' )
channelID = get( fig, 'MOLToolstripMggId' );
else 
channelID = [  ];
end 



modeManager = uigetmodemanager( fig );
if ~isempty( modeManager ) && ~isempty( modeManager.CurrentMode ) &&  ...
strcmp( modeManager.CurrentMode.Name, 'Standard.EditPlot' )

plotedit( fig, 'off' );
end 





msg = '';


cameratoolbar( fig, 'toggle' );

switch option
case 'show'
msg = 'select';
nomode( fig.CameraToolbarManager, fig );
case 'close'
msg = 'hide';
nomode( fig.CameraToolbarManager, fig );
case { 'pan', 'dollyhv', 'dollyfb', 'zoom', 'roll', 'orbit' }
if isSelected
setmodegui( fig.CameraToolbarManager, fig, option );
else 
nomode( fig.CameraToolbarManager, fig );
end 
case { 'x', 'y', 'z', 'none' }
setcoordsys( fig.CameraToolbarManager, fig, option );
case 'togglescenelight'
togglescenelight( fig.CameraToolbarManager, fig );
case { 'orthographic', 'perspective' }
setprojection( fig.CameraToolbarManager, fig, option );
case 'resetcameralight'
resetcameraandscenelight( fig.CameraToolbarManager, fig )
case 'stop'
stopmoving( fig.CameraToolbarManager );
drawnow;
otherwise 
cameratoolbar( fig, option );
end 


tb = findall( fig, 'type', 'uitoolbar' );
set( tb, 'Visible', 'off' );

fig.CameraToolbarManager.updateToolbar( fig );

if ~isempty( msg ) && ~isempty( channelID )

channel = "/figure/toolstrip/contexts" + channelID;


message.publish( channel,  ...
struct( 'eventType', 'ContextualToolstrip', 'ToolstripTag',  ...
'motwToolstrip.cameraTabGroup', 'ToolstripContextId', 'motwToolstrip.cameraContext',  ...
'FigureId', channelID,  ...
'Action', msg ) );


matlab.graphics.internal.toolstrip.FigureToolstripManager.updategf;
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpjtKwn3.p.
% Please follow local copyright laws when handling this file.

