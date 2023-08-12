function dataTypeContainer = parseDataType( dataTypeString, context )



































if nargin < 2
context = [  ];
end 

dataTypeString = convertStringsToChars( dataTypeString );

if mayBeSimulinkPathOrHandle( context )
try 


context = get_param( context, 'Object' );
catch 
end 
end 

if isBaseWorkspace( context )
dataTypeContainer = SimulinkFixedPoint.DataTypeContainer.ParsedDataTypeInBaseWorkspace( dataTypeString );
else 
dataTypeContainer = SimulinkFixedPoint.DataTypeContainer.ParsedDataTypeContainer( dataTypeString, context );
end 
end 

function b = istext( context )
b = ischar( context ) || isstring( context );
end 

function b = mayBeSimulinkPathOrHandle( context )
b = ~isempty( context ) && ( istext( context ) || isnumeric( context ) );
end 

function b = isBaseWorkspace( context )
b = istext( context ) && strcmp( context, 'base' );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpJsuzvj.p.
% Please follow local copyright laws when handling this file.

