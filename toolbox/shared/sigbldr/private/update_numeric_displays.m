function UD = update_numeric_displays( UD, X, Y )






figBgColor = get( UD.dialog, 'Color' );
if length( X ) == 2
rpStruct = UD.hgCtrls.chRightPoint;
if ( X( 1 ) ~= X( 2 ) )
if ( length( UD.adjust.XDisp ) == 1 )

UD.adjust.XDisp( 2 ) = rpStruct.xNumDisp;
set( UD.adjust.XDisp( 2 ), 'Enable', 'on', 'BackgroundColor', 'w' );
set( rpStruct.xLabel, 'Enable', 'on' );
end 
else 
if ( length( UD.adjust.XDisp ) == 2 )

set( UD.adjust.XDisp( 2 ), 'Enable', 'off', 'BackgroundColor', figBgColor, 'String', '' );
set( rpStruct.xLabel, 'Enable', 'off' );
UD.adjust.XDisp( 2 ) = [  ];
end 
end 

if ~isempty( Y )
if ( Y( 1 ) ~= Y( 2 ) )
if ( length( UD.adjust.YDisp ) == 1 )

UD.adjust.YDisp( 2 ) = rpStruct.yNumDisp;
set( UD.adjust.YDisp( 2 ), 'Enable', 'on', 'BackgroundColor', 'w' );
set( rpStruct.yLabel, 'Enable', 'on' );
end 
else 
if ( length( UD.adjust.YDisp ) == 2 )

set( UD.adjust.YDisp( 2 ), 'Enable', 'off', 'BackgroundColor', figBgColor, 'String', '' );
UD.adjust.YDisp( 2 ) = [  ];
set( rpStruct.yLabel, 'Enable', 'off' );
end 
end 
end 
end 

if ~isempty( X ) && ~isempty( UD.adjust.XDisp )
if UD.common.dispMode == 1
set( UD.adjust.XDisp( 1 ), 'String', num2str( X( 1 ) ) );
if length( UD.adjust.XDisp ) > 1
set( UD.adjust.XDisp( 2 ), 'String', num2str( X( 2 ) ) );
end 
else 
if floor( X( 1 ) ) == X, 
str = num2str( UD.common.timeVect( X( 1 ) + 1 ) );
else 
if X( 1 ) > 0.5
str = [ '> ', num2str( UD.common.timeVect( X( 1 ) + 0.5 ) ) ];
else 
str = [ '< ', num2str( UD.common.timeVect( X( 1 ) + 1.5 ) ) ];
end 
end 
set( UD.adjust.XDisp( 1 ), 'String', str );

if length( UD.adjust.XDisp ) > 1
set( UD.adjust.XDisp( 2 ), 'String', num2str( UD.common.timeVect( X( 2 ) + 1 ) ) );
end 
end 
end 

if ~isempty( Y ) && ~isempty( UD.adjust.YDisp )
set( UD.adjust.YDisp( 1 ), 'String', num2str( Y( 1 ) ) );
if length( UD.adjust.YDisp ) > 1
set( UD.adjust.YDisp( 2 ), 'String', num2str( Y( 2 ) ) );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpDBkz3u.p.
% Please follow local copyright laws when handling this file.

