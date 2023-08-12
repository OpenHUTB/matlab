function setsysloc_simulink( System )



















Handle = get_param( System, 'Handle' );
RootSys = bdroot( Handle );
Lock = get_param( RootSys, 'Lock' );
dirty_restorer = Simulink.PreserveDirtyFlag( RootSys, 'blockDiagram' );%#ok<NASGU>
set_param( RootSys, 'Lock', 'off' );




Units = get( 0, 'Units' );
set( 0, 'Units', 'points' );
set( 0, 'Units', Units );

SimLoc = get_param( Handle, 'Location' );
Width = SimLoc( 3 ) - SimLoc( 1 );
Height = SimLoc( 4 ) - SimLoc( 2 );
X1 = 25;
Y1 = 100;
set_param( Handle, 'Location', [ X1, Y1, X1 + Width, Y1 + Height ] );






SystemChildren = find_system( Handle, 'SearchDepth', 1, 'LoadFullyIfNeeded', 'off',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'BlockType', 'SubSystem' );
for SysLp = 1:length( SystemChildren )
if ~strcmp( get_param( SystemChildren( SysLp ), 'Open' ), 'on' )
BLoc = get_param( SystemChildren( SysLp ), 'Location' );

Width = BLoc( 3 ) - BLoc( 1 );
Height = BLoc( 4 ) - BLoc( 2 );
X2 = X1 + Width;
Y2 = Y1 + Height;
NewBLoc = [ X1, Y1, X2, Y2 ];
set_param( SystemChildren( SysLp ), 'Location', NewBLoc );
end 
end 

set_param( RootSys, 'Lock', Lock );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpXZ5Z0t.p.
% Please follow local copyright laws when handling this file.

