function propValueList = getPropertyValueList( value, propNames )





propValueList = '';
for i = 1:length( propNames )
propName = propNames{ i };


if ~isempty( propValueList )
propValueList = [ propValueList, ', ' ];
end 

if strcmp( propName, '<class>' )
propValueList = [ propValueList, 'class=', class( value ) ];
else 
if strcmp( propName, '<value>' )
propValueList = [ propValueList, 'value' ];
else 
propValueList = [ propValueList, propName ];
end 
if ( Simulink.data.getScalarObjectLevel( value ) == 0 ) ||  ...
isenum( value )
if isstruct( value )
propValueList = [ propValueList, ' struct differences' ];
elseif iscell( value )
propValueList = [ propValueList, ' cell differences' ];
else 
propValueList = [ propValueList, '=', mat2str( value ) ];
end 
else 
propValueList = [ propValueList, '=', getPropValue( value, propName ) ];






if isstring( propValueList )
propValueList = char( strjoin( propValueList ) );
end 
end 
end 
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpqovBpr.p.
% Please follow local copyright laws when handling this file.

