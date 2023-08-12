function v = openViewer( viewerOptions )


R36
viewerOptions.Source{ mustBeA( viewerOptions.Source, [ "systemcomposer.arch.Architecture", "systemcomposer.analysis.ArchitectureInstance" ] ) }
viewerOptions.Function{ mustBeA( viewerOptions.Function, 'function_handle' ) } = function_handle.empty( 0, 1 );
viewerOptions.Arguments{ mustBeText } = '';
viewerOptions.Direction{ mustBeA( viewerOptions.Direction, [ "string", "char", "systemcomposer.IteratorDirection" ] ) } = systemcomposer.IteratorDirection.PreOrder;
viewerOptions.Debug{ mustBeNumericOrLogical( viewerOptions.Debug ) } = false;
end 

instanceModel = [  ];
architecture = [  ];

if isa( viewerOptions.Source, 'systemcomposer.arch.Architecture' )
architecture = viewerOptions.Source;
elseif isa( viewerOptions.Source, 'systemcomposer.analysis.ArchitectureInstance' )
instanceModel = viewerOptions.Source;
else 
error( 'systemcomposer:analysis:invalidViewerSource',  ...
message( 'SystemArchitecture:Analysis:InvalidViewerSource' ).getString );
end 
fnHandle = viewerOptions.Function;
arguments = viewerOptions.Arguments;
debug = viewerOptions.Debug;

if ischar( viewerOptions.Direction ) || isstring( viewerOptions.Direction )
argValue = string( viewerOptions.Direction );
if strcmpi( argValue, "preorder" )
iterOrd = systemcomposer.IteratorDirection.PreOrder;
elseif strcmpi( argValue, "postorder" )
iterOrd = systemcomposer.IteratorDirection.PostOrder;
elseif strcmpi( argValue, "topdown" )
iterOrd = systemcomposer.IteratorDirection.TopDown;
elseif strcmpi( argValue, "bottomup" )
iterOrd = systemcomposer.IteratorDirection.BottomUp;
else 
error( 'systemcomposer:API:IterateOptionInvalid',  ...
message( 'SystemArchitecture:API:IterateOptionInvalid' ).getString );
end 
else 
iterOrd = systemcomposer.IteratorDirection( viewerOptions.Direction );
end 


if ~isempty( instanceModel )

if isempty( fnHandle )
fnHandle = instanceModel.AnalysisFunction;
end 

if isempty( arguments )
arguments = instanceModel.AnalysisArguments;
end 

if isempty( iterOrd )
iterOrd = instanceModel.AnalysisDirection;
end 
else 
if isempty( arguments )
arguments = "";
end 

if isempty( iterOrd )
iterOrd = systemcomposer.IteratorDirection.PreOrder;
end 
end 


v = systemcomposer.internal.analysis.AnalysisService.viewInstance( instanceModel, fnHandle, arguments, iterOrd, architecture, debug );

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp3JNDke.p.
% Please follow local copyright laws when handling this file.

