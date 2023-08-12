function outputValue = wrapComparisonItem( outputValue, varName, varValue, path, bIncludePath )






type = Simulink.data.getScalarObjectLevel( varValue );
if ( type == 0 )
outputValue.addprop( 'Value' );
outputValue.Value = varValue;
outputValue.addprop( 'DataType' );
outputValue.DataType = class( varValue );
else 
propsList = fieldnames( varValue )';

for index = propsList(  )
outputValue.addprop( index{ 1 } );
if needsDeepCopy( varValue.( index{ 1 } ) )
len = length( varValue.( index{ 1 } ) );
for i = 1:len
outputValue.( index{ 1 } ) = cat( 1, outputValue.( index{ 1 } ), varValue.( index{ 1 } )( i ).copy );
end 
else 
outputValue.( index{ 1 } ) = varValue.( index{ 1 } );
end 
end 

if isempty( outputValue.findprop( 'Class' ) )
outputValue.addprop( 'Class' );
outputValue.Class = class( varValue );
end 
end 


if isempty( outputValue.findprop( 'Name' ) )
outputValue.addprop( 'Name' );
outputValue.Name = varName;
end 

if bIncludePath
if isempty( outputValue.findprop( 'Path' ) )
outputValue.addprop( 'Path' );
end 
outputValue.Path = path;
end 

end 

function bDeep = needsDeepCopy( value )
bDeep = false;
if isvector( value ) &&  ...
length( value ) > 1 &&  ...
Simulink.data.getScalarObjectLevel( value( 1 ) ) > 0
bDeep = true;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpcNHnKl.p.
% Please follow local copyright laws when handling this file.

