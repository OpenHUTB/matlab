function element = createElementFromSource( targetInterface, source, elemName )












element = [  ];
if isa( source, 'systemcomposer.interface.DataElement' )
type = source.Type;
if isa( type, 'systemcomposer.ValueType' ) && ~isa( type.Owner, 'systemcomposer.interface.Dictionary' )


element = createElementAndCopyProperties( targetInterface, type, elemName );
else 

assert( isa( type, 'systemcomposer.interface.DataInterface' ) ||  ...
( isa( type, 'systemcomposer.ValueType' ) && isa( type.Owner, 'systemcomposer.interface.Dictionary' ) ) )
element = targetInterface.addElement( elemName );
element.setType( type );
end 
elseif isa( source, 'systemcomposer.interface.DataInterface' )
if source.isAnonymous

allElements = source.Elements;
if ~isempty( allElements )
for idx = 1:numel( allElements )
dataElement = allElements( idx );
newElement = systemcomposer.internal.adapter.createElementFromSource( targetInterface, dataElement, dataElement.Name );
element = [ element;newElement ];%#ok<AGROW> 
end 
end 
else 

element = targetInterface.addElement( elemName );
element.setType( source );
end 
else 
if isa( source.Owner, 'systemcomposer.arch.ArchitecturePort' )

element = createElementAndCopyProperties( targetInterface, source, elemName );
else 


assert( isa( source, 'systemcomposer.ValueType' ) );
element = targetInterface.addElement( elemName );
element.setType( source );
end 
end 


function elem = createElementAndCopyProperties( targetInterface, type, elemName )

elem = targetInterface.addElement( elemName, 'DataType', type.DataType );
elem.setDimensions( type.Dimensions );
elem.setUnits( type.Units );
elem.setMinimum( type.Minimum );
elem.setMaximum( type.Maximum );
elem.setDescription( type.Description );
elem.setComplexity( type.Complexity );
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpDHEa7K.p.
% Please follow local copyright laws when handling this file.

