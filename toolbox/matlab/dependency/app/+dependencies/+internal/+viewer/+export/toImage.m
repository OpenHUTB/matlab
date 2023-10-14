function toImage( input, target, options )

arguments
    input( 1, : )
    target( 1, 1 )string{ mustBeNonzeroLengthText };
    options.Layout( 1, 1 )dependencies.internal.viewer.Layout
    options.Size( 1, 2 )uint16{ mustBePositive }
end

controller = i_getController( input );

if isfield( options, "Layout" )
    dependencies.internal.viewer.postEvent(  ...
        controller, "LayoutRequestEvent",  ...
        "Layout", options.Layout );
end

controller.awaitPendingUpdates(  );

syntax = controller.Syntax;
appIndex = "/toolbox/matlab/dependency/app/web/app.html";

exporter = diagram.editor.print.Exporter(  ...
    syntax,  ...
    AppIndex = appIndex,  ...
    IndexParams = [ "target=export", "view=" + controller.View.UUID ] );

if isfield( options, "Size" )
    exporter.export( target, Size = options.Size );
else
    exporter.export( target );
end
end


function controller = i_getController( input )
if isa( input, "dependencies.internal.viewer.Controller" )
    controller = input;
    return
end

controller = dependencies.internal.viewer.Controller;
if isa( input, 'dependencies.internal.graph.Graph' )
    controller.setGraph( input );
else
    nodes = dependencies.internal.util.getNodes( input );
    controller.analyze( nodes );
end
end
