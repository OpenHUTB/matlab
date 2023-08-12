function viewer = htmlviewer( input, options )
































R36
input{ mustBeTextScalar } = ""
options.NewTab( 1, 1 )logical{ mustBeNumericOrLogical } = false
options.ShowToolbar( 1, 1 )logical{ mustBeNumericOrLogical } = true
end 

input = string( input );
try 
viewer = matlab.htmlviewer.internal.HTMLViewerManager.getInstance(  ).load( input, options );
catch e
throw( e )
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpg_UFcN.p.
% Please follow local copyright laws when handling this file.

