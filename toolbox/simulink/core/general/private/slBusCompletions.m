function cellCompletionStrings = slBusCompletions( block )




cellCompletionStrings = {  };
blockType = get_param( block, 'BlockType' );


if ( strcmp( blockType, 'Inport' ) || strcmp( blockType, 'Outport' ) ) &&  ...
strcmpi( get_param( block, 'IsComposite' ), 'on' )
cellCompletionStrings = getCompletionsFromSH( block );
if slfeature( 'CompositePortsAtRoot' ) == 1
pb = Simulink.BlockDiagram.Internal.getInterfaceModelBlock( block );
rootTree = pb.port.tree;
element = get_param( block, 'Element' );
elementNode = Simulink.internal.CompositePorts.TreeNode.findNode( rootTree, element );
isPartOfBusObject = ~isempty( elementNode.busTypeRootAttrs ) || ~isempty( elementNode.busTypeElementAttrs );



isMissingElementUnderBusObject = false;
if ~isPartOfBusObject && ~isempty( elementNode.childAttrs )
parentNode = elementNode.childAttrs.parent;
if ~isempty( parentNode.busTypeRootAttrs ) || ~isempty( parentNode.busTypeElementAttrs )
isMissingElementUnderBusObject = true;
end 
end 


if isPartOfBusObject || isMissingElementUnderBusObject
Simulink.internal.CompositePorts.TreeNode.reconcileBusObjectsOfTree( get_param( block, 'Handle' ) );
end 

fromTree = Simulink.internal.CompositePorts.TreeNode.getDotStringsFromTree( rootTree )';
cellCompletionStrings = [  ...
cellCompletionStrings,  ...
setdiff( setdiff( fromTree, { '' } ), cellCompletionStrings ) ...
 ];
end 
return ;
end 


if ( strcmp( blockType, 'BusSelector' ) )
portHandles = get_param( block, 'PortHandles' );
busSelectorInportHandle = portHandles.Inport;
cellCompletionStrings = getCompletionsFromSignalHierarchy( busSelectorInportHandle );
elseif ( strcmp( blockType, 'SimscapeBus' ) ...
 || strcmp( blockType, 'ConnectionLabel' ) )
cellCompletionStrings = unique( get_param( block, 'AutocompleteSuggestions' ) );
end 
end 

function completions = getCompletionsFromSH( block )
blockType = get_param( block, 'BlockType' );
completions = {  };
if strcmp( blockType, 'Inport' )
parent = get_param( block, 'Parent' );
if strcmpi( get_param( parent, 'Type' ), 'block_diagram' )return ;end 
parentPH = get_param( parent, 'PortHandles' );
portIdx = str2double( get_param( block, 'Port' ) );
shPortHandle = parentPH.Inport( portIdx );
completions = getCompletionsFromSignalHierarchy( shPortHandle );
else 
ph = get_param( block, 'PortHandles' );
portHandle = ph.Inport;

signalName = get_param( portHandle, 'Name' );
signalLabel = get_param( portHandle, 'Label' );

propName = signalLabel( numel( signalName ) + 1:end  );

signalName = processSignalName( signalName );
if ~isempty( signalName )
completions{ end  + 1 } = signalName;
end 


propName = processPropName( propName );
if ~isempty( propName )
completions{ end  + 1 } = propName;
end 
completions = unique( completions );
end 
end 

function s = replaceUnwantedChars( s )
s = regexprep( s, '\.', ':' );
s = regexprep( s, ',', ';' );
s = regexprep( s, '<|>', '' );
end 

function s = pickBetweenAngleBrackets( s )
s = regexprep( s, '^<(.*)>$', '$1' );
end 

function s = processSignalName( s )
s = replaceUnwantedChars( s );
end 

function s = processPropName( s )
s = pickBetweenAngleBrackets( s );
s = replaceUnwantedChars( s );
end 

function completions = getCompletionsFromSignalHierarchy( portHandle )
completions = {  };
try 
shinfo = get_param( portHandle, 'SignalHierarchy' );
shinfo.SignalName = '';
completions = flattenSHInfo( shinfo, completions, '' );
catch me %#ok<NASGU>
end 
completions = unique( completions );
end 



function completions = flattenSHInfo( shinfo, completions, prefix )
if ~isempty( shinfo.SignalName )
if ~isempty( prefix )
prefix = [ prefix, '.', shinfo.SignalName ];
else 
prefix = [ prefix, shinfo.SignalName ];
end 
completions{ end  + 1 } = prefix;
end 
for idx = 1:length( shinfo.Children )
completions = flattenSHInfo( shinfo.Children( idx ), completions, prefix );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpEmybw4.p.
% Please follow local copyright laws when handling this file.

