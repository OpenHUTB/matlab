function open_and_hilite_hyperlink( aSystem, aHiliteScheme )




mlock;
persistent LAST_HIGHLIGHTED_MAP;


if isempty( LAST_HIGHLIGHTED_MAP )
LAST_HIGHLIGHTED_MAP = containers.Map(  );
end 


if isempty( aSystem )
return ;
end 

aParentSystem = strtok( aSystem, '/' );
if iscell( aParentSystem )

aParentSystem = unique( aParentSystem );
assert( 1 == length( aParentSystem ) );
aParentSystem = aParentSystem{ 1 };
end 


slprivate( 'open_and_hilite_port_hyperlink', 'clear', aParentSystem )

if isKey( LAST_HIGHLIGHTED_MAP, aParentSystem )
aLastHighlighted = LAST_HIGHLIGHTED_MAP( aParentSystem );


aLastHighlightedValidIdx = is_simulink_handle( aLastHighlighted );
aLastHighlightedValid = aLastHighlighted( aLastHighlightedValidIdx );

if ~isempty( aLastHighlightedValid )
hilite_system( aLastHighlightedValid, 'none' );
end 

remove( LAST_HIGHLIGHTED_MAP, aParentSystem );
end 


if strcmp( aHiliteScheme, 'none' )
return ;
end 

open_system( aParentSystem );

hilite_system( aSystem, aHiliteScheme );
aSystemHandles = get_param( aSystem, 'handle' );
if iscell( aSystemHandles )
aSystemHandles = [ aSystemHandles{ : } ];
end 
LAST_HIGHLIGHTED_MAP( aParentSystem ) = aSystemHandles;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpl8kpnP.p.
% Please follow local copyright laws when handling this file.

