function viewer = htmlviewer( input, options )

arguments
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

