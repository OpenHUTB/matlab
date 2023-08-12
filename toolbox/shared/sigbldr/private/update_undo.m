function UD = update_undo( UD, action, contents, index, viewdata )




ActiveGroup = UD.sbobj.ActiveGroup;
if nargin > 4
if ( strcmp( contents, 'channel' ) && strcmp( action, 'edit' ) )
UD.undo.model = struct;
UD.undo.model.XData = UD.sbobj.Groups( ActiveGroup ).Signals( index ).XData;
UD.undo.model.YData = UD.sbobj.Groups( ActiveGroup ).Signals( index ).YData;


elseif ( strcmp( contents, 'dataSet' ) )
UD.undo.model = cell( 1, length( UD.channels ) );
for i = 1:length( UD.channels )
UD.undo.model{ i }.XData = UD.sbobj.Groups( ActiveGroup ).Signals( i ).XData;
UD.undo.model{ i }.YData = UD.sbobj.Groups( ActiveGroup ).Signals( i ).YData;
end 
end 
UD.undo.view = viewdata;
end 

set( [ UD.menus.figmenu.EditMenuUndo, UD.toolbar.undo ], 'Enable', 'on' );
set( [ UD.menus.figmenu.EditMenuRedo, UD.toolbar.redo ], 'Enable', 'off' );

if ( strcmp( contents, 'channel' ) && strcmp( action, 'delete' ) )
UD.undo.view.channel = UD.channels( index );
UD.undo.model = struct;
UD.undo.model.XData = UD.sbobj.Groups( ActiveGroup ).Signals( index ).XData;
UD.undo.model.YData = UD.sbobj.Groups( ActiveGroup ).Signals( index ).YData;





for i = 1:length( UD.dataSet )
UD.undo.view.allSignals{ i }.XData = UD.sbobj.Groups( i ).Signals( index ).XData;
UD.undo.view.allSignals{ i }.YData = UD.sbobj.Groups( i ).Signals( index ).YData;
end 

for i = 1:length( UD.dataSet )
UD.undo.view.dataSet( i ).activeDispIdx = UD.dataSet( i ).activeDispIdx;
end 
end 


UD.undo.command = 'undo';
UD.undo.action = action;
UD.undo.contents = contents;
UD.undo.index = index;

% Decoded using De-pcode utility v1.2 from file /tmp/tmp7FX_Iq.p.
% Please follow local copyright laws when handling this file.

