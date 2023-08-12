function open_and_hilite_port_hyperlink( action, varargin )









validActions = [ "hilite", "clear" ];
action = validatestring( action, validActions );

switch action
case "hilite"
hilite( varargin{ : } )
case "clear"
clear( varargin{ : } )
end 

end 

function hilite( blockPath, portType, portIndex )








parentSystem = get_param( blockPath, 'Parent' );
clear( parentSystem );
open_and_hilite_hyperlink( blockPath, 'none' )
hilite_system( blockPath, 'none' );



open_system( parentSystem );
Simulink.scrollToVisible( blockPath, 'ensureFit', 'on', 'panMode', 'minimal' )


ph = Simulink.PortPlacement.getPortHandleFromSLDiagInfo( blockPath, portType, portIndex );

styler = getOrCreateStyler(  );
styler.applyClass( ph, 'HiliteErrorPort' );
end 

function clear( slObj )




if isa( slObj, 'double' )
assert( is_simulink_handle( slObj ) );
rootModel = bdroot( slObj );
elseif ischar( slObj ) || isstring( slObj )






rootModel = strtok( slObj, '/' );
if ~bdIsLoaded( rootModel )
return ;
end 
end 

styler = getOrCreateStyler(  );
rootDiagramObject = diagram.resolver.resolve( rootModel, 'diagram' );
assert( ~rootDiagramObject.isNull )
styler.clearChildrenClasses( 'HiliteErrorPort', rootDiagramObject );
end 

function styler = getOrCreateStyler(  )


stylerName = 'SLHighlightErrorPort';
styler = diagram.style.getStyler( stylerName );
if ~isempty( styler )
return ;
end 


diagram.style.createStyler( stylerName );
styler = diagram.style.getStyler( stylerName );
assert( ~isempty( styler ) );


hasErrorStyle = diagram.style.Style;



trace = MG2.TraceEffect;
trace.Stroke.Color = [ 226, 61, 45, 255 ] / 255;
trace.Stroke.Width = 2;
trace.InsetType = 'Outer';

hasErrorStyle.set( 'Trace', trace );

diagram.style.Style.registerProperty( 'AlwaysShowPort', 'bool' )
hasErrorStyle.set( 'AlwaysShowPort', true );

hasErrorSelector = diagram.style.ClassSelector( 'HiliteErrorPort' );

styler.addRule( hasErrorStyle, hasErrorSelector );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpMWA9s4.p.
% Please follow local copyright laws when handling this file.

