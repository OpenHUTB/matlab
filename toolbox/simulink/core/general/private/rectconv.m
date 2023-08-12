function rout = rectconv( rin, style )
















switch lower( style ), 

case { 'handlegraphics', 'hg' }
rout = InternalSimRect2HGRect( rin );

case { 'simulink', 'sl' }
rout = InternalHGRect2SimRect( rin );

otherwise , 
DAStudio.error( 'Simulink:utility:invRectStyle' );

end 







function rout = InternalSimRect2HGRect( rin )

origRootUnits = get( 0, 'Units' );
set( 0, 'Units', 'pixel' );
screen = get( 0, 'ScreenSize' );
set( 0, 'Units', origRootUnits );





rout = zeros( 1, 4 );
rout( 1 ) = rin( 1 );
rout( 2 ) = screen( 4 ) - rin( 4 );
rout( 3 ) = rin( 3 ) - rin( 1 );
rout( 4 ) = rin( 4 ) - rin( 2 );







function rout = InternalHGRect2SimRect( rin )

origRootUnits = get( 0, 'Units' );
set( 0, 'Units', 'pixel' );
screen = get( 0, 'ScreenSize' );
set( 0, 'Units', origRootUnits );




rout = zeros( 1, 4 );
rout( 1 ) = rin( 1 );
rout( 2 ) = screen( 4 ) - rin( 2 ) - rin( 4 );
rout( 3 ) = rin( 1 ) + rin( 3 );
rout( 4 ) = screen( 4 ) - rin( 2 );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpoI7w4o.p.
% Please follow local copyright laws when handling this file.

