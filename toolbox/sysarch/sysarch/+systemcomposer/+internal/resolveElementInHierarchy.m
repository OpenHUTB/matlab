function resElem = resolveElementInHierarchy( elem, model, hier )







model = systemcomposer.loadModel( model );
fullPath = string( model.Name );
for idx = 1:length( hier )
hierElem = hier{ idx };
[ ~, elemPath ] = strtok( hierElem, '/' );
fullPath = fullPath + elemPath;
end 

if isa( elem, 'systemcomposer.arch.BaseComponent' )
fullPath = fullPath + '/' + elem.Name;
resElem = model.lookup( 'Path', fullPath );

elseif isa( elem, 'systemcomposer.arch.ArchitecturePort' )
resElem = model.Architecture.getPort( elem.Name );

elseif isa( elem, 'systemcomposer.arch.Architecture' )
resElem = model.lookup( 'Path', fullPath );

elseif isa( elem, 'systemcomposer.arch.ComponentPort' )

fullPath = fullPath + '/' + elem.Parent.Name;
parentElem = model.lookup( 'Path', fullPath );
resElem = parentElem.getPort( elem.Name );

elseif isa( elem, 'systemcomposer.arch.BaseConnector' )


assert( length( elem.Ports ) >= 2 );
resPort1 = systemcomposer.internal.resolveElementInHierarchy( elem.Ports( 1 ), model.Name, hier );
resPort2 = systemcomposer.internal.resolveElementInHierarchy( elem.Ports( 2 ), model.Name, hier );
resElem = resPort1.getConnectorTo( resPort2 );
end 

assert( ~isempty( resElem ) );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpcYJtR2.p.
% Please follow local copyright laws when handling this file.

