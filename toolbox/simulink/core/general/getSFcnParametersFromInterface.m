function [ params, valStr ] = getSFcnParametersFromInterface( fcnName, interfaceXml )





params = struct;
valStr = '';



parser = mf.zero.io.XmlParser;
mf0Mdl = '';
if ~isfile( interfaceXml )

try 
mf0Mdl = parser.parseString( interfaceXml );
catch 

return 
end 
else 

mf0Mdl = parser.parseFile( interfaceXml );
end 

zcMdl = '';
sfcnArch = '';
pDef = [  ];
for i = 1:numel( mf0Mdl )
if isa( mf0Mdl( i ), 'systemcomposer.architecture.model.SystemComposerModel' )
zcMdl = mf0Mdl( i );
end 
if isa( mf0Mdl( i ), 'systemcomposer.internal.parameter.ParameterDefinition' )
pDef = [ pDef, mf0Mdl( i ) ];
end 
end 
if isempty( zcMdl ) || isempty( pDef )

return 
end 
sfcnArch = zcMdl.getRootArchitecture;
if ~isa( sfcnArch, 'systemcomposer.architecture.model.sldomain.SFunctionBlockArchitecture' )

return 
end 
sfcnName = sfcnArch.getName;

assert( strcmp( sfcnName, fcnName ) )

for i = 1:numel( pDef )

params( i ).name = pDef( i ).getName;
params( i ).dataType = pDef( i ).getBaseType;
params( i ).complexity = '';
params( i ).initialCondition = [ params( i ).dataType, '(', pDef( i ).defaultValue.expression, ')' ];
if isempty( valStr )
valStr = params( i ).initialCondition;
else 
valStr = [ valStr, ', ', params( i ).initialCondition ];
end 














params( i ).dimensions = [ '[', num2str( size( eval( params( i ).initialCondition ) ) ), ']' ];
params( i ).unit = '';
params( i ).isRTP = '';
end 


end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpUotaeZ.p.
% Please follow local copyright laws when handling this file.

