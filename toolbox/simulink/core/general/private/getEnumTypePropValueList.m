function propValueList = getEnumTypePropValueList( enum, propNames )

numPropNames = length( propNames );
propValueCell = cell( numPropNames, 1 );

for ii = 1:numPropNames
propName = propNames{ ii };
propValue = loc_getPropValue( enum, propName );
propValueCell{ ii } = [ propName, '=', propValue ];
end 

propValueList = loc_joinValueCell( propValueCell, ", " );
end 


function value = loc_getPropValue( enum, propName )
propsWithCharValues = { 'Description',  ...
'DataScope',  ...
'HeaderFile',  ...
'DefaultValue',  ...
'StorageType',  ...
'AddClassNameToEnumNames' };
switch ( propName )
case propsWithCharValues
value = getPropValue( enum, propName );
assert( ischar( value ) );
value = [ '''', value, '''' ];
case 'Enumerals'
value = loc_getEnumerals( enum );
otherwise 
assert( false, [ 'Undefined Enum type property ''', propName, '''' ] );
end 
end 


function value = loc_getEnumerals( enum )
enumerals = enum.Enumerals;
numEnumerals = length( enumerals );
valueCell = cell( numEnumerals, 1 );
for ii = 1:numEnumerals
enumeral = enumerals( ii );
valueCell{ ii } = [ enumeral.Name, '(', enumeral.Value, ')' ];
end 

value = [ '{', loc_joinValueCell( valueCell, "," ), '}' ];
end 


function rst = loc_joinValueCell( cellStr, joinBy )
rst = string( cellStr ).join( joinBy ).char;
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpweeKcF.p.
% Please follow local copyright laws when handling this file.

