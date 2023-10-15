function [ typeObjOrName, isShared ] = getTypeFromString( typeStr, dict )


arguments
    typeStr{ mustBeTextScalar }
    dict systemcomposer.architecture.model.interface.InterfaceCatalog
end


isShared = false;
typeObjOrName = typeStr;
sharedIntrf = [  ];
if contains( typeStr, 'Bus: ' )
    typeName = strrep( typeStr, 'Bus: ', '' );
    sharedIntrf = dict.getPortInterfaceInClosureByName( '', typeName );
elseif contains( typeStr, 'ValueType: ' )
    typeName = strrep( typeStr, 'ValueType: ', '' );
    sharedIntrf = dict.getPortInterfaceInClosureByName( '', typeName );
elseif contains( typeStr, 'Connection: ' )
    typeName = strrep( typeStr, 'Connection: ', '' );
    sharedIntrf = dict.getPortInterfaceInClosureByName( '', typeName );
end

if ~isempty( sharedIntrf )
    isShared = true;
    typeObjOrName = systemcomposer.internal.getWrapperForImpl( sharedIntrf );
end

end


% Decoded using De-pcode utility v1.2 from file /tmp/tmpmYWKYy.p.
% Please follow local copyright laws when handling this file.

